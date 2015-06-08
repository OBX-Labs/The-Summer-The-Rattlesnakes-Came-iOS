//
//  SoundManager.m
//  Rattlesnakes
//
//  Created by Serge on 2013-06-04.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "SoundManager.h"
#import "Fade.h"

@implementation SoundManager

@synthesize player;

-(id) init
{
    firstStrike = nil;
    shiftingSamples = [[NSMutableArray alloc] init];
    
    currentThreat = nil;
    currentThreatStart = -1;
    nextThreatTime = 0;
    activeThreats = FALSE;
    threatVolume = 1;
    
    return self;
}

// Load ambient samples from a folder.
// @param folder
//
-(void) loadAmbientSamples:(NSString*) folder {
    ambientSamples = [self loadSamples:folder];
}


// Load threat samples from a folder.
// @param folder
// @param volume
//
-(void) loadThreatSamples:(NSString*)folder volume:(float) volume {
    threatSamples = [self loadSamples:folder];
    threatVolume = volume;
}


//
// Load rattle samples from a folder.
// @param folder
//
-(void) loadRattleSamples:(NSString*) folder {
    
    rattleSamples = [self loadSamples:folder];
    usedRattleSamples = [[NSMutableArray alloc] init];    
    rattleReleaseQueue = [[NSMutableArray alloc] init];
}

//
// Load samples from a folder.
// @param folder
// @return list of loaded samples (mp3 only)
//
-(NSMutableArray*) loadSamples:(NSString*) folder {
    //read sound files
    NSArray *files = [self aifFilesInDirectory:folder];

    if(!files)
        return nil;
    
    //SystemSoundID aSound;
    NSMutableArray *soundsToLoad = [[NSMutableArray alloc]init];
    
    for(NSString* aFileName in files) {
        
        //if file is not mp3 format, skip
        if([[aFileName pathExtension] compare: @"mp3"] != NSOrderedSame)
            continue;
        
        NSString *aString = [NSString stringWithFormat:@"%@%@", folder, aFileName];
        NSURL *filePath = [NSURL fileURLWithPath:aString isDirectory:NO];
        NSLog(@"%@", aString);
        AVAudioPlayer *theAudio;
        theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
        if(theAudio)
            [soundsToLoad addObject:theAudio];

    }
    
    return soundsToLoad;
    
}


//
// Load strike samples from a folder, and find first strike.
// @param folder folder to search in
// @param first name of the first strike
//
-(void) loadStrikeSamples:(NSString*) folder first:(NSString*)first {
    
    NSLog(@"This is first sample: %@", first);
    strikeSamples = [self loadSamples:folder];

    NSArray *files = [self aifFilesInDirectory:folder];
    
    if(!files)
        return;
    
    //SystemSoundID aSound;
    NSMutableArray *soundsToLoad = [[NSMutableArray alloc]init];
    for(NSString* aFileName in files) {
        NSString *aString = [NSString stringWithFormat:@"%@%@", folder, aFileName];
        NSURL *filePath = [NSURL fileURLWithPath:aString isDirectory:NO];
        NSLog(@"%@", aString);
        AVAudioPlayer *theAudio;
        theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
        [soundsToLoad addObject:theAudio];
        
        if([aFileName isEqualToString:first]){
            NSLog(@"Setting first strike audio:%@", aFileName);
            firstStrike = theAudio;
        }
    }
    
    usedStrikeSamples = [[NSMutableArray alloc] init];
    strikeReleaseQueue = [[NSMutableArray alloc] init];

}

//
//Get the path to an ambient sample file.
//@param file
//@return path
//
-(NSString*) ambientPath:(NSString*) file {      
    NSString *path = [NSString stringWithFormat: @"%@/Sounds/ambient/%@", [[NSBundle mainBundle] resourcePath], file];
    return path;

}

//
//Get the path to a threat sample file.
//@param file
//@return path
//
-(NSString*) threatPath:(NSString*) file {
    NSString *path = [NSString stringWithFormat: @"%@/Sounds/threat/%@", [[NSBundle mainBundle] resourcePath], file];
    return path;
}

//
//Get the path to a rattle sample file.
//@param file
//@return path
//
-(NSString*) rattlePath:(NSString*) file {
    NSString *path = [NSString stringWithFormat: @"%@/Sounds/rattle/%@", [[NSBundle mainBundle] resourcePath], file];
    return path;
}

//
//Get the path to a strike sample file.
//@param file
//@return path
//
-(NSString*) strikePath:(NSString*) file {
    NSString *path = [NSString stringWithFormat: @"%@/Sounds/strike/%@", [[NSBundle mainBundle] resourcePath], file];
    return path;
}


