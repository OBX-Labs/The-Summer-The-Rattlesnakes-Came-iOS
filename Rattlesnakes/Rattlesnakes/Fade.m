//
//  Fade.m
//  Rattlesnakes
//
//  Created by Serge on 2013-06-05.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "Fade.h"

@implementation Fade


-(id) initWithSample:(AVAudioPlayer*)aSample to:(float)aTo in:(int)aIn delay:(int)aDelay stopWhenDone:(BOOL)aStopWhenDone{

    sample = aSample;
    from = [aSample volume];
    to = aTo;
    in = aIn;
    stopWhenDone = aStopWhenDone;
    start =  [self getMillis] + aDelay;
    done = false;
    return self;
}

//
// Update
//
-(void) update {
    //already done? nothing to do
    if (done) return;
    
    //check if we reached the start time for the fade
    long long duration = [self getMillis] - start;
    if (duration < 0) return;
    
    //if we're done, set the volume to final target volume
    if (duration >= (long long)in) {
        [sample setVolume:to];

        if(stopWhenDone)
           [sample stop];
        done = true;
        return;
    }
    //if we're still in the fade duration, adjust the volume
    else {
        float volume = from + ((float)duration/(float)in)*(to-from);
        [sample setVolume:volume];
    }
}

/**
 * Check if the fade is done.
 */
-(BOOL)isDone { return done; }


-(long long) getMillis{
    
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
