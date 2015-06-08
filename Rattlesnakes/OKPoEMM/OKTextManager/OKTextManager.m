//
//  OKTextManager.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKTextManager.h"
#import "OKPoEMMProperties.h"
#import "OKInfoViewProperties.h"

static OKTextManager *sharedInstance;

@implementation OKTextManager
@synthesize textList, orderedKeys;

+ (OKTextManager*) sharedInstance
{
    @synchronized(self)
	{
		if (sharedInstance == nil)
			sharedInstance = [[OKTextManager alloc] init];
	}
	return sharedInstance;
}

#pragma mark Text List

- (id) init
{
    if(self == [super init])
    {
        [self loadDefaultPoEMM];
    }
    
    return self;
}

- (void) loadDefaultPoEMM
{
    // Check if the file system structure exists, if not create it
    [self checkCacheFolders];
    
    // Check if the text list exists and load the default if it does not
    NSString *listPath = [OKTextManager listPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:listPath])
    {
        // Copy the text file
        [OKTextManager copyFile:@"OKPoEMMProperties" ofType:@"plist" fromBundleTo:[OKTextManager cachePath]];
        
        // Load the local text list
        self.textList = [[NSDictionary alloc] initWithContentsOfFile:listPath];
        
        // Copy all default text files and font files from the list
        NSArray *packageKeys = [self.textList allKeys];
        for(NSString *packageKey in packageKeys)
        {
            // Get the package
            NSArray *package = [textList objectForKey:packageKey];
            
            // Get the key for this package
            NSString *author = [OKTextManager authorForPackage:packageKey];
            
            // Create the author directory if it's not there already
            [self checkAuthorFolder:author];
            
            // Loop through texts in this package
            for(NSDictionary *textDict in package)
            {
                // Check if specific test for device or general text
                if([textDict objectForKey:TextFile] == nil)
                {
                    // Save specific texts
                    for(NSString *devicePropertiesKey in [textDict allKeys])
                    {
                        if([devicePropertiesKey isEqualToString:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]])
                        {
                            // Copy text file to cache
                            [OKTextManager copyFile:[[textDict objectForKey:devicePropertiesKey] objectForKey:TextFile] ofType:@"txt" fromBundleTo:[OKTextManager authorPath:author]];
                        }
                    }
                }
                else
                {
                    // Save general text
                    // Copy text file to cache
                    [OKTextManager copyFile:[textDict objectForKey:TextFile] ofType:@"txt" fromBundleTo:[OKTextManager authorPath:author]];
                }
                
                // Copy font files
                // Get the properties for the current device
                NSDictionary *properties = [textDict objectForKey:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]];
                
                // Get the font file name
                NSString *fontFile = [properties objectForKey:FontFile];
                // Outline (not all poemms will have this file)
                NSString *fontOutlineFile = [properties objectForKey:FontOutlineFile];
                // Tessellation (not all poeems will have this file)
                NSString *fontTessellationFile = [properties objectForKey:FontTessellationFile];
                NSString *fontsPath = [OKTextManager fontsPath];
                
                // Copy the font files
                // Copy the default font
                if(fontFile)
                {
                    [OKTextManager copyFile:fontFile ofType:@"fnt" fromBundleTo:fontsPath];
                    [OKTextManager copyFile:fontFile ofType:@"png" fromBundleTo:fontsPath];
                }
                else
                {
                    NSLog(@"Error: init - font file is empty.");
                }
                // Copy the outline file (not all poemms will have this file)
                if(fontOutlineFile)
                {
                    [OKTextManager copyFile:fontOutlineFile ofType:@"fnt" fromBundleTo:fontsPath];
                    [OKTextManager copyFile:fontOutlineFile ofType:@"png" fromBundleTo:fontsPath];
                }
                else
                {
                    NSLog(@"Error: init - font outline file is empty. It is possible. Ignore if no outline.");
                }
                // Copy the tessellation file (not all poemms will have this file)
                if(fontTessellationFile)
                {
                    [OKTextManager copyFile:fontTessellationFile ofType:@"tes" fromBundleTo:fontsPath];
                }
                else
                {
                    NSLog(@"Error: init - font tessellation file is empty. It is possible. Ignore if no tessellation.");
                }
            }
        }
    }
    else
    {
        // Load the local text list
        self.textList = [[NSDictionary alloc] initWithContentsOfFile:listPath];
    }
    
    // Update the list of ordered keys
    [self updatedOrderedKeys];
}

