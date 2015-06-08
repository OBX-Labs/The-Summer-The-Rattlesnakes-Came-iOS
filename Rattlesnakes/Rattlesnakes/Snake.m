//
//  snake.m
//  Rattlesnakes
//
//  Created by Serge on 2013-05-06.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "Snake.h"
#import "OKPoEMMProperties.h"

@implementation Snake

@synthesize rattleSamples;
@synthesize strikeSamples;

- (id) initWithId:(int)aSnakeId physics:(CMTPParticleSystem*)aPhysics text:(NSString*)aText font:(OKTessFont*)aFont sectionCount:(int)aSectionCount side:(int)aSide renderingBounds:(CGRect)aRenderingBounds {
    
    self = [super init];
    if(self)
    {
        rBounds = aRenderingBounds;
               
        side = aSide;
        text = aText;
              
        
        //set the Font
        pFont=aFont;
        
        //link to particle system setup in Rattlesnakes.m
        physics = aPhysics;
        
        //create the sections
        sections = [[NSMutableArray alloc] init];
        for(int i=0; i<aSectionCount; i++)
        {
            currentSnakeSection = [[SnakeSection alloc] initWithId:i];
            [sections addObject:currentSnakeSection];
        }
        
       //create the springs between sections
        sectionSprings = [[NSMutableArray alloc] initWithCapacity:sections.count-1];
        
        //build the letters of the snake
        [self buildLetters:side];
        
        //build the sections of the snake
        [self buildSections:side];
        
        //build the forces that control the letters
        [self buildForces];
       
        //create the prey and its controls
        prey = [physics makeParticleWithMass:100 position:CMTPVector3DMake(0, 0, 0)];
        [prey makeFixed];
        
        //create the attraction between head and prey
        preyAttraction = [physics makeAttractionBetweenParticleA:[self getHead] particleB:prey strength:0 minDistance:50];
        [preyAttraction turnOff];
        strengthMult = 7.69f;
        bitSoundPlayed = false;
        
        //init array for sound
        strikeSamples = [[NSMutableArray alloc] init];
        rattleSamples = [[NSMutableArray alloc] init];
        
        //the snake is not retracting by default
        retracting = false;
        
        //reset word contraction flag until snake bites
        bitWordContracted = false;
        
        executeRipple=false;
        
        snakeOutside = true;
        
    }
    return self;
}


- (void) buildLetters:(int)aSide
{
    //clean up the text, remove spaces
    //cleanText = text;
    cleanText = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
    //create a position for each letter
    int letterCount = cleanText.length;
    
    letterPositions = [[NSMutableArray alloc] init];

    //create a bounding box for each letter
    letterBounds = [[NSMutableArray alloc] init];
    
    //create the default letter scales
    //this is usually set using the setScales method afterwards
    letterScales = [[NSMutableArray alloc] init];
    for(int i = 0; i < letterCount; i++)
        [letterScales addObject:[NSNumber numberWithFloat:1.0f]];
        
    //counter in the clean string
    int iClean = 0;
    
    if(!lettersOfSnake)
        lettersOfSnake = [[NSMutableArray alloc] init];
    
    //loop through all letters in the original string
    for(int i = 0; i < text.length; i++) {
        
        //if the character is a space, we can skip it
        if([text characterAtIndex:i] == ' ')
            continue;
        
        //convert each character into a drawable glyph
        unichar aChar = [text characterAtIndex:i];
        NSString *aString;
        aString = [[NSString alloc] initWithCharacters:&aChar length:1];
        OKWordObject *aWordObject = [[OKWordObject alloc] initWithWord:aString withFont:pFont];
        
        Word *aWord = [[Word alloc] initWithWordForSnake:aWordObject font:pFont renderingBounds:rBounds];
                
        //add glyph to array
        [lettersOfSnake addObject:aWord];
        [letterPositions addObject:[physics makeParticleWithMass:0 position:CMTPVector3DMake(i*2,0,0)]];
    
        float letterWidth = 10;
        float letterHeight= 40;
        [letterBounds addObject:[NSValue valueWithCGRect:CGRectMake(-letterWidth/2, -letterHeight/2, letterWidth, letterHeight)]];
        
        //increment the clean string counter
        //iClean++;
    }
    

    
}

