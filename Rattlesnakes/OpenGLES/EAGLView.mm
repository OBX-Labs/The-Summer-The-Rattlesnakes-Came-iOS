//
//  EAGLView.m
//  White
//
//  Created by Christian Gratton on 12-06-18.
//  Copyright (c) 2012 Christian Gratton. All rights reserved.
//

#import "EAGLView.h"

#import "ES1Renderer.h"
#import "OKTessFont.h"
#import "OKBitmapFont.h"
#import "OKTextObject.h"
#import "OKSentenceObject.h"
#import "OKWordObject.h"

#import <OBXKit/AppDelegate.h>
#import "OKPoEMMProperties.h"
#import "OKTextManager.h"

#import "Rattlesnakes.h"

#define IS_IPAD_RETINA (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[UIScreen mainScreen] scale] > 1.9f) // iPad 3 or more
#define IS_IPHONE_5 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define CAN_RENDER_FULL_FPS (IS_IPAD_RETINA || IS_IPHONE_5)

static BOOL DEBUG_FRAMERATE = NO;
static BOOL SHOULD_RENDER_FULL_FPS = YES;
static int MAX_FINGERS = 2;

static EAGLView *sharedInstance;

@interface EAGLView ()
@property (nonatomic, getter=isAnimating) BOOL animating;
@end

@implementation EAGLView
@synthesize animating, animationFrameInterval, displayLink, animationTimer, rattlesnakes;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

+ (EAGLView*) sharedInstance
{
    @synchronized(self)
	{
		if (sharedInstance == nil)
			sharedInstance = [[EAGLView alloc] init];
	}
	return sharedInstance;
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id) initWithFrame:(CGRect)aFrame multisampling:(BOOL)canMultisample andSamples:(int)aSamples
{    
    self = [super initWithFrame:aFrame];
    if (self)
    {       
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        [self setContentScaleFactor:[[UIScreen mainScreen] scale]]; // sets the scale based on the device
        [self setMultipleTouchEnabled:YES];
        
        lbl_frameRate = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 50), (self.frame.size.height - 20), 50, 20)];
        
        if(DEBUG_FRAMERATE)
        {
            [lbl_frameRate setTextColor:[UIColor orangeColor]];
            [lbl_frameRate setBackgroundColor:[UIColor clearColor]];
            [lbl_frameRate setFont:[UIFont boldSystemFontOfSize:15]];
            [lbl_frameRate setTextAlignment:NSTextAlignmentCenter];
            [self addSubview:lbl_frameRate];
            [lbl_frameRate release];
        }
        
        bool canMultiSample = NO;
        
        if(canMultisample)
        {
            NSString *reqVer = @"4.0.0";
            NSString *currVer = [[UIDevice currentDevice] systemVersion];
            if ([currVer compare:reqVer options:NSNumericSearch] != NSOrderedAscending)
                canMultiSample = YES;
        }
		
		//ES1Renderer (no shaders)
		renderer = [[ES1Renderer alloc] initWithMultisampling:canMultiSample andNumberOfSamples:aSamples];
        [renderer setFrame:self.frame];
        
		if (!renderer)
		{
			[self release];
			return nil;
		}
       
        // Fingers       
        fingers = [[NSMutableArray alloc] initWithCapacity:MAX_FINGERS];
        for(int i = 0; i < MAX_FINGERS; i++)
        {
            [fingers insertObject:[NSNull null] atIndex:i];
        }
        
        [self setup];
                
        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = ((CAN_RENDER_FULL_FPS && SHOULD_RENDER_FULL_FPS) ? 1 : 2);
        displayLink = nil;
        animationTimer = nil;
        
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
        
        // Add NSNotificationCenter observers for OKInfoView
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoViewWillAppear) name:@"OKInfoViewWillAppear" object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoViewWillDisappear) name:@"OKInfoViewWillDisappear" object:self.window];
 
	}
	
    return self;
}



