//
//  OKPoEMM.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-04.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKPoEMM.h"
#import "OKAppProperties.h"
#import "OKInfoViewProperties.h"
#import "OKInfoView.h"

static float INFO_VIEW_BUTTON_PADDING = 0.0f;
static float INFO_VIEW_BUTTON_SIZE = 0.0f;
static float TINT[] = {1.0f, 1.0f, 1.0f, 1.0f};

@interface OKPoEMM ()
- (void) customizeAppearance;
- (void) presentInfoViewCntroller;
- (void) toggleVisible;
- (BOOL) didTouchHotCorner:(CGPoint)aPoint;
- (float) distanceFrom:(CGPoint)aPoint toCorner:(CGPoint)aCorner;
@end

@implementation OKPoEMM

- (id) initWithFrame:(CGRect)aFrame EAGLView:(UIView*)aEAGLView isExhibition:(BOOL)flag
{
    self = [super init];
    if (self)
    {
        // List available fonts
        //[[OKAppProperties sharedInstance] listAvailableFonts];
        
        isExhibition = flag;
        
        // Get OKInfoView plist
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"OKInfoViewProperties.plist"];
        [OKInfoViewProperties initWithContentsOfFile:path];
        
        // Customize
        // Infoview button
        INFO_VIEW_BUTTON_SIZE = [[[OKInfoViewProperties objectForKey:@"Interface"] objectForKey:@"iv_button_size"] floatValue];
        INFO_VIEW_BUTTON_PADDING = [[[OKInfoViewProperties objectForKey:@"Interface"] objectForKey:@"iv_button_padding"] floatValue];
        
        // Tint
        NSArray *selectionTint = [[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Tint"];
        
        TINT[0] = [[selectionTint objectAtIndex:0] floatValue];
        TINT[1] = [[selectionTint objectAtIndex:1] floatValue];
        TINT[2] = [[selectionTint objectAtIndex:2] floatValue];
        TINT[3] = [[selectionTint objectAtIndex:3] floatValue];
        
        // Load views
        
        [self.view setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:aEAGLView];
        
        // Exhibition version, don't show infoview
        if(!isExhibition)
        {
            infoView = [[OKInfoView alloc] init];
            [infoView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            
            // Set modalview presentation style for iPad
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                [infoView setModalPresentationStyle:UIModalPresentationFormSheet];
            }
            
            // Info view buttons
            lB = [[UIButton alloc] initWithFrame:CGRectMake(INFO_VIEW_BUTTON_PADDING, aFrame.size.height - (INFO_VIEW_BUTTON_SIZE + INFO_VIEW_BUTTON_PADDING), INFO_VIEW_BUTTON_SIZE, INFO_VIEW_BUTTON_SIZE)];
            [lB addTarget:self action:@selector(presentInfoViewCntroller) forControlEvents:UIControlEventTouchUpInside];
            [lB setBackgroundImage:[UIImage imageNamed:[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"infoview-l"]] forState:UIControlStateNormal];
            [lB setBackgroundColor:[UIColor clearColor]];
            [lB setAlpha:0.0];
            [self.view insertSubview:lB aboveSubview:aEAGLView];
            [self.view addSubview:lB];
            
            rB = [[UIButton alloc] initWithFrame:CGRectMake(aFrame.size.width - (INFO_VIEW_BUTTON_SIZE + INFO_VIEW_BUTTON_PADDING), aFrame.size.height - (INFO_VIEW_BUTTON_SIZE + INFO_VIEW_BUTTON_PADDING), INFO_VIEW_BUTTON_SIZE, INFO_VIEW_BUTTON_SIZE)];
            [rB addTarget:self action:@selector(presentInfoViewCntroller) forControlEvents:UIControlEventTouchUpInside];
            [rB setBackgroundImage:[UIImage imageNamed:[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"infoview-r"]] forState:UIControlStateNormal];
            [rB setBackgroundColor:[UIColor clearColor]];
            [rB setAlpha:0.0];
            [self.view insertSubview:rB aboveSubview:aEAGLView];
            [self.view addSubview:rB];
            
            [self customizeAppearance];
        }
    }
    return self;
}

- (void) setisExhibition:(BOOL)flag
{
    isExhibition = flag;
}

- (void) customizeAppearance
{
    // Set the color tint for *all* UINavigationBars. Try to use the color image if present to avoid apple default color grading
    UIImage *colorTint = [[UIImage imageNamed:@"color.png"]
                          resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    if(colorTint){
        [[UINavigationBar appearance] setBackgroundImage:colorTint forBarMetrics:UIBarMetricsDefault];
    }
    else{
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:TINT[0] green:TINT[1] blue:TINT[2] alpha:TINT[3]]];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Dosis-Bold" size:0.0],
      UITextAttributeFont,
      nil]];
    
    // Set the color tint for *all* UIBarButtonItem
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Dosis-Bold" size:0.0],
      UITextAttributeFont,
      nil] forState:UIControlStateNormal];
    
    // Set the color tint for *all* UITabBars
    if(colorTint){
        [[UITabBar appearance] setBackgroundImage:colorTint];
    }
    else{
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:TINT[0] green:TINT[1] blue:TINT[2] alpha:TINT[3]]];
    }
    
    // Removes blue shine
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    // Removes gloss selection
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
    
    //Set the color tint for *all* UITabBarItem
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIFont fontWithName:@"Dosis-Bold" size:0.0],
      UITextAttributeFont,
      nil] forState:UIControlStateNormal];
}