//
// Build the sections.
// @param side side of the snake's head (LEFT or RIGHT)
//
- (void) buildSections:(int)aSide
{
#warning - TO Complete IF
    if(aSide)
        [self buildSectionsRight];
    else
        [self buildSectionsLeft];

}


//
// Build the sections for a snake with the head on the left.
//
- (void) buildSectionsLeft
{
    
    //index of the last letter
    int last = letterPositions.count - 1;
    
    //width of the snake based on the first and last position of the letters
    CMTPParticle *pLast = [letterPositions objectAtIndex:last];
    CMTPParticle *pFirst = [letterPositions objectAtIndex:0];
    snakeWidth = (pLast.position.x - pFirst.position.x);

     NSLog(@"SnakeWidth Left: %f", snakeWidth);
    
    //go through the sections and create a particle in the particle system for each
    for(int i = 0; i < sections.count; i++) {
        //if it's not the section for the head, create a normal particle
        currentSnakeSection = [sections objectAtIndex:i];
        if (i > 0){
            currentSnakeSection.particle = [physics makeParticleWithMass:1.0f position:CMTPVector3DMake(i*snakeWidth/(sections.count-1), 0, 0)];
            }
        //if it's the section for the head, create a heavier particle
        else{
            currentSnakeSection.particle = [physics makeParticleWithMass:2.0f position:CMTPVector3DMake(0, 0, 0)];
        }
        //if not the first section, create a spring to connect to the last section
        if (i > 0){
            CMTPParticle *particleA= [[sections objectAtIndex:(i-1)] particle];
            CMTPParticle *particleB= [[sections objectAtIndex:(i)] particle];
            CMTPSpring *aSpring;
            if(i==1){ //special between head and first, make the spring stronger
                aSpring= [physics makeSpringBetweenParticleA:particleA particleB:particleB springConstant:10.0 damping:1.0f restLength:[particleA distanceToParticleReal:particleB]];
            }
            else{
                aSpring= [physics makeSpringBetweenParticleA:particleA particleB:particleB springConstant:(2+((i-1)*(1.0f/sections.count*1.96f))) damping:1.0f restLength:[particleA distanceToParticleReal:particleB]];

            }
            [sectionSprings setObject:aSpring atIndexedSubscript:(i-1)];
        }
    }
    //make the tail fix
    currentSnakeSection = [sections objectAtIndex:(sections.count-1)];
    [currentSnakeSection.particle makeFixed];

    //setup section origins, the snakes starts flat
    //create springs between each section and its origin
    originSprings = [[NSMutableArray alloc] initWithCapacity:sections.count];

    for(int i = 0; i < sections.count; i++) {
        //create the origin particle for each section and make it fix
        currentSnakeSection = [sections objectAtIndex:i];
        
        CMTPParticle *s = currentSnakeSection.particle;
        currentSnakeSection.origParticle = [physics makeParticleWithMass:(s.mass) position:CMTPVector3DMake(s.position.x, s.position.y, s.position.z)];
        [currentSnakeSection.origParticle makeFixed];
        
        //create the spring that ties the origin and its matching section
        CMTPSpring *oSpring = [physics makeSpringBetweenParticleA:currentSnakeSection.origParticle particleB:s springConstant:0.05f damping:0.2f restLength:150.0f];

        [originSprings setObject:oSpring atIndexedSubscript:i];
        
    }

}


