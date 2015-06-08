//
//  OKPoEMM.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-04.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class OKInfoView;

@interface OKPoEMM : UIViewController
{
    // Info View
    OKInfoView *infoView;
    
    // Info View Buttons
    UIButton *lB;
    UIButton *rB;
    NSTimeInterval touchBeganTime;
    NSTimer *toggleViewTimer;
    
    // Exhibition
    BOOL isExhibition;
}

- (id) initWithFrame:(CGRect)aFrame EAGLView:(UIView*)aEAGLView isExhibition:(BOOL)flag;
- (void) setisExhibition:(BOOL)flag;

@end