- (void) setup
{
    // Reset renderer
    [renderer reset];
    
    // Text path
    NSString *textPath = [OKTextManager textPathForFile:[OKPoEMMProperties objectForKey:TextFile] inPackage:[OKPoEMMProperties objectForKey:Text]];
    NSMutableString *textFile = [NSMutableString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil];
    
    // Fonts
    NSString *fontName = [OKPoEMMProperties objectForKey:FontFile];
    
    // Clean text
    //replace em dash (charID 8212) with - (charID 45)
    unichar emdash = 8212;
    [textFile replaceOccurrencesOfString:[NSString stringWithFormat:@"%C", emdash] withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [textFile length])];
    
    // Only initializes the font if it has changed.
    if(font && ![font.name isEqualToString:fontName]) [font release];
    
    // Text font
    if(!font) {
        font  = [[OKTessFont alloc] initWithControlFile:fontName scale:1.0 filter:GL_LINEAR];
        [font setColourFilterRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    }
    
    //seperate the text into paragraphs (in text file, paragraph are separated by ***
    NSArray *textSeparated = [textFile componentsSeparatedByString:@"***"];
    theTexts = [[NSMutableArray alloc] init];
    for(NSString *aText in textSeparated){
        //NSLog(@"A TEXT: %@", aText);
        if(text) [text release];
        text = [[OKTextObject alloc] initWithText:aText withTessFont:font andCanvasSize:self.frame.size];
        [theTexts addObject:text];
    }

    //VICTOR - FIX EMPTY LINE REMOVAL
    //remove empty lines
    NSMutableArray *toDelete = [NSMutableArray array];
    
    for(OKTextObject *aText in theTexts)
    {
        //NSLog(@"Number of sentences: %d",[aText.sentenceObjects count]);
        for(OKSentenceObject *temp in aText.sentenceObjects)
        {
           // NSLog(@"A Sentence: %@ lenght:%d", [temp sentence], [[temp sentence] length] );
           /* for(OKWordObject *aWord in [temp wordObjects])
            {
                NSLog(@"A word: %@", [aWord word]);
            }*/
            if([[temp sentence]length]<1){
                //NSLog(@"REMOVE A LINE");
               
                //[aText.sentenceObjects removeObject:temp];
                [toDelete addObject:temp];
            }
        }
        
        if ([theTexts lastObject] == aText){
            [theTexts removeObjectsInArray:toDelete];
        }
    }
    
    
    
    if(rattlesnakes) [rattlesnakes release];
    //rattlesnakes = [[Rattlesnakes alloc] initWithFont:font text:text andBounds:self.frame];
    rattlesnakes = [[Rattlesnakes alloc] initWithFont:font text:text allTexts:theTexts andBounds:self.frame eaglview:self];
}


- (UIImage*)screenCapture
{
    NSLog(@"ScreenCapture");
    //grab screen for screen shot
    return [renderer glToUIImage];
}

- (int) addFingerForTouch:(UITouch*)aTouch
{
    for(int i = 0; i < MAX_FINGERS; i++)
    {
        id aFinger = [fingers objectAtIndex:i];
        
        if(aFinger == [NSNull null])
        {
            [fingers replaceObjectAtIndex:i withObject:aTouch];
            return i;
        }
    }
    
    return -1;
}

