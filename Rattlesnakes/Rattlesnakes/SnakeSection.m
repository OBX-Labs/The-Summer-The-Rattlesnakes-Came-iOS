//
//  SnakeSection.m
//  Rattlesnakes
//
//  Created by Serge on 2013-05-06.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#include <mach/mach.h>
#include <mach/mach_time.h>
#import "SnakeSection.h"

@implementation SnakeSection

@synthesize origParticle, particle;

- (id) initWithId: (int)aSectionId{
    
    self = [super init];
    if(self)
    {
        sectionId=aSectionId;
        retract = FALSE;
    }
    return self;
}

//
// Set retract behavior properties.
//
-(void) setRetract:(int) aDirection delay:(int)aDelay wave:(int)aWave speed:(float)aSpeed {
    retractDirection = aDirection;
    retractDelay = aDelay;
    retractWave = aWave;
    retractSpeed = aSpeed;
}

//
// Stop retracting.
//
-(void) stopRetract {
    retract = FALSE;
}


//
// Start retracting.
// @param direction direction of the snake, head position
//
- (void) startRetract {
    retract = TRUE;
    retractStart = [self getMillis];

}


- (void) update
{
    //get the index of the section in the snake, position from the head
    int index = sectionId;
    
    //each section of a snake starts retracting at a different time
    //make sure that we reached the good time for this section
    long long nowTime = [self getMillis];
    if(retractStart + retractDelay + index*retractWave > nowTime)return;
    
    //move linearly towards the origin
    retractDistance.x=origParticle.position.x-particle.position.x;
    retractDistance.y=origParticle.position.y-particle.position.y;
    
    float lenght = (float)[particle distanceToParticleReal:origParticle];
    
    //we're close enough, done.
    if(lenght < 1){
        [particle setVelocity:CMTPVector3DMake(0,0,0)];
        [self stopRetract];
        return;
    }
 
    
    //move the particle that control the position of the section
    retractDistance = CMTPVector3DMakeWithStartAndEndVectors(particle.position, origParticle.position);
    CMTPVector3DScaleBy(retractDistance, (float)retractSpeed/lenght*(nowTime-retractStart-retractDelay-index*retractWave)/100);
    particle.velocity = CMTPVector3DAdd(particle.velocity, retractDistance);
    
}


//
// Reset the section.
//
-(void)reset {
    [particle setVelocity:CMTPVector3DMake(0,0,0)];
    [particle setPosition:origParticle.position];
    [self stopRetract];
}


//
//  Get current ms time
//
-(long long) getMillis{
    
    //long long nowMillis = (long long)([[NSDate date] timeIntervalSince1970])*1000;
    
    static mach_timebase_info_data_t sTimebaseInfo;
    uint64_t machTime = mach_absolute_time();
    
    // Convert to nanoseconds - if this is the first time we've run, get the timebase.
    if (sTimebaseInfo.denom == 0 )
    {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    // Convert the mach time to milliseconds
    uint64_t millis = ((machTime / 1000000) * sTimebaseInfo.numer) / sTimebaseInfo.denom;
    
    long long nowMillis = (long long)millis;
    return nowMillis;
}

@end
