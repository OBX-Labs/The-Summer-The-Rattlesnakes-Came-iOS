//
//  OKCharObject.h
//  Smooth
//
//  Created by Christian Gratton on 11-06-28.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OKTessFont.h"
#import "OKWordObject.h"

@interface OKCharObject : NSObject
{
    NSString *glyph;
    
    OKCharDef *origData;
    OKCharDef *dfrmData;
    
    float width;
    float height;
    float kerning;
    float x;
    float y;
    
    float xOffset;
    float yOffset;
    
    //target
    OKPoint target;
    //velocity
	float velocityX;
	float velocityY;
    //friction
    float friction;
    
    BOOL visible;
    BOOL detached;

    OKTessFont *tessFont;
    OKPoint absPos;
    OKPoint relPos;
}

@property (nonatomic, retain) NSString *glyph;

- (id) initWithChar:(NSString*)aChar withFont:(OKTessFont*)aFont;

- (void) setWidth:(float)aWidth;
- (void) setHeight:(float)aHeight;
- (void) setKerning:(float)aKerning;
- (void) setX:(float)aX;
- (void) setY:(float)aY;
- (void) setVisible:(BOOL)isVisible;

//- (void) setXOffset:(float)aXOffset;
- (void) setPosition:(OKPoint)aPos;

- (void) setAbsolutePosition:(OKPoint)aPoint;
- (void) setRelativePosition:(OKPoint)aPoint;

- (void) setTarget;
- (void) applyFriction;
- (void) wander;

- (float) getWitdh;
- (float) getHeight;
- (float) getKerning;
- (float) getX;
- (float) getY;
- (float) getXOffset;
- (float) getYOffset;

- (float) getMinX;
- (float) getMaxX;
- (float) getMinY;
- (float) getMaxY;

- (void) detach;
- (void) unspool:(OKPoint)aPoint;
- (void) spool;
- (void) drawChar;

- (OKPoint) getCenter;
- (OKPoint) getPositionAbsolute;
- (CGRect) getLocalBoundingBox;

@end
