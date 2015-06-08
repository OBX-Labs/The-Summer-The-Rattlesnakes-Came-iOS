//
//  OKFont.h
//  ObxKit
//
//  Created by Christian Gratton based on AngelFont provided by 71Squared.com
//

#import <Foundation/Foundation.h>
#import "OKImage.h"
#import "OKCharDef.h"
#import "OKGeometry.h"

@interface OKBitmapFont : NSObject
{
	// The image which contains the bitmap font
	OKImage		*image;
	// The characters building up the font
	OKCharDef		*charsArray[256];
	// The height of a line
	GLuint		lineHeight;
	// Colour Filter = Red, Green, Blue, Alpha
	float		colourFilter[4];
	// The scale to be used when rendering the font
	float		scale;
	float		rotation;
	int commonHeight;
	// Vertex arrays
	Quad2 *texCoords;
	Quad2 *vertices;
	GLushort *indices;
}

@property(nonatomic, assign)float scale;
@property(nonatomic, assign)float rotation;

- (id)initWithFontImageNamed:(NSString*)fontImage controlFile:(NSString*)controlFile scale:(float)fontScale filter:(GLenum)filter;
- (void) drawStringAt:(OKPoint)aPoint withString:(NSString*)aString;
- (float)getWidthForString:(NSString*)string;
- (float)getHeightForString:(NSString*)string;
- (OKCharDef*) getCharDefForChar:(NSString*)aChar;
- (float)getKerningForLetter:(NSString*)aLetter withPreviousLetter:(NSString*)aPreviousLetter;

- (void)setColourFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
- (void)setScale:(float)newScale;
- (void)setRotation:(float)newRotation;
- (void) getDescriptionForString:(NSString*)aString;

@end