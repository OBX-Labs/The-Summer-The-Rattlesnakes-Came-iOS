//
//  TessGlyph.m
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "TessGlyph.h"
#import "OKPoEMMProperties.h"
#import "OKTessData.h"
#import "OKTessFont.h"
#import "OKCharObject.h"
#import "OKCharDef.h"
#import "Ripple.h"

//DEBUG settings
static BOOL DEBUG_BOUNDS = NO;

static float OUTLINE_WIDTH;// iPad 1.0 iPhone 2.0
static float RENDER_PADDING;// iPad 20.0f iPhone 10.0f
static float MAX_CONTRACTION_ITERATION=8;

//ripple deformation constants
/*
static float RIPPLE_LENGTH = 400;	//length of ripple wave
static int RIPPLE_CYCLES = 1;		//number of wave cycles
static float RIPPLE_AMPLITUDE = 50;	//amplitude of deformation
*/

@implementation TessGlyph
@synthesize charObj;

- (id) initWithChar:(OKCharObject*)aCharObj font:(OKTessFont*)aFont accurracy:(int)accurracy renderingBounds:(CGRect)aRenderingBounds
{
    self = [super init];
    if(self)
    {
        // Properties
        OUTLINE_WIDTH = [[OKPoEMMProperties objectForKey:OutlineWidth] floatValue];
        RENDER_PADDING = [[OKPoEMMProperties objectForKey:RenderPadding] floatValue];
        
        // Char Object
        charObj = aCharObj;
        
        // Font
        font = aFont;
        
        // Set Rendering Padding
        float x = [font getMaxWidth] + RENDER_PADDING;
        float width = aRenderingBounds.size.width + (x * 2);
        rBounds = CGRectMake(-x, aRenderingBounds.origin.y, width, aRenderingBounds.size.height);
        
        //Color
        fillClr[0] = 0.0f;
		fillClr[1] = 0.0f;
		fillClr[2] = 0.0f;
		fillClr[3] = 0.0f;
		
		outlineClr[0] = 0.0f;
		outlineClr[1] = 0.0f;
		outlineClr[2] = 0.0f;
		outlineClr[3] = 0.0f;
        
        canVertexArray = NO;
        NSString *reqVer = @"5.0.0";
        NSString *currVer = [[UIDevice currentDevice] systemVersion];
        if ([currVer compare:reqVer options:NSNumericSearch] != NSOrderedAscending)
            canVertexArray = YES;
        
        [self buildWithAccuracy:accurracy];
        
        RIPPLE_LENGTH = 200;
    }
    return self;
}




- (void) buildWithAccuracy:(int)aAccuracy
{
    //Get the center of the glyph and use that as the position
    OKPoint nPoint = [charObj getPositionAbsolute];
    CGRect gBounds = [charObj getLocalBoundingBox];
    
    OKPoint gCenter = OKPointMake((gBounds.origin.x + gBounds.size.width/2.0), (gBounds.origin.y + gBounds.size.height/2.0), 0.0);
    
    
    nPoint = OKPointAdd(nPoint, gCenter);
    //NSLog(@"GET ABS POS:%f %f", nPoint.x, nPoint.y);
    [self setPos:nPoint];
    
    //Tessalate text in original form
    OKCharDef *charDef = [font getCharDefForChar:charObj.glyph];
    origData = [self tesselate:charDef accuracy:aAccuracy];
    [charDef release];
    
    //Offset the vertices so they are relative to the glyph's position
    if(origData.endsCount > 0)
    {
        GLfloat *vertices = [origData getVertices];
        int numVertices = [origData numVertices];
                
        for(int i = 0; i < numVertices; i++)
        {
            vertices[i * 2 + 0] -= gCenter.x;
            vertices[i * 2 + 1] -= gCenter.y;
  
        }
    }
    
    //reset contraction 
    contractionIteration=0;
    contracting = FALSE;
    
    //reset decontracting
    decontracting = FALSE;
    decontractionIteration=0;
    
    //reset after ripple vertices positioning
    afterRipple = FALSE;
    
    
    //Clone to deformed data
    dfrmData = [origData copy];
    
}