- (BOOL) setTextList:(NSDictionary *)aDict andSave:(BOOL)aSave
{
    // Make sure dict is not nil
    if(aDict == nil) return NO;
    
    BOOL canSetText = YES;
    
    // Keep track of the current text in list to compare
    NSDictionary *oldList = [self textList];
    
    // Set the new list and update the ordered keys
    self.textList = aDict;
    
    [self updatedOrderedKeys];
    
    // Check if the file system structure exists, if not create it
    [self checkCacheFolders];
    
    // Loop through the list and download the missing text and font files
    NSArray *packageKeys = [self.textList allKeys];
    for(NSString *packageKey in packageKeys)
    {
        // Get the package
        NSArray *package = [textList objectForKey:packageKey];
        
        // Get the author key for this package
        NSString *author = [OKTextManager authorForPackage:packageKey];
        
        // Create author directory if it doesn't exists already
        [self checkAuthorFolder:author];
        
        // Loop through the texts in the current package
        for(NSDictionary *textDict in package)
        {
            // Get the old and new version numbers of the text file
            NSString *textFile = @"";
            
            // Check if specific test for device or general text
            if([textDict objectForKey:TextFile] == nil)
            {
                // Specific texts
                for(NSString *devicePropertiesKey in [textDict allKeys])
                {
                    if([devicePropertiesKey isEqualToString:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]])
                    {
                        textFile = [[textDict objectForKey:devicePropertiesKey] objectForKey:TextFile];
                    }
                }
            }
            else
            {
                // General text
                textFile = [textDict objectForKey:TextFile];
            }
            
            int oldVersion = [OKTextManager textVersionForId:packageKey withFile:textFile inList:oldList];
            int newVersion = [(NSNumber*)[textDict objectForKey:TextVersion] intValue];
            
            // Check if the file already exists
            NSString *textPath = [[OKTextManager authorPath:author] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", textFile]];
            BOOL textFileExists = [[NSFileManager defaultManager] fileExistsAtPath:textPath];
                        
            // Copy text file to the package directory
            // If we have a new version or the file is missing
            if(newVersion > oldVersion || !textFileExists)
            {
                // If not, then fetch from the server
                if(![OKTextManager copyFile:textFile ofType:@"txt" fromServer:[OKTextManager serverTextPathForAuthor:author] to:[OKTextManager authorPath:author]]) canSetText = NO;
            }
            
            // Get the author image from server and save
            // Check if the file already exists
            NSString *imageFile = [textDict objectForKey:AuthorImage];
            NSString *imagePath = [[OKTextManager authorPath:author] stringByAppendingPathComponent:imageFile];
            BOOL imageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
            
            if(!imageFileExists)
            {
                NSString *fileName = [[imageFile componentsSeparatedByString:@"."] objectAtIndex:0];
                NSString *fileType = [[imageFile componentsSeparatedByString:@"."] objectAtIndex:1];
                
                [OKTextManager copyFile:fileName ofType:fileType fromServer:[OKTextManager serverImagePathForAuthor:author] to:[OKTextManager authorPath:author]];
            }
                
            // Get the list of device specific properties
            NSDictionary *properties = [textDict objectForKey:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]];
            
            if(properties == nil) continue;
            
            // Get the font file name
            NSString *fontFile = [properties objectForKey:FontFile];
            // Outline (not all poemms will have this file)
            NSString *fontOutlineFile = [properties objectForKey:FontOutlineFile];
            // Tessellation (not all poeems will have this file)
            NSString *fontTessellationFile = [properties objectForKey:FontTessellationFile];
            
            // Update the default font
            if(fontFile)
            {
                [OKTextManager updateFontFile:fontFile ofType:@"fnt"];
                [OKTextManager updateFontFile:fontFile ofType:@"png"];
            }
            else
            {
                NSLog(@"Error: setTextList - font file is empty.");
            }
            
            // Update the outline file (not all poemms will have this file)
            if(fontOutlineFile)
            {
                [OKTextManager updateFontFile:fontOutlineFile ofType:@"fnt"];
                [OKTextManager updateFontFile:fontOutlineFile ofType:@"png"];
            }
            else
            {
                NSLog(@"Error: setTextList - font outline file is empty. It is possible. Ignore if no outline");
            }
            
            // Update the tessellation file (not all poemms will have this file)
            if(fontTessellationFile)
            {
                [OKTextManager updateFontFile:fontTessellationFile ofType:@"tes"];
            }
            else
            {
                NSLog(@"Error: setTextList - font tessellation file is empty. It is possible. Ignore if no tessellation.");
            }
        }
    }
    
    // Save it to local file
    if(aSave)
    {
        [self.textList writeToFile:[OKTextManager listPath] atomically:YES];
    }
    
    return canSetText;
}