//
// Build the sections for a snake with the head on the right.
//
- (void) buildSectionsRight
{
   
    //index of the last letter
    int last = letterPositions.count - 1;
    
    //width of the snake based on the first and last position of the letters
    CMTPParticle *pLast = [letterPositions objectAtIndex:last];
    CMTPParticle *pFirst = [letterPositions objectAtIndex:0];
    snakeWidth = pLast.position.x  - pFirst.position.x;
    
    //go through the sections and create a particle in the particle system for each
    for(int i = 0; i < sections.count; i++) {
        //if it's not the section for the head, create a normal particle
        currentSnakeSection = [sections objectAtIndex:i];
        if ( i < sections.count-1){
            currentSnakeSection.particle = [physics makeParticleWithMass:1.0f position:CMTPVector3DMake(i*snakeWidth/(sections.count-1), 0, 0)];
        }
        //if it's the section for the head, create a heavier particle
        else{
            currentSnakeSection.particle = [physics makeParticleWithMass:2.0f position:CMTPVector3DMake(i*snakeWidth/i, 0, 0)];
        }
        //if not the first section, create a spring to connect to the last section
        
        if (i > 0){
            CMTPParticle *particleA= [[sections objectAtIndex:(i-1)] particle];
            CMTPParticle *particleB= [[sections objectAtIndex:(i)] particle];

            CMTPSpring *aSpring;
            if(i==sections.count-1){  //spring between head and next particle
                aSpring= [physics makeSpringBetweenParticleA:particleA particleB:particleB springConstant:10.0 damping:1.0f restLength:[particleA distanceToParticleReal:particleB]];
            }
            else{
                aSpring= [physics makeSpringBetweenParticleA:particleA particleB:particleB springConstant:(2+((i-1)*(1.0f/sections.count*1.96f))) damping:1.0f restLength:[particleA distanceToParticleReal:particleB]];
            }
            [sectionSprings setObject:aSpring atIndexedSubscript:(i-1)];
        }
    }
    //make the tail fix
    currentSnakeSection = [sections objectAtIndex:0];
    [currentSnakeSection.particle makeFixed];
    
    //setup section origins, the snakes starts flat
    //create springs between each section and its origin  
    originSprings = [[NSMutableArray alloc] initWithCapacity:sections.count];
    
    for(int i = 0; i < sections.count; i++) {
        //create the origin particle for each section and make it fix
        currentSnakeSection = [sections objectAtIndex:i];
        
        CMTPParticle *s = currentSnakeSection.particle;
        currentSnakeSection.origParticle = [physics makeParticleWithMass:(s.mass) position:CMTPVector3DMake(s.position.x, s.position.y, s.position.z)];
        [currentSnakeSection.origParticle makeFixed];
        
        //create the spring that ties the origin and its matching section
        CMTPSpring *oSpring = [physics makeSpringBetweenParticleA:currentSnakeSection.origParticle particleB:s springConstant:0.05f damping:0.2f restLength:150.0f];
        [originSprings setObject:oSpring atIndexedSubscript:i];
        
    }

}


//
// Build the forces that control the letter positions.
//
-(void) buildForces
{
    //make space for forces between each letter of the clean text and each section
    int letterCount = cleanText.length;
    letterForces = [[NSMutableArray alloc] initWithCapacity:letterCount];
    for(int i=0; i<letterCount; i++){
        letterForces[i]=[[NSMutableArray alloc] initWithCapacity:sections.count];
    }
    
    //clean string counter
    int iClean = 0;

    //loop through the original string and create the forces for each letter
    for(int i = 0; i < text.length; i++) {
        //skip spaces
        if([text characterAtIndex:i] == ' ')
            continue;
   
        //calculate the force of each section control point on the letter
        float totalForce = 0;
        float distance = 0;
        float maxDistance = snakeWidth/(sections.count-1);
        
        //go through sections and set force based on the distance between it and the letter
        for(int j = 0; j < sections.count; j++) {
          
            currentSnakeSection = [sections objectAtIndex:j];
            CMTPParticle *currentLetterPositions = [letterPositions objectAtIndex:iClean];
            distance = [currentSnakeSection.particle distanceToParticleReal:currentLetterPositions];
            distance -= maxDistance;
            
            float force;
            if(distance>0)
                force=0;
            else
                force=-distance/maxDistance;
            rowLetterForces= [letterForces objectAtIndex:iClean];
            [rowLetterForces setObject:[NSNumber numberWithFloat:(force)] atIndexedSubscript:j];
            
            totalForce += force;
            
        }
        
        //normalize the forces
        if (totalForce > 0){
            for(int j = 0; j < sections.count; j++)
            {
                //letterForces[iClean][j] /= totalForce;
                rowLetterForces= [letterForces objectAtIndex:iClean];
                float tempFloat = [[rowLetterForces objectAtIndex:j] floatValue]/totalForce;
                [rowLetterForces setObject:[NSNumber numberWithFloat:tempFloat] atIndexedSubscript:j];
            }
        }
        //increment clean string counter
        iClean++;
    }

}

