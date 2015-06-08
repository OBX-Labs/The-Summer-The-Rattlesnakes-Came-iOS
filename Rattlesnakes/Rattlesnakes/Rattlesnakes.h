//
//  Rattlesnakes.h
//  Rattlesnakes
//
//  Created by Serge Maheu on 2013-05-03.
//  Copyright (c) 2013 Serge Maheu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "OKGeometry.h"
#import "Snake.h"
#import "BezierPath.h"
#import "EAGLView.h"
#import "SoundManager.h"
#import "Ripple.h"

@class OKTessFont;
@class OKTextObject;
@class OKSentenceObject;
@class OKCharObject;

@class OKTessData;
@class OKCharDef;
@class Line;

@class PerlinTexture;

@interface Rattlesnakes : NSObject
{
    // Screen bounds
    CGRect sBounds;
    
    // Touches
    NSMutableDictionary *ctrlPts;
    NSMutableDictionary *ctrlPtsTouch;
    
    // Properties
    OKTessFont *font;  //background font
    
    OKTextObject *text;
    float bgOpacity;
    OKPoint bgCenter;
    NSMutableArray *bgWords;
    
    NSMutableArray *scrollTextLines;
    NSMutableArray *cScrollTextLines;
    NSMutableArray *removableScrollTextLines;
    int scrollTextWords;
    int nextWordLine1;
    int nextWordLine2;
    
    NSMutableArray *words;
        
    // Animation time tracking
    NSDate *lUpdate;
    NSDate *now;
    long DT;
    int frameCount;
        
    //Particle system
    CMTPParticleSystem *physics;
    
    // the array of snakes
    NSMutableArray *snakes;
    
    //font used for the snakes
    OKTessFont *snakeFont;

	BOOL firstBite;						//true until the first bite

    int textIndex;							//index of the current background text
    NSMutableArray *allTextsObjects;
    
    NSMutableArray *textFiles;              //contains the whole text separated in blocks (array of OKTextObject)
    NSMutableArray *textLines;              //lines of the background texts
    NSMutableArray *textWords;              //words of the background texts

    OKTessFont *textFonts;                      //fonts of the background lines
    //NSMutableArray *textFontSizes;              //fonts of the background lines
	
    NSMutableArray *textWordSpacing;            //word spacing offset for the background lines
    
	int totalWordsSeen;						//counter of total word seen for a page
	int totalWords;							//counter of total words in a page
    OKWordObject *wordTest;
    Word *wordForTest;
    
    BezierPath *bgSnake;
    long long lastTouch;							//last time there was a touch
	long lastBgSnake;						//last time an idle animatiom started

    BOOL changingLock;					//true (locked) until we get a first touch
	BOOL changing;						//true when we are changing the text
	int changingText;						//index of the changing text
	long long lastChanging;						//last time the text changed
	//int[] textChangingDelays;				//array of text changing delays
    NSMutableArray *textChangingDelays;
	long long nextTextChange;					//time (in millis) when the text is allowed to change
	float textChangeSpeed;					//offset for text change speed used when touching during

    EAGLView *parentEaglView;
    SoundManager *soundManager;
    
    BOOL swipeDirectionRight;
    Ripple *ripple;
    
}

- (id) initWithFont:(OKTessFont*)tFont text:(OKTextObject*)textObj allTexts:(NSMutableArray*)theTexts andBounds:(CGRect)bounds eaglview:(EAGLView*)aView;
- (void) buildOutlinedWords:(OKSentenceObject*)aSentenceObj;
- (Line*) createLine:(int)start;

- (long long) getMillis;
-(BOOL) changingOfTheTexts;

//snakes
- (void) setupSnakes;


#pragma mark - DRAW

- (void) draw;
- (void) update:(long)dt;
- (void) updateText:(long)dt;
- (void) drawText;

-(void) handleVisibleWords;

#pragma mark - Touches

- (void) setCtrlPts:(int)aID atPosition:(CGPoint)aPosition;
- (void) removeCtrlPts:(int)aID atPosition:(CGPoint)aPosition;

- (void) touchesBegan:(int)aID atPosition:(CGPoint)aPosition;
- (void) touchesMoved:(int)aID atPosition:(CGPoint)aPosition;
- (void) touchesEnded:(int)aID atPosition:(CGPoint)aPosition;
- (void) touchesCancelled:(int)aID atPosition:(CGPoint)aPosition;

@end
