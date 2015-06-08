//
//  SnakeSection.h
//  Rattlesnakes
//
//  Created by Serge on 2013-05-06.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMTraerPhysics.h"

@interface SnakeSection : NSObject
{
    int sectionId;   //id of the section (usually its index in the snake)
    
    CMTPParticle *particle;
    CMTPParticle *origParticle;
    BOOL retract;			//true if the section is retracting
    CMTPVector3D retractDistance;   //used during the retract behavior
    int retractDirection;		//direction of the snake, used to get the position from the head
    long long retractStart;
    float retractSpeed;			//speed at which the snake retracts
    int retractDelay;			//delay until the snake retracts
    int retractWave;			//delay between letters to retract, wave effect
}

@property (nonatomic, retain) CMTPParticle *particle;
@property (nonatomic, retain) CMTPParticle *origParticle;

- (id) initWithId: (int)aSectionId;
- (void) setRetract:(int) aDirection delay:(int)aDelay wave:(int)aWave speed:(float)aSpeed;
- (void) stopRetract;
- (void) startRetract;
- (void) update;
- (void) reset;

@end
