//
//  OKShare.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-02.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "OKShareButtonProtocol.h"

@class OKInfoView;
@class OKShareButton;
@class OKShareScrollView;

@interface OKShare : UIViewController <OKShareButtonProtocol>
{
    OKInfoView *display;
    
    OKShareButton *facebook;
    OKShareButton *twitter;
    OKShareButton *mail;
    
    OKShareScrollView *scrollView;
    
    UIView *center;
    
    NSArray *imageNames;
}

- (id) initForIPadWithTitle:(NSString *)aTitle icon:(UIImage *)aIcon;
- (id) initForIPhoneWithTitle:(NSString *)aTitle icon:(UIImage *)aIcon;
- (void) setDisplayViewController:(OKInfoView*)aDisplay;

@end
