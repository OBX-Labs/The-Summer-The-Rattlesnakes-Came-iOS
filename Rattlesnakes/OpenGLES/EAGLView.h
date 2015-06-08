//
//  EAGLView.h
//  Rattlesnakes
//
//  Created by Christian Gratton on 12-06-18.
//  Copyright (c) 2012 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"

@class OKTessFont;
@class OKBitmapFont;
@class OKTextObject;
@class Rattlesnakes;

@interface EAGLView : UIView
{    
@private
    id <ESRenderer> renderer;
    
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id displayLink;
    NSTimer *animationTimer;
	
	//Font Object
    OKTessFont *font;
    OKTessFont *backgroundFont;
    //Text Object
    OKTextObject *text;
    NSMutableArray *theTexts;  //will contain all the OKTextObject (one for each block of text)
    
    //Rattlesnakes Object
    Rattlesnakes *rattlesnakes;
    
    // Touches
    NSMutableArray *fingers;
    
    //3d points in 2d space arrays
	GLfloat modelview[16];
	GLfloat projection[16];
    
	//frame rate (should be removed for final)
    UILabel *lbl_frameRate;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) id displayLink;
@property (nonatomic, assign) NSTimer *animationTimer;
@property (nonatomic, retain) Rattlesnakes *rattlesnakes;

+ (EAGLView*) sharedInstance;

- (id) initWithFrame:(CGRect)aFrame multisampling:(BOOL)canMultisample andSamples:(int)aSamples;

- (void) setup;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;
- (UIImage*) screenCapture;

- (void)getFrameRate:(float)withInterval;

// Touches
- (int) addFingerForTouch:(UITouch*)aTouch;
- (int) getFingerForTouch:(UITouch*)aTouch;
- (CGPoint) convertTouch:(CGPoint)aPoint withZ:(float)z;

// InfoView

- (void) infoViewWillAppear;
- (void) infoViewWillDisappear;

-(void) rippleEffect;

@end
