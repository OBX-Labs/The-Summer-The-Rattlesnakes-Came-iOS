//
//  OKInfoView.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-04.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKInfoView.h"
#import "OKAppProperties.h"
#import "OKInfoViewProperties.h"

#import "OKPoEMM.h"
#import "OKNavigationController.h"
#import "OKAbout.h"
#import "OKGuestPoets.h"
#import "OKUserTexts.h"
#import "OKLimitedEdition.h"
#import "OKShare.h"

@interface OKInfoView ()
@end

@implementation OKInfoView

- (id) init
{
    self = [super init];
    if(self)
    {        
        tbc = [[UITabBarController alloc] init];
        NSMutableArray *tbcItems = [[NSMutableArray alloc] init];
        
        int version = [[OKAppProperties objectForKey:@"Version"] intValue];
        BOOL isLimitedEdition = [[OKAppProperties objectForKey:@"LimitedEdition"] boolValue];
        NSDictionary *icons = [[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"icons"];
                
        // About shows on every versions
        // About
        OKAbout *rAbout = [[OKAbout alloc] initWithTitle:@"Info" icon:[UIImage imageNamed:[icons objectForKey:@"about"]]];
        about = [[OKNavigationController alloc] initWithRootViewController:rAbout andParent:self];
        [tbcItems addObject:about];
        
        // Limited Edition
        if(isLimitedEdition && version == 1 && ![[NSUserDefaults standardUserDefaults] stringForKey:@"version"])
        {
            OKLimitedEdition *rLimitedEdition = [[OKLimitedEdition alloc] initWithTitle:@"Bastard Limited Edition" style:UITableViewStyleGrouped forType:OKAccountTypeLimitedEdition];
            [rLimitedEdition setDisplayViewController:self];
            
            limitedEdition = [[OKNavigationController alloc] initWithRootViewController:rLimitedEdition andParent:self];
            [limitedEdition setTitle:@"Register"];
            [limitedEdition.tabBarItem setImage:[UIImage imageNamed:[icons objectForKey:@"limitededition"]]];
//            [tbcItems addObject:limitedEdition];
        }
        
        // Guest Poets at version 2 or more
        if(version >= 2)
        {
            OKGuestPoets *rGuestPoets = [[OKGuestPoets alloc] initWithStyle:UITableViewStylePlain title:@"Poets" icon:[UIImage imageNamed:[icons objectForKey:@"guestpoets"]]];
            guestPoets = [[OKNavigationController alloc] initWithRootViewController:rGuestPoets andParent:self];
//            [tbcItems addObject:guestPoets];
        }
        
        // User Texts at version 3 or more
        if(version >= 3)
        {
            OKUserTexts *rUserTexts = [[OKUserTexts alloc] initWithStyle:UITableViewStylePlain title:@"User Texts" icon:[UIImage imageNamed:[icons objectForKey:@"usertexts"]]];
            userTexts = [[OKNavigationController alloc] initWithRootViewController:rUserTexts andParent:self];
//            [tbcItems addObject:userTexts];
        }
        
        // Customizable at version 4 or more
        if(version >= 4)
        {
            customize = [[OKNavigationController alloc] initWithRootViewController:nil andParent:self];
//            [tbcItems addObject:customize];
        }
        
        // Share shows on every versions
        // Share
        OKShare *rShare;
        // Layout for iPad and iPhone are different
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            rShare = [[OKShare alloc] initForIPadWithTitle:@"Share" icon:[UIImage imageNamed:[icons objectForKey:@"share"]]];
        }
        else
        {
            rShare = [[OKShare alloc] initForIPhoneWithTitle:@"Share" icon:[UIImage imageNamed:[icons objectForKey:@"share"]]];
        }
        [rShare setDisplayViewController:self];
        share = [[OKNavigationController alloc] initWithRootViewController:rShare andParent:self];
//        [tbcItems addObject:share];
                
        [tbc setViewControllers:tbcItems animated:YES];
        [self.view addSubview:tbc.view];
        
        // Set colors color on UIWindow for iPhone but on the view for iPad since the FormSheet
        // ModalView does not allow us to change the color... why?
        UIImage *texture = [UIImage imageNamed:[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"texture"]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:texture]];
        }
        else
        {
            [self.view setBackgroundColor:[UIColor whiteColor]];
            [[[[UIApplication sharedApplication] windows] objectAtIndex:0] setBackgroundColor:[UIColor colorWithPatternImage:texture]];
        }

    }
    return self;
}

