//
//  OKAbout.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-06.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class OKInfoView;

@interface OKAbout : UIViewController
{        
    // ScrollView
    UIScrollView *scrollView;
    
    // LimitedEdition text
    UILabel *limitedEdition;
}

- (id) initWithTitle:(NSString *)aTitle icon:(UIImage *)aIcon;

@end
