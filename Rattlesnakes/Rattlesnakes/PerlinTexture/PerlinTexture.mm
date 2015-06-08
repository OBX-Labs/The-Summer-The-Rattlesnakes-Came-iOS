//
//  PerlinTexture.m
//  White
//
//  Created by Christian Gratton on 2013-04-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "PerlinTexture.h"
#import "OKNoise.h"

static BOOL NO_SCALE = NO; // YES to render the texture 1:1, NO for full size

@implementation PerlinTexture

- (id) init
{
    return [self initWithScale:0.0f];
}

- (id) initWithScale:(float)newScale
{
    self = [super init];
    if(self) {        
        age = 0;
        texSize = 32;
        tex = new char[texSize * texSize * 3];
        minRange = 50;
        maxRange = 200;
        range = maxRange - minRange;
        scale = newScale;
    }
    return self;
}

- (void) drawX:(int)x y:(int)y w:(int)w h:(int)h
{
    static const GLfloat perlinTexCoord[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f,  0.0f,
        1.0f,  1.0f,
    };

    static const GLfloat squareVertices[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f,  0.0f,
        1.0f,  1.0f,
    };
    
    CGPoint center = CGPointMake(x - w/2.0f, y - w/2.0f);
    
    glPushMatrix();
    glTranslatef(center.x, center.y, 0.0f);
    
    if(NO_SCALE) glScalef(texSize, texSize, 0.0);
    else glScalef(w, w, 0.0);
    
    glEnable (GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, backgroundTexture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    //avoid weird edges
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glColor4f(1.0, 0.0, 1.0, 0.25);
    
//    glTexImage2D (
//                  GL_TEXTURE_2D,
//                  0,
//                  GL_RGB,
//                  texSize,
//                  texSize,
//                  0,
//                  GL_RGB,
//                  GL_UNSIGNED_BYTE,
//                  tex
//                  );
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glTexCoordPointer(2,GL_FLOAT, 0, perlinTexCoord);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glPopMatrix();
}

- (void) update:(long)dt
{
    age += dt;
    [self setNoise];
}

- (void) setNoise
{
    [OKNoise noiseDetail:4 falloff:0.4f];
    float fAge = age/10000.0f;
    int val = 0;
    
    for(int y = 0; y < texSize; y++)
    {
        for(int x = 0; x < texSize; x++)
        {
            val = 3 * (texSize * y + x);
            
            //tex[val] = tex[val + 1] = tex[val + 2] = minRange + [OKNoise noiseX:x*4 y:y*4 z:fAge] * range;
        }
    }
}

@end
