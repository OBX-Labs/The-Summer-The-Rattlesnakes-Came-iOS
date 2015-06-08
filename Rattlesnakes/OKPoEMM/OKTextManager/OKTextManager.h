//
//  OKTextManager.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKTextManager : NSObject

@property (nonatomic, retain) NSDictionary *textList;
@property (nonatomic, retain) NSArray *orderedKeys;

+ (OKTextManager*) sharedInstance;

- (void) loadDefaultPoEMM;

// Set text list and save if specified
- (BOOL) setTextList:(NSDictionary*)aDict andSave:(BOOL)aSave;

// Update the ordered text keys
- (void) updatedOrderedKeys;

// Get the text path for a text file in a package
+ (NSString*) textPathForFile:(NSString*)aTextFile inPackage:(NSString*)aPackageKey;

// Get a path for a font file
+ (NSString*) fontPathForFile:(NSString*)aFontFile ofType:(NSString*)aType;

// Load a text from given package at a specified index
- (BOOL) loadTextFromPackage:(NSString*)aPackage atIndex:(int)aIndex;

// Get number of packages
- (int) packagesCount;

// Get the package at a specified index
- (NSString*) packageAtIndex:(int)aIndex;

// Get default package
- (NSString*) getDefaultPackage;

// Get the dictionary for a text in a package
- (NSDictionary*) textDictForId:(NSString*)aTextId atIndex:(int)aIndex;

// Get the version of the text in a package with a given text file in a certain list
+ (int) textVersionForId:(NSString*)aTextId withFile:(NSString*)aFile inList:(NSDictionary*)aList;

// Get the author key from a package key
+ (NSString*) authorForPackage:(NSString*)aPackageKey;

// Check if the cache folder structure is valid, update if not
- (void) checkCacheFolders;

// Check if the cache folder for an author's text is valid, update if not
- (void) checkAuthorFolder:(NSString*)aAuthor;

// Copy a file from app bundle to the cache
+ (BOOL) copyFile:(NSString*)aFileName ofType:(NSString*)aType fromBundleTo:(NSString*)aDstPath;

// Get the path to the texts folder in the cache
+ (NSString*) textsPath;

// Get the path to the texts of an author in the cache for a packageKey
+ (NSString*) authorPath:(NSString*)aAuthor;

//get the path to the fonts folder in the cache
+ (NSString*) fontsPath;

// Check if a font file already exists
+ (BOOL) fontFileExists:(NSString*)aFileName ofType:(NSString*)aType;

// Get the path to the list folder in the cache
+ (NSString*) listPath;

// Deletes all cached files so we can resync (major fail was detected if here)
+ (void) clearCache;

// Get the path to the cache folder
+ (NSString*) cachePath;

// Get the path of an author's texts folder on the server
+ (NSString*) serverTextPathForAuthor:(NSString*)aAuthor;

// Get the path of an author's image folder on the server
+ (NSString*) serverImagePathForAuthor:(NSString*)aAuthor;

// Copy a file with a given type from the server to the cache
+ (BOOL) copyFile:(NSString*)aFileName ofType:(NSString*)aType fromServer:(NSString*)aURL to:(NSString*)aDstPath;

// Update a file with a give type from bundle of the server to the cache
+ (void) updateFontFile:(NSString*)aFileName ofType:(NSString*)aType;

#pragma mark OKUserTexts

- (NSString*) pathForFile:(NSString*)aFile;
- (void) createFolder:(NSString*)aFolder;

#pragma mark UserTexts

- (BOOL) createFile:(NSString*)aFileName ofType:(NSString*)aType withContents:(NSString*)aContent At:(NSString*)aDstPath;
- (BOOL) saveCustomText:(NSString*)text forTitle:(NSString*)title;
- (BOOL) loadCustomTextFromPackage:(NSString *)package;

#pragma mark OKTwitterFeed

- (NSArray*) loadFeeds;
- (void) saveFeed:(NSString*)aFeed;
- (void) deleteFeed:(NSString*)aFeed;

#pragma mark OKCustomText

- (NSArray*) loadTexts;
- (NSString*) loadTextFile:(NSString*)aFile forType:(NSString*)aType;
- (void) saveTextFile:(NSString*)aFile forType:(NSString*)aType withContent:(NSString*)aContent;
- (void) deleteTextFile:(NSString*)aFile forType:(NSString*)aType;

@end
