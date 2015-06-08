//
//  OKCustomTexts.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKCustomTexts : UITableViewController <UITextFieldDelegate>
{
    // Keyboard switch
    BOOL keyboardIsShown;
    
    // Rows
    NSMutableArray *rows;
}

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle;

@end
