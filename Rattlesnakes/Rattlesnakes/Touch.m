//
//  Touch.m
//  Rattlesnakes
//
//  Created by Serge on 2013-05-10.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "Touch.h"

@implementation Touch

@synthesize x, y, touchID, start, delay, bites;
/**
 * Constructor.
 * @param id id
 * @param x x position
 * @param y y position
 */
-(id) initWithTouch:(int)aTouchId x:(float)posx y:(float)posy start:(long long)touchStart delay:(int)touchDelay
{
    NSLog(@"Init touch: %f, %f", posx, posy);
    touchId = aTouchId;
    x = posx;
    y = posy;
    start = touchStart;
    delay = touchDelay;
    bites = 0;
    
    return self;
}

/**
 * Set the position.
 * @param x x position
 * @param y y position
 */
-(void) set:(float)posx y:(float) posy {
    x = posx;
    y = posy;
}


-(float) getX
{
    return x;
}


-(float) getY{
    return y;
}

-(int) getTouchId{
    return touchId;
}

@end