//
// Get the number of sections in the snake.
// @return number of sections
//
-(int)sectionCount
{ return sections.count; }


-(void) setScales: (NSMutableArray*)positions scales:(NSMutableArray*)scales
{

    //make space for the array copies
    NSMutableArray *positionsCopy = [[NSMutableArray alloc] init];
    NSMutableArray *scalesCopy = [[NSMutableArray alloc] init];

    NSLog(@"Positions count=%d", positions.count);
    
    //if the head is on the left side, then reverse values
    // LEFT =0
    if(side==0) {
        for(int i = 0; i < positions.count; i++){
            NSNumber *temp =[NSNumber numberWithFloat:(1-[[positions objectAtIndex:positions.count-1-i] floatValue])];
            [positionsCopy addObject:temp];
        }
        for(int i = 0; i < scales.count; i++)
            [scalesCopy addObject:[scales objectAtIndex:scales.count-1-i]];
    }
    //if the head is on the right side,
    //then we assume the values are in the right order
    else {

        for(int i = 0; i < positions.count; i++){
            NSNumber *temp =[NSNumber numberWithFloat:(1-[[positions objectAtIndex:positions.count-1-i] floatValue])];
            [positionsCopy addObject:temp];
        }
        for(int i = 0; i < scales.count; i++)
            [scalesCopy addObject:[scales objectAtIndex:scales.count-1-i]];
    }
    
    //array lengths must match and it must contain at least 2 values (start and end)
    if (positionsCopy.count != scalesCopy.count) {
        NSLog(@"Setting snake scale factors failed. Number of positions and number of scale factors don't match.");
        return;
    }
    if (positionsCopy.count< 2) {
        NSLog(@"Setting snake scale factors failed. At least 2 scale factors are required.");
        return;
    }

    //make space for scaling factors
    NSMutableArray *scalePoints = [[NSMutableArray alloc] initWithCapacity:positions.count];
    NSMutableArray *rowScalePoints = [[NSMutableArray alloc] initWithCapacity:2];

    //set scales
    //convert percentage positions to letter indexes, and store scaling values
    for(int i = 0; i < positionsCopy.count; i++) {
        rowScalePoints = [[NSMutableArray alloc] initWithCapacity:2];
        [rowScalePoints setObject:[NSNumber numberWithInt:(int)([[positionsCopy objectAtIndex:i]floatValue]*cleanText.length)] atIndexedSubscript:0];
        [rowScalePoints setObject:[NSNumber numberWithFloat:([[scalesCopy objectAtIndex:i]floatValue])] atIndexedSubscript:1];
        [scalePoints setObject:rowScalePoints atIndexedSubscript:i];
    }

    //calculate the first and the next letter scale factors
    int letterScaleIndex = [[[scalePoints objectAtIndex:0] objectAtIndex:0] integerValue];
    float letterScale = [[[scalePoints objectAtIndex:0] objectAtIndex:1] floatValue];
    int nextLetterScaleIndex = [[[scalePoints objectAtIndex:1] objectAtIndex:0] integerValue];
    float nextLetterScale= [[[scalePoints objectAtIndex:1] objectAtIndex:1] floatValue];
    
    //index of the next scaling value to use after reaching nextLetterScaleIndex
    int scaleIndex = 2;
    
    //current scale factor
    float currentScale = 1;

    //loop through all letter positions
    for(int i = 0; i < letterPositions.count; i++) {
        //if we reached the nextLetterScaleIndex, then we need
        //to get values for the next two scale factors
        if (i > nextLetterScaleIndex) {
            //next indexes before the first ones
            letterScaleIndex = nextLetterScaleIndex;
            letterScale = nextLetterScale;
            
            //if the next scale index is within the bounds of the scale factor array
            //then we grad the next one
            if (scaleIndex < scalePoints.count) {
                nextLetterScaleIndex = (int)[[[scalePoints objectAtIndex:scaleIndex] objectAtIndex:0] integerValue];
                nextLetterScale = [[[scalePoints objectAtIndex:scaleIndex] objectAtIndex:1] floatValue];
                
                //increment counter for the next one
                scaleIndex++;
            }
            else {
                //if we reached the end of the scale factor array
                //then we set the index to the last letter
                nextLetterScaleIndex = letterPositions.count-1;
            }
        }
        
        [letterScales setObject:[NSNumber numberWithFloat:(i-letterScaleIndex)/(float)(nextLetterScaleIndex-letterScaleIndex)*(nextLetterScale-letterScale)+letterScale] atIndexedSubscript:i];
    }
    
    //reverse the values for the snake with head on right side
    NSMutableArray *letterScaleCopy = [[NSMutableArray alloc] init];
    if(side){
        for(int i = 0; i < letterScales.count; i++){
            NSNumber *aNumber = [NSNumber numberWithFloat:[[letterScales objectAtIndex:letterScales.count-1-i] floatValue]];
            [letterScaleCopy addObject:aNumber];
        }
        letterScales = letterScaleCopy;
    }
    
}

