//
//  OKImage.h
//  ObxKit
//
//  Created by Christian Gratton based on AngelFont provided by 71Squared.com
//

#import <Foundation/Foundation.h>
#import "OKTexture2D.h"

typedef struct _Quad2
{
	float tl_x, tl_y;
	float tr_x, tr_y;
	float bl_x, bl_y;
	float br_x, br_y;
} Quad2;

@interface OKImage : NSObject
{
	// The OpenGL texture to be used for this image
	OKTexture2D		*texture;	
	// The width of the image
	NSUInteger		imageWidth;
	// The height of the image
	NSUInteger		imageHeight;
	// The texture coordinate width to use to find the image
	NSUInteger		textureWidth;
	// The texture coordinate height to use to find the image
	NSUInteger		textureHeight;
	// The maximum texture coordinate width maximum 1.0f
	float			maxTexWidth;
	// The maximum texture coordinate height maximum 1.0f
	float			maxTexHeight;
	// The texture width to pixel ratio
	float			texWidthRatio;
	// The texture height to pixel ratio
	float			texHeightRatio;
	// The X offset to use when looking for our image
	NSUInteger		textureOffsetX;
	// The Y offset to use when looking for our image
	NSUInteger		textureOffsetY;
	// Angle to which the image should be rotated
	float			rotation;
	// Scale at which to draw the image
	float			scale;
	// Flip horizontally
	BOOL			flipHorizontally;
	// Flip Vertically
	BOOL			flipVertically;
	// Colour Filter = Red, Green, Blue, Alpha
	float			colourFilter[4];
	//Vertex Arrays
	Quad2 *vertices;
	Quad2 *texCoords;
	GLushort *indices;
}

@property(nonatomic, readonly) OKTexture2D *texture;
@property(nonatomic) NSUInteger	imageWidth;
@property(nonatomic) NSUInteger imageHeight;
@property(nonatomic, readonly) NSUInteger textureWidth;
@property(nonatomic, readonly) NSUInteger textureHeight;
@property(nonatomic, readonly) float	texWidthRatio;
@property(nonatomic, readonly) float texHeightRatio;
@property(nonatomic) NSUInteger	textureOffsetX;
@property(nonatomic) NSUInteger textureOffsetY;
@property(nonatomic) float rotation;
@property(nonatomic) float scale;
@property(nonatomic) BOOL flipVertically;
@property(nonatomic) BOOL flipHorizontally;
@property(nonatomic) Quad2 *vertices;
@property(nonatomic) Quad2 *texCoords;

// Initializers

- (id)initWithImage:(UIImage *)image scale:(float)imageScale filter:(GLenum)filter;

// Action methods
- (void)calculateVerticesAtPoint:(CGPoint)point subImageWidth:(GLuint)subImageWidth subImageHeight:(GLuint)subImageHeight centerOfImage:(BOOL)center;
- (void)calculateTexCoordsAtOffset:(CGPoint)offsetPoint subImageWidth:(GLuint)subImageWidth subImageHeight:(GLuint)subImageHeight;


@end
