//
//  OKImage.m
//  ObxKit
//
//  Created by Christian Gratton based on AngelFont provided by 71Squared.com
//

#import "OKImage.h"

// Private methods
@interface OKImage ()
- (void)initImpl;
@end

@implementation OKImage

@synthesize	texture, imageWidth, imageHeight, textureWidth, textureHeight, texWidthRatio, texHeightRatio, textureOffsetX, textureOffsetY, rotation, scale, flipHorizontally, flipVertically, vertices, texCoords;

- (void)dealloc {
	
	if(texture)
		[texture release];
	[super dealloc];
}

- (id)initWithImage:(UIImage *)image scale:(float)imageScale filter:(GLenum)filter {
	self = [super init];
	if (self != nil) {
		texture = [[OKTexture2D alloc] initWithImage:image filter:filter];
		scale = imageScale;
		[self initImpl];
	}
	return self;
}


- (void)initImpl {
	imageWidth = texture.contentSize.width;
	imageHeight = texture.contentSize.height;
	textureWidth = texture.pixelsWide;
	textureHeight = texture.pixelsHigh;
	maxTexWidth = imageWidth / (float)textureWidth;
	maxTexHeight = imageHeight / (float)textureHeight;
	texWidthRatio = 1.0f / (float)textureWidth;
	texHeightRatio = 1.0f / (float)textureHeight;
	textureOffsetX = 0;
	textureOffsetY = 0;
	rotation = 0.0f;
	colourFilter[0] = 1.0f;
	colourFilter[1] = 1.0f;
	colourFilter[2] = 1.0f;
	colourFilter[3] = 1.0f;
	
	// Init vertex arrays
	int totalQuads = 1;
	texCoords = malloc( sizeof(texCoords[0]) * totalQuads);
	vertices = malloc( sizeof(vertices[0]) * totalQuads);
	indices = malloc( sizeof(indices[0]) * totalQuads * 6);
	
	bzero( texCoords, sizeof(texCoords[0]) * totalQuads);
	bzero( vertices, sizeof(vertices[0]) * totalQuads);
	bzero( indices, sizeof(indices[0]) * totalQuads * 6);
	
	for( NSUInteger i=0;i<totalQuads;i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;
		indices[i*6+5] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+3] = i*4+3;
	}
}


- (NSString *)description {
	return [NSString stringWithFormat:@"texture:%d width:%d height:%d texWidth:%d texHeight:%d maxTexWidth:%f maxTexHeight:%f angle:%f scale:%f", [texture name], imageWidth, imageHeight, textureWidth, textureHeight, maxTexWidth, maxTexHeight, rotation, scale];
}

- (void)calculateTexCoordsAtOffset:(CGPoint)offsetPoint subImageWidth:(GLuint)subImageWidth subImageHeight:(GLuint)subImageHeight {
	// Calculate the texture coordinates using the offset point from which to start the image and then using the width and height
	// passed in
	
	if(!flipHorizontally && !flipVertically) {
		texCoords[0].br_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].br_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].tr_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tr_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].bl_x = texWidthRatio * offsetPoint.x;
		texCoords[0].bl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].tl_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
	
	if(flipVertically && flipHorizontally) {
		texCoords[0].tl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].bl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].bl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].tr_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tr_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].br_x = texWidthRatio * offsetPoint.x;
		texCoords[0].br_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
	
	if(flipHorizontally) {
		texCoords[0].bl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].bl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].tl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].br_x = texWidthRatio * offsetPoint.x;
		texCoords[0].br_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].tr_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tr_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
	
	if(flipVertically) {
		texCoords[0].tr_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tr_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].br_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].br_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].tl_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].bl_x = texWidthRatio * offsetPoint.x;
		texCoords[0].bl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
	
	if(flipVertically && flipHorizontally) {
		texCoords[0].tl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].bl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].bl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].tr_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tr_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].br_x = texWidthRatio * offsetPoint.x;
		texCoords[0].br_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
}


- (void)calculateVerticesAtPoint:(CGPoint)point subImageWidth:(GLuint)subImageWidth subImageHeight:(GLuint)subImageHeight centerOfImage:(BOOL)center {
	
	// Calculate the width and the height of the quad using the current image scale and the width and height
	// of the image we are going to render
	GLfloat quadWidth = subImageWidth * scale;
	GLfloat quadHeight = subImageHeight * scale;
	
	// Define the vertices for each corner of the quad which is going to contain our image.
	// We calculate the size of the quad to match the size of the subimage which has been defined.
	// If center is true, then make sure the point provided is in the center of the image else it will be
	// the bottom left hand corner of the image
	if(center) {
		vertices[0].br_x = point.x + quadWidth / 2;
		vertices[0].br_y = point.y + quadHeight / 2;
		
		vertices[0].tr_x = point.x + quadWidth / 2;
		vertices[0].tr_y = point.y + -quadHeight / 2;
		
		vertices[0].bl_x = point.x + -quadWidth / 2;
		vertices[0].bl_y = point.y + quadHeight / 2;
		
		vertices[0].tl_x = point.x + -quadWidth / 2;
		vertices[0].tl_y = point.y + -quadHeight / 2;
	} else {
		vertices[0].br_x = point.x + quadWidth;
		vertices[0].br_y = point.y + quadHeight;
		
		vertices[0].tr_x = point.x + quadWidth;
		vertices[0].tr_y = point.y;
		
		vertices[0].bl_x = point.x;
		vertices[0].bl_y = point.y + quadHeight;
		
		vertices[0].tl_x = point.x;
		vertices[0].tl_y = point.y;
	}				
}

@end
