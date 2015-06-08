//
//  OKShare.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-02.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKShare.h"
#import "OKInfoViewProperties.h"

#import "OKInfoView.h"
#import "OKShareButton.h"
#import "OKShareScrollView.h"

static float BUTTON_WIDTH;
static float BUTTON_HEIGHT;

@interface OKShare ()
- (void) shareWithFacebook;
- (void) shareWithTwitter;
- (void) shareWithMail;
@end

@implementation OKShare

- (id) initForIPadWithTitle:(NSString *)aTitle icon:(UIImage *)aIcon
{
    self = [super init];
    if (self)
    {
        [self setTitle:aTitle];
        [self.tabBarItem setImage:aIcon];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        BUTTON_WIDTH = [[[OKInfoViewProperties objectForKey:@"Interface"] objectForKey:@"share_button_width"] floatValue];
        BUTTON_HEIGHT = [[[OKInfoViewProperties objectForKey:@"Interface"] objectForKey:@"share_button_height"] floatValue];
        
        imageNames = [[NSArray alloc] initWithArray:[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"share"]];
        
        scrollView = [[OKShareScrollView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 540.0f, 357.5f) andPageSize:CGSizeMake(476.6f, 357.5f)];
        [scrollView setPages:imageNames forScrollingDirection:ContentScrollDirectionHorizontal];
        [self.view addSubview:scrollView];
        
        // Buttons
        facebook = [[OKShareButton alloc] initWithFrame:CGRectMake(142.5f, 414.75f, BUTTON_WIDTH, BUTTON_HEIGHT) forType:OKShareButtonTypeFacebook];
        [facebook setDelegate:self];
        [self.view addSubview:facebook];
        
        twitter = [[OKShareButton alloc] initWithFrame:CGRectMake(232.5f, 414.75f, BUTTON_WIDTH, BUTTON_HEIGHT) forType:OKShareButtonTypeTwitter];
        [twitter setDelegate:self];
        [self.view addSubview:twitter];
        
        mail = [[OKShareButton alloc] initWithFrame:CGRectMake(322.5f, 414.75f, BUTTON_WIDTH, BUTTON_HEIGHT) forType:OKShareButtonTypeMail];
        [mail setDelegate:self];
        [self.view addSubview:mail];
    }
    return self;
}

- (id) initForIPhoneWithTitle:(NSString *)aTitle icon:(UIImage *)aIcon
{
    self = [super init];
    if (self)
    {
        [self setTitle:aTitle];
        [self.tabBarItem setImage:aIcon];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        BUTTON_WIDTH = [[[OKInfoViewProperties objectForKey:@"Interface"] objectForKey:@"share_button_width"] floatValue];
        BUTTON_HEIGHT = [[[OKInfoViewProperties objectForKey:@"Interface"] objectForKey:@"share_button_height"] floatValue];
        
        imageNames = [[NSArray alloc] initWithArray:[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Images"] objectForKey:@"share"]];
        
        center = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 480.0f, 239.0f)];
        [center setBackgroundColor:[UIColor clearColor]];
        
        scrollView = [[OKShareScrollView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 300.0f, 239.0f) andPageSize:CGSizeMake(300.0f, 200.0f)];
        [scrollView setPages:imageNames forScrollingDirection:ContentScrollDirectionVertical];
        [center addSubview:scrollView];
        
        // Buttons
        facebook = [[OKShareButton alloc] initWithFrame:CGRectMake(367.5f, 7.0f, BUTTON_WIDTH, BUTTON_HEIGHT) forType:OKShareButtonTypeFacebook];
        [facebook setDelegate:self];
        [center addSubview:facebook];
        
        twitter = [[OKShareButton alloc] initWithFrame:CGRectMake(367.5f, 82.0f, BUTTON_WIDTH, BUTTON_HEIGHT) forType:OKShareButtonTypeTwitter];
        [twitter setDelegate:self];
        [center addSubview:twitter];
        
        mail = [[OKShareButton alloc] initWithFrame:CGRectMake(367.5f, 157.0f, BUTTON_WIDTH, BUTTON_HEIGHT) forType:OKShareButtonTypeMail];
        [mail setDelegate:self];
        [center addSubview:mail];
        
        [self.view addSubview:center];
    }
    return self;
}

- (void) setDisplayViewController:(OKInfoView*)aDisplay { display = aDisplay; }

- (void) shareWithType:(OKShareButtonType)type
{
    if(type == OKShareButtonTypeFacebook) [self shareWithFacebook];
    else if(type == OKShareButtonTypeTwitter) [self shareWithTwitter];
    else if(type == OKShareButtonTypeMail) [self shareWithMail];
}

- (void) shareWithFacebook
{
    UIImage *image = [UIImage imageNamed:[imageNames objectAtIndex:[scrollView currentPage]]];
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:[[OKInfoViewProperties objectForKey:@"Texts"] objectForKey:@"share"] forKey:@"Text"];
    [properties setObject:image forKey:@"Image"];
    
    [display presentSLComposeViewControllerAnimatied:YES forServiceType:SLServiceTypeFacebook withProperties:properties];
}

- (void) shareWithTwitter
{
    UIImage *image = [UIImage imageNamed:[imageNames objectAtIndex:[scrollView currentPage]]];
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:[[OKInfoViewProperties objectForKey:@"Texts"] objectForKey:@"share"] forKey:@"Text"];
    [properties setObject:image forKey:@"Image"];
    
    [display presentSLComposeViewControllerAnimatied:YES forServiceType:SLServiceTypeTwitter withProperties:properties];
}

- (void) shareWithMail
{
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:[[OKInfoViewProperties objectForKey:@"Texts"] objectForKey:@"share"] forKey:@"Body"];
    
    UIImage *img = [UIImage imageNamed:[imageNames objectAtIndex:[scrollView currentPage]]];
    NSData *data = UIImagePNGRepresentation(img);
    
    if(data)
    {
        NSMutableDictionary *attachment = [[NSMutableDictionary alloc] init];
        [attachment setObject:data forKey:@"Data"];
        [attachment setObject:@"image/png" forKey:@"MimeType"];
        [attachment setObject:@"attachment.png" forKey:@"FileName"];
        
        [properties setObject:attachment forKey:@"Attachment"];
    }
    
    [display presentMFMailComposeViewControllerAnimatied:YES withProperties:properties];
}

- (void) viewDidAppear:(BOOL)animated
{
    if(center)
    {
        float x = (self.view.frame.size.width - center.frame.size.width) / 2.0f;
        float y = (self.view.frame.size.height - center.frame.size.height) / 2.0f;
        
        [center setFrame:CGRectMake(x, y, center.frame.size.width, center.frame.size.height)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
