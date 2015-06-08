//
//  Rattlesnakes.m
//  Rattlesnakes
//
//  Created by Serge Maheu on 2013-05-03.
//  Copyright (c) 2013 Serge Maheu. All rights reserved.
//

#include <mach/mach.h>
#include <mach/mach_time.h>
#import "Rattlesnakes.h"
#import "OKPoEMMProperties.h"

#import "OKTessFont.h"
#import "OKTextObject.h"
#import "OKSentenceObject.h"
#import "OKCharObject.h"


#import "OKTessData.h"
#import "OKCharDef.h"

#import "Line.h"
#import "Word.h"
#import "OutlinedWord.h"
#import "Touch.h"

#import "OKNoise.h"
#import "PerlinTexture.h"

#define ARC4RANDOM_MAX      0x100000000

//stuff
#warning TO REMOVE WHAT IS NOT NEEDED
static NSString *BG_TEXT = @"";
//static float BG_COLOR[] = {0.0, 0.0, 0.0, 0.0};
static float BG_TEXT_SPEED;// iPad 6.0f iPhone 3.0f
static float BG_TEXT_HMARGIN;// iPad 350.0f iPhone 165.0f
static float BG_TEXT_VMARGIN;// iPad 250.0f iPhone 105.0f
static float BG_TEXT_SCALE;// iPad 7.75f iPhone 5.25f
static float BG_TEXT_TOP;
static float BG_TEXT_LEADING;
static float BG_TEXT_LEADING_SCALAR;// iPad 0.8f iPhone 0.8f
static int MAX_SENTENCES;// iPad 2 iPhone 2
static float BG_FLICKER_SPEED;// iPad 0.5f iPhone 0.5f
static float BG_FLICKER_PROPABILITY;// iPad 0.7f iPhone 0.7f
static float BG_FLICKER_SCALAR;// iPad 0.235f iPhone 0.235f
static int MAX_FADING_LINES;// iPad 10 iPhone 10


//Rattlesnakes stuff
static int START_TEXT_INDEX = 0;
static float BG_COLOR[]= {0.0, 0.0, 0.0, 0.0};					//background color
static NSString *SNAKE_FONT=@"";				//name of snake font
static int SNAKE_FONT_SIZE;				//size of snake font
static float SNAKE_FONT_SCALING;
static NSString *SNAKE_FILE=@"";				//name of snake texts file
static float SNAKE_COLOR[]= {0.0, 0.0, 0.0, 0.0};					//snake color
//static String[] TEXT_FILES;				//text files for main background text
//static float[][] TEXT_LINES_SPACINGS;	//line spacings for each line and text
static NSString *TEXT_FONT=@"";				//name of main background text font
static float TEXT_VERTICAL_MARGIN;		//top margin between edge and text
static float TEXT_HORIZONTAL_MARGIN;	//left and right margins between edges and text
static float TEXT_COLOR[]= {0.0, 0.0, 0.0, 0.0};					//text color
static float TEXT_FADEIN_SPEED;			//speed at which the words fade in
static float TEXT_FADEOUT_SPEED;		//speed at which the words fade out
static int UNBITABLE_MARGIN;			//number of pixels were words can't be bit
static float SNAKE_BITE_MASS;			//mass of the snake's bitable prey
static float SNAKE_BITE_STRENGTH_MULT;  //strength of the snake's attraction to its prey
static float SNAKE_BITE_MIN_DISTANCE;	//minimum distance for the snake's attraction
static float SNAKE_BITE_OPACITY_TRIGGER;//minimum word opacity for a snake to bite
static float SNAKE_SCALING_FACTORS[]= {0.0, 0.0, 0.0, 0.0};		//scaling factors to define the snake's shape
static float SNAKE_SCALING_POSITIONS[]= {0.0, 0.0, 0.0, 0.0};	//scaling positions to define the snake's shape
static int TEXT_CHANGE_INTERVAL;		//interval between background text changes
static int TEXT_CHANGE_SPEED;			//speed at which the text wave animates
static int IDLE_INTERVAL;				//time until idle state with background animations
static int BGSNAKE_INTERVAL;			//interval between background idle animations
static float BGSNAKE_OPACITY;			//opacity of background animation words

static int FIRST_BITE_DELAY;			//delay between touch and a first bite
static int NEXT_BITE_MINIMUM_DELAY;		//minimum delay between a touch and a second bite
static int NEXT_BITE_MAXIMUM_DELAY;		//maximum delay between a touch and a second bite

static int SHIFT_SOUNDS_TIME;			//time in millis to shift sounds between texts
static float AMBIENT_VOLUME_START;		//volume of first ambient sounds
static float AMBIENT_VOLUME_END;		//volume of ambient sounds after fade down
static float THREAT_VOLUME;				//volume of threat sounds
static float RATTLE_VOLUME;				//volume of rattle sounds
static float STRIKE_VOLUME;				//volume of strike sounds
static NSString *FIRST_STRIKE_SND_FILE=@"";	//first strike sound file

static float PHYSICS_GRAVITY;			//gravity of the particle system
static float PHYSICS_DRAG;				//drag of the particle system
static int SMOOTH_LEVEL;				//anti-aliasing level
static int LEFT=0;
static int RIGHT=1;
static float TOUCH_OFFSET;


@implementation Rattlesnakes

