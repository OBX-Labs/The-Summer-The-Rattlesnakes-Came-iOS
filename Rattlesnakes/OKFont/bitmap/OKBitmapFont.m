//
//  OKBitmapFont.m
//  ObxKit
//
//  Created by Christian Gratton based on AngelFont provided by 71Squared.com
//

#import "OKBitmapFont.h"

@interface OKBitmapFont ()
- (void)parseFont:(NSString*)controlFile;
- (void)parseCommon:(NSString*)line;
- (void)parseCharacterDefinition:(NSString*)line charDef:(OKCharDef*)CharDef;
- (void)parseKerningDefinition:(NSString*)line;
- (void)initVertexArrays:(int)totalQuads;
@end

@implementation OKBitmapFont

@synthesize scale, rotation;

- (id)initWithFontImageNamed:(NSString*)fontImage controlFile:(NSString*)controlFile scale:(float)fontScale filter:(GLenum)filter {
	self = [self init];
	if (self != nil) {
		// Reference the font image which has been supplied and which contains the character bitmaps
		image = [[OKImage alloc] initWithImage:[UIImage imageNamed:fontImage] scale:fontScale filter:filter];
		// Set the scale to be used for the font
		scale = fontScale;
		colourFilter[0] = 1.0f;
		colourFilter[1] = 1.0f;
		colourFilter[2] = 1.0f;
		colourFilter[3] = 1.0f;
		// Parse the control file and populate charsArray which the character definitions		
		[self parseFont:controlFile];
	}
	return self;
}


- (void)parseFont:(NSString*)controlFile {
	
	// Read the contents of the file into a string
	NSString *contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:controlFile ofType:@"fnt"] encoding:NSUTF8StringEncoding error:nil];
	
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
	
	// Create a holder for each line we are going to work with
	NSString *line;
	
	// A holder for the number of characters read in from the font file
	int totalQuads = 0;
	
	// Loop through all the lines in the lines array processing each one
	while(line = [nse nextObject]) {
		// Check to see if the start of the line is something we are interested in
		if([line hasPrefix:@"common"]) {
			[self parseCommon:line];  //// NEW CODE ADDED 05/02/10 to parse the common params
		} else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			OKCharDef *characterDefinition = [[[OKCharDef alloc] initCharDefWithFontImage:image scale:scale] retain];
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
	// Finished with lines so release it
	[lines release];
	
	// Now we have passed the font control file we know how many characters we have so we can set
	// up the vertext arracys
	//NSLog(@"AngelCodeFont: Initializing vertex arrays for font '%@' with capacity of '%d'", controlFile, totalQuads);
	[self initVertexArrays:totalQuads];
}


