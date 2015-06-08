//
//  OKImageManipulator.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-09.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKImageManipulator : NSObject

+ (UIImage*) imageWithImage:(UIImage*)image resizeToScale:(CGSize)scale;
+ (UIImage*) roundCornersForImage:(UIImage*)image forScale:(CGSize)scale withCornerRadius:(CGSize)radius;

@end
