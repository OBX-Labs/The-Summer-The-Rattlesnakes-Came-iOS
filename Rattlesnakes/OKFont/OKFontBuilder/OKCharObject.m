//
//  OKCharObject.m
//  Smooth
//
//  Created by Christian Gratton on 11-06-28.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import "OKCharObject.h"

@implementation OKCharObject
@synthesize glyph;

- (id) initWithChar:(NSString*)aChar withFont:(OKTessFont*)aFont
{
    self = [self init];
    if (self != nil)
    {
        glyph = [[NSString alloc] initWithString:aChar];
        tessFont = aFont;
        
        if([glyph isEqualToString:@" "])
        {
            width = [aFont getWidthForString:@" "];            
            height = [aFont getHeightForString:@"L"]; // L because it seems to be the highest letter
        }
        else
        {
            width = [aFont getWidthForString:glyph];
            height = [aFont getHeightForString:glyph];
        }
        
        OKCharDef* charDef = [aFont getCharDefForChar:glyph];
        xOffset = [charDef xOffset];
        yOffset = [charDef yOffset];
        [charDef release];
                
        kerning = 0.0f;
        x = 0.0f;
        y = 0.0f;
        
        
        visible = NO;
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

- (void) setKerning:(float)aKerning
{
    kerning = aKerning;
}

- (void) setX:(float)aX
{
    x = aX;
}

- (void) setY:(float)aY
{
    y = aY;
}

- (void) setVisible:(BOOL)isVisible
{
    visible = isVisible;
}

- (void) setPosition:(OKPoint)aPos
{
    [self setX:aPos.x];
    [self setY:aPos.y];
    absPos = aPos;
}

- (void) setAbsolutePosition:(OKPoint)aPoint
{
    absPos = aPoint;
}

- (void) setRelativePosition:(OKPoint)aPoint
{
    [self setX:aPoint.x];
    [self setY:aPoint.y];
    relPos = aPoint;
}

/*- (void) setXOffset:(float)aXOffset
{
    xOffset += aXOffset;
}*/

#pragma mark getters

- (float) getWitdh
{
    return width;
}

- (float) getHeight
{
    return height;
}

- (float) getKerning
{
    return kerning;
}

- (float) getX
{
    return x;
}

- (float) getY
{
    return y;
}

- (float) getXOffset
{
    return xOffset;
}

- (float) getYOffset
{
    return yOffset;
}

- (float) getMinX
{
    return [self getLocalBoundingBox].origin.x - [self getWitdh]/2.0f;
}

- (float) getMaxX
{
    return [self getMinX] + [self getWitdh];
}

- (float) getMinY
{
    return [self getLocalBoundingBox].origin.y - [self getHeight]/2.0f;
}

- (float) getMaxY
{
    return [self getMinY] + [self getHeight];
}

#pragma mark draw

- (void) detach
{
    [self setTarget];
    detached = YES;
}

- (void) unspool:(OKPoint)aPoint
{
    x = (aPoint.x + xOffset);
    y = (aPoint.y);
}

- (void) spool
{
    xOffset = 0.0f;
    visible = NO;
}

- (void) drawChar
{
    if(visible)
    {
        [tessFont drawStringAt:OKPointMake(x, y, 800.0) withString:glyph andDetail:3];
        
//        if(detached)
//            [self wander];
    }
}

- (void) setTarget
{
    float angle = (((arc4random() % 101)/100.0f) * (M_PI*2));
    
    target = OKPointMake((512.0 - cosf(angle) * 50.0), (384.0 - sinf(angle) * 50.0), 800.0);
}

- (void) applyFriction
{
    float diff;
    float delta;
    float direction;
    
    float smooth = 0.98 - friction;
    if(smooth < 0)
		smooth *= -1;
    
	//friction
	diff = 0.98 - smooth;
	if(diff != 0)
	{
		delta = smooth * (1.0/10.0);
		
		direction = diff < 0 ? -1 : 1;
		
		if((diff * direction) < delta)
			friction = smooth;
		else
			friction += (delta * direction);
	}
}

- (void) wander
{
    //get distance to target
	float dx = target.x - x;
	float dy = target.y - y;		
	float d = sqrt(pow(dx, 2) + pow(dy, 2));
	
	if (d > 10)
	{
		dx *= (1/d) * 0.5; //get acceleration
		dy *= (1/d) * 0.5;
		velocityX += dx;  //apply acceleration
		velocityY += dy;
		velocityX *= friction; //friction
		velocityY *= friction;
		x += velocityX; //apply velocity
		y += velocityY;
	}
	else
	{
		[self setTarget];
	}
    
    [self applyFriction];
}

- (OKPoint) getCenter
{
    return OKPointMake((x + width/2), (y + height/2), 0);
}

- (OKPoint) getPositionAbsolute
{
    return OKPointMake(x, y, 0);
}

- (CGRect) getLocalBoundingBox
{
    //return CGRectMake(x, y, width, height);
    return CGRectMake(0.0, 0.0, width, height);
}

#pragma mark dealloc
- (void)dealloc
{
    [glyph release];
	[super dealloc];
}

@end
