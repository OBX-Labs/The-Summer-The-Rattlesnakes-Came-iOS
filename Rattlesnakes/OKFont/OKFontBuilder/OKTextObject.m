//
//  OKTextObject.m
//  Smooth
//
//  Created by Christian Gratton on 11-06-28.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import "OKTextObject.h"

#import "OKSentenceObject.h"
#import "OKWordObject.h"
#import "OKCharObject.h"

@implementation OKTextObject
@synthesize text, sentenceObjects, tessFont;

- (id) initWithText:(NSString*)aText withTessFont:(OKTessFont*)aTess andCanvasSize:(CGSize)aSize
{
    self = [self init];
	if (self != nil)
	{        
        text = [[NSString alloc] initWithString:aText];
        tessFont = aTess;
        canvas = aSize;
        
        width = 0.0f;
        height = 0.0f;
        x = 0.0f;
        y = 0.0f;
        
        unspool = NO;
        multitouch = NO;
        
        sentenceObjects = [[NSMutableArray alloc] init];
        
        //Split text into sentences
        NSArray *temp = [aText componentsSeparatedByString:@"\n"];
        
        for(int i = 0; i < [temp count]; i++)
        {
            //Make sure the sentence is not empty
            if([temp count]<=1) continue;
            
            OKSentenceObject *sentence = [[OKSentenceObject alloc] initWithSentence:[temp objectAtIndex:i] withTessFont:tessFont];
            
            [sentenceObjects addObject:sentence];
            [sentence release];
        }
    }
    return self;
}

- (void) setAbsPos
{
    for(OKSentenceObject *sentence in sentenceObjects)
    {
        [sentence setPosition:OKPointMake(0, 0, 0)];
    }
}

#pragma mark setters

- (void) setWidth:(float)aWidth
{
    width = aWidth;
}

- (void) setHeight:(float)aHeight
{
    height = aHeight;
}

- (void) setX:(float)aX
{
    x = aX;
}

- (void) setY:(float)aY
{
    y = aY;
}

- (void) setPosition:(OKPoint)aPoint
{
    touchPoint = aPoint;
}

#pragma mark getters

- (float) getWitdh
{
    return width;
}

- (float) getHeight
{
    return height;
}

- (float) getX
{
    return x;
}

- (float) getY
{
    return y;
}

#pragma mark draw

- (void) drawText
{
    [tessFont drawStringAt:OKPointMake(x, y, 800.0) withString:text andDetail:3];
}


#pragma mark dealloc
- (void)dealloc
{
    [text release];
	[sentenceObjects release];
	[super dealloc];
}

@end
