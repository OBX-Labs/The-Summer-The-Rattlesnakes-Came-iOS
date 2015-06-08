//
//  Word.h
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KineticObject.h"
#import "CMTraerPhysics.h"
#import "Ripple.h"

@class Line;
@class OKTessFont;

@class OKWordObject;
@class OKCharObject;

typedef enum
{
    FADE_IN,
    FADE_OUT,
    STABLE,
} FadeState;

@interface Word : KineticObject
{
    // Font
    OKTessFont *font;
    
    // Glyphs
    NSMutableArray *glyphs;
    
    // Properties
    float opacity; // opacity
    float fadeInSpeed, fadeOutSpeed; // fading speeds
    FadeState fadeState; // fading state (in, out, stable)
    float fadeTo; // opacity to fade to
    float fadeInTo;
    //CMTPVector3D position;
    CGRect bounds;
    BOOL seen;
    
 	float contractFac;					//contract factor from 0 to 1, where 1 is most contracted
	float contractAcc;					//contract acceleration
	float contractVel;					//velocity affecting the contract factor
	//PVector contractFrom;				//point to contract away from
    CMTPVector3D contractFrom;
	BOOL contracting;				//true when contracting
	float contractPeriod;				//period of contraction for animation
	long long contractStart;					//when did the contract start
    
    OKPoint velocity; // velocity
    float drag; // drag
    
    CGSize size;
    NSString *value;

    OKPoint realPos;
    /*
    static ArrayList<Ripple> ripples = null;	//static ripples used by tessellator
	protected static FontRenderContext frc = new FontRenderContext(null, false, false);
	
	ArrayList<PVector> vertices;
	ArrayList<int[]> contours;
	GeneralPath outline;
	
    static protected GLU glu = new GLU();
    
    static protected GLUtessellator tessellator = GLU.gluNewTess();
    static float TESSELLATOR_DETAIL = 3.0f;
    
    static protected GLUtessellatorCallbackAdapter tessCallback;
    int tessCount;
    ArrayList<Float> tessInit;
    float[] tessOrig;
    float[] tess;
*/
    
}


- (id) initWithWord:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds;
- (id) initWithWordForSnake:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds;

- (void) build:(OKWordObject*)aWordObj renderingBounds:(CGRect)aRenderingBounds;

#pragma mark - DRAW

- (void) draw; // Draws fill and outline
- (void) drawShadow; //draw the shadow for the word
- (void) drawFill; // Draws fill
- (void) drawOutline; // Draws outline
- (void) drawDebugBounds;
- (void) update:(long)dt;
- (void) updateGlyphs:(long)dt;

#pragma mark - SETTERS

- (void) setPosition:(OKPoint)aPosition;
- (void) setRealPosX:(float)posX y:(float)posY;
- (void) setOpacity:(float)aOpacity;
- (void) fadeTo:(float)aOpacity speed:(float)aSpeed;
- (void) fadeIn:(float)aOpacity;
- (void) fadeOut:(float)aOpacity;
- (void) fadeIn:(float)aOpacity speed:(float)aSpeed;
- (void) fadeOut:(float)aOpacity speed:(float)aSpeed;
- (void) setFadeInSpeed:(float)aFadeInSpeed fadeOutSpeed:(float)aFadeOutSpeed;
- (void) fadeIn:(float)aOpacity speed:(float)aSpeed outspeed:(float)aOutspeed;
- (void) fadeOut;
- (void) setGlyphsScaling:(float)aScale;
-(void) updateContract;
-(void) contract:(float)x y:(float)y;
-(void) decontract;
-(void) setSeen:(BOOL)s;
-(void) setRipple:(Ripple*)r;

#pragma mark - GETTERS

- (CGRect) getAbsoluteBounds;
- (CGSize) getSize;
- (BOOL) isInside:(OKPoint)pt;
//- (OKPoint) center;
- (CMTPVector3D) center;
- (BOOL) isFadingIn;
- (BOOL) isFadingOut;
- (BOOL) isFadedOut;
- (float) opacity;
-(BOOL) isContracted;
-(BOOL) isContracting;
-(BOOL) wasSeen;
-(BOOL) isFading;




- (NSString*) description;
- (NSString*) value;

@end