- (void) updatedOrderedKeys
{
    // Create dictionary
    NSMutableDictionary *keyDict = [[NSMutableDictionary alloc] init];
    
    // Default poemm key for order
    NSString *defaultPoemmKey = nil;
    
    // Get tiles for each packages
    NSArray *packageKeys = [self.textList allKeys];
    for(NSString *packageKey in packageKeys)
    {
        // Get the package for the key
        NSArray *package = [textList objectForKey:packageKey];
        for(NSDictionary *textDict in package)
        {
            // Default poemm key
            if([[textDict objectForKey:Default] boolValue])
            {
                defaultPoemmKey = [NSString stringWithFormat:@"%@ - %@", [textDict objectForKey:@"Author"], [textDict objectForKey:Title]];
            }
            
            // Add text to key dictionary
            // This will allow a ordering based on author and title of text
            [keyDict setObject:packageKey forKey:[NSString stringWithFormat:@"%@ - %@", [textDict objectForKey:@"Author"], [textDict objectForKey:Title]]];
            break; // we only care about the first one for now
        }
    }
    
    // Get the list of sorted titles
    NSArray *sortedTitles = [[keyDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    // Sort package keys and make sure that the default poemm is first
    NSMutableArray *newOrderedKeys = [[NSMutableArray alloc] init];
    for(NSString *title in sortedTitles)
    {
        // Get package key
        NSString *packageKey = [keyDict objectForKey:title];
        
        // Check if default poemm, if so, make it first
        if([title isEqualToString:defaultPoemmKey])
        {
            [newOrderedKeys insertObject:packageKey atIndex:0];
        }
        else
        {
            [newOrderedKeys addObject:packageKey];
        }
    }
    
    // Set keys
    self.orderedKeys = [[NSArray alloc] initWithArray:newOrderedKeys];
}

+ (NSString*) textPathForFile:(NSString *)aTextFile inPackage:(NSString *)aPackageKey
{    
    NSString *path = [OKTextManager authorPath:[OKTextManager authorForPackage:aPackageKey]];    
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", aTextFile]];
}

+ (NSString*) fontPathForFile:(NSString *)aFontFile ofType:(NSString *)aType
{
    // Adjust the string if we have a hi-res device
    if(aType == nil)
    {
        return [[OKTextManager fontsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", aFontFile]];
    }
    
    return [[OKTextManager fontsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", aFontFile, aType]];
}

- (BOOL) loadTextFromPackage:(NSString *)aPackage atIndex:(int)aIndex
{
    // Get the text properties
    NSDictionary *textDict = [self textDictForId:aPackage atIndex:aIndex];
    
    // If nothing, return NO
    if(textDict == nil) return NO;
    
    // Get the path to the text in the cache
    NSString *authorPath = [OKTextManager authorPath:[OKTextManager authorForPackage:aPackage]];
    
    // Get Text File
    NSString *textFile = @"";
        
    // Check if specific test for device or general text
    if([textDict objectForKey:TextFile] == nil)
    {
        // Specific texts
        for(NSString *devicePropertiesKey in [textDict allKeys])
        {
            if([devicePropertiesKey isEqualToString:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]])
            {
                textFile = [[textDict objectForKey:devicePropertiesKey] objectForKey:TextFile];
            }
        }
    }
    else
    {
        // General text
        textFile = [textDict objectForKey:TextFile];
    }
    
    NSString *textPath = [authorPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", textFile]];
    
    // Make sure we have the text file
    if(![[NSFileManager defaultManager] fileExistsAtPath:textPath])
    {
        // Reset the text list, which will update the cache
        if(![self setTextList:textList andSave:YES]) return NO;
    }
    
    // Get the list of device specific properties
    NSDictionary *properties = [textDict objectForKey:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]];
    
    if(properties == nil) return NO;
        
    // Get the font file name
    NSString *fontFile = [properties objectForKey:FontFile];
    NSString *fontTessellationFile = [properties objectForKey:FontTessellationFile];
    if(fontFile == nil) return NO;
    
    // Get the font control file path
    NSString *fontsPath = [OKTextManager fontsPath];
    NSString *fontFilePath = [fontsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.fnt", fontFile]];
    
    // Make sure the font control file is cached
    if(![[NSFileManager defaultManager] fileExistsAtPath:fontFilePath])
    {
        // Reset the text list, which will update the cache
        if(![self setTextList:textList andSave:YES]) return NO;
    }
    
    // Get the font image file path
    NSString *fontImageFilePath = [fontsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", fontFile]];
    
    // Make sure the control file is cached
    if(![[NSFileManager defaultManager] fileExistsAtPath:fontImageFilePath])
    {
        // Reset the text list, which will update the cache
        if(![self setTextList:textList andSave:YES]) return NO;
    }
    
    // Get the font tessellation file path (not all poemms will have this)
    NSString *fontTessellationFilePath = [fontsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tes", fontTessellationFile]];
    
    // Make sure the control file is cached
    if(![[NSFileManager defaultManager] fileExistsAtPath:fontTessellationFilePath])
    {
        // Reset the text list, which will update the cache
        if(![self setTextList:textList andSave:YES])
        {
            NSLog(@"Error: loadTextFromPackage - font tessellation file is empty. It is possible. Ignore if no tessellation.");
        }
    }
    
    // Set text id
    [OKPoEMMProperties setObject:aPackage forKey:Text];
    
    // Fill properties
    [OKPoEMMProperties fillWith:textDict];
    
    // Save current text key to use when restarting the app
    [[NSUserDefaults standardUserDefaults] setObject:[OKPoEMMProperties objectForKey:Text] forKey:Text];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

- (int) packagesCount { return [[textList allKeys] count]; }

- (NSString*) packageAtIndex:(int)aIndex { return [orderedKeys objectAtIndex:aIndex]; }

- (NSString*) getDefaultPackage
{
    NSString *defaultKey;
    NSArray *packageKeys = [self.textList allKeys];
    
    for(NSString *packageKey in packageKeys)
    {
        // Get the package for the key
        NSArray *package = [textList objectForKey:packageKey];
        for(NSDictionary *textDict in package)
        {
            // Default poemm key
            if([[textDict objectForKey:Default] boolValue])
            {
                defaultKey = [[NSString alloc] initWithString:packageKey];
                break; // we only care about the first one
            }
        }
    }
    
    return defaultKey;
}

+ (NSString*) authorForPackage:(NSString *)aPackageKey { return [[aPackageKey componentsSeparatedByString:@"."] objectAtIndex:3]; }

+ (int) textVersionForId:(NSString *)aTextId withFile:(NSString *)aFile inList:(NSDictionary *)aList
{
    NSArray *texts = [aList objectForKey:aTextId];
    if(texts == nil) return -1;
    
    for(NSDictionary *textDict in texts)
    {
        // Get Text File
        NSString *textFile = @"";
        
        // Check if specific test for device or general text
        if([textDict objectForKey:TextFile] == nil)
        {
            // Specific texts
            for(NSString *devicePropertiesKey in [textDict allKeys])
            {
                if([devicePropertiesKey isEqualToString:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]])
                {
                    textFile = [[textDict objectForKey:devicePropertiesKey] objectForKey:TextFile];
                }
            }
        }
        else
        {
            // General text
            textFile = [textDict objectForKey:TextFile];
        }
                
        if([aFile isEqualToString:textFile])
        {
            return [(NSNumber*)[textDict objectForKey:TextVersion] intValue];
        }
    }
    
    return -1;
}

- (NSDictionary*) textDictForId:(NSString *)aTextId atIndex:(int)aIndex
{
    NSArray *texts = [textList objectForKey:aTextId];
    if(textList == nil) return nil;
    return [texts objectAtIndex:aIndex];
}

#pragma mark Cache

- (void) checkCacheFolders
{
    BOOL isDir = NO;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Check texts folder
    if(![fm fileExistsAtPath:[OKTextManager textsPath] isDirectory:&isDir] && isDir == NO)
    {
        [fm createDirectoryAtPath:[OKTextManager textsPath] withIntermediateDirectories:NO attributes:nil error:&error];
        
        if(error != nil) NSLog(@"Error: failed to create texts directory (%@)", [error localizedDescription]);
    }
    
    // Reset if error
    if(error != nil) error = nil;
    
    // Check fonts folder
    if(![fm fileExistsAtPath:[OKTextManager fontsPath] isDirectory:&isDir] && isDir == NO)
    {
        [fm createDirectoryAtPath:[OKTextManager fontsPath] withIntermediateDirectories:NO attributes:nil error:&error];
        
        if(error != nil) NSLog(@"Error: failed to create fonts directory (%@)", [error localizedDescription]);
    }
}

- (void) checkAuthorFolder:(NSString *)aAuthor
{
    BOOL isDir = NO;
    NSError *error = nil;
    NSString *authorPath = [OKTextManager authorPath:aAuthor];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:authorPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:authorPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if(error != nil) NSLog(@"Error: failed to create directory for author %@ (%@)", aAuthor, [error localizedDescription]);
    }
}

+ (BOOL) copyFile:(NSString *)aFileName ofType:(NSString *)aType fromBundleTo:(NSString *)aDstPath
{
    NSError *error = nil;
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:aFileName ofType:aType];
    NSString *cachePath = [aDstPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", aFileName, aType]];

    // This is just a check for us
    if(bundlePath == nil)
    {
        NSLog(@"Error: copy file bundlePath is nil (%@)", aFileName);
        return NO;
    }
    
    if(cachePath == nil)
    {
        NSLog(@"Error: copy file cachePath is nil (%@)", aFileName);
        return NO;
    }
        
    // Check if we can copy
    if(![[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:cachePath error:&error])
    {
        NSLog(@"Error: failed to copy %@.%@ to %@ (%@)", aFileName, aType, aDstPath, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

#pragma mark File System

+ (NSString*) textsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Texts"];
}

+ (NSString*) authorPath:(NSString *)aAuthor
{
    return [[OKTextManager textsPath] stringByAppendingPathComponent:aAuthor];
}

+ (NSString*) fontsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Fonts"];
}

+ (BOOL) fontFileExists:(NSString *)aFileName ofType:(NSString *)aType
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[OKTextManager fontsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", aFileName, aType]]];
}

+ (NSString*) listPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"OKPoEMMProperties.plist"];
}

+ (void) clearCache
{    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [OKTextManager cachePath];
    NSError *error;
    NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:cachePath error:nil];
    for (NSString *file in cacheFiles)
    {
        error = nil;
        [fileManager removeItemAtPath:[cachePath stringByAppendingPathComponent:file] error:&error];
        
        if(error != nil) NSLog(@"Error: clear cache faild (%@)", [error localizedDescription]);
        else NSLog(@"Clear file %@ at %@", file, [cachePath stringByAppendingPathComponent:file]);
    }
    
    [[OKTextManager sharedInstance] loadDefaultPoEMM];
}

+ (NSString*) cachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

#pragma mark Server

+ (NSString*) serverTextPathForAuthor:(NSString *)aAuthor
{    
    NSString *url;
    if([[OKAppProperties objectForKey:@"Development"] boolValue]) url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"texts_dev"];
    else url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"texts_live"];
    
    return [NSString stringWithFormat:@"%@%@/", url, aAuthor];
}

+ (NSString*) serverImagePathForAuthor:(NSString*)aAuthor
{
    NSString *url;
    if([[OKAppProperties objectForKey:@"Development"] boolValue]) url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"images_dev"];
    else url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"images_live"];
    
    return [NSString stringWithFormat:@"%@%@/", url, aAuthor];
}

+ (BOOL) copyFile:(NSString *)aFileName ofType:(NSString *)aType fromServer:(NSString *)aURL to:(NSString *)aDstPath
{
    NSError *error = nil;
    
    NSString *cachePath = [aDstPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", aFileName, aType]];
    NSURL *serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.%@", aURL, aFileName, aType]];
    
    NSData *data = [NSData dataWithContentsOfURL:serverURL options:NSDataReadingUncached error:&error];
    
    if(error == nil)
    {
        if(![[NSFileManager defaultManager] createFileAtPath:cachePath contents:data attributes:nil])
        {
            NSLog(@"Error: can't create file");
            return NO;
        }
        else NSLog(@"File created at %@", cachePath);
    }
    else
    {
        NSLog(@"Error: data with contents of URL %@ (%@)", serverURL, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

+ (void) updateFontFile:(NSString *)aFileName ofType:(NSString *)aType
{
    if([OKTextManager fontFileExists:aFileName ofType:aType]) return;
    
    NSString *bundleFilePath = nil;
    BOOL bundleFileExists = NO;
    BOOL bundleFileCopied = NO;
    
    // Try to copy the file from the main bundle if it's there
    bundleFilePath = [[NSBundle mainBundle] pathForResource:aFileName ofType:aType];
    bundleFileExists = [[NSFileManager defaultManager] fileExistsAtPath:bundleFilePath];
    
    if(bundleFileExists)
    {
        bundleFileCopied = [OKTextManager copyFile:aFileName ofType:aType fromBundleTo:[OKTextManager fontsPath]];
        
        if(bundleFileCopied)
        {
            NSLog(@"Copied file %@.fnt from bundle", aFileName);
        }
        else
        {
            NSLog(@"Couldn't copy file %@.fnt from bundle", aFileName);
        }
    }
    
    // If file doesn't exists or wasn't copied, fetch from server
    if(!bundleFileExists || !bundleFileCopied)
    {        
        NSString *url;
        if([[OKAppProperties objectForKey:@"Development"] boolValue]) url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"fonts_dev"];
        else url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"fonts_live"];
        
        [OKTextManager copyFile:aFileName ofType:aType fromServer:url to:[OKTextManager fontsPath]];
        
        NSLog(@"Copied file %@.fnt from server", aFileName);
    }
}

#pragma mark OKUserTexts

- (NSString*) pathForFile:(NSString*)aFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *doc = [paths objectAtIndex:0];
    
	return [doc stringByAppendingPathComponent:aFile];
}

- (void) createFolder:(NSString*)aFolder
{
    BOOL isFolder = YES;
    
    //Create folder to store user texts according to type
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self pathForFile:aFolder] isDirectory:&isFolder])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self pathForFile:aFolder] withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

