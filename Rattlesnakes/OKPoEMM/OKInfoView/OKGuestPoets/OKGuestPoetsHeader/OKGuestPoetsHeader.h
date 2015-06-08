//
//  OKGuestPoetsHeader.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-09.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class OKInfoText;

@interface OKGuestPoetsHeader : UIView
{    
    // Guest Poet URL
    UILabel *lblUrl;
    NSURL *url;
}

- (id)initWithFrame:(CGRect)aFrame andGuestPoet:(NSDictionary*)aPoet;

@end
