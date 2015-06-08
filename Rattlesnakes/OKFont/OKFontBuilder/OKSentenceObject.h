//
//  OKSentenceObject.h
//  Smooth
//
//  Created by Christian Gratton on 11-06-28.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OKTessFont.h"
#import "OKBitmapFont.h"

@interface OKSentenceObject : NSObject
{
    NSString *sentence;
    NSMutableArray *wordObjects;
    
    float width;
    float height;
    float x;
    float y;
    
    OKTessFont *tessFont;
    OKPoint absPos;
}

@property (nonatomic, retain) NSString *sentence;
@property (nonatomic, retain) NSMutableArray *wordObjects;
@property (nonatomic, retain) OKTessFont *tessFont;

- (id) initWithSentence:(NSString*)aSentence withTessFont:(OKTessFont*)aTess;

- (void) setWidth:(float)aWidth;
- (void) setHeight:(float)aHeight;
- (void) setX:(float)aX;
- (void) setY:(float)aY;

- (void) setPosition:(OKPoint)aPos;

- (float) getWitdh;
- (float) getHeight;
- (float) getX;
- (float) getY;

- (OKPoint) getCenter;

@end
