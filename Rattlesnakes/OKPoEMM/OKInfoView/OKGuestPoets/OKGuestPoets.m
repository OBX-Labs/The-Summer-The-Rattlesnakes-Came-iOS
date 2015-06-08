//
//  OKGuestPoets.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKGuestPoets.h"
#import "OKInfoViewProperties.h"

#import "OKGuestPoetsHeader.h"
#import "OKTextManager.h"
#import "OKPoEMMProperties.h"
#import "DejalActivityView.h"
#import "OKNavigationController.h"
#import "AppDelegate.h"
#import "EAGLView.h"

static float SEPERATOR_TINT[] = {0.35f, 0.35f, 0.35f, 1.0f};
static float SELECTION_TINT[] = {0.0f, 0.0f, 1.0f, 1.0f}; // Default
// TableView
// Default
static float HEADER_HEIGHT = 140.0f;
static float ROW_HEIGHT = 34.0f;

static BOOL hasUpdatedOnce = NO;

@interface OKGuestPoets ()
- (void) buildHeadersForTableView;
- (BOOL) hasConnection;
- (void) updateTexts:(UIRefreshControl*)refresh;
- (void) updateTexts;
- (void) loadNewTextForPackage:(NSString*)aPackage;
@end

@implementation OKGuestPoets

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle icon:(UIImage *)aIcon
{
    self = [super initWithStyle:aStyle];
    if (self)
    {
        [self setTitle:aTitle];
        [self.tabBarItem setImage:aIcon];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        overlay = [[UIView alloc] init];
        [overlay setBackgroundColor:[UIColor clearColor]];
        [overlay setUserInteractionEnabled:NO];
        [self.view addSubview:overlay];
        
        NSArray *selectionTint = [[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"SelectionTint"];
        
        SELECTION_TINT[0] = [[selectionTint objectAtIndex:0] floatValue];
        SELECTION_TINT[1] = [[selectionTint objectAtIndex:1] floatValue];
        SELECTION_TINT[2] = [[selectionTint objectAtIndex:2] floatValue];
        SELECTION_TINT[3] = [[selectionTint objectAtIndex:3] floatValue];
        
        [self.tableView setSeparatorColor:[UIColor colorWithRed:SEPERATOR_TINT[0] green:SEPERATOR_TINT[1] blue:SEPERATOR_TINT[2] alpha:SEPERATOR_TINT[3]]];
    }
    return self;
}

- (void) buildHeadersForTableView
{
    // Table to contain headers to avoid a lag during scrollin
    headers = [[NSMutableArray alloc] init];
    // Array and Dictionary that contains all packages to text for authors
    authors = [[NSMutableArray alloc] init];
    packages = [[NSMutableDictionary alloc] init];
    
    for(int i = 0; i < [[OKTextManager sharedInstance] packagesCount]; i++)
    {
        // Get all packages
        NSString *package = [[OKTextManager sharedInstance] packageAtIndex:i];
        NSDictionary *textDict = [[OKTextManager sharedInstance] textDictForId:package atIndex:0];
        
        // Check if author's row has already been created
        if(![[packages allKeys] containsObject:[textDict objectForKey:@"Author"]]) // Has not yet been created
        {
            NSString *author = [OKTextManager authorForPackage:package];
            NSString *imagePath = [[OKTextManager authorPath:author] stringByAppendingPathComponent:@"test.jpg"];
            
            if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) imagePath = [[NSBundle mainBundle] pathForResource:@"placeholder" ofType:@"png"];
            
            NSDictionary *authorDict = [NSDictionary dictionaryWithObjectsAndKeys:[textDict objectForKey:@"Author"], @"AuthorName", imagePath, @"ImagePath", [textDict objectForKey:@"AuthorBio"], @"AuthorBio", [textDict objectForKey:@"AuthorWebsite"], @"AuthorWebsite", nil];
            
            OKGuestPoetsHeader *v = [[OKGuestPoetsHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, HEADER_HEIGHT) andGuestPoet:authorDict];
            [headers addObject:v];
            
            // Add array of package to author (in case he has more than one)
            NSMutableArray *tmpPackages = [[NSMutableArray alloc] initWithObjects:package, nil];
            [packages setValue:tmpPackages forKey:[textDict objectForKey:@"Author"]];
            // Add author as a key
            [authors addObject:[textDict objectForKey:@"Author"]];
        }
        else
        {
            // Author already has a section, add new row to it
            NSMutableArray *tmpPackages = [packages objectForKey:[textDict objectForKey:@"Author"]];
            [tmpPackages addObject:package];
            [packages setValue:tmpPackages forKey:[textDict objectForKey:@"Author"]];
        }
    }
    
    [self.tableView reloadData];
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (BOOL) hasConnection
{
    NSString *networkStatus = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.apple.com"] encoding:NSUTF8StringEncoding error:nil];
    
    return ( networkStatus != NULL ) ? YES : NO;
}

- (void) updateTexts:(UIRefreshControl*)refresh
{
    [refresh setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing data..."]];
            
    [self updateTexts];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    
    [refresh setAttributedTitle:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]]]];
    [refresh endRefreshing];
}

