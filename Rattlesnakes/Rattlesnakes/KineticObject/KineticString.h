//
//  KineticString.h
//  Choice
//
//  Created by Christian Gratton on 11-11-16.
//  Copyright (c) 2011 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KineticString : NSObject
{
    NSString *string;
    int group;
}

- (id) initWithString:(NSString*)aString;

@end
