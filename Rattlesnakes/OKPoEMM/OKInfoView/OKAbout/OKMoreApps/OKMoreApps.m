//
//  OKMoreApps.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-04.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKMoreApps.h"
#import "OKMoreAppsItem.h"
#import "OKAppProperties.h"
#import "OKInfoViewProperties.h"

static int MAX_MORE_APPS = 7;
static float ITEM_WIDTH = 60.0f;

@implementation OKMoreApps

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 25.0f)];
        [title setFont:[UIFont fontWithName:@"Dosis-Bold" size:14.0f]];
        [title setText:@"P.o.E.M.M. APPS"];
        [self addSubview:title];
        
        moreApps = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 25.0f, frame.size.width, frame.size.height - 25.0f)];
        [moreApps setBackgroundColor:[UIColor clearColor]];
        [self addSubview:moreApps];
    }
    return self;
}

- (void) setItems:(NSDictionary*)items
{
    NSMutableDictionary *keys = [[NSMutableDictionary alloc] initWithCapacity:[[items allKeys] count]];
        
    for(NSString *key in [items allKeys])
    {
        NSDictionary *item = [items objectForKey:key];
        
        // This way we don't have to modify the info plist each time
        if(![key isEqualToString:[OKAppProperties objectForKey:@"Name"]])
            [keys setObject:key forKey:[NSString stringWithFormat:@"%i", [[item objectForKey:@"order"] intValue]]];
    }
    
    NSArray *sortedKeys = [[keys allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    float padding = (moreApps.frame.size.width / MAX_MORE_APPS) - ITEM_WIDTH;
    
    for(int i = 0; i < [sortedKeys count]; i++)
    {
        NSString *key = [keys objectForKey:[sortedKeys objectAtIndex:i]];
        NSDictionary *item = [items objectForKey:key];
        
        OKMoreAppsItem *ma = [[OKMoreAppsItem alloc] initAtPosition:CGPointMake((i * (ITEM_WIDTH + padding)), 0.0f) withTitle:key andImage:[UIImage imageNamed:[item objectForKey:@"image"]]];
        [ma setURL:[item objectForKey:@"url"]];
        
        [moreApps addSubview:ma];
    }
}

@end
