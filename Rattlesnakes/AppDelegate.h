//
//  AppDelegate.h
//  Rattlesnakes
//
//  Created by Serge Maheu on 2013-05-03.
//  Copyright (c) 2013 Serge Maheu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OKPoEMM;
@class EAGLView;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) OKPoEMM *poemm;
@property (nonatomic, strong) EAGLView *eaglView;

- (void) loadOKPoEMMInFrame:(CGRect)frame;

@end
