//
//  OKInfoViewProperties.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-06.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKInfoViewProperties : NSObject

@property (nonatomic, retain) NSMutableDictionary *properties;

+ (OKInfoViewProperties*) sharedInstance;
+ (void) initWithContentsOfFile:(NSString*)path;
+ (id) objectForKey:(id)key;
+ (void) setObject:(id)object forKey:(id)key;
- (void) listAvailableFonts;

@end
