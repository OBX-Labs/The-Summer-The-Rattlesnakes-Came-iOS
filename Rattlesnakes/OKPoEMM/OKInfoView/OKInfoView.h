//
//  OKInfoView.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-04.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@class OKInfoViewProperties;
@class OKNavigationController;
@class OKAccountManager;

typedef enum
{
    OKAccountTypeLimitedEdition,
    OKAccountTypePublisher,
} OKAccountType;

@interface OKInfoView : UIViewController <MFMailComposeViewControllerDelegate>
{
    // Tab Bar Controller
    UITabBarController *tbc;
    
    // Tabs (sections)
    OKNavigationController *about;
    OKNavigationController *guestPoets;
    OKNavigationController *userTexts;
    OKNavigationController *customize;
    OKNavigationController *limitedEdition;
    OKNavigationController *share;
}

- (id) init;
- (void) dismiss;
- (void) setSelectedIndex:(NSInteger)aIndex;
- (void) presentMFMailComposeViewControllerAnimatied:(BOOL)aAnimated;
- (void) presentMFMailComposeViewControllerAnimatied:(BOOL)aAnimated withProperties:(NSDictionary*)properties;
- (void) presentSLComposeViewControllerAnimatied:(BOOL)aAnimated forServiceType:(NSString*)serviceType;
- (void) presentSLComposeViewControllerAnimatied:(BOOL)aAnimated forServiceType:(NSString*)serviceType withProperties:(NSDictionary*)properties;

@end
