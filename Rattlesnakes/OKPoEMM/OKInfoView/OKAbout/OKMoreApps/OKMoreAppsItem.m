//
//  OKMoreAppsItem.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-08.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKMoreAppsItem.h"
#import "OKImageManipulator.h"

// These values were tweaked (based on the illustrator file and a bit of magic)
static float ITEM_WIDTH = 60.0f;
static float ITEM_HEIGHT = 75.0f;
static float ITEM_ICON_WIDTH = 50.0f;
static float ITEM_ICON_HEIGHT = 50.0f;
static float ITEM_ICON_CORNER_RADIUS = 8.0f;

@interface OKMoreAppsItem ()
- (void) openURL;
@end

@implementation OKMoreAppsItem

- (id) initAtPosition:(CGPoint)position withTitle:(NSString *)title andImage:(UIImage *)image
{
    CGRect frame = CGRectMake(position.x, position.y, ITEM_WIDTH, ITEM_HEIGHT);
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        // Icon
        float padding = (ITEM_WIDTH - ITEM_ICON_WIDTH) / 2.0f;
        icon = [[UIButton alloc] initWithFrame:CGRectMake(padding, padding, ITEM_ICON_WIDTH, ITEM_ICON_HEIGHT)];
        [icon addTarget:self action:@selector(openURL) forControlEvents:UIControlEventTouchUpInside];
        [icon setImage:[OKImageManipulator roundCornersForImage:image forScale:CGSizeMake(ITEM_ICON_WIDTH, ITEM_ICON_HEIGHT) withCornerRadius:CGSizeMake(ITEM_ICON_CORNER_RADIUS, ITEM_ICON_CORNER_RADIUS)] forState:UIControlStateNormal];
        
        // Applies shadow
        [icon.layer setShadowOffset:CGSizeZero];
        [icon.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [icon.layer setShadowOpacity:0.95f];
        [icon.layer setShadowRadius:2.5f];
        [icon.layer setShouldRasterize:YES];
        
        [self addSubview:icon];
        
        // Title
        padding = icon.frame.origin.y + icon.frame.size.height;
        
        UILabel *itemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, padding, frame.size.width, frame.size.height - padding)];
        [itemTitle setFont:[UIFont fontWithName:@"Dosis-Bold" size:12.0f]];
        [itemTitle setBackgroundColor:[UIColor clearColor]];
        [itemTitle setTextAlignment:NSTextAlignmentCenter];
        [itemTitle setText:title];
        
        [self addSubview:itemTitle];
        
    }
    return self;
}

- (void) setURL:(NSString*)aURL { url = [[NSURL alloc] initWithString:aURL]; }

- (void) openURL { [[UIApplication sharedApplication] openURL:url]; }

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [icon setHighlighted:YES];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(icon.isHighlighted)
    {
        [icon setHighlighted:NO];
        [self openURL];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(icon.isHighlighted)
        [icon setHighlighted:NO];
}

@end
