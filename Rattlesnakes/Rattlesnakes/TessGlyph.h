//
//  TessGlyph.h
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KineticObject.h"
#import "Word.h"
#import "Ripple.h"

@class OKTessData;
@class OKTessFont;

@class OKCharObject;
@class OKCharDef;

#define ARC4RANDOM_MAX 0x100000000

@interface TessGlyph : KineticObject
{
    // Rendering Bounds
    CGRect rBounds;
    
    // TessFont
    OKTessFont *font;
    
    // TessData
    OKTessData *origData;
    OKTessData *dfrmData;
    
    // Bounds
    CGRect bounds;
    CGRect absBounds;
    
    // 3D Point in 2D space arrays
    GLfloat modelview[16];
	GLfloat projection[16];
    
    //Color
    float fillClr[4];
    float outlineClr[4];
    
    // Outline
    BOOL canVertexArray;
    
    OKPoint contractPosition;
    int contractionIteration;
    float decontractionIteration;
    BOOL contracting;
    BOOL decontracting;
    
    BOOL afterRipple;
    float afterRippleIteration;
    
    OKPoint wordPos;
    
    Ripple *ripple;
    GLfloat *verticesToDisplay;
    float RIPPLE_LENGTH;
    
}

@property (nonatomic, strong) OKCharObject *charObj;

- (id) initWithChar:(OKCharObject*)aCharObj font:(OKTessFont*)aFont accurracy:(int)accurracy renderingBounds:(CGRect)aRenderingBounds;
- (void) buildWithAccuracy:(int)aAccuracy;
- (void) setWordPosX:(float)posX y:(float)posY;
- (OKTessData*) tesselate:(OKCharDef*)aCharDef accuracy:(int)aAccuracy;

#pragma mark - DRAW

- (void) drawShadow;
- (void) draw;
- (void) drawFill;
- (void) drawOutline;
- (void) drawDebugBoundsForMinX:(float)minX maxX:(float)maxX minY:(float)minY maxY:(float)maxY;
- (void) update:(long)dt;

#pragma mark - COLOR

- (float*) getFillColor;
- (float*) getOutlineColor;
- (void) setFillColor:(float*)clr;
- (void) setOutlineColor:(float*)clr;

#pragma mark - PROPERTIES

- (BOOL) isOutside:(CGRect)b;
- (BOOL) isInside:(CGPoint)p;

#pragma mark - GETTERS

- (CGRect) getBounds;
- (CGRect) getAbsoluteBounds;
- (OKPoint) getAbsoluteCoordinates;
- (OKPoint) transform:(OKPoint)aPoint;

#pragma mark - POINT CONVERSION

- (CGPoint) convertPoint:(CGPoint)aPoint withZ:(float)z;

#pragma mark - RANDOM

- (float) floatRandom;
- (float) arc4randomf:(float)max :(float)min;

- (void) setContractPoint:(float)x y:(float)y;
- (void) setContract:(BOOL)aContractState;

- (void) setRipple:(Ripple*)aRipple;

@end
