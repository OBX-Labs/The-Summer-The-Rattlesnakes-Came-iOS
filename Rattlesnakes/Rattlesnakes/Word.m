//
//  Word.m
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "Word.h"
#import "OKPoEMMProperties.h"

#import "OKTessFont.h"
#import "TessGlyph.h"

#import "OKWordObject.h"
#import "OKCharObject.h"

//DEBUG settings
static BOOL DEBUG_BOUNDS = NO;

static float WORD_FILL_COLOR[] = {0.0, 0.0, 0.0, 0.0};
static int WORD_ACCURRACY;// iPad 4 iPhone 4

@implementation Word

- (id) initWithWord:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds
{
    self = [super init];
    if(self)
    {
        // Properties
        //NSArray *fillClr = [OKPoEMMProperties objectForKey:WordFillColor];
        NSArray *fillClr = [OKPoEMMProperties objectForKey:TextColor];
        WORD_FILL_COLOR[0] = [[fillClr objectAtIndex:0] floatValue];
        WORD_FILL_COLOR[1] = [[fillClr objectAtIndex:1] floatValue];
        WORD_FILL_COLOR[2] = [[fillClr objectAtIndex:2] floatValue];
        WORD_FILL_COLOR[3] = [[fillClr objectAtIndex:3] floatValue];
        WORD_ACCURRACY = [[OKPoEMMProperties objectForKey:WordTessellationAccurracy] intValue];
        
        // Font
        font = aFont;
        
        // Glyphs
        glyphs = [[NSMutableArray alloc] init];
        
        // Build
        [self build:aWordObj renderingBounds:aRenderingBounds];
        
        // Properties
        opacity = 1.0f;
        fadeInSpeed = 0.05f;
        fadeOutSpeed = 0.01f;
        fadeState = STABLE;
        fadeTo = 1.0f;
        velocity = OKPointMake(0.0f, 0.0f, 0.0f);
        drag = 0.98f;
        bounds = [self getAbsoluteBounds];
        
        // Size
        size = CGSizeMake([aWordObj getWitdh], [aWordObj getHeight]);
        
        seen = FALSE;
    }
    return self;
}

- (id) initWithWordForSnake:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds
{
    self = [super init];
    if(self)
    {
        // Properties
        //NSArray *fillClr = [OKPoEMMProperties objectForKey:WordFillColor];
        NSArray *fillClr = [OKPoEMMProperties objectForKey:SnakeColor];
        WORD_FILL_COLOR[0] = [[fillClr objectAtIndex:0] floatValue];
        WORD_FILL_COLOR[1] = [[fillClr objectAtIndex:1] floatValue];
        WORD_FILL_COLOR[2] = [[fillClr objectAtIndex:2] floatValue];
        WORD_FILL_COLOR[3] = [[fillClr objectAtIndex:3] floatValue];
        WORD_ACCURRACY = [[OKPoEMMProperties objectForKey:WordTessellationAccurracy] intValue];
        
        // Font
        font = aFont;
        
        // Glyphs
        glyphs = [[NSMutableArray alloc] init];
        
        // Build
        [self build:aWordObj renderingBounds:aRenderingBounds];
        
        // Properties
        opacity = 1.0f;
        fadeInSpeed = 0.05f;
        fadeOutSpeed = 0.01f;
        fadeState = STABLE;
        fadeTo = 1.0f;
        velocity = OKPointMake(0.0f, 0.0f, 0.0f);
        drag = 0.98f;
        bounds = [self getAbsoluteBounds];
        
        // Size
        size = CGSizeMake([aWordObj getWitdh], [aWordObj getHeight]);
    }
    return self;
}



- (void) build:(OKWordObject*)aWordObj renderingBounds:(CGRect)aRenderingBounds
{
    value = [[NSString alloc] initWithString:aWordObj.word];
    
    for(OKCharObject *charObj in aWordObj.charObjects)
    {
        TessGlyph *glyph = [[TessGlyph alloc] initWithChar:charObj font:font accurracy:WORD_ACCURRACY renderingBounds:aRenderingBounds];
        [glyph setFillColor:WORD_FILL_COLOR];
        [glyphs addObject:glyph];
        [glyph release];
    }
}


#pragma mark - DRAW

- (void) draw
{
    //Transform
    glPushMatrix();
    glTranslatef(pos.x, pos.y, pos.z);
    glScalef(sca, sca, 0.0);
    for(TessGlyph *tg in glyphs)
    {
        // No point in drawing if not visible
        if(opacity != 0)
            [tg draw];
    }
    
    if(DEBUG_BOUNDS) [self drawDebugBounds];
    
    glPopMatrix();
}