- (id) initWithFont:(OKTessFont*)tFont text:(OKTextObject*)textObj allTexts:(NSMutableArray*)theTexts andBounds:(CGRect)bounds eaglview:(EAGLView*)aView
{
    self = [super init];
    if(self)
    {
        // Load propeties
        BG_TEXT = [OKPoEMMProperties objectForKey:Title];
        NSArray *bgColor = [OKPoEMMProperties objectForKey:BackgroundColor];
        BG_COLOR[0] = [[bgColor objectAtIndex:0] floatValue];
        BG_COLOR[1] = [[bgColor objectAtIndex:1] floatValue];
        BG_COLOR[2] = [[bgColor objectAtIndex:2] floatValue];
        BG_COLOR[3] = [[bgColor objectAtIndex:3] floatValue];
        NSLog(@"BG COLOR= %f, %f, %f, %f", BG_COLOR[0],BG_COLOR[1],BG_COLOR[2],BG_COLOR[3]);

        //white
        BG_TEXT_SPEED = [[OKPoEMMProperties objectForKey:BackgroundTextSpeed] floatValue];
        BG_TEXT_HMARGIN = [[OKPoEMMProperties objectForKey:BackgroundTextHorizontalMargin] floatValue];
        BG_TEXT_VMARGIN = [[OKPoEMMProperties objectForKey:BackgroundTextVerticalMargin] floatValue];
        BG_TEXT_SCALE = [[OKPoEMMProperties objectForKey:BackgroundTextScale] floatValue];
        BG_TEXT_LEADING_SCALAR = [[OKPoEMMProperties objectForKey:BackgroundTextLeadingScalar] floatValue];
        MAX_SENTENCES = [[OKPoEMMProperties objectForKey:MaximumSentences] floatValue];
        BG_FLICKER_SPEED = [[OKPoEMMProperties objectForKey:BackgroundFlickerSpeed] floatValue];
        BG_FLICKER_PROPABILITY = [[OKPoEMMProperties objectForKey:BackgroundFlickerPropability] floatValue];
        BG_FLICKER_SCALAR = [[OKPoEMMProperties objectForKey:BackgroundFlickerScalar] floatValue];
        MAX_FADING_LINES = [[OKPoEMMProperties objectForKey:MaximumFadingLines] intValue];
        NSLog(@"MAX_FADING_LINES is %d", MAX_FADING_LINES);
        
        //Rattlesnake
        SNAKE_FONT=[OKPoEMMProperties objectForKey:SnakeFont];
        NSLog(@"SNAKE FONT is %@", SNAKE_FONT);
        SNAKE_FONT_SIZE=[[OKPoEMMProperties objectForKey:SnakeFontSize] integerValue];
        NSLog(@"SNAKE FONT SIZE is %d", SNAKE_FONT_SIZE);
        SNAKE_FONT_SCALING=[[OKPoEMMProperties objectForKey:SnakeFontScaling] floatValue];

        SNAKE_FILE=[OKPoEMMProperties objectForKey:SnakeFile];
        NSArray *aColor = [OKPoEMMProperties objectForKey:SnakeColor];
        SNAKE_COLOR[0] = [[aColor objectAtIndex:0] floatValue];
        SNAKE_COLOR[1] = [[aColor objectAtIndex:1] floatValue];
        SNAKE_COLOR[2] = [[aColor objectAtIndex:2] floatValue];
        SNAKE_COLOR[3] = [[aColor objectAtIndex:3] floatValue];
        NSLog(@"SNAKE_COLOR= %f, %f, %f, %f", SNAKE_COLOR[0],SNAKE_COLOR[1],SNAKE_COLOR[2],SNAKE_COLOR[3]);
        //static String[] TEXT_FILES;				//text files for main background text
        //static float[][] TEXT_LINES_SPACINGS;	//line spacings for each line and text
        TEXT_FONT=[OKPoEMMProperties objectForKey:TextFont];
        TEXT_VERTICAL_MARGIN=[[OKPoEMMProperties objectForKey:TextVerticalMargin] floatValue];		
        TEXT_HORIZONTAL_MARGIN=[[OKPoEMMProperties objectForKey:TextHorizontalMargin] floatValue];
        aColor = [OKPoEMMProperties objectForKey:TextColor];
        TEXT_COLOR[0] = [[aColor objectAtIndex:0] floatValue];
        TEXT_COLOR[1] = [[aColor objectAtIndex:1] floatValue];
        TEXT_COLOR[2] = [[aColor objectAtIndex:2] floatValue];
        TEXT_COLOR[3] = [[aColor objectAtIndex:3] floatValue];
        
        TEXT_FADEIN_SPEED =[[OKPoEMMProperties objectForKey:TextFadeInSpeed] floatValue];		
        TEXT_FADEOUT_SPEED=[[OKPoEMMProperties objectForKey:TextFadeOutSpeed] floatValue];		
        UNBITABLE_MARGIN=[[OKPoEMMProperties objectForKey:UnbitableMargin] integerValue];		
        SNAKE_BITE_MASS=[[OKPoEMMProperties objectForKey:SnakeBiteMass] floatValue];			
        SNAKE_BITE_STRENGTH_MULT=[[OKPoEMMProperties objectForKey:SnakeBiteStrenghtMult] floatValue];
        SNAKE_BITE_MIN_DISTANCE=[[OKPoEMMProperties objectForKey:SnakeBiteMinDistance] floatValue];
        SNAKE_BITE_OPACITY_TRIGGER=[[OKPoEMMProperties objectForKey:SnakeBiteOpacityTrigger] floatValue];
        NSArray *aScale= [OKPoEMMProperties objectForKey:SnakeScalingFactors];
        SNAKE_SCALING_FACTORS[0] = [[aScale objectAtIndex:0] floatValue];
        SNAKE_SCALING_FACTORS[1] = [[aScale objectAtIndex:1] floatValue];
        SNAKE_SCALING_FACTORS[2] = [[aScale objectAtIndex:2] floatValue];
        SNAKE_SCALING_FACTORS[3] = [[aScale objectAtIndex:3] floatValue];
        aScale= [OKPoEMMProperties objectForKey:SnakeScalingPositions];
        SNAKE_SCALING_POSITIONS[0] = [[aScale objectAtIndex:0] floatValue];
        SNAKE_SCALING_POSITIONS[1] = [[aScale objectAtIndex:1] floatValue];
        SNAKE_SCALING_POSITIONS[2] = [[aScale objectAtIndex:2] floatValue];
        SNAKE_SCALING_POSITIONS[3] = [[aScale objectAtIndex:3] floatValue];
        NSLog(@"SNAKE SCALING POS= %f, %f, %f, %f", SNAKE_SCALING_POSITIONS[0],SNAKE_SCALING_POSITIONS[1],SNAKE_SCALING_POSITIONS[2],SNAKE_SCALING_POSITIONS[3]);
        TEXT_CHANGE_INTERVAL=1000*[[OKPoEMMProperties objectForKey:TextChangeInterval] integerValue];
        TEXT_CHANGE_SPEED=1000*[[OKPoEMMProperties objectForKey:TextChangeSpeed] integerValue];
        IDLE_INTERVAL=1000*[[OKPoEMMProperties objectForKey:IdleInterval] integerValue];
        BGSNAKE_INTERVAL=1000*[[OKPoEMMProperties objectForKey:BgSnakeInterval] integerValue];
        BGSNAKE_OPACITY=[[OKPoEMMProperties objectForKey:BgSnakeOpacity] floatValue];			
        
        FIRST_BITE_DELAY=[[OKPoEMMProperties objectForKey:FirstBiteDelay] integerValue];				
        NEXT_BITE_MINIMUM_DELAY=[[OKPoEMMProperties objectForKey:NextBiteMinimumDelay] integerValue];			
        NEXT_BITE_MAXIMUM_DELAY=[[OKPoEMMProperties objectForKey:NextBiteMaximumDelay] integerValue];			

        PHYSICS_GRAVITY=[[OKPoEMMProperties objectForKey:PhysicsGravity] floatValue];				//gravity of the particle system
        PHYSICS_DRAG=[[OKPoEMMProperties objectForKey:PhysicsDrag] floatValue];					//drag of the particle system
        SMOOTH_LEVEL=[[OKPoEMMProperties objectForKey:SmoothLevel] integerValue];					//anti-aliasing level
        
        //rattlesnakes sounds
        SHIFT_SOUNDS_TIME=[[OKPoEMMProperties objectForKey:ShiftSoundsTime] integerValue];
        AMBIENT_VOLUME_START=[[OKPoEMMProperties objectForKey:AmbientVolumeStart] floatValue];
        AMBIENT_VOLUME_END=[[OKPoEMMProperties objectForKey:AmbientVolumeEnd] floatValue];
        THREAT_VOLUME=[[OKPoEMMProperties objectForKey:ThreatVolume] floatValue];
        RATTLE_VOLUME=[[OKPoEMMProperties objectForKey:RattleVolume] floatValue];
        STRIKE_VOLUME=[[OKPoEMMProperties objectForKey:StrikeVolume] floatValue];
        FIRST_STRIKE_SND_FILE=[OKPoEMMProperties objectForKey:FirstStrikeSndFile];
        
        // Screen bounds
        sBounds = bounds;
        
        // Touches
        TOUCH_OFFSET = [[OKPoEMMProperties objectForKey:TouchOffset] floatValue];
        ctrlPts = [[NSMutableDictionary alloc] init];
        ctrlPtsTouch =[[NSMutableDictionary alloc] init];
        
        // Properties
        font = tFont;
        
        text = textObj;
        allTextsObjects = theTexts;
        
        bgOpacity = 0.0f;
        bgCenter = OKPointMake(sBounds.size.width / 2.0f, sBounds.size.height / 2.0f, 0.0f);
        
        // Background words
        bgWords = [[NSMutableArray alloc] init];
        
        OKSentenceObject *outlinedSentence = [[OKSentenceObject alloc] initWithSentence:BG_TEXT withTessFont:font];
        [self buildOutlinedWords:outlinedSentence];
        [outlinedSentence release];
        
        // Count scroll text words
        //scrollTextWords = [self scrollTextWordsCount:text];
        // Set the current index (next word shown on touch) to the first word
        nextWordLine1 = 0;
        nextWordLine2 = 0;
        
        // Create empty lines array
        scrollTextLines = [[NSMutableArray alloc] init];
        
        // Create array that holds max current sentences (this needs to match MAX_FINGERS in EAGLView)
        cScrollTextLines = [[NSMutableArray alloc] initWithCapacity:MAX_SENTENCES];
        // Insert null value in array
        for(int i = 0; i < MAX_SENTENCES; i++)
        {
            [cScrollTextLines insertObject:[NSNull null] atIndex:i];
        }
        
        // Create array that is used to dump "dead" sentences
        removableScrollTextLines = [[NSMutableArray alloc] init];
        
        // Create an array of words (all words)
        words = [[NSMutableArray alloc] init];
        
        for(OKSentenceObject *sentenceObj in textObj.sentenceObjects)
        {
            for(OKWordObject *wordObj in sentenceObj.wordObjects)
            {
                [words addObject:wordObj];
            }
        }

        // Animation time tracking
        lUpdate = [[NSDate alloc] init];
        now = [[NSDate alloc] init];
                
        // Stats
        NSLog(@"Total Sentences %i", [text.sentenceObjects count]);
        NSLog(@"Total Words %i", scrollTextWords);
        NSLog(@"Total Glyphs (with spaces) %i", [text.text length]);
                
        [self readTexts];
        [self setupTexts];
        [self setupAudio];
        
        //init particle system
        physics = [[CMTPParticleSystem alloc] initWithGravityVector:CMTPVector3DMake(0, PHYSICS_GRAVITY, 0) drag:PHYSICS_DRAG];
        [physics setIntegrator:CMTPParticleSystemIntegratorRungeKutta];
        
        //setup the snakes
        [self setupSnakes];
        
        [self setupChangingOfTheTexts];
      
        [[soundManager ambient:0] setVolume:0];
        [[soundManager ambient:1] setVolume:0];
        [soundManager fadeInAndRepeatAmbient:0 to:AMBIENT_VOLUME_START duration:12000];
        [soundManager fadeInAndRepeatAmbient:1 to:0 duration:0];
        
        //get parent view
        parentEaglView = aView;
        
        //setup for 2 fingers swipe right
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [swipeRight setNumberOfTouchesRequired:2];
        [aView addGestureRecognizer:swipeRight];
        [swipeRight release];
        
        //setup for 2 fingers swipe right
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeLeft setNumberOfTouchesRequired:2];
        [aView addGestureRecognizer:swipeLeft];
        [swipeLeft release];
        
        swipeDirectionRight=FALSE;   //Left=FALSE, Right=TRUE
        
    }
    return self;
}

