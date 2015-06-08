//
//  OKShareButton.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-02.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OKShareButtonProtocol.h"

@interface OKShareButton : UIView
{
    UIButton *icon;
    UILabel *title;
    OKShareButtonType type;
}

@property (nonatomic, setter = setDelegate:) id<OKShareButtonProtocol> delegate;

- (id) initWithFrame:(CGRect)frame forType:(OKShareButtonType)aType;

@end
