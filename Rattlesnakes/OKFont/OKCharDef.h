//
//  OKCharDef.h
//  ObxKit
//
//  Created by Christian Gratton based on AngelFont provided by 71Squared.com
//

#import <Foundation/Foundation.h>

#import "OKImage.h"
#import "TouchXML.h"

@interface OKCharDef : NSObject {
	// ID of the character
	int charID;
	// X location on the spritesheet
	int x;
	// Y location on the spritesheet
	int y;
	// Width of the character image
	float width;
	// Height of the character image
	float height;
	// The X amount the image should be offset when drawing the image
	int xOffset;
	// The Y amount the image should be offset when drawing the image
	int yOffset;
	// The amount to move the current position after drawing the character
	int xAdvance;
	// The image containing the character
	OKImage *image;
	// Scale to be used when rendering the character
	float scale;
    
    NSMutableDictionary *kerning;
    NSMutableDictionary *tessData;
}

@property(nonatomic, retain)OKImage *image;
@property(nonatomic)int charID;
@property(nonatomic)int x;
@property(nonatomic)int y;
@property(nonatomic)float width;
@property(nonatomic)float height;
@property(nonatomic)int xOffset;
@property(nonatomic)int yOffset;
@property(nonatomic)int xAdvance;
@property(nonatomic)float scale;
@property(nonatomic, retain)NSMutableDictionary *kerning;
@property(nonatomic, retain)NSMutableDictionary *tessData;

- (id) initCharDefWithFontImage:(OKImage*)image scale:(float)fontScale;
- (id) initCharDefWithFontScale:(float)fontScale;
- (void) loadGlyph:(CXMLDocument*)aDoc;

@end