- (void)handleSwipeRight:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"Handle Swipe Right");
    swipeDirectionRight=TRUE;
    [self changingOfTheTexts];
}

- (void)handleSwipeLeft:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"Handle Swipe Left");
    swipeDirectionRight=FALSE;
    [self changingOfTheTexts];
}


//
// Read text lines.
//

 -(void) readTexts {    
     
     textFiles = [[NSMutableArray alloc] init];
     
   
     for(OKTextObject *aTextObject in allTextsObjects)
     {
        NSMutableArray *someLines = [[NSMutableArray alloc] init];
         
        //calculate the total height for the lines of the text
        float totalHeight=0;
        int totalValidSentences=0;
        for(OKSentenceObject *bSentenceObject in aTextObject.sentenceObjects)
         {
             //make sure the line is not empty
             if([bSentenceObject getWitdh]!=0){
                 float aScale = sBounds.size.width/[bSentenceObject getWitdh];
                 totalHeight = totalHeight + (aScale * [bSentenceObject getHeight]);
                 totalValidSentences++;
             }
         }
         NSLog(@"Total Height for TEXT: %f", totalHeight);
         NSLog(@"Total Sentence for TEXT %d", totalValidSentences);
         
         float lineSpacing = (sBounds.size.height - totalHeight)/(totalValidSentences+1);
         
        int countLine=1;
        float positionY = sBounds.size.height;
        for(OKSentenceObject *aSentenceObject in aTextObject.sentenceObjects)
        {

            //make sure the line is not empty
            if([aSentenceObject getWitdh]!=0){
                
                float lineScale = sBounds.size.width/[aSentenceObject getWitdh];
                Line *aLine = [[Line alloc] initWithScale:lineScale font:font source:aSentenceObject.wordObjects start:0 renderingBounds:sBounds positionY:positionY];
                [aLine setHeight:[aSentenceObject getHeight]*lineScale];
                positionY = positionY - [aSentenceObject getHeight]*lineScale - lineSpacing;
                [aLine setPosX:0 y:positionY z:0];
                [someLines addObject:aLine];
                [aLine release];
                countLine++;
            }
        }
        [textFiles addObject:someLines];
        [someLines release];
     }
 
 }