- (void) presentInfoViewCntroller
{
    [self presentViewController:infoView animated:YES completion:nil];
    [self toggleVisible];
}

- (void) toggleVisible
{
    // Toggle invisible timer (if valid stop timer as we are hidding buttons, if invalid start it as we just showed buttons)
    if([toggleViewTimer isValid])
        [toggleViewTimer invalidate];
    else
        toggleViewTimer = [NSTimer scheduledTimerWithTimeInterval:[[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Animations"] objectForKey:@"iv_hide_delay"] floatValue] target:self selector:@selector(toggleVisible) userInfo:nil repeats:NO];
    
    [UIView beginAnimations:@"toggle" context:nil];
    [UIView setAnimationDelay:[[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Animations"] objectForKey:@"iv_fade_delay"] floatValue]];
    [UIView setAnimationDuration:[[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Animations"] objectForKey:@"iv_fade_duration"] floatValue]];
    
    if(lB.alpha == 0.0)
       [lB setAlpha:1.0];
    else if(lB.alpha == 1.0)
        [lB setAlpha:0.0];
    
    if(rB.alpha == 0.0)
        [rB setAlpha:1.0];
    else if(rB.alpha == 1.0)
        [rB setAlpha:0.0];
    
    
    [UIView commitAnimations];
}

- (BOOL) didTouchHotCorner:(CGPoint)aPoint
{
    CGPoint leftHotCorner = CGPointMake(0.0f, self.view.frame.size.width);
    CGPoint rightHotCorner = CGPointMake(self.view.frame.size.height, self.view.frame.size.width);
    
    float hotCornerRadius = [[[OKInfoViewProperties objectForKey:@"Interface"] objectForKey:@"hot_corner_radius"] floatValue];
    
    if([self distanceFrom:aPoint toCorner:leftHotCorner] <= hotCornerRadius)
        return YES;
    else if([self distanceFrom:aPoint toCorner:rightHotCorner] <= hotCornerRadius)
        return YES;
    
    return NO;
}

- (float) distanceFrom:(CGPoint)aPoint toCorner:(CGPoint)aCorner
{    
    float dx = aPoint.x - aCorner.x;
    float dy = aPoint.y - aCorner.y;
    
    return sqrtf(pow(dx, 2) + pow(dy, 2));
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    touchBeganTime = touch.timestamp;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint pt = [touch locationInView:self.view];
    
    // Check for quick tap
    if(touch.timestamp - touchBeganTime < [[[OKInfoViewProperties objectForKey:@"Interface"] objectForKey:@"tap_max_time"] floatValue] && !isExhibition)
    {
        if([self didTouchHotCorner:pt])
            [self toggleVisible];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Prevents from showing the buttons when dismissing from a full screen modal
    if(self.presentedViewController != infoView) [self toggleVisible];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