//
// Set the original body position.
// @param amplitude amplitude of the sin wave of the body
// @param length length of the body
// @param cycles number of cycles in the wave
//
-(void) setOrigin:(float)amplitude lenght:(float)length cycles:(float)cycles {
    //rads for the number of cycles
    float rads = cycles*2*M_PI;

    //go through each section and find its correct position to create the wave
    for(int i = 0; i < sections.count; i++) {
        //find the x position of this section
        float xrad = i*rads/(sections.count-1);
        
        //adjust the section's position and its original position
        CMTPParticle *aParticle;
        aParticle = [[sections objectAtIndex:i] origParticle];
        [aParticle setPosition:(CMTPVector3DMake(xrad * length/sections.count, -amplitude * (float)sinf(xrad), 0))];
        
        //sections[i].particle.position().set(sections[i].origParticle.position());
        CMTPParticle *bParticle;
        bParticle = [[sections objectAtIndex:i] particle];
        [bParticle setPosition:aParticle.position];
        
        //adjust the spring with the last section
        if(i>0){
            CMTPSpring *aSpring = [sectionSprings objectAtIndex:i-1];
            [aSpring setRestLength: [[[sections objectAtIndex:i] origParticle] distanceToParticleReal:[[sections objectAtIndex:i-1] particle]]];
        }
            
    }

}

//
// Get the head's particle.
// @return head particle
//
-(CMTPParticle*) getHead {
    if (head == nil) {
        if([[[sections objectAtIndex:0] particle] isFixed])
            head = [[sections objectAtIndex:sections.count-1] particle];
        else
            head = [[sections objectAtIndex:0] particle];
    }
    return head;
}


// Get the original head's particle.
// @return original head particle
//
-(CMTPParticle*) originalHead {
    if([[[sections objectAtIndex:0] origParticle] isFixed])
        return [[sections objectAtIndex:sections.count-1] origParticle];
    else
        return [[sections objectAtIndex:0] origParticle];
}


