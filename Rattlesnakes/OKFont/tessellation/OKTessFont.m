//
//  OKTessFont.m
//  OKBitmapFontSample
//
//  Created by Christian Gratton on 11-07-11.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import "OKTessFont.h"
#import "TouchXML.h"
#import "OKTessData.h"

@interface OKTessFont ()
- (void) parseFont:(NSString*)controlFile;
- (void) parseCommon:(NSString*)line;
- (void) parseCharacterDefinition:(NSString*)line charDef:(OKCharDef*)CharDef;
- (void) parseKerningDefinition:(NSString*)line;
- (void) parseTess:(NSString*)controlFile;
@end

@implementation OKTessFont
@synthesize scale, rotation, name;

- (id) initWithControlFile:(NSString*)controlFile scale:(float)fontScale filter:(GLenum)filter {
	self = [self init];
	if (self != nil)
    {
        // Set name
        [self setName:controlFile];
        // Set the scale to be used for the font
		scale = fontScale;
		colourFilter[0] = 1.0f;
		colourFilter[1] = 1.0f;
		colourFilter[2] = 1.0f;
		colourFilter[3] = 1.0f;
        
		// Parse the control file and populate charsArray which the character definitions	
        [self parseTess:controlFile];
		[self parseFont:controlFile];
	}
	return self;
}

- (void) parseFont:(NSString*)controlFile
{
    
	// Read the contents of the file into a string
	NSString *contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:controlFile ofType:@"fnt"] encoding:NSUTF8StringEncoding error:nil];
	
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
	
    NSLog(@"PASS HERE42");
	// Create a holder for each line we are going to work with
	NSString *line;
	
	// A holder for the number of characters read in from the font file
	int totalQuads = 0;
	
    NSLog(@"PASS HERE43");
	// Loop through all the lines in the lines array processing each one
	while(line = [nse nextObject]) {
		// Check to see if the start of the line is something we are interested in
		if([line hasPrefix:@"common"]) {
			[self parseCommon:line];  //// NEW CODE ADDED 05/02/10 to parse the common params
		} else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			OKCharDef *characterDefinition = [[[OKCharDef alloc] initCharDefWithFontScale:scale] retain];
			[self parseCharacterDefinition:line charDef:characterDefinition];
			
			// Add the CharDef returned to the charArray
			charsArray[[characterDefinition charID]] = characterDefinition;
			[characterDefinition release];
			
			// Increment the total number of characters
			totalQuads++;
		} else if([line hasPrefix:@"kerning first"]) { //// NEW CODE ADDED 06/08/11 to parse kerning when available
            [self parseKerningDefinition:line];
        }
        
	}
    
    NSLog(@"PASS HERE41");
	// Finished with lines so release it
	[lines release];
}

- (void) parseTess:(NSString*)controlFile
{
    NSData *XMLData   = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:controlFile ofType:@"tes"]];
    xmlTess = [[CXMLDocument alloc] initWithData:XMLData options:0 error:nil];
}

//// NEW CODE ADDED 05/02/10 to parse the common params
- (void) parseCommon:(NSString*)line {
	
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	
	// Get the enumerator for the array of components which has been created
	NSEnumerator *nse = [values objectEnumerator];
	
	// We are going to place each value we read from the line into this string
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// Common Line Height
	propertyValue = [nse nextObject];
    commonHeight = [propertyValue intValue];
    //Ignore the next entry
    [nse nextObject];
    // scaleW is the width of the texture atlas for this font.
	propertyValue = [nse nextObject];
    NSAssert([propertyValue intValue] <= 1024, @"ERROR - BitmapFont: Texture atlas cannot be larger than 1024x1024");
    // scaleH is the height of the texture atlas for this font.
	propertyValue = [nse nextObject];
    NSAssert([propertyValue intValue] <= 1024, @"ERROR - BitmapFont: Texture atlas cannot be larger than 1024x1024");
    // pages are the number of different texture atlas files being used for this font
	propertyValue = [nse nextObject];
    NSAssert([propertyValue intValue] == 1, @"ERROR - BitmapFont: Only supports fonts with a single texture atlas.");
}

