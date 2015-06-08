//
//  OKMoreAppsItem.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-08.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface OKMoreAppsItem : UIView
{
    UIButton *icon;
    NSURL *url;
}

- (id) initAtPosition:(CGPoint)position withTitle:(NSString *)title andImage:(UIImage *)image;
- (void) setURL:(NSString*)aURL;

@end
