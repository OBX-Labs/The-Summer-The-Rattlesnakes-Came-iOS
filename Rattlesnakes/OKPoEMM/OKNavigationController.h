//
//  OKNavigationController.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKNavigationController : UINavigationController
{
    UIViewController *parent;
    UIViewController *root;
    UIPopoverController *po;
}

- (id) initWithRootViewController:(UIViewController*)aRoot andParent:(UIViewController*)aParent;
- (void) dismiss;
- (UIViewController*) getParentViewController;

@end
