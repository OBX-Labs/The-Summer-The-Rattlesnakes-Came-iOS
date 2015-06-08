//
//  OKTwitterFeeds.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-18.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OKTwitterProtocol.h"

@interface OKTwitterFeeds : UITableViewController <UITextFieldDelegate, OKTwitterProtocol>
{
    // Keyboard switch
    BOOL keyboardIsShown;
    
    // Rows
    NSMutableArray *rows;
    NSIndexPath *sRow;
    
    // Invisible overlay (for DSActivityView)
    UIView *overlay;
    
    // Current feed
    NSString *cFeed;
    
    // Button
    UIBarButtonItem *search;
}

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle;

@end
