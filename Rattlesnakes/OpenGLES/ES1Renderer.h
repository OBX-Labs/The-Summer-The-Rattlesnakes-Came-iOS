//
//  ES1Renderer.h
//  White
//
//  Created by Christian Gratton on 12-06-18.
//  Copyright (c) 2012 Christian Gratton. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class Rattlesnakes;

@interface ES1Renderer : NSObject <ESRenderer>
{
@private
    EAGLContext *context;
    
    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
    
	//buffers for MSAA
	GLuint msaaFramebuffer, msaaColorbuffer;
    
	BOOL glInitialised;
    BOOL multiSampling;
    
    int samplesToUse;
    int pixelFormat;
    
    //window frame
    CGRect wFrame;
}

- (id) initWithMultisampling:(BOOL)aMultiSampling andNumberOfSamples:(int)requestedSamples;
- (void) reset;
- (void) render;
- (void) setFrame:(CGRect)aFrame;
- (void) renderRattlesnakes:(Rattlesnakes*)rattlesnakes;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

- (void) initOpenGL;

-(UIImage *) glToUIImage;

@end
