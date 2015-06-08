//
//  snake.h
//  Rattlesnakes
//
//  Created by Serge on 2013-05-06.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <AVFoundation/AVFoundation.h>

#import "SnakeSection.h"
#import "CMTraerPhysics.h"
#import "Word.h"
#import "Line.h"
#import "OKCharObject.h"
#import "Touch.h"
#import "TessGlyph.h"
#import "Ripple.h"

@interface Snake : NSObject
{

    //parent Processing applet
	//PApplet p;
    CGRect rBounds;
    int snakeId;						//id of the snake
    int side;					//side the head is (LEFT=0 or RIGHT=1)

    NSString *text;				//textual value
    OKTessFont *pFont;
    
    float textWidth;			//width of the text
    float snakeWidth;			//width of the snake
    
    CMTPVector3D position;
    NSMutableArray *sections;
    SnakeSection *currentSnakeSection;
    CMTPParticle *head; //cached head particle
    NSMutableArray *sectionSprings; //springs controlling the sections
    NSMutableArray *originSprings;  //springs connecting the sections with their origins
    Word *bitWord;				//word object the snake bit on
    Touch *bitTouch;    //touch object the snake is biting on
    CMTPParticle *prey; //prey particle to control the bite animation
    CMTPAttraction *preyAttraction; //attraction between the head and the prey
    
    float strengthMult;			//strength multiplier for the attraction to the prey
    BOOL bitSoundPlayed; 	//true if the strike sound was played for the current bite
    
    NSMutableArray *strikeSamples;  //array of strike sounds
    NSMutableArray *rattleSamples;  //array of rattle sounds
    
    BOOL bitWordContracted;     //true when the snake contract the word it bit on last
    BOOL retracting;        //true if the snake is retracting, false if not

    NSString *cleanText;			//cleaned (no space) textual value
    Line *snakeText;
    
    NSMutableArray *letterPositions;
    NSMutableArray *letterForces;
    NSMutableArray *rowLetterForces; //a row of letterForces
    NSMutableArray *letterScales;
    NSMutableArray *letterBounds;
    
    NSMutableArray *lettersOfSnake;
    CMTPParticleSystem *physics;
    
    BOOL executeRipple;
    Ripple *ripple;
    
    BOOL snakeOutside;
}

@property (nonatomic, retain) NSMutableArray *strikeSamples;
@property (nonatomic, retain) NSMutableArray *rattleSamples;


- (id) initWithId:(int)aSnakeId physics:(CMTPParticleSystem*)aPhysics text:(NSString*)aText font:(OKTessFont*)aFont sectionCount:(int)aSectionCount side:(int)aSide renderingBounds:(CGRect)aRenderingBounds;
- (void) buildLetters:(int)aSide;
- (void) buildSections:(int)aSide;
- (void) buildSectionsLeft;
- (void) buildSectionsRight;
- (void) buildForces;
-(int)sectionCount;
-(void) setScales: (NSMutableArray*)positions scales:(NSMutableArray*)scales;
-(void) setOrigin:(float)amplitude lenght:(float)length cycles:(float)cycles;
-(CMTPParticle*) head;
-(CMTPParticle*) originalHead;
-(void) translate:(float)x y:(float)y z:(float) z;
-(BOOL) isBiting;
-(void) setBite:(float) mass strenght:(float)strength minDistance:(float)minDistance;
-(void) setSamples:(NSMutableArray*) strikes svolume:(float)svolume rattles:(NSMutableArray*)rattles rvolume:(float) rvolume;
-(void) setRattleSamples: (NSMutableArray*)rattles rvolume:(float) rvolume;
-(void) setStrikeSample:(AVAudioPlayer*)strike volume:(float) volume;

-(void) bite:(Word*)w touch:(Touch*)t;
-(void) bite:(float)x y:(float)y z:(float)z;
-(Touch*) getBitTouch;

-(void) setRetract:(int)direction delay:(int)delay wave:(int) wave speed:(float) speed;
-(void) retract;
-(void) update:(long)dt;
-(float) distanceFromPrey;
-(void) draw;
-(void) drawBounds;
-(void) drawSkeleton;

- (BOOL) getExecuteRipple;
- (void) setExecuteRipple:(BOOL)aState;
- (Ripple*) getRipple;

    
@end