//
//Get a list of exclusive rattles, which won't be assigned again until released.
//@param n number of rattles
//@return list of rattles
//
-(NSMutableArray*) exclusiveRattles:(int) n {
   
    NSMutableArray *samples = [[NSMutableArray alloc] init];
        
    for( int i=0; i< n && [rattleSamples count]!=0; i++){
        int randIndex = arc4random() % [rattleSamples count];  //get value from 0 to count-1
        NSLog(@"Addind randIndex: %d", randIndex);
        [samples addObject:[rattleSamples objectAtIndex:randIndex]];
        NSLog(@"TEST 1");
        [rattleSamples removeObjectAtIndex:randIndex];
         NSLog(@"TEST 2");
    }
    
    
    [usedRattleSamples addObjectsFromArray:samples];
    NSLog(@"samples count:%d", [samples count]);
    return samples;

}

//
//Release a list of rattle samples
//@param samples samples to release
//
-(void) releaseRattles:(NSMutableArray*)samples {
    
    NSMutableArray *discardedItems = [NSMutableArray array];
    
    for(AVAudioPlayer *s in samples){
        for(AVAudioPlayer *usedSample in usedRattleSamples){
            if([usedSample isEqual:s]){
                [discardedItems addObject:s];
                [rattleSamples addObject:s];
            }
        }
    }
    [usedRattleSamples removeObjectsInArray:discardedItems];
    
}


//
//Fade out and release a list of rattle samples.
//@param samples samples to fade and release
//@param duration fade duration
//@param delay delay before fade
//
-(void) fadeOutAndReleaseRattles:(NSMutableArray*)samples duration:(int)duration delay:(int) delay {
    
    //add samples to shift queue
    for(AVAudioPlayer *s in samples){
        Fade *aFade = [[Fade alloc] initWithSample:s to:0 in:duration delay:delay stopWhenDone:TRUE];
        [shiftingSamples addObject:aFade];
    }
    
    //add samples to release rattle queue
    [rattleReleaseQueue addObjectsFromArray:samples];
}

//
//Get a random threat sample.
//@return
//
-(AVAudioPlayer*) randomThreat{
    
    if(!threatSamples)
        return nil;
    
    int randSample = arc4random() % [threatSamples count];
    return [threatSamples objectAtIndex:randSample];

}


//
//Get a list of exclusive strike samples, which won't be assigned again until released.
//@param n number of samples
//@return list of samples
//
-(NSMutableArray*) exclusiveStrikes:(int) n {
    
    if(!strikeSamples)
        return nil;
    
    NSMutableArray *samples = [NSMutableArray array];
    
    for( int i=0; i< n && [strikeSamples count]!=0; i++){
        int randIndex = arc4random() % [strikeSamples count];  //get value from 0 to count-1
        [samples addObject:[strikeSamples objectAtIndex:randIndex]];
        [strikeSamples removeObjectAtIndex:randIndex];
    }
    
    [usedStrikeSamples addObjectsFromArray:samples];
    return samples;
}


//
//Get the exclusive first strike sample.
//@return sample
//

-(AVAudioPlayer*) exclusiveFirstStrike {
    
    if(!strikeSamples)
        return nil;
    
    NSMutableArray *discardedItems = [NSMutableArray array];
    for(AVAudioPlayer* s in strikeSamples){
        if([s isEqual:firstStrike]){
             NSLog(@"is Equal");
            [discardedItems addObject:s];
            [usedStrikeSamples addObject:s];
        }
    }
    NSLog(@"Exclusive First Strike");
    [strikeSamples removeObjectsInArray:discardedItems];
    return firstStrike;
}



//
//Release a list of strike samples.
//@param samples
//
-(void) releaseStrikes:(NSMutableArray*) samples {
    
    NSMutableArray *discardedItems = [NSMutableArray array];

    for(AVAudioPlayer *s in samples){
        for(AVAudioPlayer *strike in usedStrikeSamples){
            if([strike isEqual:s]){
                [discardedItems addObject:s];
                [strikeSamples addObject:s];
            }
        }
    }
    [usedStrikeSamples removeObjectsInArray:discardedItems];
   
}


//
//Fade out and release a list of strike samples.
//@param samples samples to fade and release
//@param duration fade duration
//
-(void) fadeOutAndReleaseStrikes:(NSMutableArray*) samples duration:(int) duration {
    
     //add samples to shift queue
    for(AVAudioPlayer *s in samples){
        Fade *aFade = [[Fade alloc] initWithSample:s to:0 in:duration delay:0 stopWhenDone:TRUE];
        [shiftingSamples addObject:aFade];
    }
    
     //add samples to release strike queue
    [strikeReleaseQueue addObjectsFromArray:samples];
}


//
//Get the ambient sample at the specified index.
//@param index
//@return sample
//

