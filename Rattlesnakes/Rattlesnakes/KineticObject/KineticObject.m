//
//  KineticObject.m
//  Choice
//
//  Created by Christian Gratton on 11-11-14.
//  Copyright (c) 2011 Christian Gratton. All rights reserved.
//

#import "KineticObject.h"

@implementation KineticObject
@synthesize friction, pos, acc, vel, origVel, pSca, sca;

- (id) init
{
    self = [super init];
	if(self)
    {
		age = 0;
        dead = NO;
        
        ang = 0;
        angAcc = 0;
        angVel = 0;
        
        scaTarget = pSca = sca = 1;
        scaAcc = scaVel = 0;
        scaSpeed = 0;
        scaFriction = 0;
        
        //default to no friction
        friction = 1;
        angFriction = 1;
	}
	return self;
}

- (void) update:(long)dt
{
    //grow old
    age += dt;
    
    //apply motion
    [self updatePosition];
    
    //apply rotation
    [self updateRotation];
    
    //apply scale
    [self updateScale];
}

- (void) updatePosition
{
    // Previous pos
    pPos = pos;
    
    //get distance to target
	float dx = target.x - pos.x;
	float dy = target.y - pos.y;
	float d = sqrt(pow(dx, 2) + pow(dy, 2));
	
	if (d != 0)
	{
        OKPoint diff = OKPointGet(target);
        diff = OKPointSub(diff, pos);
        
        if(OKPointMag(diff) > speed)
        {
            diff = OKPointDivf(diff, OKPointMag(diff));
            diff = OKPointMultf(diff, speed);
            acc = OKPointAdd(acc, diff);
        }
        else
        {
            vel = OKPointMultf(vel, friction);
            pos = OKPointSet(target);
        }
	}
	else
	{
		target = OKPointSet(pos);
	}
    
    vel = OKPointAdd(vel, acc);
    acc = OKPointMake(0, 0, 0);
    
    vel = OKPointMultf(vel, friction);
    
    pos = OKPointAdd(pos, vel);
}

- (void) updateRotation
{
    //apply angular acceleration
    angVel += angAcc;
    angAcc = 0;
    
    //apply friction
    angVel *= angFriction; 
    
    //apply angular velocity
    ang += angVel;
}

- (void) updateScale
{
    if (scaTarget == sca) return;
    
    float diff = scaTarget - sca;
    int dir = diff < 0 ? -1 : 1;
    scaAcc = diff/(dir*diff)*scaSpeed;
    scaVel += scaAcc;
    scaAcc = 0;
    
    pSca = sca;
    
    if (diff*dir < scaSpeed)
        sca = scaTarget;
    else
        sca += scaVel;
    
    scaVel *= scaFriction;
}

- (void) approachScale:(float)aTarget speed:(float)aSpeed friction:(float)aFriction
{
    scaTarget = aTarget;
    scaSpeed = aSpeed;
    scaFriction = aFriction;
}

- (void) setScale:(float)aScale
{
    scaTarget = sca = aScale;
}

- (float) getScale
{
    return sca;
}

- (void) pushX:(float)aX y:(float)aY z:(float)aZ
{
    acc.x += aX;
    acc.y += aY;
    acc.z += aZ;
    target = OKPointSet(pos);
}

- (void) push:(OKPoint)aPoint
{
    acc.x += aPoint.x;
    acc.y += aPoint.y;
    acc.z += aPoint.z;
    target = OKPointSet(pos);
}

- (void) spin:(float)aF
{
    angAcc += aF;//(aF * 20);
}

- (void) setPosX:(float)aX y:(float)aY z:(float)aZ
{
    pos = OKPointMake(aX, aY, aZ);
    target = OKPointSet(pos);
}

- (void) setPos:(OKPoint)aPoint
{
    pos = OKPointMake(aPoint.x, aPoint.y, aPoint.z);
    target = OKPointSet(pos);
}

- (void) moveByX:(float)aX y:(float)aY z:(float)aZ
{
    pos.x += aX; 
    pos.y += aY;
    pos.z += aZ;
    target = OKPointSet(pos);
}

- (void) moveBy:(OKPoint)aPoint
{
    pos.x += aPoint.x; 
    pos.y += aPoint.y;
    pos.z += aPoint.z;
    target = OKPointSet(pos);
}

- (void) approachX:(float)aX y:(float)aY z:(float)aZ s:(float)aS
{
    
    target = OKPointMake(aX, aY, aZ);    
    speed = aS;
}

- (void) approachX:(float)aX y:(float)aY z:(float)aZ s:(float)aS f:(float)aF
{
    [self approachX:aX y:aY z:aZ s:aS];
    friction = aF;
}

- (void) setFriction:(float)aF af:(float)aAF
{
    friction = aF;
    angFriction = aAF;
}

- (long) getAge
{
    return age;
}

- (void) kill
{
    dead = YES;
    angAcc = angVel = 0;
    acc = OKPointMake(0, 0, 0);
    vel = OKPointMake(0, 0, 0);
    age = 0;
}

- (BOOL) isDead
{
    return dead;
}

- (void)dealloc
{	
    [super dealloc];
}

@end
