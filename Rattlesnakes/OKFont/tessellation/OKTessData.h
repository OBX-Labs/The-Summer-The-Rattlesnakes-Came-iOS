//
//  OKTessData.h
//  OKBitmapFontSample
//
//  Created by Christian Gratton on 11-07-11.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface OKTessData : NSObject
{
    int ID;
    int shapesCount;
    int endsCount;
    int verticesCount;
    GLfloat *verticesAr;
    GLint *typesAr;
    GLint *endsAr;
    
    // Outlines
    int oShapesCount;
    int oEndsCount;
    int oIndicesCount;
    GLint *oEndsAr;
    GLint *oIndicesAr;
}

@property int ID;
@property int shapesCount;
@property int endsCount;
@property int verticesCount;
@property(nonatomic) GLfloat *verticesAr;
@property(nonatomic) GLint *typesAr;
@property(nonatomic) GLint *endsAr;
// Outlines
@property int oShapesCount;
@property int oEndsCount;
@property int oIndicesCount;
@property(nonatomic) GLint *oEndsAr;
@property(nonatomic) GLint *oIndicesAr;

- (id) initWithID:(int)aID;
- (id) initWithCopy:(OKTessData*)aTessData;

- (void) fillVertices:(NSMutableArray*)aArray;
- (void) fillShapes:(NSMutableArray*)aArray;
- (void) fillEnds:(NSMutableArray*)aArray;

// Outlines
- (void) fillOutlineEnds:(NSMutableArray*)aArray;
- (void) fillOutlineIndices:(NSMutableArray *)aArray;

- (GLfloat*) getVertices;
- (GLfloat*) getVertices:(int)aShape;
- (GLint*) getTypes;
- (GLint) getType:(int)aShape;
- (GLint) numVertices;
- (GLint) numVertices:(int)aShape;
- (GLint*) getEnds;
- (GLint) getEnds:(int)aShape;

// Outlines
- (GLint*) getOutlineEnds;
- (GLint) getOutlineEnds:(int)aShape;
- (GLint*) getOutlineIndices;
- (GLint*) getOutlineIndices:(int)aShape;
- (GLint) numOutlineIndices;
- (GLint) numOutlineIndices:(int)aShape;

@end