- (void) drawShadow
{
    //draw the shadow
    glPushMatrix();
    glTranslatef(pos.x, pos.y, pos.z);
    glScalef(sca, sca, 0.0);
    for(TessGlyph *tg in glyphs)
    {
        // No point in drawing if not visible
        if(opacity != 0)
            [tg drawShadow];
    }
    glPopMatrix();

}

- (void) drawFill
{
    //Transform
    glPushMatrix();
    glTranslatef(pos.x, pos.y, pos.z);
    
    for(TessGlyph *tg in glyphs)
    {
        // No point in drawing if not visible
        if(opacity != 0) [tg drawFill];
    }
    
    if(DEBUG_BOUNDS) [self drawDebugBounds];
    
    glPopMatrix();
}

- (void) drawOutline
{
    //Transform
    glPushMatrix();
    glTranslatef(pos.x, pos.y, pos.z);
    for(TessGlyph *tg in glyphs)
    {
                // No point in drawing if not visible
        if(opacity != 0) {
            [tg drawOutline];
        }
    }
    
    if(DEBUG_BOUNDS) [self drawDebugBounds];
    
    glPopMatrix();
}

- (void) drawDebugBounds
{
    glColor4f(0, 0, 0, 1);
    
    //debug bounding box
    const GLfloat line[] =
    {        
        0.0f - (size.width/2.0f) , 0.0f, //point A Bottom left
        0.0f - (size.width/2.0f), size.height, //point B Top left
        size.width/2.0f, size.height, //point C Top Right
        size.width/2.0f, 0.0f, //point D Bottom Right
    };
    
    glVertexPointer(2, GL_FLOAT, 0, line);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
}

- (void) update:(long)dt
{
    [super update:dt];
    
    // Fade in or out based on current state
    switch (fadeState)
    {
        case FADE_IN:
            opacity += fadeInSpeed;
            if(opacity > fadeTo) { opacity = fadeTo; fadeState = STABLE; }
            break;
        case FADE_OUT:
            opacity -= fadeOutSpeed;
            if(opacity < fadeTo) { opacity = fadeTo; fadeState = STABLE; }
            break;
        default:
            break;
    }
    
    //OKPoint newPos = OKPointAdd(pos, OKPointMultf(velocity, drag));
    //[self setPosition:newPos];
    [self updateContract];
    
    [self updateGlyphs:dt];
}

- (void) updateGlyphs:(long)dt
{
    for(TessGlyph *tg in glyphs)
    {
        [tg update:dt];
        
        // Fade color
        float *fillClr = [tg getFillColor];
        fillClr[3] = opacity;
        [tg setFillColor:fillClr];
    }
}

#pragma mark - SETTERS

- (void) setPosition:(OKPoint)aPosition { [self setPos:aPosition];}


-(void) setRealPosX:(float)posX y:(float)posY
{
    realPos.x = posX;
    realPos.y = posY;
    for(TessGlyph *aGlyph in glyphs){
        [aGlyph setWordPosX:posX y:posY];
    }
}

- (void) setOpacity:(float)aOpacity { opacity = aOpacity; }

- (void) fadeTo:(float)aOpacity speed:(float)aSpeed
{
    if(aOpacity > opacity) [self fadeIn:aOpacity speed:aSpeed];
    else if(aOpacity < opacity) [self fadeOut:aOpacity speed:aSpeed];
}

- (void) fadeIn:(float)aOpacity { fadeState = FADE_IN; fadeTo = aOpacity; }

- (void) fadeOut:(float)aOpacity  { fadeState = FADE_OUT; fadeTo = aOpacity; }

- (void) fadeIn:(float)aOpacity speed:(float)aSpeed { fadeState = FADE_IN; fadeTo = aOpacity; fadeInSpeed = aSpeed; }

- (void) fadeOut:(float)aOpacity speed:(float)aSpeed { fadeState = FADE_OUT; fadeTo = aOpacity; fadeOutSpeed = aSpeed; }

- (void) setFadeInSpeed:(float)aFadeInSpeed fadeOutSpeed:(float)aFadeOutSpeed
{
    fadeInSpeed = aFadeInSpeed;
    fadeOutSpeed = aFadeOutSpeed;
}

- (void) fadeIn:(float)aOpacity speed:(float)aSpeed outspeed:(float)aOutspeed { [self fadeIn:aOpacity speed:aSpeed]; fadeOutSpeed = aOutspeed; }

- (void) fadeOut { fadeState = FADE_OUT; }

- (void) setGlyphsScaling:(float)aScale
{
    for(TessGlyph *aGlyphs in glyphs)
    {
        [aGlyphs setSca:aScale];
    }
}


