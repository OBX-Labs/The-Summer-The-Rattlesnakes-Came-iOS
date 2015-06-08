//
//  PerlinTexture.h
//  White
//
//  Created by Christian Gratton on 2013-04-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface PerlinTexture : NSObject
{
    long age;
    int texSize;
    char *tex;
    int minRange, maxRange, range;
    float scale;
    
    GLuint backgroundTexture;
}

- (id) initWithScale:(float)newScale;

- (void) drawX:(int)x y:(int)y w:(int)w h:(int)h;
- (void) update:(long)dt;
- (void) setNoise;

@end
