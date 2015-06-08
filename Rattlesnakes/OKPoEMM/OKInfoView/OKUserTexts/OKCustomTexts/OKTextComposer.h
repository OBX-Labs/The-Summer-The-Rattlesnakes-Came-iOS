//
//  OKTextComposer.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKTextComposer : UIViewController <UITextViewDelegate, UIScrollViewDelegate>
{
    // Keyboard switch
    BOOL keyboardIsShown;
    
    // Composing view
    UITextView *composer;
    
    // Composer line counter
    UIScrollView *lineCounters;
    NSMutableArray *lineCountersAr;
    // Composer character per line counter
    UIScrollView *characterCounters;
    NSMutableArray *characterCountersAr;
    // Counter toggle;
    NSTimer *counterToggle;
    BOOL countersVisible;
    // Publish button
    UIBarButtonItem *publish;
}

- (id) initWithTitle:(NSString*)aTitle;
- (id) initWithTitle:(NSString*)aTitle andText:(NSString*)aText;

@end
