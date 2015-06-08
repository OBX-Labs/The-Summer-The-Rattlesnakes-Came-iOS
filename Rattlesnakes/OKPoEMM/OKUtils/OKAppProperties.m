//
//  OKAppProperties.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-18.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKAppProperties.h"

// The shared instance
static OKAppProperties *sharedInstance = nil;

@implementation OKAppProperties
@synthesize properties, iPad, iPhone568h, pushed, scale;

+ (OKAppProperties*) sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[OKAppProperties alloc] init];
            sharedInstance.properties = [[NSMutableDictionary alloc] init];
            sharedInstance.iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
            sharedInstance.iPhone568h = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 568.0f);
            sharedInstance.pushed = NO;
            sharedInstance.scale = 1.0f;
            
            // Detect if we have a retina device
            if([[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"scale")])
            {
                if([[UIScreen mainScreen] scale] > 1.9f)
                {
                    [sharedInstance setScale:2.0f];
                }
            }
        }
    }
    return sharedInstance;
}

+ (void) initWithContentsOfFile:(NSString *)aPath andOptions:(NSDictionary *)aOptions
{
    [OKAppProperties sharedInstance].properties = [[NSMutableDictionary alloc] initWithContentsOfFile:aPath];
    
    // Check if app was launched with a remote notification
    NSDictionary *remoteNotification = [aOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [OKAppProperties sharedInstance].pushed = (remoteNotification != nil);
    
    // Set device specific values    
    NSDictionary *deviceSpecific = [OKAppProperties objectForKey:@"DeviceSpecific"];
    NSArray *keys = [deviceSpecific allKeys];
    NSString *type = [OKAppProperties deviceType];
    
    for(NSString *key in keys)
    {        
        if([key isEqualToString:type])
        {
            [OKAppProperties setObject:[deviceSpecific objectForKey:key] forKey:@"DeviceSpecific"];
        }
    }
}

+ (id) objectForKey:(id)aKey { return [[OKAppProperties sharedInstance].properties objectForKey:aKey]; }

+ (void) setObject:(id)aObject forKey:(id)aKey { [[OKAppProperties sharedInstance].properties setObject:aObject forKey:aKey]; }

+ (BOOL) isOSGreaterOrEqualThan:(NSString *)aOS
{
    NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
    return ([currentVersion compare:aOS options:NSNumericSearch] != NSOrderedAscending);
}

+ (BOOL) isiPad { return [[OKAppProperties sharedInstance] isiPad]; }

+ (BOOL) isiPhone568h { return [[OKAppProperties sharedInstance] isiPhone568h]; }

+ (BOOL) isRetina { return [[OKAppProperties sharedInstance] scale] > 1.0f; }

+ (NSString*) deviceType
{
    NSString *type;
    
    if(![OKAppProperties isiPad] && ![OKAppProperties isRetina] && ![OKAppProperties isiPhone568h]) type = @"iPhone";
    else if(![OKAppProperties isiPad] && [OKAppProperties isRetina] && ![OKAppProperties isiPhone568h]) type = @"iPhone-Retina";
    else if(![OKAppProperties isiPad] && [OKAppProperties isRetina] && [OKAppProperties isiPhone568h]) type = @"iPhone-568h";
    else if([OKAppProperties isiPad] && ![OKAppProperties isRetina] && ![OKAppProperties isiPhone568h]) type = @"iPad";
    else if([OKAppProperties isiPad] && [OKAppProperties isRetina] && ![OKAppProperties isiPhone568h]) type = @"iPad-Retina";
    
    return type;
}

// List all available fonts
- (void) listAvailableFonts
{
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
}

+ (void) listProperties { NSLog(@"%@", [OKAppProperties sharedInstance].properties); }

@end