//
//  Setup the background texts.
//

-(void) setupTexts {
    textIndex = START_TEXT_INDEX;
    totalWordsSeen = 0;
    totalWords = [self totalWordsForText:textIndex];
    
}
        
        
/**
 * Get the total number of words in a page of text
 * @param index index of the page
 * @return
 */
-(int) totalWordsForText:(int)index {
    int count = 0;
    
    //load current text
    NSMutableArray *someLines = [textFiles objectAtIndex:index];
    for(Line *aLine in someLines)
    {
        count +=[[aLine words]count];
    }
    return count;
}




//
// Setup the snakes
//
- (void) setupSnakes
{
    //read the texts from snake text file

    //setup the scaling table
    NSMutableArray *snakeScalingPositions= [[NSMutableArray alloc] init];
    NSMutableArray *snakeScalingFactors= [[NSMutableArray alloc] init];
    for(int j=0;j<4;j++){
        [snakeScalingPositions addObject:[NSNumber numberWithFloat:SNAKE_SCALING_POSITIONS[j]]];
        
        NSLog(@"SnakeScalinPosition[%d]: %f", j, [[snakeScalingPositions objectAtIndex:j] floatValue] );
        [snakeScalingFactors addObject:[NSNumber numberWithFloat:(SNAKE_SCALING_FACTORS[j]*SNAKE_FONT_SCALING)]];
    }
    
    //create the snake font
    //snakeFont = [[OKTessFont alloc] initWithControlFile:SNAKE_FONT scale:SNAKE_FONT_SCALING filter:GL_LINEAR];
    snakeFont = [[OKTessFont alloc] initWithControlFile:SNAKE_FONT scale:1.0 filter:GL_LINEAR];
    [snakeFont setColourFilterRed:0 green:0 blue:0 alpha:0];
  
    //initialise the snakes
    snakes = [[NSMutableArray alloc] init];
    
    Snake *currentSnake;
    
    //top-left
    currentSnake = [[Snake alloc] initWithId:0 physics:physics text:@"yesterday tom didn't have a son today he does all twenty-four years of one" font:snakeFont sectionCount:24 side:RIGHT renderingBounds:sBounds];
    [currentSnake setScales:snakeScalingPositions scales:snakeScalingFactors];
    [currentSnake setBite:SNAKE_BITE_MASS strenght:SNAKE_BITE_STRENGTH_MULT minDistance:SNAKE_BITE_MIN_DISTANCE];
    [currentSnake setRetract:RIGHT delay:0 wave:0 speed:0.02f];
    [currentSnake setOrigin:50 lenght:200 cycles:4];
    [currentSnake translate:-(sBounds.size.width/4) y:sBounds.size.height+200 z:0];
    [currentSnake retract];
    [snakes addObject:currentSnake];
    [currentSnake release];
        
    //top-right
    currentSnake = [[Snake alloc] initWithId:1 physics:physics text:@"of sky to river and the stillness surrounding the rumbling rush and the smell of pine needles" font:snakeFont sectionCount:24 side:LEFT renderingBounds:sBounds];
    [currentSnake setScales:snakeScalingPositions scales:snakeScalingFactors];
    [currentSnake setBite:SNAKE_BITE_MASS strenght:SNAKE_BITE_STRENGTH_MULT minDistance:SNAKE_BITE_MIN_DISTANCE];
    [currentSnake setRetract:RIGHT delay:250 wave:25 speed:0.05f];
    [currentSnake setOrigin:50 lenght:200 cycles:4];
    [currentSnake translate:sBounds.size.width-100 y:sBounds.size.height+200 z:0];
    [currentSnake retract];
    [snakes addObject:currentSnake];
    [currentSnake release];
    
    //bottom-left
    currentSnake = [[Snake alloc] initWithId:2 physics:physics text:@"of sky to river and the stillness surrounding the rumbling rush and the smell of pine needles" font:snakeFont sectionCount:24 side:RIGHT renderingBounds:sBounds];
    [currentSnake setScales:snakeScalingPositions scales:snakeScalingFactors];
    [currentSnake setBite:SNAKE_BITE_MASS strenght:SNAKE_BITE_STRENGTH_MULT minDistance:SNAKE_BITE_MIN_DISTANCE];
    [currentSnake setRetract:LEFT delay:200 wave:50 speed:0.2f];
    [currentSnake setOrigin:50 lenght:10 cycles:4];
    [currentSnake translate:-(sBounds.size.width/4) y:-(sBounds.size.height/3) z:0];
    [currentSnake retract];
    [snakes addObject:currentSnake];
    [currentSnake release];
    
    NSLog(@"Width:%f Height:%f", sBounds.size.width, sBounds.size.height);
    //bottom-right
    currentSnake = [[Snake alloc] initWithId:3 physics:physics text:@"zzzzztzzzzzzzztzzzzzzztzzzzztzzzzzzzztzzzzzzztzzzzztzzzzzzzztzzzzzzztzzzzztzzzzzzzztzzzzzzzt" font:snakeFont sectionCount:24 side:LEFT renderingBounds:sBounds];
    [currentSnake setScales:snakeScalingPositions scales:snakeScalingFactors];
    [currentSnake setBite:SNAKE_BITE_MASS strenght:SNAKE_BITE_STRENGTH_MULT minDistance:SNAKE_BITE_MIN_DISTANCE];
    [currentSnake setRetract:LEFT delay:100 wave:100 speed:0.4f];
    [currentSnake setOrigin:50 lenght:200 cycles:4];
    [currentSnake translate:sBounds.size.width-100 y:-(sBounds.size.height/3) z:0];
    [currentSnake retract];
    [snakes addObject:currentSnake];
    [currentSnake release];

    
    //flag to keep track of the first bite
    firstBite = true;
    
}