-(void) setWordPosX:(float)posX y:(float)posY
{
    wordPos.x = posX;
    wordPos.y = posY;
    
}

- (OKTessData*) tesselate:(OKCharDef*)aCharDef accuracy:(int)aAccuracy
{
    return [[aCharDef.tessData objectForKey:[NSString stringWithFormat:@"%i", aAccuracy]] copy];
}

#pragma mark - DRAW


-(void) updateRipple{
    OKTessData *data = dfrmData;
    GLfloat *contractedVertices = [data getVertices];
    int numVertices = [origData numVertices];
    
    if(ripple==nil)
        return;
    Ripple *r=ripple;

    float correction;
    BOOL loadOriginal=FALSE;
    
    if(contracting)
        return;
    
   // NSLog(@"A ripple");
    for(int i = 0; i < numVertices; i++)
    {
        //get x-y coordinate of vertices 
        double vx = contractedVertices[i * 2 + 0] + wordPos.x + pos.x*sca;
        double vy = contractedVertices[i * 2 + 1] + wordPos.y + pos.y*sca;
        
        //get the distance between the vertex and the edge of the ripple
        double distSq = ((vx-r.center.x)*(vx-r.center.x) + (vy-r.center.y)*(vy-r.center.y));
        distSq = sqrt(distSq);
        double distance = distSq;
        distSq -= r.radius;
        if (distSq < 0) distSq *= -1;
        
        //if the distance square is less than the threshold, apply ripple force
        if (distSq < r.radius){
            
                //correction to apply to vertices
                correction = sinf(2*M_PI *(r.radius- distance)/(r.maxRadius/3.2));
                
                //fade with distance
                correction *= 1 - (r.radius/r.maxRadius);
            
                //modify the coordinates
                if((vx-r.center.x)>=0)
                    contractedVertices[i * 2 + 0] = contractedVertices[i * 2 + 0] +  (vx-r.center.x)/distance * correction;
                else
                    contractedVertices[i * 2 + 0] = contractedVertices[i * 2 + 0] -  (r.center.x-vx)/distance * correction;
                if((vy-r.center.y)>=0)
                    contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] +  (vy-r.center.y)/distance * correction;
                else
                    contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] -  (r.center.y-vy)/distance * correction;
        }
        else{
            //loadOriginal=TRUE;
            break;
      
        }
            
    }
    if(loadOriginal){
        NSLog(@"Load original");
        contracting=false;
        decontracting=false;
    }

}


- (void) setRipple:(Ripple*)aRipple{
    ripple = aRipple;
    if(aRipple==nil){
        afterRipple=true;
        afterRippleIteration = 10;
        
        contracting=false;
        decontracting=false;
    }
}

-(void) updateContraction{
    
    OKTessData *data = dfrmData;
    GLfloat *contractedVertices = [data getVertices];
    int numVertices = [origData numVertices];
    BOOL atLeastOneVerticesContracted=false;
    
    //if we are in contracting mode, deform data
    if(contracting){
        //make sure we don't go beyond the max iteration
        if(contractionIteration < MAX_CONTRACTION_ITERATION){
            for(int i = 0; i < numVertices; i++)
            {
                //deform y position of vertices if vertices x is positionned near of the contract position
                float distanceFromContraction = fabsf( (wordPos.x + pos.x*sca + contractedVertices[i * 2 + 0]*sca)- contractPosition.x);
                if( distanceFromContraction < (rBounds.size.width/50)*sca){
                    
                    contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] + bounds.size.height/2;
                    float contractValue = ((cosf(distanceFromContraction/((rBounds.size.width/50)*sca)*M_PI)+1)/2)/MAX_CONTRACTION_ITERATION;
                    if(contractValue>0.01)
                        atLeastOneVerticesContracted=true;
                    contractedVertices[i * 2 + 1] *= 1 - contractValue;
                    contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] - bounds.size.height/2;
                  
                }
            }
            //if no vertices got contracted, no need to try contracting the glyphs anymore.
            if(atLeastOneVerticesContracted==false)
                contracting=false;
            
            contractionIteration++;
        }
        else{
            //set decontraction with approximate number of iteration to reform the vertices
            decontractionIteration = contractionIteration;
            decontracting=TRUE;
            
            //reset contraction
            contracting = FALSE;
            contractionIteration=0;
        }
    }
    else if(decontracting){
        //we are in decontracting mode
        [self decontract];
    }
        
}


