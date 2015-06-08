//
//  OKNavigationController.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKNavigationController.h"

#import "OKInfoView.h"

@interface OKNavigationController ()
@end

@implementation OKNavigationController

- (id) initWithRootViewController:(UIViewController*)aRoot andParent:(UIViewController*)aParent
{
    self = [super initWithRootViewController:aRoot];
    if (self)
    {        
        parent = aParent;
        root = aRoot;
        
        // Buttons
        UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
        [close setFrame:CGRectMake(0.0f, 0.0f, self.navigationBar.frame.size.height, self.navigationBar.frame.size.height)];
        [close addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [close setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        //UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
        //UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
        [root.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:close] animated:NO];
    }
    return self;
}

- (void) dismiss
{
    [parent dismissViewControllerAnimated:YES completion:nil];
}

- (UIViewController*) getParentViewController
{
    return parent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
