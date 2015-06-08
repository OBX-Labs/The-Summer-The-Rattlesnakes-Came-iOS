//
//  OKUserTexts.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-18.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKUserTexts.h"
#import "OKInfoViewProperties.h"

#import "OKTwitterFeeds.h"
#import "OKCustomTexts.h"

static float SELECTION_TINT[] = {0.0f, 0.0f, 1.0f, 1.0f}; // Default

@interface OKUserTexts ()

@end

@implementation OKUserTexts

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle icon:(UIImage *)aIcon
{
    self = [super initWithStyle:aStyle];
    if (self)
    {
        [self setTitle:aTitle];
        [self.tabBarItem setImage:aIcon];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        NSArray *selectionTint = [[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"SelectionTint"];
        
        SELECTION_TINT[0] = [[selectionTint objectAtIndex:0] floatValue];
        SELECTION_TINT[1] = [[selectionTint objectAtIndex:1] floatValue];
        SELECTION_TINT[2] = [[selectionTint objectAtIndex:2] floatValue];
        SELECTION_TINT[3] = [[selectionTint objectAtIndex:3] floatValue];
        
        types = [[NSArray alloc] initWithObjects:@"Twitter Feeds", @"Custom Texts", nil];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [types count]; }

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [[cell textLabel] setText:[types objectAtIndex:[indexPath row]]];
    [[cell textLabel] setFont:[UIFont fontWithName:@"Dosis-Bold" size:16.0f]];
    
    // Set SelectionStyle to match tint // Get from prefs
    UIView *tableViewCellSelectionStyleTint = [[UIView alloc] init];
    [tableViewCellSelectionStyleTint setBackgroundColor:[UIColor colorWithRed:SELECTION_TINT[0] green:SELECTION_TINT[1] blue:SELECTION_TINT[2] alpha:SELECTION_TINT[3]]];
    [cell setSelectedBackgroundView:tableViewCellSelectionStyleTint];
    
    return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[types objectAtIndex:[indexPath row]] isEqualToString:@"Twitter Feeds"])
    {
        OKTwitterFeeds *twitterFeeds = [[OKTwitterFeeds alloc] initWithStyle:UITableViewStylePlain title:@"Twitter Feeds"];
        [self.navigationController pushViewController:twitterFeeds animated:YES];
    }
    else if([[types objectAtIndex:[indexPath row]] isEqualToString:@"Custom Texts"])
    {
        OKCustomTexts *customTexts = [[OKCustomTexts alloc] initWithStyle:UITableViewStylePlain title:@"Custom Texts"];
        [self.navigationController pushViewController:customTexts animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
