//
//  OKPreloader.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-11.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface OKPreloader : UIViewController
{
    CGRect frame;
    AppDelegate *delegate;
    BOOL loadOnAppear;
}

- (id) initWithFrame:(CGRect)aFrame forApp:(AppDelegate*)aDelegate loadOnAppear:(BOOL)flag;

@end
