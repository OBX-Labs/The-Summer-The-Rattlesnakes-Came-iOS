//
//  OKTessData.m
//  OKBitmapFontSample
//
//  Created by Christian Gratton on 11-07-11.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import "OKTessData.h"


@implementation OKTessData
@synthesize ID, shapesCount, endsCount, verticesCount, verticesAr, typesAr, endsAr, /*Outlines*/ oShapesCount, oEndsCount, oIndicesCount, oEndsAr, oIndicesAr;


- (id) initWithID:(int)aID
{
    self = [self init];
	if (self != nil)
    {
		ID = aID;
	}
	return self;
}

- (void) fillVertices:(NSMutableArray*)aArray
{
    verticesCount = [aArray count]; 
    verticesAr = new GLfloat[(verticesCount*2)];
    int iterator = 0;
            
    for(int i = 0; i < verticesCount; i++)
    {
        NSArray *vertX = [NSArray arrayWithArray:[aArray objectAtIndex:i]];
        NSArray *vertY = [NSArray arrayWithArray:[aArray objectAtIndex:i]];
        
        verticesAr[iterator] = ([[vertX objectAtIndex:0] doubleValue]);
        verticesAr[(iterator + 1)] = ([[vertY objectAtIndex:1] doubleValue]);
        iterator += 2;

    }
}

- (void) fillShapes:(NSMutableArray*)aArray
{
    shapesCount = [aArray count];
    typesAr = new GLint[shapesCount];
    
    for(int i = 0; i < shapesCount; i++)
    {
        if([[aArray objectAtIndex:i] isEqualToString:@"t"])
            typesAr[i] = GL_TRIANGLES;
        else if([[aArray objectAtIndex:i] isEqualToString:@"f"])
            typesAr[i] = GL_TRIANGLE_FAN;
        else if([[aArray objectAtIndex:i] isEqualToString:@"s"])
            typesAr[i] = GL_TRIANGLE_STRIP;
    }
}

- (void) fillEnds:(NSMutableArray*)aArray
{
    endsCount = [aArray count];
    endsAr = new GLint[endsCount];
    
    for(int i = 0; i < endsCount; i++)
    {
        endsAr[i] = [[aArray objectAtIndex:i] intValue];
    }
}

// Outlines
- (void) fillOutlineEnds:(NSMutableArray*)aArray
{
    oEndsCount = [aArray count];
    oShapesCount = oEndsCount;
    
    oEndsAr = new GLint[oEndsCount];
    
    for(int i = 0; i < oEndsCount; i++)
    {
        oEndsAr[i] = [[aArray objectAtIndex:i] intValue];
    }
}

- (void) fillOutlineIndices:(NSMutableArray *)aArray
{
    oIndicesCount = [aArray count];
    
    oIndicesAr = new GLint[oIndicesCount];
    
    for(int i = 0; i < oIndicesCount; i++)
    {
        oIndicesAr[i] = [[aArray objectAtIndex:i] intValue];
    }
}

//copy
- (id) initWithCopy:(OKTessData*)aTessData
{
    self = [self init];
	if (self != nil)
    {
		ID = aTessData.ID;
        verticesCount = aTessData.verticesCount;
        shapesCount = aTessData.shapesCount;
        endsCount = aTessData.endsCount;
        
        int numVertices = verticesCount;
        verticesAr = new GLfloat[(numVertices*2)];
        memcpy(verticesAr, [aTessData getVertices], numVertices*2);
        
        int numTypes = shapesCount;
        typesAr = new GLint[numTypes];
        memcpy(typesAr, [aTessData getTypes], numTypes);
        
        int numEnds = endsCount;
        endsAr = new GLint[numEnds];
        memcpy(endsAr, [aTessData getEnds], numEnds);
        
        // Outlines
        oShapesCount = aTessData.oShapesCount;
        oEndsCount = aTessData.oEndsCount;
        oIndicesCount = aTessData.oIndicesCount;
        
        int numOutlineEnds = oEndsCount;
        oEndsAr = new GLint[numOutlineEnds];
        memcpy(oEndsAr, [aTessData getOutlineEnds], numOutlineEnds);
        
        int numOutlineIndices = oIndicesCount;
        oIndicesAr = new GLint[numOutlineIndices];
        memcpy(oIndicesAr, [aTessData getOutlineIndices], numOutlineIndices);
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	OKTessData *copy = [[[self class] allocWithZone: zone] init];
    
    copy.ID = [self ID];
    copy.verticesCount = [self verticesCount];
    copy.shapesCount = [self shapesCount];
    copy.endsCount = [self endsCount];
   
    int numVertices = [self verticesCount];
    copy.verticesAr = new GLfloat[(numVertices*2)];
    memcpy(copy.verticesAr, verticesAr, numVertices*2*sizeof(GLfloat));
    
    int numTypes = [self shapesCount];
    copy.typesAr = new GLint[numTypes];
    memcpy(copy.typesAr, typesAr, numTypes*sizeof(GLint));
    
    int numEnds = [self endsCount];
    copy.endsAr = new GLint[numEnds];
    memcpy(copy.endsAr, endsAr, numEnds*sizeof(GLint));
    
    // Outlines
    copy.oShapesCount = [self oShapesCount];
    copy.oEndsCount = [self oEndsCount];
    copy.oIndicesCount = [self oIndicesCount];
    
    int numOutlineEnds = [self oEndsCount];
    copy.oEndsAr = new GLint[numOutlineEnds];
    memcpy(copy.oEndsAr, oEndsAr, numOutlineEnds*sizeof(GLint));
    
    int numOutlineIndices = [self oIndicesCount];
    copy.oIndicesAr = new GLint[numOutlineIndices];
    memcpy(copy.oIndicesAr, oIndicesAr, numOutlineIndices*sizeof(GLint));
    
    return copy;
}

- (GLfloat*) getVertices { return verticesAr; }

- (GLfloat*) getVertices:(int)aShape
{
    return &verticesAr[(aShape == 0 ? 0 : (endsAr[(aShape - 1)] * 2))];
}

- (GLint*) getTypes { return typesAr; }
- (GLint) getType:(int)aShape { return typesAr[aShape]; }
- (GLint) numVertices { return verticesCount; }
- (GLint) numVertices:(int)aShape
{
    int shapeEnd = endsAr[aShape];
    int shapeStart = aShape == 0 ? 0 : endsAr[(aShape - 1)];
    return shapeEnd - shapeStart;
}

- (GLint*) getEnds { return endsAr; }

- (GLint) getEnds:(int)aShape { return endsAr[aShape]; }

// Outlines
- (GLint*) getOutlineEnds { return oEndsAr; }

- (GLint) getOutlineEnds:(int)aShape { return oEndsAr[aShape]; }

- (GLint*) getOutlineIndices { return oIndicesAr; }

- (GLint*) getOutlineIndices:(int)aShape { return &oIndicesAr[(aShape == 0 ? 0 : (oEndsAr[(aShape - 1)]))]; }

- (GLint) numOutlineIndices { return oIndicesCount; }

- (GLint) numOutlineIndices:(int)aShape
{
    int shapeEnd = oEndsAr[aShape];
    int shapeStart = aShape == 0 ? 0 : oEndsAr[(aShape - 1)];
    return shapeEnd - shapeStart;
}

- (void) dealloc
{
    delete [] verticesAr;
    delete [] typesAr;
    delete [] endsAr;
    
    delete [] oEndsAr;
    delete [] oIndicesAr;
    
    [super dealloc];
}

@end
