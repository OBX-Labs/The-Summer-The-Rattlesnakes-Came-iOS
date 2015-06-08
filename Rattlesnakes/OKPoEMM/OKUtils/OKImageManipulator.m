//
//  OKImageManipulator.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-09.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKImageManipulator.h"

@implementation OKImageManipulator

+ (UIImage*) imageWithImage:(UIImage*)image resizeToScale:(CGSize)scale
{
    // Create a bitmap context.
    UIGraphicsBeginImageContext(scale);
    [image drawInRect:CGRectMake(0.0f ,0.0f , scale.width, scale.height)];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

+ (UIImage*) roundCornersForImage:(UIImage*)image forScale:(CGSize)scale withCornerRadius:(CGSize)radius
{
    UIImage *roundedCorners;
    
    UIImage *resizedImg = [OKImageManipulator imageWithImage:image resizeToScale:scale];
    int w = resizedImg.size.width;
    int h = resizedImg.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, resizedImg.size.width, resizedImg.size.height);
    addRoundedRectToPath(context, rect, radius.width, radius.height);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), resizedImg.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    roundedCorners = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    
    return roundedCorners;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@end
