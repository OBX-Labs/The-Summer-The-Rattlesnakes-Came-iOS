//
//  OKGuestPoetsHeader.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-09.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKGuestPoetsHeader.h"
#import "OKInfoViewProperties.h"

static float SEPERATOR_TINT[] = {0.35f, 0.35f, 0.35f, 1.0f};
static float SELECTION_TINT[] = {0.0f, 0.0f, 0.0f, 1.0f}; // Default
static float PADDING = 15.0f;
static float ARTIST_IMAGE_WIDTH = 100.0f;
static float ARTIST_IMAGE_HEIGHT = 100.0f;

@implementation OKGuestPoetsHeader

- (id)initWithFrame:(CGRect)aFrame andGuestPoet:(NSDictionary*)aPoet
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        // Background color
        [self setBackgroundColor:[UIColor whiteColor]];
        
        NSArray *selectionTint = [[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"SelectionTint"];
        
        SELECTION_TINT[0] = [[selectionTint objectAtIndex:0] floatValue];
        SELECTION_TINT[1] = [[selectionTint objectAtIndex:1] floatValue];
        SELECTION_TINT[2] = [[selectionTint objectAtIndex:2] floatValue];
        SELECTION_TINT[3] = [[selectionTint objectAtIndex:3] floatValue];
        
        // Guest Poet Image
        UIImageView *gpi = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, (self.frame.size.height - ARTIST_IMAGE_HEIGHT) / 2.0f, ARTIST_IMAGE_WIDTH, ARTIST_IMAGE_HEIGHT)];
        [gpi setBackgroundColor:[UIColor whiteColor]];
        [gpi setImage:[UIImage imageWithContentsOfFile:[aPoet objectForKey:@"ImagePath"]]];       
        
//        // Applies border
//        [gpi.layer setBorderColor:[[UIColor whiteColor] CGColor]];
//        [gpi.layer setBorderWidth:2.5f];
//        
//        // Applies shadow
//        [gpi.layer setShadowOffset:CGSizeMake(0, 1)];
//        [gpi.layer setShadowColor:[[UIColor blackColor] CGColor]];
//        [gpi.layer setShadowOpacity:0.15f];
//        [gpi.layer setShadowRadius:2.0f];
//        [gpi.layer setShouldRasterize:YES];
        
        [self addSubview:gpi];
        
        // Guest poet name
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(gpi.frame.origin.x + gpi.frame.size.width + PADDING, PADDING, self.frame.size.width - (gpi.frame.origin.x + gpi.frame.size.width + (PADDING * 2)), 20.0f)];
        [name setFont:[UIFont fontWithName:@"Dosis-Bold" size:22.0f]];        
        [name setBackgroundColor:[UIColor clearColor]];
        [name setText:[aPoet objectForKey:@"AuthorName"]];
        [self addSubview:name];
        
        // Guest poet bio
        UILabel *bio = [[UILabel alloc] initWithFrame:CGRectMake(gpi.frame.origin.x + gpi.frame.size.width + PADDING, name.frame.origin.y + name.frame.size.height + 2.0f, self.frame.size.width - (gpi.frame.origin.x + gpi.frame.size.width + (PADDING * 2)), 71.0f)];
        [bio setFont:[UIFont fontWithName:@"Museo-500" size:12.0f]];
        [bio setLineBreakMode:NSLineBreakByWordWrapping];
        [bio setBackgroundColor:[UIColor clearColor]];
        [bio setNumberOfLines:0];
        [bio setText:[aPoet objectForKey:@"AuthorBio"]];
        [self addSubview:bio];
        
        // Guest poet url
        lblUrl = [[UILabel alloc] initWithFrame:CGRectMake(gpi.frame.origin.x + gpi.frame.size.width + PADDING, bio.frame.origin.y + bio.frame.size.height, self.frame.size.width - (gpi.frame.origin.x + gpi.frame.size.width + (PADDING * 2)), 16.0f)];
        [lblUrl setFont:[UIFont fontWithName:@"Dosis-Bold" size:12.0f]];
        [lblUrl setBackgroundColor:[UIColor clearColor]];
        [lblUrl setText:[aPoet objectForKey:@"AuthorWebsite"]];
        [lblUrl setUserInteractionEnabled:YES];
        [self addSubview:lblUrl];
        
        // URL        
        if(![[aPoet objectForKey:@"AuthorWebsite"] isEqualToString:@""]) url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@", [aPoet objectForKey:@"AuthorWebsite"]]];
        
        // Seperator
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 1.0f, self.frame.size.width, 1.0)];
        [seperator setBackgroundColor:[UIColor colorWithRed:SEPERATOR_TINT[0] green:SEPERATOR_TINT[1] blue:SEPERATOR_TINT[2] alpha:SEPERATOR_TINT[3]]];
        [self addSubview:seperator];
    }
    return self;
}

- (UIImage*) resizeImage:(UIImage*)aImage forScale:(CGSize)aScale
{
    UIGraphicsBeginImageContext(aScale);
    [aImage drawInRect:CGRectMake(0.0f, 0.0f, aScale.width, aScale.height)];
    UIImage *nImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return nImage;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if([touch view] == lblUrl)
    {
        [lblUrl setTextColor:[UIColor colorWithRed:SELECTION_TINT[0] green:SELECTION_TINT[1] blue:SELECTION_TINT[2] alpha:SELECTION_TINT[3]]];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if([touch view] == lblUrl)
    {
        [lblUrl setTextColor:[UIColor blackColor]];
                
        if(url != nil) [[UIApplication sharedApplication] openURL:url];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if([touch view] == lblUrl)
    {
        [lblUrl setTextColor:[UIColor blackColor]];
    }
}

@end
