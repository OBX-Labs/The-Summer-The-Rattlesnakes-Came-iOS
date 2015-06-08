//
//  KineticObject.h
//  Choice
//
//  Created by Christian Gratton on 11-11-14.
//  Copyright (c) 2011 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKGeometry.h"

@interface KineticObject : NSObject
{
    long age; //age in mllis
    BOOL dead;
    
    OKPoint pos; //position
    OKPoint pPos; // Previous position
    OKPoint vel; //velocity
    OKPoint origVel; //original velocity
    OKPoint acc; //acceleration
    float friction; //friction
    OKPoint target; //target
    float speed; //speed
    
    float angAcc;  //angular acceleration
    float angVel;  //angular velocity
    float ang;     //angle/forward direction
    float angFriction; //angular friction
    
    float pSca;
    float sca;
    float scaTarget;
    float scaAcc;
    float scaVel;
    float scaSpeed;
    float scaFriction;
    
    OKPoint screenPos;
    
    // Counter scroll
    OKPoint csPos;
}

@property (nonatomic) float friction;
@property (nonatomic) OKPoint pos;
@property (nonatomic) OKPoint acc;
@property (nonatomic) OKPoint vel;
@property (nonatomic) OKPoint origVel;
@property (nonatomic) float pSca;
@property (nonatomic) float sca;

- (id) init;

- (void) update:(long)dt;
- (void) updatePosition;
- (void) updateRotation;
- (void) updateScale;
- (void) approachScale:(float)aTarget speed:(float)aSpeed friction:(float)aFriction;
- (void) setScale:(float)aScale;
- (float) getScale;
- (void) pushX:(float)aX y:(float)aY z:(float)aZ;
- (void) push:(OKPoint)aPoint;
- (void) spin:(float)aF;
- (void) setPosX:(float)aX y:(float)aY z:(float)aZ;
- (void) setPos:(OKPoint)aPoint;
- (void) moveByX:(float)aX y:(float)aY z:(float)aZ;
- (void) moveBy:(OKPoint)aPoint;
- (void) approachX:(float)aX y:(float)aY z:(float)aZ s:(float)aS;
- (void) approachX:(float)aX y:(float)aY z:(float)aZ s:(float)aS f:(float)aF;
- (void) setFriction:(float)aF af:(float)aAF;
- (long) getAge;
- (void) kill;
- (BOOL) isDead;

@end