/**
 * Update contraction.
 */
-(void) updateContract {
    //apply contract acceleration
    contractVel += contractAcc;
    contractAcc = 0;
    contractFac += contractVel;
    
    //apply friction
    contractVel *= 0.8;
    if (contractVel < 0.1) {
        //decontract
        contractFac *= 0.99;
        if (!contracting) {
            contractVel = 0;
            if (contractFac < 0.001) contractFac = 0;
        }
    }
}


/**
 * Contract the word.
 * @param x x position to contract away from
 * @param y y position to contract away from
 */
-(void) contract:(float)x y:(float)y {
    
    //set contraction point
    contractFrom.x=x;
    contractFrom.y=y;
    
    //if not contraction, set the contract for the first time
    if(!contracting){
        contracting=true;
        contractStart = [self getMillis];
        
        for(TessGlyph *aTessGlyph in glyphs ){
            [aTessGlyph setContractPoint:contractFrom.x y:contractFrom.y];
            [aTessGlyph setContract:true];
        }

    }
    //if we're contracting, adjust it
    else{
                    
    }
        
   /* if (!contracting) {
        contractFrom.set(x, y, 0);
        contractPeriod = 100;
        contracting = true;
        contractStart = p.millis();
    }
    //if we're contracting, adjust it
    else {
        contractFrom.set(x, y, 0);
        contractPeriod = 100 + PApplet.sin((p.millis()-contractStart)/700.0f)*8;
    }
    */
    //apply acceleration to contraction
    if (contractFac < 1) contractAcc += (1-contractFac)/5;
}

/**
 * Starts decontracting.
 */
-(void) decontract {
    contracting = false;
    for(TessGlyph *aTessGlyph in glyphs ){
        [aTessGlyph setContract:false];
        
    }
}

/**
 * Flag the word as seen, it was made visible once.
 * @param s true to set as seen
 */
-(void) setSeen:(BOOL) s { seen = s; }

//Set current ripple 
-(void) setRipple:(Ripple*)r{
    for(TessGlyph *aGlyph in glyphs){
        [aGlyph setRipple:r];
    }
}


#pragma mark - GETTERS

- (CGRect) getAbsoluteBounds
{
    CGRect bnds = CGRectNull;
    
    for(TessGlyph *glyph in glyphs)
    {
        if(CGRectIsNull(bnds)) bnds = [glyph getAbsoluteBounds];
        else bnds = CGRectUnion(bnds, [glyph getAbsoluteBounds]);
    }
    
    return bnds;
}

- (CGSize) getSize { return size; }

- (BOOL) isInside:(OKPoint)pt {// return CGRectContainsPoint([self getAbsoluteBounds], CGPointMake(pt.x, pt.y)); }
 
    BOOL isInside = NO;
    for(TessGlyph *glyph in glyphs)
    {
        if([glyph isInside:CGPointMake(pt.x, pt.y)]) isInside = YES;
    }
    
    return isInside;
}

/*- (OKPoint) center
{
    return OKPointMake(0.0f, 0.0f, 0.0f);
}*/
- (CMTPVector3D) center { return CMTPVector3DMake(bounds.origin.x, bounds.origin.y, 0);}

- (BOOL) isFadingIn { return fadeState == FADE_IN; }

- (BOOL) isFadingOut { return fadeState == FADE_OUT; }

- (BOOL) isFadedOut { return opacity == 0; }

- (float) opacity { return opacity; }

- (NSString*) description { return [NSString stringWithFormat:@"VALUE %@ COLOR %f %f %f %f ACCURRACY %i", value, WORD_FILL_COLOR[0], WORD_FILL_COLOR[1], WORD_FILL_COLOR[2], WORD_FILL_COLOR[3], WORD_ACCURRACY]; }

- (NSString*) value { return value; }

/**
 * Check if the word is contracted.
 * @return true if contracted
 */
-(BOOL) isContracted { return contractFac != 0; }

/**
 * Check if the word is contracting.
 * @return true if contracting.
 */
-(BOOL) isContracting { return contracting; }

/**
 * Check if the word has been seen.
 * @return true if it was seen
 */
-(BOOL) wasSeen { return seen; }

/**
 * Check if the word is fading.
 * @return true if it's fading
 */
-(BOOL) isFading { return fadeState != STABLE; }


-(long long) getMillis{
    long long nowMillis = (long long)([[NSDate date] timeIntervalSince1970])*1000;
    return nowMillis;
}



- (void) dealloc
{    
    [glyphs release];
    
    [super dealloc];
}

@end






