- (void) parseCharacterDefinition:(NSString*)line charDef:(OKCharDef*)characterDefinition {
    
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	
	// Get the enumerator for the array of components which has been created
	NSEnumerator *nse = [values objectEnumerator];
	
	// We are going to place each value we read from the line into this string
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// Character ID
	propertyValue = [nse nextObject];
    [characterDefinition setCharID:[propertyValue intValue]];
	// Character x
	propertyValue = [nse nextObject];
	[characterDefinition setX:[propertyValue intValue]];
	// Character y
	propertyValue = [nse nextObject];
	[characterDefinition setY:[propertyValue intValue]];
	// Character width
	propertyValue = [nse nextObject];
	[characterDefinition setWidth:[propertyValue intValue]];
	// Character height
	propertyValue = [nse nextObject];
	[characterDefinition setHeight:[propertyValue intValue]];
	// Character xoffset
	propertyValue = [nse nextObject];
	[characterDefinition setXOffset:[propertyValue intValue]];
	// Character yoffset
	propertyValue = [nse nextObject];
	[characterDefinition setYOffset:[propertyValue intValue]];
	// Character xadvance
	propertyValue = [nse nextObject];    
	[characterDefinition setXAdvance:[propertyValue intValue]];
    
    [characterDefinition loadGlyph:xmlTess];
}

- (void) parseKerningDefinition:(NSString*)line
{
    // Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	
	// Get the enumerator for the array of components which has been created
	NSEnumerator *nse = [values objectEnumerator];
	
	// We are going to place each value we read from the line into this string
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
    // 1st Character ID
	propertyValue = [nse nextObject];
    OKCharDef *kChar = charsArray[[propertyValue intValue]];
    
    // 2nd Character ID
    propertyValue = [nse nextObject];
    int charKey = [propertyValue intValue];
    // amount
    propertyValue = [nse nextObject];
    int kerningAmount = ([propertyValue intValue] * scale);
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:[NSNumber numberWithInt:kerningAmount]] forKeys:[NSArray arrayWithObject:[NSNumber numberWithInt:charKey]]];
    [kChar.kerning addEntriesFromDictionary:dict];
    [dict release];
}

- (void) drawStringAt:(OKPoint)aPoint withString:(NSString*)aString andDetail:(int)aDetail
{	
    // Loop through all the characters in the text
	for(int i=0; i<[aString length]; i++)
    {
		// Grab the unicode value of the current character
		int charID = [aString characterAtIndex:i];
        
		// Move the x location along by the amount defined for this character in the control file so the charaters are spaced
		// correctly
        
        float xPos = aPoint.x - ([self getWidthForString:aString]/2);
        float yPos = aPoint.y - ([self getHeightForString:aString]/2);
        
        glPushMatrix();
		
        glTranslatef(xPos, yPos, aPoint.z);
        glScalef(scale, scale, 0.0);
        
        
        OKTessData *tess = [[charsArray[charID] tessData] objectForKey:[NSString stringWithFormat:@"%i", aDetail]];
        
        if(tess.endsCount > 0)
        {
            for(int i = 0; i < tess.shapesCount; i++)
            {            
                glVertexPointer(2, GL_FLOAT, 0, [tess getVertices:i]);
                glEnableClientState(GL_VERTEX_ARRAY);
                glColor4f(colourFilter[0], colourFilter[1], colourFilter[2], colourFilter[3]);
                glDrawArrays([tess getType:i], 0, [tess numVertices:i]);
            }
        }
        
        aPoint.x += [charsArray[charID] xAdvance] * scale;
        
        glPopMatrix();
    }
}

- (float) getXAdvanceForString:(NSString*)aString
{
    return [charsArray[[aString characterAtIndex:0]] xAdvance] * scale;
}

- (float) getMaxWidth
{
    float mWidth = 0.0;
    
    for(int i = 0; i < 256; i++)
    {
        float width = [charsArray[i] width];
        
        if(width > mWidth)
            mWidth = width;
    }
    
    return mWidth;
}

- (OKPoint) getPositionAbsolute:(OKPoint)aPoint withString:(NSString*)aString
{
    // Loop through all the characters in the text
	for(int i=0; i<[aString length]; i++)
    {
		// Grab the unicode value of the current character
		int charID = [aString characterAtIndex:i];

        aPoint.x += [charsArray[charID] xAdvance] * scale;        
    }
    
    return aPoint;
}


