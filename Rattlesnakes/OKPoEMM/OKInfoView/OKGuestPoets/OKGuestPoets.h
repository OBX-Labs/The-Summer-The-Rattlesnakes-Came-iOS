//
//  OKGuestPoets.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface OKGuestPoets : UITableViewController <NSURLConnectionDelegate>
{
    // Table View Headers (prevents lags if initialized and stored one)
    NSMutableArray *headers;
    NSMutableArray *authors;
    NSMutableDictionary *packages;
    
    // Invisible overlay (for DSActivityView)
    UIView *overlay;
    
    // Row
    NSIndexPath *sRow;
}

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle icon:(UIImage *)aIcon;

@end
