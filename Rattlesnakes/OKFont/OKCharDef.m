//
//  OKCharDef.m
//  ObxKit
//
//  Created by Christian Gratton based on AngelFont provided by 71Squared.com
//

#import "OKCharDef.h"

#import "OKTessData.h"

@implementation OKCharDef
@synthesize image, charID, x, y, width, height, xOffset, yOffset, xAdvance, scale, kerning, tessData;

- (id)initCharDefWithFontImage:(OKImage*)fontImage scale:(float)fontScale
{
	self = [super init];
	if (self != nil) {
		// Reference the image file which contains the spritemap for the characters
		image = fontImage;
		// Set the scale for this character
		scale = fontScale;
        
        kerning = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id) initCharDefWithFontScale:(float)fontScale
{
    self = [super init];
	if (self != nil) {
		// Set the scale for this character
		scale = fontScale;
        
        kerning = [[NSMutableDictionary alloc] init];
        tessData = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	OKCharDef *copy = [[[self class] allocWithZone: zone] init];
    
	copy.charID = [self charID];
    copy.x = [self x];
    copy.y = [self y];
    copy.width = [self width];
    copy.height = [self height];
    copy.xOffset = [self xOffset];
    copy.yOffset = [self yOffset];
    copy.xAdvance = [self xAdvance];
    copy.image = [self image];
    copy.scale = [self scale];
    copy.kerning = [self kerning];
    copy.tessData = [self tessData];
	
    return copy;
}

- (void) loadGlyph:(CXMLDocument*)aDoc
{
    NSArray *tessDetail = [aDoc nodesForXPath:@"//tesselation" error:nil];
    
    for(CXMLElement *tesselation in tessDetail)
    {        
        NSArray *glyphs = [tesselation nodesForXPath:@"glyph" error:nil];
        
        for(CXMLElement *glyph in glyphs)
        {
            if([[[glyph attributeForName:@"id"] stringValue] isEqualToString:[NSString stringWithFormat:@"%i", charID]])
            {                
                NSArray *shapes = [glyph nodesForXPath:@"polygon/shapes/shape" error:nil];
                NSArray *vertices = [glyph nodesForXPath:@"polygon/vertices/vertex" error:nil];
                NSArray *ends = [glyph nodesForXPath:@"polygon/ends/end" error:nil];
                NSArray *oEnds = [glyph nodesForXPath:@"outline/ends/end" error:nil];
                NSArray *oIndices = [glyph nodesForXPath:@"outline/indices/index" error:nil];
                
                NSMutableArray *tessShapes = [[NSMutableArray alloc] init];
                NSMutableArray *tessVertices = [[NSMutableArray alloc] init];
                NSMutableArray *tessEnds = [[NSMutableArray alloc] init];
                NSMutableArray *oTessEnds = [[NSMutableArray alloc] init];
                NSMutableArray *oTessIndices = [[NSMutableArray alloc] init];
                
                for(CXMLElement *shape in shapes)
                {
                    [tessShapes addObject:[[shape attributeForName:@"type"] stringValue]];
                }
                
                for(CXMLElement *vertex in vertices)
                {                    
                    [tessVertices addObject:[NSArray arrayWithObjects:[[vertex attributeForName:@"x"] stringValue],[[vertex attributeForName:@"y"] stringValue], [[vertex attributeForName:@"z"] stringValue], nil]];
                }
                
                for(CXMLElement *end in ends)
                {
                    [tessEnds addObject:[[end attributeForName:@"index"] stringValue]];
                }
                
                for(CXMLElement *end in oEnds)
                {
                    [oTessEnds addObject:[[end attributeForName:@"index"] stringValue]];
                }
                
                for(CXMLElement *index in oIndices)
                {
                    [oTessIndices addObject:[[index attributeForName:@"index"] stringValue]];
                }
                
                OKTessData *tess = [[OKTessData alloc] initWithID:[[[tesselation attributeForName:@"detail"] stringValue] intValue]];
                
                [tess fillVertices:tessVertices];
                [tess fillShapes:tessShapes];
                [tess fillEnds:tessEnds];
                [tess fillOutlineEnds:oTessEnds];
                [tess fillOutlineIndices:oTessIndices];
               
                [tessData setObject:tess forKey:[[tesselation attributeForName:@"detail"] stringValue]];
                [tess release];
                
                [tessShapes release];
                [tessVertices release];
                [tessEnds release];
                [oTessEnds release];
                [oTessIndices release];
            }
        }
    }
}

- (NSString *)description {
	// Log what we have created
	return [NSString stringWithFormat:@"CharDef = id:%d x:%d y:%d width:%f height:%f xoffset:%d yoffset:%d xadvance:%d tessdata:%i", 
			charID, 
			x, 
			y, 
			width, 
			height, 
			xOffset, 
			yOffset, 
			xAdvance,
            [tessData count]];
}


- (void)dealloc {
    [kerning release];
	[super dealloc];
}

@end
