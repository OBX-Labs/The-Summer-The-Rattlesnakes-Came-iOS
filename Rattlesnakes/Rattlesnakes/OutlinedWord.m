//
//  OutlinedWord.m
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OutlinedWord.h"
#import "OKPoEMMProperties.h"

#import "OKTessFont.h"
#import "TessGlyph.h"

#import "OKWordObject.h"
#import "OKCharObject.h"

//DEBUG settings
static BOOL DEBUG_BOUNDS = NO;
static float OUTLINED_WORD_FILL_COLOR[] = {1.0, 1.0, 1.0, 0.0};
static float OUTLINED_WORD_OUTLINE_COLOR[] = {0.0, 0.0, 0.0, 0.0};
static int OUTLINED_WORD_ACCURRACY;// iPad 3 iPhone 3

@implementation OutlinedWord

- (id) initWithWord:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds
{
    self = [super init];
    if(self)
    {
        // Properties
        NSArray *fillClr = [OKPoEMMProperties objectForKey:OutlinedWordFillColor];
        OUTLINED_WORD_FILL_COLOR[0] = [[fillClr objectAtIndex:0] floatValue];
        OUTLINED_WORD_FILL_COLOR[1] = [[fillClr objectAtIndex:1] floatValue];
        OUTLINED_WORD_FILL_COLOR[2] = [[fillClr objectAtIndex:2] floatValue];
        OUTLINED_WORD_FILL_COLOR[3] = [[fillClr objectAtIndex:3] floatValue];
        NSArray *outlineClr = [OKPoEMMProperties objectForKey:OutlinedWordOutlineColor];
        OUTLINED_WORD_OUTLINE_COLOR[0] = [[outlineClr objectAtIndex:0] floatValue];
        OUTLINED_WORD_OUTLINE_COLOR[1] = [[outlineClr objectAtIndex:1] floatValue];
        OUTLINED_WORD_OUTLINE_COLOR[2] = [[outlineClr objectAtIndex:2] floatValue];
        OUTLINED_WORD_OUTLINE_COLOR[3] = [[outlineClr objectAtIndex:3] floatValue];
        OUTLINED_WORD_ACCURRACY = [[OKPoEMMProperties objectForKey:OutlinedWordTessellationAccurracy] intValue];
        
        // Font
        font = aFont;
        
        // Size
        size = CGSizeMake([aWordObj getWitdh], [aWordObj getHeight]);
        
        opacity = 0.0f;
        
        // Glyphs
        glyphs = [[NSMutableArray alloc] init];
        
        // Build
        [self build:aWordObj renderingBounds:aRenderingBounds];
    }
    return self;
}

- (void) build:(OKWordObject*)aWordObj renderingBounds:(CGRect)aRenderingBounds
{
    value = [[NSString alloc] initWithString:aWordObj.word];
    
    for(OKCharObject *charObj in aWordObj.charObjects)
    {
        TessGlyph *glyph = [[TessGlyph alloc] initWithChar:charObj font:font accurracy:OUTLINED_WORD_ACCURRACY renderingBounds:aRenderingBounds];
        [glyph setFillColor:OUTLINED_WORD_FILL_COLOR];
        [glyph setOutlineColor:OUTLINED_WORD_OUTLINE_COLOR];
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
        [tg draw];
    }
    
    if(DEBUG_BOUNDS) [self drawDebugBounds];
    
    glPopMatrix();
}

- (void) drawFill
{
    //Transform
    glPushMatrix();
    glTranslatef(pos.x, pos.y, pos.z);
    
    for(TessGlyph *tg in glyphs)
    {        
        [tg drawFill];
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
        [tg drawOutline];
    }
    
    if(DEBUG_BOUNDS) [self drawDebugBounds];
    
    glPopMatrix();
}

- (void) drawDebugBounds
{
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
    
    [self updateGlyphs:dt];
}

- (void) updateGlyphs:(long)dt
{
    for(TessGlyph *tg in glyphs)
    {        
        [tg update:dt];
        
        // Fade colors
        // Fill
        float *fillClr = [tg getFillColor];
        fillClr[3] = opacity;
        [tg setFillColor:fillClr];
        
        // Outline
        float *outlineClr = [tg getOutlineColor];
        outlineClr[3] = opacity;        
        [tg setOutlineColor:outlineClr];
    }
}

- (void) setOpacity:(float)aOpacity {opacity = aOpacity; }

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

- (NSString*) description { return [NSString stringWithFormat:@"VALUE %@ COLOR %f %f %f %f OUTLINE COLOR %f %f %f %f ACCURRACY %i", value, OUTLINED_WORD_FILL_COLOR[0], OUTLINED_WORD_FILL_COLOR[1], OUTLINED_WORD_FILL_COLOR[2], OUTLINED_WORD_FILL_COLOR[3], OUTLINED_WORD_OUTLINE_COLOR[0], OUTLINED_WORD_OUTLINE_COLOR[1], OUTLINED_WORD_OUTLINE_COLOR[2], OUTLINED_WORD_OUTLINE_COLOR[3], OUTLINED_WORD_ACCURRACY]; }

- (void) dealloc
{
    [glyphs release];
    
    [super dealloc];
}

@end
























