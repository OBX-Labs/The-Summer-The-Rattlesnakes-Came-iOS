//
//  OKPublisher.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKInfoView.h"

@class OKInfoView;

@interface OKPublisher : UITableViewController
{
    // TableView Sections
    NSMutableArray *sections;
    
    // Display ViewController
    OKInfoView *display;
    
    // Account type
    OKAccountType accountType;
}

- (id) initWithTitle:(NSString*)aTitle style:(UITableViewStyle)aStyle forType:(OKAccountType)aType;
- (void) setDisplayViewController:(OKInfoView*)aDisplay;



@end
