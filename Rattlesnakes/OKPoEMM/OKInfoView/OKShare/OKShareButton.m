//
//  OKShareButton.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-02.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKShareButton.h"
#import "OKInfoViewProperties.h"
#import "OKImageManipulator.h"

// These values were tweaked (based on the illustrator file and a bit of magic)
// Default
static float ICON_WIDTH = 57.0f;
static float ICON_HEIGHT = 57.0f;
static float ICON_Y_PADDING = 5.0f;

@interface OKShareButton ()
- (void) share;
@end

@implementation OKShareButton
@synthesize delegate;

- (id) initWithFrame:(CGRect)frame forType:(OKShareButtonType)aType
{
    self = [super initWithFrame:frame];
    if (self)
    {
        type = aType;
        
        // Icon
        float x = (frame.size.width - ICON_WIDTH) / 2.0f;
        
        icon = [[UIButton alloc] initWithFrame:CGRectMake(x, ICON_Y_PADDING, ICON_WIDTH, ICON_HEIGHT)];
        [icon addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        
        if(type == OKShareButtonTypeFacebook)
        {
            NSString *name = [[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"facebook"];
            UIImage *image = [UIImage imageNamed:name];
            [icon setImage:[OKImageManipulator imageWithImage:image resizeToScale:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateNormal];
        }
        else if(type == OKShareButtonTypeTwitter)
        {
            NSString *name = [[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"twitter"];
            UIImage *image = [UIImage imageNamed:name];
            [icon setImage:[OKImageManipulator imageWithImage:image resizeToScale:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateNormal];
        }
        else if(type == OKShareButtonTypeMail)
        {
            NSString *name = [[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"mail"];
            UIImage *image = [UIImage imageNamed:name];
            [icon setImage:[OKImageManipulator imageWithImage:image resizeToScale:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)] forState:UIControlStateNormal];
        }
        
        // Applies shadow
        [icon.layer setShadowOffset:CGSizeZero];
        [icon.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [icon.layer setShadowOpacity:0.5f];
        [icon.layer setShadowRadius:3.5f];
        [icon.layer setShouldRasterize:YES];
        
        // Add to view
        [self addSubview:icon];
        
        // Title
        float yPadding = icon.frame.origin.y + icon.frame.size.height;
        title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, yPadding, frame.size.width, self.frame.size.height - yPadding)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setFont:[UIFont fontWithName:@"Dosis-Bold" size:12.0f]];
        [title setTextAlignment:NSTextAlignmentCenter];
        
        if(type == OKShareButtonTypeFacebook) [title setText:@"Facebook"];
        else if(type == OKShareButtonTypeTwitter) [title setText:@"Twitter"];
        else if(type == OKShareButtonTypeMail) [title setText:@"Mail"];
        
        // Add to view
        [self addSubview:title];
    }
    return self;
}

- (void) share
{
    [delegate shareWithType:type];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [icon setHighlighted:YES];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(icon.isHighlighted)
    {
        [self share];
        [icon setHighlighted:NO];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(icon.isHighlighted)
        [icon setHighlighted:NO];
}

@end