#pragma mark UserTexts

- (BOOL) createFile:(NSString*)aFileName ofType:(NSString*)aType withContents:(NSString*)aContent At:(NSString*)aDstPath
{
    NSString *cachePath = [aDstPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", aFileName, aType]];
    
    NSError *error;
    
    if(![aContent writeToFile:cachePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"Error: createFile - could not save file (%@.%@) at %@ (%@)", aFileName, aType, aDstPath, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

- (BOOL) saveCustomText:(NSString*)text forTitle:(NSString*)title
{
    // Trim text to match current device limitations
    NSString *withoutWhiteSpace = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];    
    NSArray *lines = [withoutWhiteSpace componentsSeparatedByString:@"\n"];
    
    int appMaxLines = [[[OKAppProperties objectForKey:@"DeviceSpecific"] objectForKey:@"max_lines"] intValue];
    int maxLines = ([lines count] > appMaxLines ? appMaxLines : [lines count]);
    
    NSMutableString *formatedText = [[NSMutableString alloc] init];
    
    for(int i = 0; i < maxLines; i++)
    {        
        NSString *line = [lines objectAtIndex:i];
        int appMaxCharPerLine = [[[OKAppProperties objectForKey:@"DeviceSpecific"] objectForKey:@"max_char_per_line"] intValue];
        int maxCharPerLine = ([line length] > appMaxCharPerLine ? appMaxCharPerLine : [line length]);
        int charIndex = 0;
        
        for(int j = 0; j < maxCharPerLine; j++)
        {
            // Add character to line
            [formatedText appendString:[NSString stringWithFormat:@"%C", [line characterAtIndex:charIndex]]];
            
            charIndex++;
        }
        
        if(i < (maxLines - 1)) [formatedText appendString:@"\n"];
    }
    
    // Check if the file system structure exists, if not create it
    [self checkCacheFolders];
    
    // Create package id
    NSString *deviceName = [[[UIDevice currentDevice] name] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *package = [[NSString alloc] initWithFormat:@"net.obxlabs.%@.%@.custom", [OKAppProperties objectForKey:@"Name"], deviceName];
    NSString *author = [OKTextManager authorForPackage:package];
    
    // Create the author directory if it's not there already
    [self checkAuthorFolder:author];
    
    // Save text
    if(![self createFile:@"custom" ofType:@"txt" withContents:formatedText At:[OKTextManager authorPath:author]])
    {
        NSLog(@"Error: saveCustomText - could not save text (custom.txt) at path: %@", [OKTextManager authorPath:author]);
        return NO;
    }
    
    // Create package based on default (uses same fonts and visual)
    NSMutableDictionary *textDict = [[NSMutableDictionary alloc] initWithDictionary:[self textDictForId:[self getDefaultPackage] atIndex:0]];
    [textDict setObject:author forKey:@"Author"];
    [textDict setObject:[NSNumber numberWithBool:NO] forKey:@"DefaultPoem"];
    [textDict setObject:title forKey:@"Title"];
    [textDict setObject:@"custom" forKey:@"TextFile"];
        
    // Get default package
    NSDictionary *properties = [textDict objectForKey:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]];
        
    if(properties == nil)
    {
        NSLog(@"Error: saveCustomText - properties is empty.");
        return NO;
    }
        
    // Get the font file name
    NSString *fontFile = [properties objectForKey:FontFile];
    // Outline (not all poemms will have this file)
    NSString *fontOutlineFile = [properties objectForKey:FontOutlineFile];
    // Tessellation (not all poeems will have this file)
    NSString *fontTessellationFile = [properties objectForKey:FontTessellationFile];
    
    // Update the default font
    if(fontFile)
    {
        [OKTextManager updateFontFile:fontFile ofType:@"fnt"];
        [OKTextManager updateFontFile:fontFile ofType:@"png"];
    }
    else
    {
        NSLog(@"Error: saveCustomText - font file is empty.");
    }
    
    // Update the outline file (not all poemms will have this file)
    if(fontOutlineFile)
    {
        [OKTextManager updateFontFile:fontOutlineFile ofType:@"fnt"];
        [OKTextManager updateFontFile:fontOutlineFile ofType:@"png"];
    }
    else
    {
        NSLog(@"Error: saveCustomText - font outline file is empty. It is possible. Ignore if no outline");
    }
    
    // Update the tessellation file (not all poemms will have this file)
    if(fontTessellationFile)
    {
        [OKTextManager updateFontFile:fontTessellationFile ofType:@"tes"];
    }
    else
    {
        NSLog(@"Error: saveCustomText - font tessellation file is empty. It is possible. Ignore if no tessellation.");
    }
    
    NSString *path = [[OKTextManager cachePath] stringByAppendingPathComponent:@"custom.plist"];
    if(![textDict writeToFile:path atomically:YES])
    {
        NSLog(@"Error: save textDict");
    }
    
    // Set text id
    [OKPoEMMProperties setObject:package forKey:Text];
    
    // Fill properties
    [OKPoEMMProperties fillWith:textDict];
    
//    // Set text file after we filled the properties because it is possible
//    // that a poemm has a different text file for each devices
//    [OKPoEMMProperties setObject:@"custom" forKey:TextFile];
    
    // Save current text key to use when restarting the app
    [[NSUserDefaults standardUserDefaults] setObject:[OKPoEMMProperties objectForKey:Text] forKey:Text];
    [[NSUserDefaults standardUserDefaults] synchronize];
        
    return YES;
}

- (BOOL) loadCustomTextFromPackage:(NSString *)package
{
    NSString *path = [[OKTextManager cachePath] stringByAppendingPathComponent:@"custom.plist"];
    NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:path];

    // If nothing, return NO
    if(textDict == nil) return NO;
    
    // Get the path to the text in the cache
    NSString *author = [OKTextManager authorForPackage:package];
    NSString *authorPath = [OKTextManager authorPath:author];
    NSString *textPath = [authorPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", [textDict objectForKey:TextFile]]];

    // Make sure we have the text file
    if(![[NSFileManager defaultManager] fileExistsAtPath:textPath]) return NO;

    // Get the list of device specific properties
    NSDictionary *properties = [textDict objectForKey:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]];

    if(properties == nil) return NO;

    // Get the font file name
    NSString *fontFile = [properties objectForKey:FontFile];
    NSString *fontTessellationFile = [properties objectForKey:FontTessellationFile];
    if(fontFile == nil) return NO;
    
    // Get the font control file path
    NSString *fontsPath = [OKTextManager fontsPath];
    NSString *fontFilePath = [fontsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.fnt", fontFile]];
    
    // Make sure the font control file is cached
    if(![[NSFileManager defaultManager] fileExistsAtPath:fontFilePath]) return NO;
    
    // Get the font image file path
    NSString *fontImageFilePath = [fontsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", fontFile]];
    
    // Make sure the control file is cached
    if(![[NSFileManager defaultManager] fileExistsAtPath:fontImageFilePath]) return NO;
    
    // Get the font tessellation file path (not all poemms will have this);
    NSString *fontTessellationFilePath = [fontsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tes", fontTessellationFile]];
    
    // Make sure the tessellation file file is cached
    if(![[NSFileManager defaultManager] fileExistsAtPath:fontTessellationFilePath])
    {
        NSLog(@"Error: loadCustomTextFromPackage - font tessellation file is empty. It is possible. Ignore if no tessellation.");
    }
    
    // Set text id
    [OKPoEMMProperties setObject:package forKey:Text];
    
    // Fill properties
    [OKPoEMMProperties fillWith:textDict];
    
    // Save current text key to use when restarting the app
    [[NSUserDefaults standardUserDefaults] setObject:[OKPoEMMProperties objectForKey:Text] forKey:Text];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

#pragma mark OKTwitterFeed

- (NSArray*) loadFeeds
{
    NSMutableArray *feeds = [[NSMutableArray alloc] init];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[self pathForFile:@"/TwitterFeeds/feeds.plist"]])
    {
        for(NSData *list in [NSArray arrayWithContentsOfFile:[self pathForFile:@"/TwitterFeeds/feeds.plist"]])
        {
            [feeds addObject:[NSKeyedUnarchiver unarchiveObjectWithData:list]];
        }
    }
    
    return feeds;
}

- (void) saveFeed:(NSString*)aFeed
{
    NSArray *eFeeds = [self loadFeeds];
    NSMutableArray *feeds = [[NSMutableArray alloc] init];
    
    for(NSString *feed in eFeeds)
    {
        // Add existing feed to new feeds
        [feeds addObject:[NSKeyedArchiver archivedDataWithRootObject:feed]];
    }
    
    // Add new feed to feeds if it doesn't exists already
    if(![eFeeds containsObject:aFeed])
    {
        [feeds addObject:[NSKeyedArchiver archivedDataWithRootObject:aFeed]];
    }
    
    if(![feeds writeToFile:[self pathForFile:@"/TwitterFeeds/feeds.plist"] atomically:YES])
    {
        NSLog(@"Error: save feed");
    }
}

- (void) deleteFeed:(NSString*)aFeed
{
    NSArray *eFeeds = [self loadFeeds];
    NSMutableArray *feeds = [[NSMutableArray alloc] init];
    
    for(NSString *feed in eFeeds)
    {
        // Check for existing feed to be removed
        if(![feed isEqualToString:aFeed])
        {
            // Add existing feed to new feeds
            [feeds addObject:[NSKeyedArchiver archivedDataWithRootObject:feed]];
        }
    }
    
    if(![feeds writeToFile:[self pathForFile:@"/TwitterFeeds/feeds.plist"] atomically:YES])
    {
        NSLog(@"Error: delete feed");
    }
}

#pragma mark OKCustomText

- (NSArray*) loadTexts
{
    NSMutableArray *texts = [[NSMutableArray alloc] init];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[self pathForFile:@"/CustomTexts/texts.plist"]])
    {
        for(NSData *list in [NSArray arrayWithContentsOfFile:[self pathForFile:@"/CustomTexts/texts.plist"]])
        {
            [texts addObject:[NSKeyedUnarchiver unarchiveObjectWithData:list]];
        }
    }
    
    return texts;
}

- (NSString*) loadTextFile:(NSString*)aFile forType:(NSString*)aType
{
    NSString *path = [self pathForFile:[NSString stringWithFormat:@"/CustomTexts/%@.%@", aFile, aType]];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (void) saveTextFile:(NSString*)aFile forType:(NSString*)aType withContent:(NSString*)aContent
{
    NSArray *eTexts = [self loadTexts];
    NSMutableArray *texts = [[NSMutableArray alloc] init];
    
    for(NSString *text in eTexts)
    {
        // Add existing feed to new feeds
        [texts addObject:[NSKeyedArchiver archivedDataWithRootObject:text]];
    }
    
    // Add new feed to feeds if it doesn't exists already
    if(![eTexts containsObject:aFile])
    {
        // Add new text
        [texts addObject:[NSKeyedArchiver archivedDataWithRootObject:aFile]];
    }
    
    // Write file, if it works add the file to the texts.plist
    [aContent writeToFile:[self pathForFile:[NSString stringWithFormat:@"/CustomTexts/%@.%@", aFile, aType]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if(![texts writeToFile:[self pathForFile:@"/CustomTexts/texts.plist"] atomically:YES])
    {
        NSLog(@"Error: save text file");
    }
}

- (void) deleteTextFile:(NSString*)aFile forType:(NSString*)aType
{
    NSArray *eTexts = [self loadTexts];
    NSMutableArray *texts = [[NSMutableArray alloc] init];
    
    for(NSString *text in eTexts)
    {
        // Check for existing feed to be removed
        if(![text isEqualToString:aFile])
        {
            // Add existing feed to new feeds
            [texts addObject:[NSKeyedArchiver archivedDataWithRootObject:text]];
        }
    }
    
    // Delete file
    NSString *path = [self pathForFile:[NSString stringWithFormat:@"/CustomTexts/%@.%@", aFile, aType]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    if(![texts writeToFile:[self pathForFile:@"/CustomTexts/texts.plist"] atomically:YES])
    {
        NSLog(@"Error: delete text file");
    }
}


@end