-(void) decontract{
    
    //load deformed data
    OKTessData *data = dfrmData;
    GLfloat *contractedVertices = [data getVertices];
    int numVertices = [origData numVertices];
    
    //load original data
    OKTessData *oData = [origData copy];
    GLfloat *oVertices = [oData getVertices];
    
    //put back vertices to original position... slowly
    if(decontractionIteration>=0){
        for(int i = 0; i < numVertices; i++){
            //calculate distance between actual vertice position to original position
            float xDist = oVertices[i * 2 + 0] - contractedVertices[i * 2 + 0];
            float yDist = oVertices[i * 2 + 1] - contractedVertices[i * 2 + 1];
            contractedVertices[i * 2 + 0] = contractedVertices[i * 2 + 0] + xDist/20;
            contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] + yDist/20;
        }
        decontractionIteration=decontractionIteration-0.1;
    }
    //process is done
    else{
        decontracting=FALSE;
        decontractionIteration=0;
        
        //reload original glyph (to make sure we really come back to original form)
        dfrmData = [origData copy];
    }
    
    [oData release];
    
}


-(void) afterRippleVerticesBackToOriginal{
    
    //if glyphs is contracting or decontracting, no ripple effect was applied.
    if(contracting || decontracting)
        return;
    
    //load deformed data
    OKTessData *data = dfrmData;
    GLfloat *contractedVertices = [data getVertices];
    int numVertices = [origData numVertices];
    
    //load original data
    OKTessData *oData = [origData copy];
    GLfloat *oVertices = [oData getVertices];
    
    //put back vertices to original position... slowly
    if(afterRippleIteration>=0){
        for(int i = 0; i < numVertices; i++){
            //calculate distance between actual vertice position to original position
            float xDist = oVertices[i * 2 + 0] - contractedVertices[i * 2 + 0];
            float yDist = oVertices[i * 2 + 1] - contractedVertices[i * 2 + 1];
            contractedVertices[i * 2 + 0] = contractedVertices[i * 2 + 0] + xDist/10;
            contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] + yDist/10;
        }
        afterRippleIteration=afterRippleIteration-0.1;
    }
    //process is done
    else{
        afterRipple = false;
    }
    
    [oData release];
}

- (void) drawShadow
{
    //work on a copy of data
    OKTessData *shadowData = [dfrmData copy];
    GLfloat *shadowVertices = [shadowData getVertices];
    int numVertices = [origData numVertices];
    
    double vx = wordPos.x + pos.x*sca;
    float scaling = 0.7*((rBounds.size.width/2)-vx)/(rBounds.size.width/2);
    float scaling2 = 0.7*(1-((rBounds.size.width-vx)/(rBounds.size.width/2)));
    
    for(int i = 0; i < numVertices; i++){
       
        if(vx<rBounds.size.width/2){
            shadowVertices[i * 2 + 1] = shadowVertices[i * 2 + 1] + bounds.size.height/2;
            shadowVertices[i * 2 + 0] = shadowVertices[i * 2 + 0] + scaling * bounds.size.height * (1-((bounds.size.height - shadowVertices[i * 2 + 1])/bounds.size.height));
            
            shadowVertices[i * 2 + 1] = shadowVertices[i * 2 + 1] * 0.6;
            shadowVertices[i * 2 + 1] = shadowVertices[i * 2 + 1] - bounds.size.height/2;
        }
        else
        {
            shadowVertices[i * 2 + 1] = shadowVertices[i * 2 + 1] + bounds.size.height/2;
            shadowVertices[i * 2 + 0] = shadowVertices[i * 2 + 0] - scaling2 * bounds.size.height * (1-((bounds.size.height - shadowVertices[i * 2 + 1])/bounds.size.height));
            shadowVertices[i * 2 + 1] = shadowVertices[i * 2 + 1] * 0.6;
            shadowVertices[i * 2 + 1] = shadowVertices[i * 2 + 1] - bounds.size.height/2;
        }
    }
    
    glPushMatrix();
    glTranslatef(pos.x, pos.y, pos.z);
    //Draw deformed data
    if(shadowData)
    {
        OKTessData *data = shadowData;
        if(data.endsCount > 0)
        {
            //sBounds
            if(![self isOutside:rBounds])
            {
                //use black color, with current opacity
                glColor4f(0, 0, 0, fillClr[3]*0.15);
                // glColor4f(0, 0, 0, 1);
                
                // Fill
                for(int i = 0; i < data.shapesCount; i++)
                {
                    glVertexPointer(2, GL_FLOAT, 0, [data getVertices:i]);
                    glDrawArrays([data getType:i], 0, [data numVertices:i]);
                }
            }
        }
    }
    
    glPopMatrix();

    [shadowData release];
   
}


