//
//  ESRenderer.h
//  White
//
//  Created by Christian Gratton on 12-06-18.
//  Copyright (c) 2012 Christian Gratton. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@class Rattlesnakes;

@protocol ESRenderer <NSObject>

- (id) initWithMultisampling:(BOOL)aMultiSampling andNumberOfSamples:(int)requestedSamples;
- (void) reset;
- (void) render;
- (void) setFrame:(CGRect)aFrame;
- (void) renderRattlesnakes:(Rattlesnakes*)rattlesnakes;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

-(UIImage *) glToUIImage;
@end