- (int) getFingerForTouch:(UITouch*)aTouch
{
    for(int i = 0; i < MAX_FINGERS; i++)
    {
        if([fingers objectAtIndex:i] == aTouch) return i;
    }
    
    return -1; // Didn't find finger...
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    for(UITouch *touch in touches)
    {
        // found a touch, has it been registered?
        int fID = [self getFingerForTouch:touch];
        
        // If -1 is returned, no touch has been found.
        // Given that this touch began, we should ignore anything that isn't -1.
        if(fID == -1)
        {
            // New finger
            int nfID = [self addFingerForTouch:touch];
            
            // New touch was added
            if(nfID != -1)
            {
                CGPoint pt = [touch locationInView:self];
                [rattlesnakes touchesBegan:nfID atPosition:CGPointMake(pt.x, (self.frame.size.height - pt.y))];
            }
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
    for(UITouch *touch in touches)
    {
        // Found a touch, has it been registered?
        int fID = [self getFingerForTouch:touch];
        
        // If -1 is returned, no touch has been found.
        // Given that this is touch moved, we should ignore a touch that doesn't exist.
        if(fID != -1)
        {
            CGPoint pt = [touch locationInView:self];
            [rattlesnakes touchesMoved:fID atPosition:CGPointMake(pt.x, (self.frame.size.height - pt.y))];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{   
    for(UITouch *touch in touches)
    {
        // Found a touch, has it been registered?
        int fID = [self getFingerForTouch:touch];
        
        // If -1 is returned, no touch has been found.
        // Given that this is touch ended, we should ignore a touch that doesn't exist.
        if(fID != -1)
        {
            CGPoint pt = [touch locationInView:self];
            [rattlesnakes touchesEnded:fID atPosition:CGPointMake(pt.x, (self.frame.size.height - pt.y))];
            
            // Remove finger
            [fingers replaceObjectAtIndex:fID withObject:[NSNull null]];
        }
    }
    
    [super touchesEnded:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{    
    for(UITouch *touch in touches)
    {
        // Found a touch, has it been registered?
        int fID = [self getFingerForTouch:touch];
        
        // If -1 is returned, no touch has been found.
        // Given that this is touch ended, we should ignore a touch that doesn't exist.
        if(fID != -1)
        {
            CGPoint pt = [touch locationInView:self];
            [rattlesnakes touchesCancelled:fID atPosition:CGPointMake(pt.x, (self.frame.size.height - pt.y))];
            
            // Remove finger
            [fingers replaceObjectAtIndex:fID withObject:[NSNull null]];
        }
    }
    
    [super touchesCancelled:touches withEvent:event];
}

- (CGPoint) convertTouch:(CGPoint)aPoint withZ:(float)z
{
    float ax = ((modelview[0] * aPoint.x) + (modelview[4] * aPoint.y) + (modelview[8] * z) + modelview[12]);
	float ay = ((modelview[1] * aPoint.x) + (modelview[5] * aPoint.y) + (modelview[9] * z) + modelview[13]);
	float az = ((modelview[2] * aPoint.x) + (modelview[6] * aPoint.y) + (modelview[10] * z) + modelview[14]);
	float aw = ((modelview[3] * aPoint.x) + (modelview[7] * aPoint.y) + (modelview[11] * z) + modelview[15]);
	
	float ox = ((projection[0] * ax) + (projection[4] * ay) + (projection[8] * az) + (projection[12] * aw));
	float oy = ((projection[1] * ax) + (projection[5] * ay) + (projection[9] * az) + (projection[13] * aw));
	float ow = ((projection[3] * ax) + (projection[7] * ay) + (projection[11] * az) + (projection[15] * aw));
	
	if(ow != 0)
		ox /= ow;
	
	if(ow != 0)
		oy /= ow;
	
	return CGPointMake(([UIScreen mainScreen].bounds.size.height * (1 + ox) / 2.0f), ([UIScreen mainScreen].bounds.size.width * (1 + oy) / 2.0f));
}

- (void) infoViewWillAppear { [self stopAnimation]; }

- (void) infoViewWillDisappear  { [self startAnimation]; }

- (void)drawView:(id)sender
{    
    NSDate *startDate = [NSDate date];
    
    glPushMatrix();
    
	glGetFloatv(GL_MODELVIEW_MATRIX, modelview);        // Retrieve The Modelview Matrix
	
	glPopMatrix();
	
	glGetFloatv(GL_PROJECTION_MATRIX, projection);    // Retrieve The Projection Matrix
	
	//rendering etc in here
    [renderer renderRattlesnakes:rattlesnakes];
    
    if(DEBUG_FRAMERATE)
        [self getFrameRate:[[NSDate date] timeIntervalSinceDate:startDate]];
    
}

- (void)getFrameRate:(float)withInterval
{    
	lbl_frameRate.text = [NSString stringWithFormat:@"%.1f", 60-(withInterval*1000)];	
}

- (void)layoutSubviews
{
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.
            
            self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
        
        self.animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            self.displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            self.animationTimer = nil;
        }
        
        self.animating = FALSE;
    }
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)dealloc
{
    [renderer release];
    [displayLink release];
    [font release];
    [backgroundFont release];
    [text release];
    [rattlesnakes release];
	
    [super dealloc];
}

@end
