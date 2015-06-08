//
//  Line.h
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KineticObject.h"
#import "Ripple.h"

@class Word;
@class OKSentenceObject;
@class OKTessFont;

@interface Line : KineticObject
{
    // Font
    OKTessFont *font;
    CGRect rBounds;
    
    // Words
    NSMutableArray *wordSource;
    NSMutableArray *source;
    NSMutableArray *words;
    
    // Background loaders    
    NSOperationQueue *queue;
    
    // Touches
    NSMutableDictionary *ctrlPts;
    
    // Properties
    int left, right;
    int highlight;
    
    float dragScroll;
    float xScroll;
    float axScroll;
    float vxScroll;
    
    float touchOffset;
    float offsetSpeed;
    
    float height;
    
}
@property (nonatomic, strong) NSMutableArray *words;

- (id) initWithFont:(OKTessFont*)aFont source:(NSArray*)aSource start:(int)aStart renderingBounds:(CGRect)aRenderingBounds;
- (id) initWithScale:(float)aScale font:(OKTessFont*)aFont source:(NSArray*)aSource start:(int)aStart renderingBounds:(CGRect)aRenderingBounds positionY:(float)positionY;
- (BOOL) revive:(int)highlightedWordIndex;
- (void) backgroundLoadWordAtIndex:(int)index;
- (void) setGlyphsScaling:(float)aScale;
- (void) setHeight:(float)aHeight;
-(float) getHeight;

#pragma mark - DRAW

- (void) draw;
- (void) drawFill;
- (void) drawOutline;
- (void) update:(long)dt;
- (void) updateTouchOffset:(long)dt;

#pragma mark - TOUCHES

- (void) setCtrlPts:(KineticObject*)aCtrlPt forID:(int)aID;
- (void) removeCtrlPts:(int)aID;

#pragma mark - BAHVIOURS

- (void) detach;
- (void) quickFadeOut;
- (void) removeLeft;
- (BOOL) addLeft;
- (void) removeRight;
- (BOOL) addRight;

- (BOOL) isFadedOut;
- (BOOL) isTouchingAt:(OKPoint)aPos;
- (int) highlightedWordIndex;
- (int) sourceIndexForWordIndex:(int)index;

@end
