//
//  KineticString.m
//  Choice
//
//  Created by Christian Gratton on 11-11-16.
//  Copyright (c) 2011 Christian Gratton. All rights reserved.
//

#import "KineticString.h"

@implementation KineticString

- (id) initWithString:(NSString*)aString
{
    self = [super init];
	if(self)
    {
		string = aString;
        group = -1;
	}
	return self;
}

- (void)dealloc
{	
    [super dealloc];
}

@end