//
//  Get current ms time
//
-(long long) getMillis{
    
    //long long nowMillis = (long long)([[NSDate date] timeIntervalSince1970])*1000;
    
    static mach_timebase_info_data_t sTimebaseInfo;
    uint64_t machTime = mach_absolute_time();
    
    // Convert to nanoseconds - if this is the first time we've run, get the timebase.
    if (sTimebaseInfo.denom == 0 )
    {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    // Convert the mach time to milliseconds
    uint64_t millis = ((machTime / 1000000) * sTimebaseInfo.numer) / sTimebaseInfo.denom;
    
    long long nowMillis = (long long)millis;
    return nowMillis;
}


-(void) setupIdleAnimation {
    //create array of words highlighted by the animation
#warning to implement
    
}


//
// Reset the background snake animation.
//
-(void) resetBgSnake {
    //set the last time the background snake animation started
    //lastBgSnake = millis();
    NSTimeInterval time = ([[NSDate date] timeIntervalSince1970]);
    long digits = (long)time; // this is the first 10 digits
    int decimalDigits = (int)(fmod(time, 1) * 1000); // this will get the 3 missing digits
    lastBgSnake =(digits * 1000) + decimalDigits;
    
    //reset the bezier path to a random position above the canvas
    //float sx = random(0, width);
    float sx  = arc4random() % (int)sBounds.size.width;
    
    //float ex = random(0, width);
    float ex  = arc4random() % (int)sBounds.size.width;
    
    bgSnake = [[BezierPath alloc] initWithPositions:sx sy:-10 c1x:(sx+ex)/2 c1y:sBounds.size.width/3 c2x:(sx+ex)/2 c2y:sBounds.size.width*2/3 ex:ex ey:sBounds.size.height+100];
    
    //set it to randomly move up or down
    //if (random(1.0f) < 0.5) bgSnake.reverse();
    if( (arc4random() / ARC4RANDOM_MAX)< 0.5)
        [bgSnake reverse];
}


//
//Setup the text changing animation.
//
-(void) setupChangingOfTheTexts {
        
    //if the changing delays have never been initialized
    //create an array that holds as many delays as the text page with most lines
    if (!textChangingDelays) {
        int maxDelays = 0;
        for(NSMutableArray *someLines in textFiles){
            if([someLines count]>maxDelays)
                maxDelays = [someLines count];
        }
        textChangingDelays = [[NSMutableArray alloc] initWithCapacity:maxDelays];
    }
    
    //lock until the first touch
    changingLock = true;
    
    //flag text as not changing
    changing = false;
    
    //set the last time the text changed
    lastChanging = [self getMillis];
    
    //set the next time the text is allowed to change
    nextTextChange = lastChanging + TEXT_CHANGE_INTERVAL;
}



//
// Setup the audio using Minim.
//
-(void) setupAudio {
    //init sound manager
    soundManager = [[SoundManager alloc] init];
    
    //load sounds
    [soundManager loadAmbientSamples:[soundManager ambientPath:@""]];
    [soundManager loadThreatSamples:[soundManager threatPath:@""] volume:THREAT_VOLUME];
    [soundManager loadRattleSamples:[soundManager rattlePath:@""]];
    [soundManager loadStrikeSamples:[soundManager strikePath:@""] first:FIRST_STRIKE_SND_FILE];
}



//Make the snakes bite
-(void) snakeBite{
    
    //don't bite for the first 3 texts
    if (textIndex < 3) return;
    
    //increment one bite each text after that
    if ([self countSnakesBiting] > textIndex-3) return;
    
    //get time
    long long nowTime = [self getMillis];
    
    //load current text
    NSMutableArray *someLines = [textFiles objectAtIndex:textIndex];
    
    //go through all the word
    for(Line *aLine in someLines)
    {
        for(Word *aWord in [aLine words]){
            
            if(aWord.opacity< SNAKE_BITE_OPACITY_TRIGGER) continue;
            
            //is there a corresponding touch for the word?
            //Touch *wTouch = [Touch alloc];
            Touch *wTouch=nil;
            for(id key in ctrlPtsTouch)
            {
                id idTouch = [ctrlPtsTouch objectForKey:key];
                Touch *aTouch = (Touch*)idTouch;
                
                if(aTouch){
                    //NSLog(@"WORD %d: PosY: %f", lineNb, aLine.pos.y);
                    if([aTouch getX]<aWord.pos.x+([aWord getSize].width*[aWord getScale])/2
                       && [aTouch getX]>aWord.pos.x-([aWord getSize].width*[aWord getScale])/2
                       && [aTouch getY]<aLine.pos.y+[aLine getHeight] && [aTouch getY]>aLine.pos.y){
                        
                        if(aTouch.bites>0){
                            if(nowTime >= aTouch.start+aTouch.delay && ((!wTouch) || aTouch.bites< wTouch.bites)){
                               wTouch = aTouch;
                            }
                        }
                        else if( nowTime >= aTouch.start+FIRST_BITE_DELAY){
                            wTouch = aTouch;
                            break;
                        }
                    }
                }
            }
            
            if(!wTouch) {
                continue;
            }
            
            //get the snake that matches the quadrant the word is in
            int index=0;
            if(aWord.pos.x > sBounds.size.width/2)
                index+=1;
            if(aLine.pos.y < sBounds.size.height/2)
                index+=2;
            
            Snake *currSnake = [snakes objectAtIndex:index];
            
            if(![currSnake isBiting]){
                //if this is the first bite
                if (firstBite) {
                                       
                    //turn off first rattle players
                    [soundManager stopThreats];
                    [currSnake setRattleSamples:[soundManager exclusiveRattles:1] rvolume:RATTLE_VOLUME];
                    
                    AVAudioPlayer *a = [soundManager exclusiveFirstStrike];
                    [currSnake setStrikeSample:a volume:STRIKE_VOLUME];
                    firstBite = false;
                }
                else {
                    int numSnds = [self numSoundsForText:textIndex];
                
                    [currSnake setSamples:[soundManager exclusiveStrikes:numSnds] svolume:STRIKE_VOLUME rattles:[soundManager exclusiveRattles:numSnds] rvolume:RATTLE_VOLUME];
                    
                }
                
                //bite that word/touch pair
                [currSnake bite:aWord touch:wTouch];
                
                //increase the delay till the next snake bite
                wTouch.delay += (int)(NEXT_BITE_MINIMUM_DELAY + arc4random() % (NEXT_BITE_MAXIMUM_DELAY - NEXT_BITE_MINIMUM_DELAY));
                
                //[wTouch release];

                
            }

        }
    }

}


//
// Get the number of biting snakes.
// @return the number of biting snakes
//
-(int) countSnakesBiting {
    int count = 0;
    for(Snake* s in snakes){
        if([s isBiting])
            count++;
    }
    return count;
}

- (void) buildOutlinedWords:(OKSentenceObject*)aSentenceObj
{
    for(OKWordObject *word in aSentenceObj.wordObjects)
    {
        OutlinedWord *oWord = [[OutlinedWord alloc] initWithWord:word font:font renderingBounds:sBounds];
        [oWord setScale:BG_TEXT_SCALE];
        [bgWords addObject:oWord];
        [oWord release];
    }
    
    BG_TEXT_LEADING = ([aSentenceObj getHeight] * BG_TEXT_SCALE) * BG_TEXT_LEADING_SCALAR; // Overlaps texts
    BG_TEXT_TOP = sBounds.size.height/2.0f + (((BG_TEXT_LEADING * [bgWords count])/2.0f) - BG_TEXT_LEADING); // Centers text
}



- (Line*) createLine:(int)start { return [[Line alloc] initWithFont:font source:words start:start renderingBounds:sBounds]; }


#pragma mark - DRAW

- (void) draw
{
    
    //Millis since last draw
    DT = (long)([now timeIntervalSinceDate:lUpdate] * 1000);
    [lUpdate release];
    
    //Clear - Draw bg color (open gl)
    glClearColor(BG_COLOR[0], BG_COLOR[1], BG_COLOR[2], BG_COLOR[3]);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //Enable Blending
    glEnable(GL_BLEND);
    
    // Update
    [self update:DT];
    
    // Draw Text
    [self drawText];
   
    //update particle system
    [physics tick:0.1f];
    
    //update the sound manager
    [soundManager update];
        
    //if it's not time, then handle touches on words
    [self handleBitableWords];
    
    [self handleVisibleWords];
    
    
    //check if it's time to change the text (and change if it is)
    long long nowTime = [self getMillis];
    
    if(changing || (!changingLock && nextTextChange<nowTime && [ctrlPtsTouch count]==0)){
        //NSLog(@"Time for Text Change");
        [self changingOfTheTexts];
    }
    else{
        //check if it's time for the idle animation
        //moveBgSnake();
        
        //make the snakes bite
       [self snakeBite];
    }

    //draw snakes
    for(Snake *aSnake in snakes){
        [aSnake update:DT];
        [aSnake draw];
        [aSnake drawSkeleton];
        [aSnake drawBounds];
    }
    
    //Disable Blending
    glDisable(GL_BLEND);
    
    //Keep track of time    
    lUpdate = [[NSDate alloc] initWithTimeIntervalSince1970:[now timeIntervalSince1970]];
    
    [now release];
    now = [[NSDate alloc] init];
    frameCount++;
    
   }


//
// Change the sounds from the current to the next text.
//
-(void) updateChangingSounds {
    //the current text index is textIndex
    //and we are changing left or right based on chagingDirection
    //if moving from screen 1 to screen 2 fade to next sounds
    if (textIndex == 0) {
        //fade out first ambient sound
        //[soundManager fadeAmbient:0 to:0 duration:5000 stopwhendone:TRUE];
        [soundManager fadeAmbient:0 to:0 duration:5000 stopwhendone:FALSE];
        
        //fade in second ambient sound
        //[soundManager fadeInAndRepeatAmbient:1 to:AMBIENT_VOLUME_START duration:5000];
        [soundManager fadeAmbient:1 to:AMBIENT_VOLUME_START duration:5000 stopwhendone:FALSE];
        
        //start playing threat sounds
        [soundManager playThreats];
   
    }
    //when moving from screen 3 to 4
    else if (textIndex == 2) {
        //bring down the ambient sound
        [soundManager fadeAmbient:1 to:AMBIENT_VOLUME_END duration:10000 stopwhendone:FALSE];

    }
    //when moving from the last to the first screen
    else if (textIndex ==  [textFiles count]-1) {
        NSLog(@"Fade in ambiant 0");
        //fade in the first ambient sound
        //[soundManager fadeInAndRepeatAmbient:0 to:AMBIENT_VOLUME_START duration:5000];
        [soundManager fadeAmbient:0 to:AMBIENT_VOLUME_START duration:5000 stopwhendone:FALSE];

        //fade out the second ambient sound
        [soundManager fadeAmbient:1 to:0 duration:5000 stopwhendone:FALSE];

        //stop threat sounds
        [soundManager stopThreats];

    }
}

/**
 * Manage the words that have been touches and set as bitable.
 */
- (void) handleBitableWords
{
    //load current text
    NSMutableArray *someLines = [textFiles objectAtIndex:textIndex];
    
    //go through all the word
    for(Line *aLine in someLines)
    {
        for(Word *aWord in [aLine words]){
            
            //go through all the touch
            for(id key in ctrlPtsTouch)
            {
                id idTouch = [ctrlPtsTouch objectForKey:key];
                Touch *aTouch = (Touch*)idTouch;
                if(aTouch){
                    
                    if([aTouch getX]<aWord.pos.x+([aWord getSize].width*[aWord getScale])/2
                       && [aTouch getX]>aWord.pos.x-([aWord getSize].width*[aWord getScale])/2
                       && [aTouch getY]<aLine.pos.y+[aLine getHeight] && [aTouch getY]>aLine.pos.y)
                    {
                        [aWord fadeTo:0.8f speed:TEXT_FADEIN_SPEED];
                        if(![aWord wasSeen]){
                            [aWord setSeen:true];
                            totalWordsSeen++;
                            
                            if(totalWordsSeen/(float)totalWords>0.8){
                                long long n = [self getMillis]+3000;
                                if(n< nextTextChange)
                                    nextTextChange = n;
                            }
                        }
                        break; //at least a touch was found for the word, we stop the search for a touch
                    }
                    else{
                        [aWord fadeOut:0.0 speed:TEXT_FADEOUT_SPEED];
                    }
                   
                }
            }
           
        }
        
    }
}

-(void) handleVisibleWords {
    //fade out visible words that aren't under the background snake
    //or under any touches

    NSMutableArray *someLines = [textFiles objectAtIndex:textIndex];
    for(Line *aLine in someLines)
    {
        for(Word *aWord in [aLine words]){
            if(![aWord isFadingIn]){
                [aWord fadeOut:0.0 speed:TEXT_FADEOUT_SPEED];
            }
        }
    }
}

-(BOOL) changingOfTheTexts{
    
    //NSLog(@"ChangingOfTheTexts");
    //if we weren't changing on the last frame, then init changing values
    if (!changing) {
        changing = true;			//start changing
        changingText = textIndex;	//keep track of the changing text index
        lastChanging = [self getMillis];	//track when we started changing
        //bgSnake.end();				//end the idle animation in case we're in the middle of it
        textChangeSpeed = TEXT_CHANGE_SPEED;	//reset the text change speed
        
        //we wan't each changing animation to be slightly different
        //so we generate random delays for each line to start animating
        [self updateChangingDelays];
        
        //adjust the sounds for the next text
        [self updateChangingSounds];

        return false;
    }

    //if there is a touch during the change
    //speed it up to move quickly to the next screen
    if ( [ctrlPtsTouch count]!=0 || textChangeSpeed != TEXT_CHANGE_SPEED) {
        textChangeSpeed *= 0.97f;
        if (textChangeSpeed <= 0) textChangeSpeed = 1;
    }
    
    
    //fade the words in and out in a wave based on when the changing animation started
    long long diff = [self getMillis] - lastChanging;
    BOOL done = true;
    
    //load current text being changed
    NSMutableArray *someLines = [textFiles objectAtIndex:textIndex];
    
    int lineNb=0;
    //go through all the word
    for(Line *aLine in someLines)
    {
        //enough delay since last change
        if(diff>[[textChangingDelays objectAtIndex:lineNb]longLongValue] ){
            
            int i = (int) (diff-[[textChangingDelays objectAtIndex:lineNb]longLongValue])/textChangeSpeed*[[aLine words]count];
            int wordNb=0;
            for(Word *aWord in [aLine words]){
                //fade in the word reach by the iterator i
                if (wordNb==i){
                    if(![aWord isFadingIn]){
                        if(textChangeSpeed==TEXT_CHANGE_SPEED)
                            [aWord fadeIn:0.8f speed:0.03f outspeed:0.01f];
                        else
                            [aWord fadeIn:0.8f speed:0.4f outspeed:0.1f];
                    }
                    done=false; 
                }
                //fade out all other word
                else if([aWord opacity]>0){
                    
                   // if(![aWord isFading]){
                        if(textChangeSpeed==TEXT_CHANGE_SPEED)
                            [aWord fadeOut];
                        else
                            [aWord fadeOut:0.0f speed:0.1f];
                        //done=false;
                  //  }
                    done=false;
                }
                else
                    [aWord setSeen:FALSE];
                wordNb++;
            }
        }
        else
            done=false;
        lineNb++;
    }

    //if all the words were faded in then out completely
    if (done) {
        //flag text as not changing
        changing = false;
               
        //set the last time the text changed
        lastChanging = [self getMillis];
        
        //set the next time the text is allowed to change
        nextTextChange = [self getMillis] + TEXT_CHANGE_INTERVAL;
        
        if(swipeDirectionRight==FALSE){
            //move to the next in normal direction (and check if we reached the end)
            if(++textIndex >= [textFiles count]){
                //go back to first text
                firstBite = true;
                changingLock = true;
                textIndex = 0;
            }
        }
        //swipeDirectionRight==TRUE
        else{
            if(--textIndex <= 0){
                //if we are back to first text
                if(textIndex==0){
                    firstBite=true;
                    changingLock=true;
                }
                else
                    textIndex = [textFiles count]-1;
            }
            //reset reverse direction swipe.
            swipeDirectionRight=FALSE;

        }
            
        NSLog(@"We load next textindex: %d", textIndex);
        
        //reset word seen counter
        totalWords = [self totalWordsForText:textIndex];
        totalWordsSeen = 0;
    }
    
    //return true when we are changing
    return true;
}


/**
 * Generate random delay for each line of the changing text animation.
 */
-(void) updateChangingDelays {
    //generate the random delays
    int minDelay = INT_MAX;
    
    //for each line of current text
    NSMutableArray *someLines = [textFiles objectAtIndex:textIndex];
    for(int i=0; i< [someLines count];i++){
        //long long temp=[[NSNumber numberWithLongLong:(arc4random()%1000)]longLongValue];
        [textChangingDelays setObject:[NSNumber numberWithLongLong:(arc4random()%1000)] atIndexedSubscript:i];
        if( [[textChangingDelays objectAtIndex:i]integerValue]< minDelay)
            minDelay = [[textChangingDelays objectAtIndex:i]integerValue];
    } 
}



- (void) update:(long)dt
{
    for(Snake *aSnake in snakes){
        if([aSnake getExecuteRipple]){
            
            ripple = [[Ripple alloc] initWithPosition:[aSnake getBitTouch].x y:[aSnake getBitTouch].y s:sBounds.size.width/100 maxRadius:sBounds.size.width/2];
            
            //load ripple into all words/glyphs
            for(NSMutableArray *someLines in textFiles){
                //NSMutableArray *someLines = [textFiles objectAtIndex:textIndex];
                for(Line *aLine in someLines){
                    for(Word *aWord in [aLine words]){
                        [aWord setRipple:ripple];
                    }
                }
            }
            [aSnake setExecuteRipple:false];
        }

    }
    
    if(ripple){

        BOOL notFinished = [ripple update];

        //if ripple is finished
        if(!notFinished){
            //[ripple release]
            ripple=nil;
            //load ripple into all words/glyphs
            for(NSMutableArray *someLines in textFiles){
                for(Line *aLine in someLines){
                    for(Word *aWord in [aLine words]){
                        [aWord setRipple:nil];
                    }
                }
            }
        }
    }
    
    // Update control points
    for(NSString *aKey in ctrlPts)
    {
        KineticObject *ko = [ctrlPts objectForKey:aKey];
        [ko update:dt];
    }
    
    // Update text
    [self updateText:dt];
    
}



- (void) updateText:(long)dt
{

    //update all the  lines
    for(NSMutableArray *atextLine in textFiles)
    {
        for(Line *aLine in atextLine)
        {
            [aLine update:dt];
        }
    }

      
}

- (void) drawText
{
 //load text color
    glColor4f(TEXT_COLOR[0], TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3]);
    
    //draw all the lines from current text
    NSMutableArray *someLines = [textFiles objectAtIndex:textIndex];
    for(Line *aLine in someLines)
    {
        [aLine draw];
    }

}