- (void) updateTexts
{    
    hasUpdatedOnce = YES;
    [self.view bringSubviewToFront:overlay];
    [DejalBezelActivityView activityViewForView:overlay withLabel:@"Downloading"];
    
    // Fetch the new list from the server
    NSString *url;
    if([[OKAppProperties objectForKey:@"Development"] boolValue]) url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"guestpoets_dev"];
    else url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"guestpoets_live"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if([data length] > 0 && error == nil)
        {
            NSString *errorDescription = nil;
            NSPropertyListFormat format;
            
            NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorDescription];
            
            NSLog(@"Guest Poets %@", plist);
            
            if(errorDescription != nil)
            {
                NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"11"]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
                [alert show];
            }
            else
            {
                #warning Incomplete implementation. Remove dict and replace dict with plist (this loads the default OKPoEMM for testing purposes)
                NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"OKPoEMMProperties.plist"]];
                [[OKTextManager sharedInstance] setTextList:dict andSave:YES];
            }
            
            // Build headers for/refresh table view
            dispatch_async(dispatch_get_main_queue(), ^{
                [self buildHeadersForTableView];
            });
        }
        else if([data length] == 0 || error != nil)
        {
            // Inform the user that a connection couldn't be obtained
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"1"]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
                [alert show];
                
                [DejalBezelActivityView removeViewAnimated:YES];
            });
        }
    }];
}

- (void) loadNewTextForPackage:(NSString*)aPackage
{
    if([[OKTextManager sharedInstance] loadTextFromPackage:aPackage atIndex:0])
    {
        // Switch the text
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [[delegate eaglView] setup];
    }
    else
    {
        // Inform the user that a loading has failed
        NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"2"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
        [alert show];
    }
    
    OKNavigationController *navController = (OKNavigationController*)self.navigationController;
    [navController dismiss];
    
    [DejalBezelActivityView removeViewAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView { return [headers count]; }

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [headers objectAtIndex:section]; }

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return HEADER_HEIGHT; }

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return ROW_HEIGHT; }

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [[packages objectForKey:[authors objectAtIndex:section]] count]; }

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Get peom for author at row
    NSString *package = [[packages objectForKey:[authors objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    NSDictionary* textDict = [[OKTextManager sharedInstance] textDictForId:package atIndex:0];
    
    // If we have a dict for author add name of poem, if not, add a placeholder title (Unknown)
    if(textDict != nil)
    {
        [[cell textLabel] setText:[[textDict objectForKey:@"Title"] lowercaseString]];
    }
    else
    {
        [[cell textLabel] setText:@"Unknown"];
    }
    
    [[cell textLabel] setFont:[UIFont fontWithName:@"Dosis-Bold" size:22.0f]];
    
    // Set SelectionStyle to match tint // Get from prefs
    UIView *tableViewCellSelectionStyleTint = [[UIView alloc] init];
    [tableViewCellSelectionStyleTint setBackgroundColor:[UIColor colorWithRed:SELECTION_TINT[0] green:SELECTION_TINT[1] blue:SELECTION_TINT[2] alpha:SELECTION_TINT[3]]];
    [cell setSelectedBackgroundView:tableViewCellSelectionStyleTint];
        
    return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get package key of displaying cell
    NSString *package = [[packages objectForKey:[authors objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    
    // This is a quick and dirty fix to update Jason's text properly with the keys
    NSString *appName = [OKAppProperties objectForKey:@"Name"];
    NSString *master = [NSString stringWithFormat:@"net.obxlabs.%@.jlewis.%@", appName, appName];
    if([[OKPoEMMProperties objectForKey:Text] isEqualToString:master])
    {
        [OKPoEMMProperties setObject:[[OKTextManager sharedInstance] packageAtIndex:0] forKey:Text];
    }
    
    // Select if active
    if([package isEqualToString:[OKPoEMMProperties objectForKey:Text]])
    {
        sRow = indexPath;
        [cell setSelected:YES animated:YES];
    }
    else
    {
        [cell setSelected:NO animated:YES];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(sRow)
    {
        UITableViewCell *sCell = [tableView cellForRowAtIndexPath:sRow];
        [sCell setSelected:NO animated:YES];
    }
        
    // Get package key of selected cell
    NSString *package = [[packages objectForKey:[authors objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    
    if(![package isEqualToString:[OKPoEMMProperties objectForKey:Text]])
    {
        [self.view bringSubviewToFront:overlay];
        
        // Make sure the overlay is centered. This is because we are uising a UITableViewController and the self.view is based on the tableView's scrollView.
        CGRect visibleRect;
        visibleRect.origin = self.tableView.contentOffset;
        visibleRect.size = self.tableView.bounds.size;
        [overlay setFrame:visibleRect];
        
        [DejalBezelActivityView activityViewForView:overlay];
        
        // If the package id is not the currently active one switch it after small delay
        [self performSelector:@selector(loadNewTextForPackage:) withObject:package afterDelay:1.0f];
    }
    else
    {
        OKNavigationController *navController = (OKNavigationController*)self.navigationController;
        [navController dismiss];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    // Match frame of overlay to view
    [overlay setFrame:self.view.frame];
    
    // Only update on launch
    if(!hasUpdatedOnce)
    {
        [DejalBezelActivityView activityViewForView:overlay];
        if([self hasConnection])
        {
            // Update the text
            [self updateTexts:nil];
        }
        else
        {
            // Load the latest list
            [self buildHeadersForTableView];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to refresh"]];
    [refresh addTarget:self action:@selector(updateTexts:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData]; // Fixes issue where row was not selected on appear
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
