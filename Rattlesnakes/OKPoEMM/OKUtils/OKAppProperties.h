//
//  OKAppProperties.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-18.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKAppProperties : NSObject

@property (nonatomic, retain) NSMutableDictionary *properties;
@property (nonatomic, getter = isiPad) BOOL iPad;
@property (nonatomic, getter = isiPhone568h) BOOL iPhone568h;
@property (nonatomic, getter = wasPushed) BOOL pushed;
@property (nonatomic) float scale;

+ (OKAppProperties*) sharedInstance;

// Init the properties with a plist
+ (void) initWithContentsOfFile:(NSString*)aPath andOptions:(NSDictionary*)aOptions;

// Retreive a property value from a singleton
+ (id) objectForKey:(id)aKey;
+ (void) setObject:(id)aObject forKey:(id)aKey;

// Check if the os is above or equal to the passed version
+ (BOOL) isOSGreaterOrEqualThan:(NSString*)aOS;

// Check if the app is running on the iPad
+ (BOOL) isiPad;

// Check if the app is running on a 5 inch screen device (568h)
+ (BOOL) isiPhone568h;

// Check if the app is running on a device with retina display
+ (BOOL) isRetina;

+ (NSString*) deviceType;

- (void) listAvailableFonts;

+ (void) listProperties;

@end
