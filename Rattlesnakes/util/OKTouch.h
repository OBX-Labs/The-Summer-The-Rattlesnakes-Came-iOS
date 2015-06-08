//
//  OKTouch.h
//  Smooth
//
//  Created by Christian Gratton on 11-09-12.
//  Copyright 2011 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OKTouch : NSObject
{
    int iid;
    CGPoint pos;
}

@property (nonatomic) int iid;
@property (nonatomic) CGPoint pos;

- (id) initWithId:(int)aID andPos:(CGPoint)aPos;

@end