- (void) draw
{
    //Transform
    glPushMatrix();
    
    glTranslatef(pos.x, pos.y, pos.z);
    //glScalef(sca, sca, 0.0);
    
    //Keep track of bounding box
    float minX = CGFLOAT_MAX;
    float minY = CGFLOAT_MAX;
    float maxX = CGFLOAT_MIN;
    float maxY = CGFLOAT_MIN;
    
    //Draw deformed data
    if(dfrmData)
    {
        OKTessData *data = dfrmData;
        
        if(data.endsCount > 0)
        {
            //sBounds
            if(![self isOutside:rBounds])
            {
                glColor4f(fillClr[0], fillClr[1], fillClr[2], fillClr[3]);
                //glColor4f(fillClr[0], fillClr[1], fillClr[2], 1);
                
                //contract glyph where snake bite
                [self updateContraction];
                
                //update ripple effect only on glyph not being contracted
                if(!contracting && !decontracting)
                    [self updateRipple];
                
                //put back vertices to their normal position after a ripple
                if(afterRipple)
                    [self afterRippleVerticesBackToOriginal];
                
                // Fill
                for(int i = 0; i < data.shapesCount; i++)
                {
                    glVertexPointer(2, GL_FLOAT, 0, [data getVertices:i]);
                    glDrawArrays([data getType:i], 0, [data numVertices:i]);
                    
                }
                
                glColor4f(outlineClr[0], outlineClr[1], outlineClr[2], outlineClr[3]);
                
                /*
                // Outline
                for(int i = 0; i < data.oShapesCount; i++)
                {
                    if(canVertexArray)
                    {
                        glEnable(GL_LINE_SMOOTH);
                        
                        //glEnableClientState(GL_VERTEX_ARRAY);
                        glVertexPointer(2, GL_FLOAT, 0, [data getVertices]);
                        glLineWidth(OUTLINE_WIDTH);
                        glDrawElements(GL_LINE_LOOP, [data numOutlineIndices:i], GL_UNSIGNED_INT, [data getOutlineIndices:i]);
                        
                        glDisable(GL_LINE_SMOOTH);
                    }
                    else
                    {
                        // Variables
                        GLfloat *vertices = [data getVertices]; // get existing verts (all of them since there are more shapes in fill than stroke)
                        int numIndices = [data numOutlineIndices:i]; // indexes in outline
                        GLfloat *vert = new GLfloat[numIndices * 2]; // create new array to store outline vertices based on fill
                        //GLfloat *vert = new GLfloat[numIndices * 3]; // create new array to store outline vertices based on fill

                        GLint *indices = [data getOutlineIndices:i]; // get array of indexes
                        
                        for(int j = 0; j < numIndices; j++)
                        {
                            vert[j * 2 + 0] = vertices[indices[j] * 2 + 0]; // x
                            vert[j * 2 + 1] = vertices[indices[j] * 2 + 1]; // y
                           // vert[j * 3 + 0] = vertices[indices[j] * 3 + 0]; // x
                           // vert[j * 3 + 1] = vertices[indices[j] * 3 + 1]; // y
                           // vert[j * 3 + 2] = 0;

                        }
                        
                        // Draw outline
                        glEnable(GL_LINE_SMOOTH);
                        
                        glVertexPointer(2, GL_FLOAT, 0, vert);
                        //glVertexPointer(3, GL_FLOAT, 0, vert);

                        glLineWidth(OUTLINE_WIDTH);
                        glDrawArrays(GL_LINE_LOOP, 0, numIndices);
                        
                        glDisable(GL_LINE_SMOOTH);
                    }
                }*/
            }
            
            // Determine bounds for actual glyph
            GLfloat *vertices = [origData getVertices:0];
            
            for(int i = 0; i < origData.verticesCount; i++)
            {
                if(vertices[i * 2 + 0] < minX) minX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 0] > maxX) maxX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 1] < minY) minY = vertices[i * 2 + 1];
                if(vertices[i * 2 + 1] > maxY) maxY = vertices[i * 2 + 1];
            }
        }
        else // Should be space
        {
            if([charObj.glyph isEqualToString:@" "])
            {
                minX = [charObj getMinX];
                maxX = [charObj getMaxX];
                minY = [charObj getMinY];
                maxY = [charObj getMaxY];
            }
        }
    }
    
    bounds = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    glPushMatrix();
    
    glGetFloatv(GL_MODELVIEW_MATRIX, modelview);
    
    glPopMatrix();
    
    glGetFloatv(GL_PROJECTION_MATRIX, projection);
    
    //Might need to offset to absPos of Glyph
    CGPoint aPointMin = [self convertPoint:CGPointMake(minX, minY) withZ:0.0];
    CGPoint aPointMax = [self convertPoint:CGPointMake(maxX, maxY) withZ:0.0];

    absBounds = CGRectMake(aPointMin.x, aPointMin.y, aPointMax.x - aPointMin.x, aPointMax.y - aPointMin.y);
    
    //NSLog(@"A POINT: %f %f", pos.x, pos.y);
    if(absBounds.size.width < 1) absBounds.size.width++;
    if(absBounds.size.height < 1) absBounds.size.height++;
    
    if(DEBUG_BOUNDS)
        [self drawDebugBoundsForMinX:minX maxX:maxX minY:minY maxY:maxY];
    
    glPopMatrix();
}