//
// Translate the snake.
// @param x x offset
// @param y y offset
// @param z z offset
//
-(void) translate:(float)x y:(float)y z:(float) z {
    //translate
    position = CMTPVector3DAdd(position, CMTPVector3DMake(x, y, z));
    
    //translate sections, which are absolutes
    for (SnakeSection *aSnakeSection in sections){
        [[aSnakeSection particle] setPosition:CMTPVector3DAdd([[aSnakeSection particle] position], CMTPVector3DMake(x, y, z))];
        [[aSnakeSection origParticle] setPosition:CMTPVector3DAdd([[aSnakeSection origParticle] position], CMTPVector3DMake(x, y, z))];
    }
}


//
// Check if the snake is biting.
// @return true if biting, false if not
//
-(BOOL) isBiting{
    return [preyAttraction isOn];
}

//
// Set the properties that control the bite behavior.
// @param mass			mass of the bitten object (used by particle system)
// @param strength		strength of the bite's attraction
// @param minDistance	minimum distance for the bite's attraction to affect the position
//
-(void) setBite:(float)mass strenght:(float)strength minDistance:(float)minDistance
{
    [prey setMass:mass];
    [preyAttraction setMinDistance:minDistance];
    strengthMult = strength;
}



//
// Set the sound samples for strikes and rattles.
// @param strikes list of strike sound samples
// @param svolume strike sound volume
// @param rattles list of rattle sound samples
// @param rvolume rattle sound volume
//
-(void) setSamples:(NSMutableArray*) strikes svolume:(float)svolume rattles:(NSMutableArray*)rattles rvolume:(float) rvolume {
    [strikeSamples removeAllObjects];

    NSLog(@"Set Samples");
    if(strikes){
        NSLog(@"Strikes is not nil");
        for(AVAudioPlayer *s in strikes){
            NSLog(@"Set Samples - ADD OBJECT");
            s.volume=svolume;
            [strikeSamples addObject:s];
        }
    }
    [self setRattleSamples:rattles rvolume:rvolume];
     
}

//
 // Set the rattle sounds samples.
 // @param rattles list of rattle sound samples
 // @param rvolume rattle sound volume
 //
-(void) setRattleSamples: (NSMutableArray*)rattles rvolume:(float) rvolume {
    
    [rattleSamples removeAllObjects];

    if(rattles){
        for(AVAudioPlayer *s in rattles){
            s.volume=rvolume;
            [rattleSamples addObject:s];
        }
    }
}
 

//
 // Set one strike sound sample.
 // @param strike strike sample
 // @param svolume strike sound volume
 //
-(void) setStrikeSample:(AVAudioPlayer*)strike volume:(float) volume {
    
    [strikeSamples removeAllObjects];

    strike.volume = volume;
    [strikeSamples addObject:strike];

}


//
// Bite on a touch object.
// @param t the touch object to bite
//
-(void) bite:(Word*)w touch:(Touch*)t {
    //keep track of the word object
    bitWord = w;
    
    //keep track of the touch object
    bitTouch = t;
    bitTouch.bites++;
    
    //reset the strike sound
    bitSoundPlayed = false;
    
    //bite on the touch's location
    [self bite:t.x y:t.y z:0];
     
}

 // Bite at a specific location.
 // @param x x position
 // @param y y position
 // @param z z position
 //
-(void) bite:(float)x y:(float)y z:(float)z {
    //disable retracting
    retracting = false;
 
    //stop sections from retracting
    for(SnakeSection *currSection in sections)
        [currSection stopRetract];
 
    //enable springs between sections and their origins
    for(CMTPSpring *s in originSprings)
        [s turnOn];
 
    //set and enable the attraction to the bitten object
    CMTPParticle *pBiteLocation = [physics makeParticleWithMass:0 position:CMTPVector3DMake(x, y, z)];
    prey.position = CMTPVector3DMake(x, y, z);
    [preyAttraction setStrength:(strengthMult * [[self originalHead] distanceToParticleReal:pBiteLocation])];
    [preyAttraction turnOn];
 }


-(Touch*) getBitTouch{
    return bitTouch;
}

