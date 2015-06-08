//
//  OKWordObject.m
//  Smooth
//
//  Created by Christian Gratton on 11-06-28.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import "OKWordObject.h"
#import "OKCharObject.h"

@implementation OKWordObject
@synthesize word, charObjects;

- (id) initWithWord:(NSString*)aWord withFont:(OKTessFont*)aFont
{
    self = [self init];
	if (self != nil)
	{
        word = [[NSString alloc] initWithString:aWord];
        tessFont = aFont;
        width = [aFont getWidthForString:word];
        height = [aFont getHeightForString:word];
        
        charObjects = [[NSMutableArray alloc] init];
        
        //Split word into characters
        for(int i = 0; i < [aWord length]; i++)
        {
            OKCharObject *charObj = [[OKCharObject alloc] initWithChar:[NSString stringWithFormat:@"%C", [aWord characterAtIndex:i]] withFont:aFont];
            [charObjects addObject:charObj];
            [charObj release];
        }
        
        x = 0.0f;
        y = 0.0f;
    }
    return self;
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

- (void) setPosition:(OKPoint)aPos
{    
    [self setX:aPos.x];
    [self setY:aPos.y];
}

- (void) setAbsolutePosition:(OKPoint)aPoint
{
    absPos = aPoint;
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

- (void) drawWord
{
    [tessFont drawStringAt:OKPointMake(x, y, 800.0) withString:word andDetail:3];
}

- (void) drawChars
{
    for(OKCharObject *charObj in charObjects)
    {
        [charObj drawChar];
    }
}

- (OKPoint) getCenter
{
    return OKPointMake(width/2, height/2, 0);
}

#pragma mark dealloc
- (void)dealloc
{
    [word release];
	[charObjects release];
	[super dealloc];
}

@end
