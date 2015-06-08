//
//  BezierPath.m
//  
//
//  Created by Serge on 2013-05-16.
//
//

#import "BezierPath.h"

@implementation BezierPath

-(id) initWithPositions:(float)sx sy:(float)sy c1x:(float)c1x c1y:(float)c1y c2x:(float)c2x c2y:(float)c2y ex:(float)ex ey:(float)ey
{
    
    s = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:sx], [NSNumber numberWithFloat:sy], nil];
    c1 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:c1x], [NSNumber numberWithFloat:c1y], nil];
    c2 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:c2x], [NSNumber numberWithFloat:c2y], nil];
    e = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:ex], [NSNumber numberWithFloat:ey], nil];
    t=0;
    d = FORWARD;
    spd = 0.004f;
    
}

//
// Set the path direction to move backwards.
//
-(void) reverse { d = BACKWARD; }


/**
 * Update the current position on the path.
 */
-(void) update {
    //if we reached the end, nothing to do
    if ([self done]) return;
    
    //increment position
    t += spd;
    if (t > 1.0) t = 1.0f;
}

/**
 * Check if the position reached the end of the path.
 * @return true of the position reached the end
 */
-(BOOL) done {
    return t == 1.0f;
}

/**
 * Set the position to the end of the path.
 */
-(void) end { t = 1.0f; }

/**
 * Get the current x position on the path.
 * @return x position
 */
//-(float) x { return p.bezierPoint(s[0], c1[0], c2[0], e[0], d==PathDirection.BACKWARD?1-t:t); }


/**
 * Get the current y position on the path.
 * @return y position
 */
//public float y() { return p.bezierPoint(s[1], c1[1], c2[1], e[1], d==PathDirection.BACKWARD?1-t:t); }


/**
 * Draw the bezier path.
 */
//public void draw() { p.bezier(s[0], s[1], c1[0], c1[1], c2[0], c2[1], e[0], e[1]); }



@end