- (void)initVertexArrays:(int)totalQuads {
		
	// Init the texture, vertices and indices arrays ready for taking data.  The size we allocate
	// to these arrays is based on the number of characters (quads) read from the font control file
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


//// NEW CODE ADDED 05/02/10 to parse the common params
- (void)parseCommon:(NSString*)line {
	
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


- (void)parseCharacterDefinition:(NSString*)line charDef:(OKCharDef*)characterDefinition {
    
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
	[characterDefinition setWidth:[propertyValue floatValue]];
	// Character height
	propertyValue = [nse nextObject];
	[characterDefinition setHeight:[propertyValue floatValue]];
	// Character xoffset
	propertyValue = [nse nextObject];
	[characterDefinition setXOffset:[propertyValue intValue]];
	// Character yoffset
	propertyValue = [nse nextObject];
	[characterDefinition setYOffset:[propertyValue intValue]];
	// Character xadvance
	propertyValue = [nse nextObject];
	[characterDefinition setXAdvance:[propertyValue intValue]];
}

- (void)parseKerningDefinition:(NSString*)line
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

- (void) drawStringAt:(OKPoint)aPoint withString:(NSString*)aString
{	    
	// Reset the number of quads which are going to be drawn
	int currentQuad = 0;
	
	// Enable those states necessary to draw with textures and allow blending
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // Bind to the texture which was generated for the spritesheet image used for this font.  We only
	// need to bind once before the drawing as all characters are on the same texture.
	glBindTexture(GL_TEXTURE_2D, [[image texture] name]);
	
	// Loop through all the characters in the text
	for(int i=0; i<[aString length]; i++) {
		
		// Grab the unicode value of the current character
		int charID = [aString characterAtIndex:i];
		
		// Only render the current character if it is going to be visible otherwise move the variables such as currentQuad and point.x
		// as normal but don't render the character which should save some cycles
		if(aPoint.x > 0 - ([charsArray[charID] width] * scale) || aPoint.x < [[UIScreen mainScreen] bounds].size.width || aPoint.y > 0 - ([charsArray[charID] height] * scale) || aPoint.y < [[UIScreen mainScreen] bounds].size.height) {
			
			// Using the current x and y, calculate the correct position of the character using the x and y offsets for each character.
			// This will cause the characters to all sit on the line correctly with tails below the line etc.
			int y = aPoint.y + (commonHeight * charsArray[charID].scale) - (charsArray[charID].height + charsArray[charID].yOffset) * charsArray[charID].scale;
			int x = aPoint.x + charsArray[charID].xOffset;
			CGPoint newPoint = CGPointMake(x, y);
						
			// Create a point into the bitmap font spritesheet using the coords read from the control file for this character
			CGPoint pointOffset = CGPointMake([charsArray[charID] x], [charsArray[charID] y]);
			
			// Calculate the texture coordinates and quad vertices for the current character
			[[charsArray[charID] image] calculateTexCoordsAtOffset:pointOffset subImageWidth:[charsArray[charID] width] subImageHeight:[charsArray[charID] height]];
			[[charsArray[charID] image] calculateVerticesAtPoint:newPoint subImageWidth:[charsArray[charID] width] subImageHeight:[charsArray[charID] height] centerOfImage:NO];
			
			// Place the calculated texture coordinates and quad vertices into the arrays we will use when drawing out string
			texCoords[currentQuad] = *[[charsArray[charID] image] texCoords];
			vertices[currentQuad] = *[[charsArray[charID] image] vertices];
            
			// Increment quad count
			currentQuad++;
		}
		
		// Move the x location along by the amount defined for this character in the control file so the charaters are spaced
		// correctly
		aPoint.x += [charsArray[charID] xAdvance] * scale;
	}
	
	float xPos = aPoint.x - ([self getWidthForString:aString]/2);
	float yPos = aPoint.y - ([self getHeightForString:aString]/2);
	
	glPushMatrix();
    
	glTranslatef(xPos, yPos, -aPoint.z);
	
	//glRotatef(0.0, 0.0, 1.0, 0.0);
	
	glTranslatef(-xPos, -yPos, 0);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_FOG);
    
	glDepthFunc(GL_LESS);
	// Now that we have calculated all the quads and textures for the string we are drawing we can draw them all
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glColor4f(colourFilter[0], colourFilter[1], colourFilter[2], colourFilter[3]);
	glDrawElements(GL_TRIANGLES, currentQuad*6, GL_UNSIGNED_SHORT, indices);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glDisable(GL_TEXTURE_2D);    
    glDisable(GL_BLEND);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
	glPopMatrix();
}

- (float)getWidthForString:(NSString*)string {
	// Set up stringWidth
	float stringWidth = 0;
	
	// Loop through the characters in the text and sum the xAdvance for each one
	// xAdvance holds how far to move long X for each character so that the correct
	// space is left after each character
	for(int index=0; index<[string length]; index++) {
		int charID = [string characterAtIndex:index];
		
		// Add the xAdvance value of the current character to stringWidth scaling as necessary
		stringWidth += [charsArray[charID] xAdvance] * scale;
	}	
	// Return the total width calculated
	return stringWidth;
}


- (float)getHeightForString:(NSString*)string {
	// Set up stringHeight	
	float stringHeight = 0;
	float lowYoffeset = INT_MAX;
	
	// Loop through the characters in the text and sum the height.  The sum will take into
	// account the offset of the character as some characters sit below the line etc
	for(int i=0; i<[string length]; i++) {
		int charID = [string characterAtIndex:i];
		
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

- (float)getKerningForLetter:(NSString*)aLetter withPreviousLetter:(NSString*)aPreviousLetter
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
        kerning = [[kChar.kerning objectForKey:[NSNumber numberWithInt:prevCharID]] floatValue];
	}	
	// Return the total width calculated
	return kerning;
}

- (void)setColourFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
	// Set the colour filter of the spritesheet image used for this font
	colourFilter[0] = red;
	colourFilter[1] = green;
	colourFilter[2] = blue;
	colourFilter[3] = alpha;
}


- (void)setScale:(float)newScale {
	scale = newScale;
	[image setScale:newScale];
}

- (void)setRotation:(float)newRotation
{
	rotation = newRotation;
	[image setRotation:newRotation];
}

- (void) getDescriptionForString:(NSString*)aString
{
    for(int i=0; i<[aString length]; i++) {
		
		// Grab the unicode value of the current character
		int charID = [aString characterAtIndex:i];
        
        NSLog(@"%@", [charsArray[charID] description]);
    }
}

- (void)dealloc {
	free(texCoords);
	free(vertices);
	free(indices);
	[image release];
	[super dealloc];
}

@end