-(AVAudioPlayer*) ambient:(int)index {
    if (index < 0) return nil;
    if (index >= [ambientSamples count]) return nil;
    
    return [ambientSamples objectAtIndex:index];
}
 


//
//Repeat ambient sample at the specified index.
//@param index
//@param volume
//
-(void) repeatAmbient:(int) index volume:(float) volume {
    //repeatAmbient(index, volume, -1);
    [self repeatAmbient:index volume:volume];
}


//
//Repeat ambient sample at the specified index for a number of times.
//@param index
//@param volume
//@param repeats number of times to repeat
//
-(void) repeatAmbient:(int) index volume:(float) volume repeats:(int) repeats {

    if (index < 0) return;
    if (index >= [ambientSamples count]) return;
    
    AVAudioPlayer *s = [ambientSamples objectAtIndex:index];
    [s setVolume:volume];

    [s setNumberOfLoops:repeats];
}


//
//Fade ambient sample at specified index.
//@param index
//@param to fade to volume
// @param duration fade duration
//@param stopWhenDone true to stop the sample when done fading
//
-(void) fadeAmbient:(int) index to:(float)to duration:(int) duration stopwhendone:(BOOL) stopWhenDone {
    //the ambient
    AVAudioPlayer *s = [ambientSamples objectAtIndex:index];
    
    //add samples to shift queue
    Fade *aFade = [[Fade alloc] initWithSample:s to:to in:duration delay:0 stopWhenDone:stopWhenDone];
    [shiftingSamples addObject:aFade];
   
}


//
//Fade and repeat ambient at specified index.
//@param index
//@param to fade to volume
//@param duration fade duration
//
-(void) fadeInAndRepeatAmbient:(int)index to:(float)to duration:(int) duration {
    
    AVAudioPlayer *s = [ambientSamples objectAtIndex:index];
    
    //setup fade for the sample
    Fade *aFade = [[Fade alloc] initWithSample:s to:to in:duration delay:0 stopWhenDone:FALSE];
    [shiftingSamples addObject:aFade];
    
    //make it repeat
    [s setNumberOfLoops:-1];
    [s play];
}


//
//Update the samples.
//
-(void) update {
    
    //update the shifting samples
    NSMutableArray *discardedItems = [NSMutableArray array];
    for(Fade* aFade in shiftingSamples){
        [aFade update];
        if([aFade isDone]){
           [discardedItems addObject:aFade];
        }
    }
    [shiftingSamples removeObjectsInArray:discardedItems];
      
    [discardedItems removeAllObjects];
    for(AVAudioPlayer *anAudio in rattleReleaseQueue){
        if(![anAudio isPlaying]){
            [rattleSamples addObject:anAudio];
            [discardedItems addObject:anAudio];
        }
    }
    [rattleReleaseQueue removeObjectsInArray:discardedItems];
        
       
    [discardedItems removeAllObjects];
    for(AVAudioPlayer *anAudio in strikeReleaseQueue){
        if(![anAudio isPlaying]){
            [strikeSamples addObject:anAudio];
            [discardedItems addObject:anAudio];
        }
    }
    [strikeReleaseQueue removeObjectsInArray:discardedItems];

    //update threats
    if(activeThreats){
        
        if(currentThreat==nil && [self getMillis]>nextThreatTime){
            
            if(currentThreatStart==-1)
                currentThreatStart = [self getMillis];
            float duration = (float)([self getMillis] - currentThreatStart)/45000;
            
            if(duration>1)
                duration=1;
            float volume = duration * threatVolume;
            currentThreat = [self randomThreat];
            currentThreat.volume = volume;
            [currentThreat play];
            //NSLog(@"Play a threat, duration=%f, volume=%f", duration, volume);
        }
        else if (currentThreat!=nil && ![currentThreat isPlaying]){
            currentThreat=nil;
            nextThreatTime = [self getMillis] + (int)arc4random() % 4000 + 4000;
        }
    }
}

//
//Start playing threat samples.
//
-(void) playThreats { activeThreats = true; }

//
//Stop playing theat samples.
//
-(void) stopThreats {
    if(currentThreat !=nil && [currentThreat isPlaying])
       [currentThreat stop];
    
    currentThreat = nil;
    currentThreatStart = -1;
    nextThreatTime = 0;
    
    activeThreats = FALSE;
    
}

//
// Stop the sound manager.
//
-(void) stop {
    //Sonia.stop();
}



/**
 * Get the list of files in a passed relative director.
 */
-(NSArray*) aifFilesInDirectory:(NSString*) dir {
   
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    
    NSLog(@"THERE ARE %d SAMPLES in %@", [directoryContent count], dir);
    return directoryContent;
    return nil;
}

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
