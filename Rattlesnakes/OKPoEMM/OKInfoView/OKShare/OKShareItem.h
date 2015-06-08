//
//  OKShareItem.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-03.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface OKShareItem : UIView
{
    UIImageView *imageView;
}

- (id) initWithFrame:(CGRect)aFrame andImage:(UIImage*)aImage;

@end