- (void) drawFill
{
    //Transform
    glPushMatrix();
    
    glTranslatef(pos.x, pos.y, pos.z);
    
    glScalef(sca, sca, 0.0);
    
    //Keep track of bounding box
    float minX = CGFLOAT_MAX;
    float minY = CGFLOAT_MAX;
    float maxX = CGFLOAT_MIN;
    float maxY = CGFLOAT_MIN;
        
    //Draw deformed data
    if(dfrmData)
    {
        OKTessData *data = dfrmData;
            
        if(data.endsCount > 0)
        {
            //sBounds
            if(![self isOutside:rBounds])
            {
                glColor4f(fillClr[0], fillClr[1], fillClr[2], fillClr[3]);
                
                for(int i = 0; i < data.shapesCount; i++)
                {
                    glVertexPointer(2, GL_FLOAT, 0, [data getVertices:i]);
                    //glEnableClientState(GL_VERTEX_ARRAY);
                    glDrawArrays([data getType:i], 0, [data numVertices:i]);
                }
            }
                        
            // Determine bounds for actual glyph
            GLfloat *vertices = [origData getVertices:0];
            
            for(int i = 0; i < origData.verticesCount; i++)
            {
                if(vertices[i * 2 + 0] < minX) minX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 0] > maxX) maxX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 1] < minY) minY = vertices[i * 2 + 1];
                if(vertices[i * 2 + 1] > maxY) maxY = vertices[i * 2 + 1];
            }
        }
        else // Should be space
        {
            if([charObj.glyph isEqualToString:@" "])
            {
                minX = [charObj getMinX];
                maxX = [charObj getMaxX];
                minY = [charObj getMinY];
                maxY = [charObj getMaxY];
            }
        }
    }
    
    bounds = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    glPushMatrix();
    
    glGetFloatv(GL_MODELVIEW_MATRIX, modelview);
    
    glPopMatrix();
    
    glGetFloatv(GL_PROJECTION_MATRIX, projection);
    
    //Might need to offset to absPos of Glyph
    CGPoint aPointMin = [self convertPoint:CGPointMake(minX, minY) withZ:0.0];
    CGPoint aPointMax = [self convertPoint:CGPointMake(maxX, maxY) withZ:0.0];
    
    absBounds = CGRectMake(aPointMin.x, aPointMin.y, aPointMax.x - aPointMin.x, aPointMax.y - aPointMin.y);
    
    if(absBounds.size.width < 1) absBounds.size.width++;
    if(absBounds.size.height < 1) absBounds.size.height++;
    
    if(DEBUG_BOUNDS)
        [self drawDebugBoundsForMinX:minX maxX:maxX minY:minY maxY:maxY];
    
    glPopMatrix();
}

