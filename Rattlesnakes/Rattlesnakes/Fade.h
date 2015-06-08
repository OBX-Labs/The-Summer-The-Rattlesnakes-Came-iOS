//
//  Fade.h
//  Rattlesnakes
//
//  Created by Serge on 2013-06-05.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

@interface Fade : NSObject
{
    AVAudioPlayer *sample;	//the sample
    float from, to;			//from and to volumes
    int in;					//duration
    long long start;		//when to start in millis
    BOOL stopWhenDone;      //flag to stop the sample when done fading
    BOOL done;
}

-(id) initWithSample:(AVAudioPlayer*)aSample to:(float)aTo in:(int)aIn delay:(int)aDelay stopWhenDone:(BOOL)aStopWhenDone;
-(void) update;
-(long long) getMillis;
-(BOOL)isDone;

@end
