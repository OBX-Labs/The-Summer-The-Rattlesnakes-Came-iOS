//
//  OKSentenceObject.m
//  Smooth
//
//  Created by Christian Gratton on 11-06-28.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import "OKSentenceObject.h"
#import "OKWordObject.h"
#import "OKCharObject.h"

@implementation OKSentenceObject
@synthesize sentence, wordObjects, tessFont;

- (id) initWithSentence:(NSString*)aSentence withTessFont:(OKTessFont*)aTess
{
    self = [self init];
	if (self != nil)
	{
        sentence = [[NSString alloc] initWithString:aSentence];
        tessFont = aTess;
        width = [aTess getWidthForString:sentence];
        height = [aTess getHeightForString:sentence];
                
        wordObjects = [[NSMutableArray alloc] init];
                
        //Split sentence into words
        NSArray *temp = [aSentence componentsSeparatedByString:@" "];
        
        for(int i = 0; i < [temp count]; i++)
        {
            OKWordObject *word = [[OKWordObject alloc] initWithWord:[temp objectAtIndex:i] withFont:aTess];
            [wordObjects addObject:word];
            [word release];
        }
        
        //set positions
        x = 0;
        y = 0;
        
        OKPoint wordPoint = OKPointMake(-width/2, 0, 0);
        for(OKWordObject *wordObj in wordObjects)
        {
            float wordWidth = [wordObj getWitdh];
            [wordObj setPosition:OKPointMake(wordPoint.x+wordWidth/2, wordPoint.y, wordPoint.z)];
             
            OKPoint charPoint = OKPointMake(-wordWidth/2, 0, 0);
            OKCharObject* prevCharObj = nil;
            for(OKCharObject *charObj in wordObj.charObjects)
            {
                [charObj setPosition:OKPointMake(charPoint.x, charPoint.y, 0)];
                charPoint.x += [aTess getXAdvanceForString:charObj.glyph] - (prevCharObj == nil ? 0 : [aTess getKerningForLetter:charObj.glyph withPreviousLetter:prevCharObj.glyph]);
                prevCharObj = charObj;
            }
            prevCharObj = nil;
            //space
            wordPoint.x += wordWidth + [aTess getWidthForString:@" "];
        }
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
    absPos = [tessFont getPositionAbsolute:aPos withString:sentence];
    
    [self setX:aPos.x];
    [self setY:aPos.y];
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

- (OKPoint) getCenter
{
    return OKPointMake(width/2, height/2, 0);
}

#pragma mark dealloc
- (void)dealloc
{
    [sentence release];
    [wordObjects release];
	[super dealloc];
}

@end