- (void) drawOutline
{    
    //Transform
    glPushMatrix();
    glTranslatef(pos.x, pos.y, pos.z);
    glScalef(sca, sca, 0.0);
    
    //Keep track of bounding box
    float minX = CGFLOAT_MAX;
    float minY = CGFLOAT_MAX;
    float maxX = CGFLOAT_MIN;
    float maxY = CGFLOAT_MIN;
    
    //Draw deformed data
    if(dfrmData)
    {
        OKTessData *data = dfrmData;
        
        if(data.endsCount > 0)
        {
            //sBounds
            if(![self isOutside:rBounds])
            {
                glColor4f(outlineClr[0], outlineClr[1], outlineClr[2], outlineClr[3]);
                
                for(int i = 0; i < data.oShapesCount; i++)
                {
                    if(canVertexArray)
                    {
                        glEnable(GL_LINE_SMOOTH);
                        
                        //glEnableClientState(GL_VERTEX_ARRAY);
                        glVertexPointer(2, GL_FLOAT, 0, [data getVertices]);
                        glLineWidth(OUTLINE_WIDTH);
                        glDrawElements(GL_LINE_LOOP, [data numOutlineIndices:i], GL_UNSIGNED_INT, [data getOutlineIndices:i]);
                        
                        glDisable(GL_LINE_SMOOTH);
                    }
                    else
                    {
                        // Variables
                        GLfloat *vertices = [data getVertices]; // get existing verts (all of them since there are more shapes in fill than stroke)
                        int numIndices = [data numOutlineIndices:i]; // indexes in outline
                        GLfloat *vert = new GLfloat[numIndices * 2]; // create new array to store outline vertices based on fill
                        GLint *indices = [data getOutlineIndices:i]; // get array of indexes
                        
                        for(int j = 0; j < numIndices; j++)
                        {
                            vert[j * 2 + 0] = vertices[indices[j] * 2 + 0]; // x
                            vert[j * 2 + 1] = vertices[indices[j] * 2 + 1]; // y
                        }
                        
                        // Draw outline
                        glEnable(GL_LINE_SMOOTH);
                        
                        glVertexPointer(2, GL_FLOAT, 0, vert);
                        glLineWidth(OUTLINE_WIDTH);
                        glDrawArrays(GL_LINE_LOOP, 0, numIndices);
                        
                        glDisable(GL_LINE_SMOOTH);
                    }
                }
            }
                        
            // Determine bounds for actual glyph
            GLfloat *vertices = [origData getVertices:0];
            
            for(int i = 0; i < origData.verticesCount; i++)
            {
                if(vertices[i * 2 + 0] < minX) minX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 0] > maxX) maxX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 1] < minY) minY = vertices[i * 2 + 1];
                if(vertices[i * 2 + 1] > maxY) maxY = vertices[i * 2 + 1];
            }
        }
        else // Should be space
        {
            if([charObj.glyph isEqualToString:@" "])
            {
                minX = [charObj getMinX];
                maxX = [charObj getMaxX];
                minY = [charObj getMinY];
                maxY = [charObj getMaxY];
            }
        }
    }
    
    bounds = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    glPushMatrix();
    
    glGetFloatv(GL_MODELVIEW_MATRIX, modelview);
    
    glPopMatrix();
    
    glGetFloatv(GL_PROJECTION_MATRIX, projection);
    
    //Might need to offset to absPos of Glyph
    CGPoint aPointMin = [self convertPoint:CGPointMake(minX, minY) withZ:0.0];
    CGPoint aPointMax = [self convertPoint:CGPointMake(maxX, maxY) withZ:0.0];
        
    absBounds = CGRectMake(aPointMin.x, aPointMin.y, aPointMax.x - aPointMin.x, aPointMax.y - aPointMin.y);
    
    if(absBounds.size.width < 1) absBounds.size.width++;
    if(absBounds.size.height < 1) absBounds.size.height++;
        
    if(DEBUG_BOUNDS)
        [self drawDebugBoundsForMinX:minX maxX:maxX minY:minY maxY:maxY];
    
    glPopMatrix();
}

