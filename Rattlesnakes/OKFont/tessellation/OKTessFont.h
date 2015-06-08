//
//  OKTessFont.h
//  OKBitmapFontSample
//
//  Created by Christian Gratton on 11-07-11.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKCharDef.h"
#import "OKGeometry.h"

@interface OKTessFont : NSObject
{
    // The characters building up the font
	OKCharDef		*charsArray[256];
    CXMLDocument *xmlTess;
	// The height of a line
	GLuint		lineHeight;
	// Colour Filter = Red, Green, Blue, Alpha
	float		colourFilter[4];
	// The scale to be used when rendering the font
	float		scale;
	float		rotation;
	int commonHeight;
}

@property(nonatomic, assign)float scale;
@property(nonatomic, assign)float rotation;
@property(nonatomic, retain) NSString *name;

- (id) initWithControlFile:(NSString*)controlFile scale:(float)fontScale filter:(GLenum)filter;
- (void) drawStringAt:(OKPoint)aPoint withString:(NSString*)aString andDetail:(int)aDetail;
- (float) getWidthForString:(NSString*)aString;
- (float) getHeightForString:(NSString*)aString;
- (float) getKerningForLetter:(NSString*)aLetter withPreviousLetter:(NSString*)aPreviousLetter;

- (void) setColourFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
- (void) setScale:(float)newScale;
- (void) setRotation:(float)newRotation;
- (void) getDescriptionForString:(NSString*)aChar;
- (OKCharDef*) getCharDefForCharID:(int)aCharID;
- (OKCharDef*) getCharDefForChar:(NSString*)aChar;
- (NSArray*) getCharDefForString:(NSString*)aString;

- (OKPoint) getPositionAbsolute:(OKPoint)aPoint withString:(NSString*)aString;
- (float) getXAdvanceForString:(NSString*)aString;

- (float) getMaxWidth;

@end