#pragma mark - Touches

- (void) setCtrlPts:(int)aID atPosition:(CGPoint)aPosition
{
    //[super rippleEffect];
    
    //stop idle animation
    [bgSnake end];
    
    lastTouch = [self getMillis];
    
    //find the touch
    Touch *aTouch = [ctrlPtsTouch objectForKey:[NSString stringWithFormat:@"%i", aID]];
    
    //if the touch is found, update the pos with touch offset
    if(aTouch){
        [aTouch set:aPosition.x y:(aPosition.y+TOUCH_OFFSET)];
    }
    //else, create a new one in the dict, with Touch offset.
    else{
        aTouch = [[Touch alloc] initWithTouch:aID x:(float)aPosition.x y:(float)(aPosition.y+TOUCH_OFFSET) start:lastTouch
                                        delay:(int)(NEXT_BITE_MINIMUM_DELAY + arc4random() % (NEXT_BITE_MAXIMUM_DELAY - NEXT_BITE_MINIMUM_DELAY))];
        
        //NSLog(@"Adding touch in ctrlpts : %@, x:%f y:%f", newTouch, [newTouch getX], [newTouch getY]);
        [ctrlPtsTouch setObject:aTouch forKey:[NSString stringWithFormat:@"%i", aID]];
        [aTouch release];
    }
        
}

