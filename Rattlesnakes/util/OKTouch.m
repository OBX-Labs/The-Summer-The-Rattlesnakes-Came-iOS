//
//  OKTouch.m
//  Smooth
//
//  Created by Christian Gratton on 11-09-12.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import "OKTouch.h"


@implementation OKTouch
@synthesize iid, pos;

- (id) initWithId:(int)aID andPos:(CGPoint)aPos
{
    self = [super init];
    if(self)
    {
        iid = aID;
        pos = aPos;
    }
    return self;
}

@end
