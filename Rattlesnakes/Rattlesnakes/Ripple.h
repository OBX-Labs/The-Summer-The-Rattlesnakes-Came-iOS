//
//  Ripple.h
//  Rattlesnakes
//
//  Created by Serge on 2013-06-28.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "CMTraerPhysics.h"

@interface Ripple : NSObject
{
    CMTPVector3D center; //PVector center;	//center location
	float radius;	//radius
	float speed;	//growth speed
    float maxRadius;
    
}

@property (nonatomic) CMTPVector3D center;
@property (nonatomic) float radius;
@property (nonatomic) float maxRadius;

-(id) initWithPosition:(float)x y:(float)y s:(float)s maxRadius:(float)maxRadius;
-(BOOL) update;

@end
