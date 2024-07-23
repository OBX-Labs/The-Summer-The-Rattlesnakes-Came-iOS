//
//  OKPreloader.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-11.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKPreloader.h"
#import <OBXKit/AppDelegate.h>
#import "OKAppProperties.h"

#define M_PI 3.14159265358979323846264338327950288f
#define DEGREES_TO_RADIANS(angle) (angle / 180.0f * M_PI)

@interface OKPreloader ()

@end

@implementation OKPreloader

- (id) initWithFrame:(CGRect)aFrame forApp:(AppDelegate *)aDelegate loadOnAppear:(BOOL)flag
{
    self = [super init];
    if(self)
    {
        frame = aFrame;
        delegate = aDelegate;
        loadOnAppear = flag;
        
        // Background
        NSString *name;
        UIImage *image;
        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        {
            name = ([OKAppProperties isiPhone568h] ? @"Default-568h@2x.png" : @"Default.png");
            image = [[UIImage alloc] initWithCGImage:[[UIImage imageNamed:name] CGImage] scale:1.0 orientation:UIImageOrientationRight];
        }
        else
        {
            name = @"Default-Landscape.png";
            image = [[UIImage alloc] initWithCGImage:[[UIImage imageNamed:name] CGImage] scale:1.0 orientation:UIImageOrientationUp];
        }
        
        UIImageView *background = [[UIImageView alloc] initWithFrame:aFrame];
        [background setImage:image];     
        [self.view addSubview:background];
        
        // Loader
        float x = frame.size.width / 2.0f; // center on x
        float halfHeight = (frame.size.height / 2.0f);
        float y = halfHeight + (halfHeight / 2.0);
        
        UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loader setCenter:CGPointMake(x, y)];
        [loader startAnimating];
        [self.view addSubview:loader];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    // Only load if there's not an epic fail
    if(loadOnAppear) [delegate loadOKPoEMMInFrame:frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
