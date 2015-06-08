//
//  OKNewAccount.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKInfoView.h"

@class OKInfoView;
@class OKRegistration;

@interface OKNewAccount : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>
{
    // TableView Sections
    NSMutableArray *sections;
    
    // Validation errors
    NSMutableArray *validationErrors;
    
    // First Responders
    NSMutableArray *firstResponders;
    
    // Display ViewController
    OKInfoView *display;
    
    // Account type
    OKAccountType accountType;
    
    // Keyboard switch
    BOOL keyboardIsShown;
    
    // Row Switcher
    NSIndexPath *sRow;
}

- (id) initWithTitle:(NSString*)aTitle style:(UITableViewStyle)aStyle forType:(OKAccountType)aType;
- (void) setDisplayViewController:(OKInfoView*)aDisplay;

@end