- (void) removeCtrlPts:(int)aID atPosition:(CGPoint)aPosition
{
  
    //increase the text change timeout so that it doesn't
    //change right after release
    long long n = [self getMillis];
    if (changingLock)
        n = n + TEXT_CHANGE_INTERVAL;
    else
        n = n + 2000;
    if(n>nextTextChange)
        nextTextChange = n;

    
    //execute only if there are ctrlPtsTouch in array
    if([ctrlPtsTouch count] == 0) return;
    
    //if changing is locked, unlock it
    if (changingLock) changingLock = false;
    
    //remove the touch
    //Touch t = touches.remove(new Integer(id));
    Touch *t = [ctrlPtsTouch objectForKey:[NSString stringWithFormat:@"%i", aID]];
    [ctrlPtsTouch removeObjectForKey:[NSString stringWithFormat:@"%i", aID]];
    
    //if any snake is biting that touch, then retract it
    int fadeDelay = 0;
    for(Snake *currSnake in snakes) {
        if ([currSnake isBiting] && [currSnake getBitTouch] == t) {
            //retract the snake
            [currSnake retract];
            
            //fade out rattle samples
            [soundManager fadeOutAndReleaseRattles:[currSnake rattleSamples] duration:1000 delay:fadeDelay];
            [soundManager fadeOutAndReleaseStrikes:[currSnake strikeSamples] duration:1000];
            fadeDelay+=1000;
            
            //get a new set of sounds
            [currSnake setSamples:nil svolume:0 rattles:nil rvolume:0];            
            
        }
    }

}

- (void) touchesBegan:(int)aID atPosition:(CGPoint)aPosition
{        
    // Set Control Point
    [self setCtrlPts:aID atPosition:aPosition];
}

- (void) touchesMoved:(int)aID atPosition:(CGPoint)aPosition
{
    // Set Control Point
    [self setCtrlPts:aID atPosition:aPosition];
}

- (void) touchesEnded:(int)aID atPosition:(CGPoint)aPosition
{
    // Remove Control Point
    [self removeCtrlPts:aID atPosition:aPosition];
}

- (void) touchesCancelled:(int)aID atPosition:(CGPoint)aPosition
{
    // Remove Control Point
    [self removeCtrlPts:aID atPosition:aPosition];
}

//
// Count number of sounds to hear per text
//
-(int) numSoundsForText:(int) index {
    
    if (index < 5)
        return 1;
    else if (index < 6){
        if([self countSnakesBiting]<2)
            return 1;
        else
            return 2;
    }
    else
        return 2;
}


- (void) dealloc
{    
    [ctrlPts release];
    [bgWords release];
    [scrollTextLines release];
    [removableScrollTextLines release];
    [words release];
    [lUpdate release];
    [now release];
    
    [super dealloc];
}

@end
