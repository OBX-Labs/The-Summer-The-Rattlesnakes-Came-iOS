//
//  OKInfoViewProperties.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-06.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKInfoViewProperties.h"
#import "OKAppProperties.h"

static OKInfoViewProperties *sharedInstance;

@implementation OKInfoViewProperties
@synthesize properties;

+ (OKInfoViewProperties*) sharedInstance
{
    @synchronized(self)
	{
		if (sharedInstance == nil)
        {
			sharedInstance = [[OKInfoViewProperties alloc] init];
        }
	}
	return sharedInstance;
}

+ (void) initWithContentsOfFile:(NSString *)path
{
    [OKInfoViewProperties sharedInstance].properties = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    // Device type
    NSString *type = [OKAppProperties deviceType];
    
    // Set device specific images
    NSDictionary *deviceSpecificImages = [[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"];
    NSArray *keys = [deviceSpecificImages allKeys];
    
    NSMutableDictionary *images = [[NSMutableDictionary alloc] init];
    
    for(NSString *key in keys)
    {
        if([key isEqualToString:type])
        {
            NSDictionary *dict = [deviceSpecificImages objectForKey:key];
            
            for(NSString *dKey in [dict allKeys])
            {
                [images setObject:[dict objectForKey:dKey] forKey:dKey];
            }
        }
        else if(![key isEqualToString:@"iPhone"] && ![key isEqualToString:@"iPhone-Retina"] && ![key isEqualToString:@"iPhone-568h"] && ![key isEqualToString:@"iPad"] && ![key isEqualToString:@"iPad-Retina"])
        {
            [images setObject:[deviceSpecificImages objectForKey:key] forKey:key];
        }
    }
    
    // Update images
    [[OKInfoViewProperties objectForKey:@"Style"] setObject:images forKey:@"Images"];
    
    // Set device specific interface
    NSDictionary *deviceSpecificInterface = [OKInfoViewProperties objectForKey:@"Interface"];
    keys = [deviceSpecificInterface allKeys];
    
    NSMutableDictionary *interface = [[NSMutableDictionary alloc] init];
    
    for(NSString *key in keys)
    {
        if([key isEqualToString:type])
        {
            NSDictionary *dict = [deviceSpecificInterface objectForKey:key];
            
            for(NSString *dKey in [dict allKeys])
            {
                [interface setObject:[dict objectForKey:dKey] forKey:dKey];
            }
        }
        else if(![key isEqualToString:@"iPhone"] && ![key isEqualToString:@"iPhone-Retina"] && ![key isEqualToString:@"iPhone-568h"] && ![key isEqualToString:@"iPad"] && ![key isEqualToString:@"iPad-Retina"])
        {
            [interface setObject:[deviceSpecificInterface objectForKey:key] forKey:key];
        }
    }
    
    // Update interface
    [OKInfoViewProperties setObject:interface forKey:@"Interface"];
}

+ (id) objectForKey:(id)key { return [[OKInfoViewProperties sharedInstance].properties objectForKey:key]; }

+ (void) setObject:(id)object forKey:(id)key { [[OKInfoViewProperties sharedInstance].properties setObject:object forKey:key]; }

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

@end