//
// Set the retract behavior values.
// @param direction direction of the retraction
// @param delay delay before retracting
// @param wave delay between each snake section
// @param speed speed of retraction
//
-(void) setRetract:(int)direction delay:(int)delay wave:(int) wave speed:(float) speed {
    for(SnakeSection *aSnakeSection in sections){
        [aSnakeSection setRetract:direction delay:delay wave:wave speed:speed];
    }
}



//
// Retract the snake.
//
-(void) retract{
    
    //clear the bitten objects
    if(bitWord){
        [bitWord decontract];
        bitWordContracted = false;
        bitWord=nil;
    }
        
    bitTouch = nil;
  
    //turn off the attraction to the bitten object
    [preyAttraction turnOff];
    
    //turn off the spring between the sections and their origins
    //for(CMTPSpring *s in originSprings)
    //    [s turnOff];
    
    //start retracting the sections
    for(SnakeSection *currSection in sections)
        [currSection startRetract];
        
    //flag snake as retracting
    retracting = true;
}


//
// update procedure
//
-(void) update:(long)dt
{
    //if the snake is retracting,
    //then update the sections
    if (retracting) {
        //make the sections retract to the origin
        for(SnakeSection *aSnakeSection in sections){
            [aSnakeSection update];
        }
        
        //if all the sections are out of the screen,
        //reset to origin (this solves the twitching snake syndrome)
        //if ([self outside]) {
        if(snakeOutside){
            for(SnakeSection *aSnakeSection in sections)
                [aSnakeSection reset];
            retracting = false;
        }
    }
    //if we're not retracting, and we're biting on something
    else if (bitTouch != nil) {
        //then adjust the position of the bitten object to match the touch
        [prey setPosition:CMTPVector3DMake(bitTouch.x, bitTouch.y, 0)];
        
        if(!bitSoundPlayed && [self distanceFromPrey]<rBounds.size.height/2){
            for(AVAudioPlayer *s in strikeSamples){
                [s play];
            }
            for(AVAudioPlayer *s in rattleSamples){
                [s play];
            }
            bitSoundPlayed = TRUE;
            
                    }
                 
        if (!bitWordContracted) {
            if(CGRectContainsPoint([bitWord getAbsoluteBounds], CGPointMake(head.position.x, head.position.y)))
                {
                //contract the word
                [bitWord contract:prey.position.x y:prey.position.y];
                bitWordContracted = TRUE;
                    
                //create ripple so rattlesnake will read value and create animation
                executeRipple=true;

            }
        }
    
        //If word got contracted, or head of snake got nearby of touch, 
        //setup head position touch to avoid random spinning of snake head
        if(bitWordContracted || (fabsf(bitTouch.x - [self getHead].position.x)<rBounds.size.height/10 && fabsf(bitTouch.y - [self getHead].position.y)<rBounds.size.height/10)){
            //setup the head to touch position of the touch
            [[self getHead] setPosition:CMTPVector3DMake(bitTouch.x, bitTouch.y, 0)];
         
        }
    }
    
    //update the letter positions, which are controlled by the sections
    //also look if all letters are inside or outside.
    CMTPVector3D newPosition;
    CMTPParticle *aParticle;
    BOOL outside=TRUE;   //to check if all letters are out of screen
    
    for(int i=0; i< letterPositions.count; i++){
        newPosition = CMTPVector3DMake(0, 0, 0);
        for(int j = 0; j < sections.count; j++) {
            newPosition = CMTPVector3DAdd(newPosition, CMTPVector3DScaleBy([[[sections objectAtIndex:j] particle] position], [[[letterForces objectAtIndex:i] objectAtIndex:j] floatValue]));
        }
        aParticle = [letterPositions objectAtIndex:i];
        [aParticle setPosition:newPosition];
        
        //look if at least one letter is still visible
        if(outside){
            CGPoint aPoint = CGPointMake(aParticle.position.x, aParticle.position.y);
            if(CGRectContainsPoint(rBounds, aPoint)){
                outside=FALSE;
            }
        }
    }
    
    //is snake outside or inside bounds after the update?
    if(outside)
        snakeOutside=true;
    else
        snakeOutside=false;

}