- (void) drawDebugBoundsForMinX:(float)minX maxX:(float)maxX minY:(float)minY maxY:(float)maxY
{
    //debug bounding box
    const GLfloat line[] =
    {
        minX, minY, //point A
        minX, maxY, //point B
        maxX, maxY, //point C
        maxX, minY, //point D
    };
    
    glVertexPointer(2, GL_FLOAT, 0, line);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
}

- (void) update:(long)dt
{
    [super update:dt];
}

#pragma mark - COLOR

- (float*) getFillColor { return fillClr; }

- (float*) getOutlineColor  { return outlineClr; }

- (void) setFillColor:(float*)clr { fillClr[0] = clr[0]; fillClr[1] = clr[1]; fillClr[2] = clr[2]; fillClr[3] = clr[3]; }

- (void) setOutlineColor:(float*)clr { outlineClr[0] = clr[0]; outlineClr[1] = clr[1]; outlineClr[2] = clr[2]; outlineClr[3] = clr[3]; }

#pragma mark - PROPERTIES

- (BOOL) isOutside:(CGRect)b { return (CGRectIntersectsRect(b, absBounds) ? NO : YES); }

- (BOOL) isInside:(CGPoint)p { return (CGRectContainsPoint(absBounds, p) ? YES : NO); }

#pragma mark - GETTERS

- (CGRect) getBounds { return bounds; }

- (CGRect) getAbsoluteBounds { return absBounds; }

- (OKPoint) getAbsoluteCoordinates { return OKPointMake(absBounds.origin.x, absBounds.origin.y, 0.0); }

- (OKPoint) transform:(OKPoint)aPoint
{
    OKPoint ac = [self getAbsoluteCoordinates];
    OKPoint ptSca = aPoint;
    
    return OKPointMake(ac.x + ptSca.x, ac.y + ptSca.y, ac.z + ptSca.z);
}

#pragma mark - POINT CONVERSION

- (CGPoint) convertPoint:(CGPoint)aPoint withZ:(float)z
{
    float ax = ((modelview[0] * aPoint.x) + (modelview[4] * aPoint.y) + (modelview[8] * z) + modelview[12]);
	float ay = ((modelview[1] * aPoint.x) + (modelview[5] * aPoint.y) + (modelview[9] * z) + modelview[13]);
	float az = ((modelview[2] * aPoint.x) + (modelview[6] * aPoint.y) + (modelview[10] * z) + modelview[14]);
	float aw = ((modelview[3] * aPoint.x) + (modelview[7] * aPoint.y) + (modelview[11] * z) + modelview[15]);
	
	float ox = ((projection[0] * ax) + (projection[4] * ay) + (projection[8] * az) + (projection[12] * aw));
	float oy = ((projection[1] * ax) + (projection[5] * ay) + (projection[9] * az) + (projection[13] * aw));
	float ow = ((projection[3] * ax) + (projection[7] * ay) + (projection[11] * az) + (projection[15] * aw));
	
	if(ow != 0)
		ox /= ow;
	
	if(ow != 0)
		oy /= ow;
	
	return CGPointMake(([UIScreen mainScreen].bounds.size.height * (1 + ox) / 2.0f), ([UIScreen mainScreen].bounds.size.width * (1 + oy) / 2.0f));
}

#pragma mark - RANDOM

- (float) floatRandom
{
    return (float)arc4random()/ARC4RANDOM_MAX;
}

- (float) arc4randomf:(float)max :(float)min
{
    return ((max - min) * [self floatRandom]) + min;
}


- (void) setContractPoint:(float)x y:(float)y{
    contractPosition.x=x;
    contractPosition.y=y;
}

- (void) setContract:(BOOL)aContractState{
    contracting = aContractState;
}

- (void) dealloc
{
    [origData release];
    [dfrmData release];
    
    [super dealloc];
}

@end
