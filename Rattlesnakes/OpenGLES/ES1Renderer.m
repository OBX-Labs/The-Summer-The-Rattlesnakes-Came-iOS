//
//  ES1Renderer.m
//  White
//
//  Created by Christian Gratton on 12-06-18.
//  Copyright (c) 2012 Christian Gratton. All rights reserved.
//

#import "ES1Renderer.h"

#import "Rattlesnakes.h"

static BOOL VIEW_PORT_IS_FRUSTRUM = NO;

@implementation ES1Renderer

// Create an OpenGL ES 1.1 context
- (id) initWithMultisampling:(BOOL)aMultiSampling andNumberOfSamples:(int)requestedSamples
{
    self = [super init];
    if (self)
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context])
        {
            [self release];
            return nil;
        }
        
        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
        
        pixelFormat = GL_RGB565_OES;
        
        multiSampling = aMultiSampling;
        if(multiSampling) {
            GLint maxSamplesAllowed;
            glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamplesAllowed);
            samplesToUse = MIN(maxSamplesAllowed, requestedSamples);
        }
        
    }
    
    return self;
}

- (void) reset { glInitialised = NO; }

- (void) setFrame:(CGRect)aFrame
{
    wFrame = aFrame;
}

- (void) initOpenGL
{	
    GLfloat zNear;
    GLfloat zFar;
    
    GLfloat ymax;
    GLfloat ymin;
    GLfloat xmin;
    GLfloat xmax;	
    
    if(VIEW_PORT_IS_FRUSTRUM)
    {
        zNear = 300;
        zFar = 1000;
        
        GLfloat radtheta = 2.0 * atan2(wFrame.size.height/2, zNear);
        
        GLfloat fovY = (100.0 * radtheta) / M_PI;
        GLfloat aspect = wFrame.size.width/wFrame.size.height;
        
        ymax = zNear * tan(fovY * M_PI / 360.0);
        ymin = -ymax;
        xmin = ymin * aspect;
        xmax = ymax * aspect;
    }
    
    NSLog(@"Window Frame: %f %f", wFrame.size.width, wFrame.size.height);
    
	glViewport(0, 0, wFrame.size.width, wFrame.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
    
    if(VIEW_PORT_IS_FRUSTRUM)
    {
        glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
        glTranslatef(-(wFrame.size.width/2), -(wFrame.size.height/2), 0);
    }
    else
        glOrthof(0, wFrame.size.width, 0, wFrame.size.height, 0, 1000);
      
    
	glMatrixMode(GL_MODELVIEW);
    
	// Save the current matrix to the stack
	glPushMatrix();
	
	//initialize opengl states	
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_DST);
	glEnableClientState(GL_VERTEX_ARRAY);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        
    // Blend Func
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
	//set opengl initialized
	glInitialised = YES;
}

- (void) render
{
    // Replace the implementation of this method to do your own custom drawing
	
	if(!glInitialised)
	{
		[self initOpenGL];
	}
    // Replace the implementation of this method to do your own custom drawing
	
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_READ_FRAMEBUFFER_APPLE, msaaFramebuffer);
    glBindFramebufferOES(GL_DRAW_FRAMEBUFFER_APPLE, defaultFramebuffer);
    glResolveMultisampleFramebufferAPPLE();    
	
	//draw scene
	//glClear(GL_COLOR_BUFFER_BIT);
    
    const GLenum discards[]  = {GL_COLOR_ATTACHMENT0_OES};
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,1,discards);
    
    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer); 
}

- (void) renderRattlesnakes:(Rattlesnakes*)rattlesnakes
{
    if(!glInitialised)
	{
		[self initOpenGL];
	}
    
	// This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
	
    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    if(multiSampling) {
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
    } else glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    
    glViewport(0, 0, backingWidth, backingHeight);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
	//draw scene
	glDepthMask (GL_FALSE);
    glDisable(GL_DEPTH_TEST);
    
    //draw text
    [rattlesnakes draw];
    
    if(multiSampling) {
        /* Resolve from msaaFramebuffer to resolveFramebuffer */
        glBindFramebufferOES(GL_DRAW_FRAMEBUFFER_APPLE, defaultFramebuffer);
        glBindFramebufferOES(GL_READ_FRAMEBUFFER_APPLE, msaaFramebuffer);
        glResolveMultisampleFramebufferAPPLE();
        
        /* Discard */
        const GLenum discards[]  = {GL_COLOR_ATTACHMENT0_OES};
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,1,discards);
    }
    
    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    
    //VICTOR - FIX BACKGROUND PROCESS CRASH
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    if(multiSampling)
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
    
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{	
    // Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (multiSampling)
    {
        NSLog(@"Using samples: %i", samplesToUse);
        
        /* Create the MSAA framebuffer (offscreen) */
        glGenFramebuffersOES(1, &msaaFramebuffer);
        glGenRenderbuffersOES(1, &msaaColorbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer); 
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaColorbuffer);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, samplesToUse, GL_RGBA8_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, msaaColorbuffer);
        
        if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
        {
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
            NSLog(@"0x%x", glGetError()); //GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
        }
        
    }
    
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        NSLog(@"0x%x", glGetError()); //GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
        return NO;
    }
    
    return YES;
}

//grabs screenshot of canvas and returns an image
-(UIImage *) glToUIImage
{    
    int width = wFrame.size.width;
    int height = wFrame.size.height;
    
    NSInteger myDataLength = width * height * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < height; y++)
    {
        for(int x = 0; x < width * 4; x++)
        {
            buffer2[((height - 1) - y) * width * 4 + x] = buffer[y * 4 * width + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

- (void) dealloc
{
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffersOES(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
    
    if (colorRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
    
    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    context = nil;
    
    [super dealloc];
}

@end