//
// Get the distance between the head and the prey (bite).
// @return distance in pixels
//
-(float) distanceFromPrey {
    return [[self getHead] distanceToParticleReal:prey];
}


//
// Check if the snakes is outside the window.
// @return true if completely outside
//
/*
-(BOOL) outside {    
    
    for(int i=0; i<letterPositions.count; i++){
        
        CMTPParticle *cParticle = [letterPositions objectAtIndex:i];
        //NSLog(@"Particle pos: %f %f", (float)[cParticle position].x, [cParticle position].y);
        
        //cParticle = [letterPositions objectAtIndex:i];
        //NSLog(@"Particle pos: %f %f", (float)[cParticle position].x, [cParticle position].y);
        //CGPoint aPoint = CGPointMake(aParticle.position.x, aParticle.position.y);
        
        //NSLog(@"A Point: %f, %f", aPoint.x, aPoint.y);
        //if(CGRectContainsPoint(rBounds, aPoint))
         //   return FALSE;
    }
     
    return false;
}
 */


//
// Draw.
//
-(void) draw {

    //if there is no section, nothing to draw
    if (sections.count == 0) return;
    
    //loop through all letter positions
    for(int i = 0; i < letterPositions.count; i++) {
               
        //move to the right position and draw the letter
         glPushMatrix();
        CMTPParticle *aParticle = [letterPositions objectAtIndex:i];        
        glTranslatef(aParticle.position.x, aParticle.position.y, aParticle.position.z);

       // NSLog(@"Particle pos: %f %f", aParticle.position.x, aParticle.position.y);
        glScalef([[letterScales objectAtIndex:i]floatValue], [[letterScales objectAtIndex:i]floatValue], 0);
        Word *aWord = [lettersOfSnake objectAtIndex:i];
        [aWord draw];

        glPopMatrix();
        
    }
         
}


 
 //
 // Draw the bounds of the letters.
 //
-(void) drawBounds {
 
    for(int i = 0; i < letterPositions.count; i++) {
          
        CGRect aRect = [[letterBounds objectAtIndex:i] CGRectValue];

        GLfloat squareVertices[] = {
         -aRect.size.width/2, -aRect.size.height/2,
         aRect.size.width/2, -aRect.size.height/2,
         -aRect.size.width/2,  aRect.size.height/2,
         aRect.size.width/2,  aRect.size.height/2,
        };

        glPushMatrix();
        CMTPParticle *aParticle = [letterPositions objectAtIndex:i];
        glTranslatef(aParticle.position.x, aParticle.position.y, aParticle.position.z);

        glEnableClientState(GL_VERTEX_ARRAY);

        glPopMatrix();
    }
}


//
// Draw the skeleton.
//
-(void) drawSkeleton {
    //if there is no section, then nothing to draw
    if (sections.count == 0) return;
    
    //save the fill color
    //int savedFill = p.g.fillColor;
    
    //loop through sections and draw a line between each, and a dot for each
    //Particle lastPt = null;
    CMTPParticle *lastPt;
    
    for(SnakeSection *curSection in sections){
        
        if (lastPt == nil)
            lastPt = curSection.particle;
        else {
            glLineWidth(2);
            GLfloat line[]={lastPt.position.x, lastPt.position.y, curSection.particle.position.x, curSection.particle.position.y};
            glVertexPointer(2, GL_FLOAT, 0, line);
            glEnableClientState(GL_VERTEX_ARRAY);
            glDrawArrays(GL_LINES, 0, 2);
            lastPt = curSection.particle;
        }
        
        //p.fill(savedFill);
        //p.ellipse(section.particle.position().x(), section.particle.position().y(), 8, 8);


    }
    
}


- (BOOL) getExecuteRipple{
    return executeRipple;
}
- (void) setExecuteRipple:(BOOL)aState{
    executeRipple = aState;
}

- (Ripple*) getRipple{
    if(ripple)
        return ripple;
    else
        return nil;
}

@end