- (void) dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setSelectedIndex:(NSInteger)aIndex { [tbc setSelectedIndex:aIndex]; }

- (void) presentMFMailComposeViewControllerAnimatied:(BOOL)aAnimated
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setModalPresentationStyle:UIModalPresentationCurrentContext];
        [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [controller setMailComposeDelegate:self];
        
        // For the iPad we present the view on the UITabBarController but for the iPhone we present it
        // on OKInfoView
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [tbc presentViewController:controller animated:aAnimated completion:nil];
        }
        else
        {
            [self presentViewController:controller animated:aAnimated completion:nil];
        }
    }
    else
    {
        NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"7"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
        [alert show];
    }
}

- (void) presentMFMailComposeViewControllerAnimatied:(BOOL)aAnimated withProperties:(NSDictionary*)properties
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setModalPresentationStyle:UIModalPresentationCurrentContext];
        [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [controller setMailComposeDelegate:self];
        [controller setToRecipients:[properties objectForKey:@"Recipients"]];
        [controller setSubject:[properties objectForKey:@"Subject"]];
        [controller setMessageBody:[properties objectForKey:@"Body"] isHTML:NO];
        
        NSDictionary *attachement = [properties objectForKey:@"Attachment"];
        
        if(attachement)
        {
            [controller addAttachmentData:[attachement objectForKey:@"Data"] mimeType:[attachement objectForKey:@"MimeType" ] fileName:[attachement objectForKey:@"FileName"]];
        }
        
        // For the iPad we present the view on the UITabBarController but for the iPhone we present it
        // on OKInfoView
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [tbc presentViewController:controller animated:aAnimated completion:nil];
        }
        else
        {
            [self presentViewController:controller animated:aAnimated completion:nil];
        }
    }
    else
    {
        NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"7"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
        [alert show];
    }
}

- (void) presentSLComposeViewControllerAnimatied:(BOOL)aAnimated forServiceType:(NSString*)serviceType
{
    if([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composer setModalPresentationStyle:UIModalPresentationCurrentContext];
        [composer setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [composer setCompletionHandler:^(SLComposeViewControllerResult result)
        {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        // For the iPad we present the view on the UITabBarController but for the iPhone we present it
        // on OKInfoView
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [tbc presentViewController:composer animated:aAnimated completion:nil];
        }
        else
        {
            [self presentViewController:composer animated:aAnimated completion:nil];
        }
    }
    else
    {
        NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"7"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
        [alert show];
    }
}

- (void) presentSLComposeViewControllerAnimatied:(BOOL)aAnimated forServiceType:(NSString*)serviceType withProperties:(NSDictionary*)properties
{    
    if([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composer setModalPresentationStyle:UIModalPresentationCurrentContext];
        [composer setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];        
        [composer setInitialText:[properties objectForKey:@"Text"]];
        [composer addImage:[properties objectForKey:@"Image"]];
        [composer addURL:[NSURL URLWithString:[properties objectForKey:@"URL"]]];
        [composer setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             switch (result) {
                 case SLComposeViewControllerResultCancelled:
                     NSLog(@"Post Canceled");
                     [composer dismissViewControllerAnimated:YES completion:nil];
                     break;
                 case SLComposeViewControllerResultDone:
                     NSLog(@"Post Sucessful");
                     break;
                     
                 default:
                     break;
             }
         }];
        
        
        // For the iPad we present the view on the UITabBarController but for the iPhone we present it
        // on OKInfoView
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [tbc presentViewController:composer animated:aAnimated completion:nil];
        }
        else
        {
            [self presentViewController:composer animated:aAnimated completion:nil];
        }
    }
    else
    {
        NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"7"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
        [alert show];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) disablesAutomaticKeyboardDismissal { return NO; }

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Overrides the corners radius to -1 pixels to prevent from seeing with corners
    self.view.superview.layer.cornerRadius = 7.0f;
    for(CALayer *layer in self.view.superview.layer.sublayers)
    {
        if (layer != self.view.layer)
        {
            layer.cornerRadius = 8.0f;
        }
    }
    
    if(limitedEdition && [[NSUserDefaults standardUserDefaults] stringForKey:@"version"])
    {
        NSMutableArray *items = [NSMutableArray arrayWithArray:tbc.viewControllers];
        [items removeObject:limitedEdition];
        [tbc setViewControllers:items];
        [tbc setSelectedIndex:0];
    }
    
    [self setSelectedIndex:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OKInfoViewWillAppear" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OKInfoViewWillDisappear" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