- (float) getWidthForString:(NSString*)aString {
	// Set up stringWidth
	float stringWidth = 0;
    
	// Loop through the characters in the text and sum the xAdvance for each one
	// xAdvance holds how far to move long X for each character so that the correct
	// space is left after each character
	for(int index=0; index<[aString length]; index++) {
		int charID = [aString characterAtIndex:index];
        
		// Add the xAdvance value of the current character to stringWidth scaling as necessary
		stringWidth += [charsArray[charID] xAdvance] * scale;
	}	
	// Return the total width calculated
	return stringWidth;
}


- (float) getHeightForString:(NSString*)aString {
	// Set up stringHeight	
	float stringHeight = 0;
	float lowYoffeset = INT_MAX;
	
	// Loop through the characters in the text and sum the height.  The sum will take into
	// account the offset of the character as some characters sit below the line etc
	for(int i=0; i<[aString length]; i++) {
		int charID = [aString characterAtIndex:i];
		// Don't bother checking if the character is a space as they have no height
		if(charID == ' ')
			continue;
		
		// Check to see if the height of the current character is greater than the current max height
		// If so then replace the current stringHeight with the height of the current character
		stringHeight = MAX(([charsArray[charID] height] * scale) + ([charsArray[charID] yOffset] * scale), stringHeight);
		lowYoffeset = MIN(([charsArray[charID] yOffset] * scale), lowYoffeset);	
	}	
	// Return the total height calculated
	return stringHeight - lowYoffeset;	
}

- (float) getKerningForLetter:(NSString*)aLetter withPreviousLetter:(NSString*)aPreviousLetter
{
    // Set up kerning
	float kerning = 0;
	
	// Loop through the characters in the text and sum the xAdvance for each one
	// xAdvance holds how far to move long X for each character so that the correct
	// space is left after each character
	for(int index=0; index<[aLetter length]; index++) {
		int charID = [aLetter characterAtIndex:index];
        int prevCharID = [aPreviousLetter characterAtIndex:index];
		
		// Add the xAdvance value of the current character to stringWidth scaling as necessary
        OKCharDef *kChar = charsArray[charID];
        kerning = [[kChar.kerning objectForKey:[NSNumber numberWithInt:prevCharID]] floatValue] * scale;
	}	
	// Return the total width calculated
	return kerning;
}

- (void) setColourFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
	// Set the colour filter of the spritesheet image used for this font
	colourFilter[0] = red;
	colourFilter[1] = green;
	colourFilter[2] = blue;
	colourFilter[3] = alpha;
}

- (void) setScale:(float)newScale
{
	scale = newScale;
}

- (void) setRotation:(float)newRotation
{
	rotation = newRotation;
}

- (void) getDescriptionForString:(NSString*)aString
{
    for(int i=0; i<[aString length]; i++) {
		
		// Grab the unicode value of the current character
		int charID = [aString characterAtIndex:i];
        
        NSLog(@"%@", [charsArray[charID] description]);
    }
}

- (OKCharDef*) getCharDefForCharID:(int)aCharID
{
    OKCharDef *charDef;
    
    charDef = [charsArray[aCharID] copy];
    
    return charDef;
}

- (OKCharDef*) getCharDefForChar:(NSString*)aChar
{
    OKCharDef *charDef;
    
    for(int i=0; i<[aChar length]; i++)
    {
		
		// Grab the unicode value of the current character
		int charID = [aChar characterAtIndex:i];

        charDef = [charsArray[charID] copy];
    }
    
    return charDef;
}

- (NSArray*) getCharDefForString:(NSString*)aString
{
    NSMutableArray *charDefs = [[[NSMutableArray alloc] init] autorelease];
    
	for(int i=0; i<[aString length]; i++)
    {
		
		// Grab the unicode value of the current character
		int charID = [aString characterAtIndex:i];

        OKCharDef *charDef = [charsArray[charID] copy];
        [charDefs addObject:charDef];
        //[charDef release];
    }
    
    return [NSArray arrayWithArray:charDefs];
}

- (void)dealloc
{
	[xmlTess release];
    [name release];
	[super dealloc];
}

@end
