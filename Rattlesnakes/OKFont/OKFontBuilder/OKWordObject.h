//
//  OKWordObject.h
//  Smooth
//
//  Created by Christian Gratton on 11-06-28.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OKTessFont.h"

@interface OKWordObject : NSObject
{
    NSString *word;
    NSMutableArray *charObjects;
    
    float width;
    float height;
    float x;
    float y;
    
    OKTessFont *tessFont;
    OKPoint absPos;
    OKPoint relPos;
}

@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSMutableArray *charObjects;

- (id) initWithWord:(NSString*)aWord withFont:(OKTessFont*)aFont;

- (void) setWidth:(float)aWidth;
- (void) setHeight:(float)aHeight;
- (void) setX:(float)aX;
- (void) setY:(float)aY;

- (void) setPosition:(OKPoint)aPos;

- (void) setAbsolutePosition:(OKPoint)aPoint;

- (float) getWitdh;
- (float) getHeight;
- (float) getX;
- (float) getY;

- (void) drawWord;
- (void) drawChars;

- (OKPoint) getCenter;

@end
