//
//  Ripple.m
//  Rattlesnakes
//
//  Created by Serge on 2013-06-28.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "Ripple.h"

#define DEGREES_TO_RADIANS(x) (3.14159265358979323846 * x / 180.0)
#define RANDOM_FLOAT_BETWEEN(x, y) (((float) rand() / RAND_MAX) * (y - x) + x)

@implementation Ripple

@synthesize center, radius, maxRadius;

/**
 * Constructor.
 * @param x x coordinate of the center
 * @param y y coordinate of the center
 * @param s speed
 */
-(id) initWithPosition:(float)x y:(float)y s:(float)s maxRadius:(float)aMaxRadius{
    
    self = [super init];
    if(self){
        center = CMTPVector3DMake(x, y, 0);
        speed = s;
        radius = 50;
        maxRadius = aMaxRadius;
    }
    return self;
}

/**
 * Update the ripple, make it grow. If ripple got to max Radius, return false
 */
-(BOOL) update {
    
    //NSLog(@"Update ripple");
    radius += speed;
    
    if(radius>maxRadius)
        return false;
    
    //draw a circle for degug purpose
   /*
    GLfloat vertices[720];
    for (int i = 0; i < 720; i += 2) {
        // x value
        vertices[i]   = (cos(DEGREES_TO_RADIANS(i)) * radius);
        // y value
        vertices[i+1] = (sin(DEGREES_TO_RADIANS(i)) * radius);
    }
    glPushMatrix();
    glTranslatef(center.x, center.y, center.z);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColor4f(1.0f, 0.0f, 0.0f, 0.1);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 360);
    glPopMatrix();
     */
    
    return true;
}

@end
