//
//  OutlinedWord.h
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KineticObject.h"

@class OKTessFont;

@class OKWordObject;
@class OKCharObject;

@interface OutlinedWord : KineticObject
{    
    // Font
    OKTessFont *font;
    
    // Glyphs
    NSMutableArray *glyphs;
    
    // Size
    CGSize size;
    
    // Value
    NSString *value;
    
    // Opacity
    float opacity;
}

- (id) initWithWord:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds;
- (void) build:(OKWordObject*)aWordObj renderingBounds:(CGRect)aRenderingBounds;

#pragma mark - DRAW

- (void) draw; // Draws fill and outline
- (void) drawFill; // Draws fill
- (void) drawOutline; // Draws outline
- (void) drawDebugBounds;
- (void) update:(long)dt;
- (void) updateGlyphs:(long)dt;

- (void) setOpacity:(float)aOpacity;

- (CGRect) getAbsoluteBounds;
- (CGSize) getSize;

@end
