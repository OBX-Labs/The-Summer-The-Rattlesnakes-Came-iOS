//
//  OKPublisher.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKPublisher.h"

#import "OKRegistration.h"
#import "OKNewAccount.h"
#import "OKSignIn.h"

@interface OKPublisher ()
- (void) buildRowsForTableView;
- (void) useExistingAccount;
- (void) createNewAccount;
@end

@implementation OKPublisher

- (id) initWithTitle:(NSString*)aTitle style:(UITableViewStyle)aStyle forType:(OKAccountType)aType
{
    self = [super initWithStyle:aStyle];
    if (self)
    {
        [self setTitle:aTitle];
        
        // Set trusted hosts
        [[OKRegistration sharedInstance] setTrustedHost:[NSArray arrayWithObjects:@"www.poemm.net", nil]];
        
        // Account Type
        accountType = aType;
        
        // Build rows for view
        [self buildRowsForTableView];
    }
    return self;
}

- (void) setDisplayViewController:(OKInfoView*)aDisplay { display = aDisplay; }

- (void) buildRowsForTableView
{
    sections = [[NSMutableArray alloc] init];
    
    //Account rows
    NSMutableArray *account_rows = [[NSMutableArray alloc] init];
    
    //Sign In
    NSDictionary *signIn_row = [[NSDictionary alloc] initWithObjectsAndKeys:@"Register using an existing account", @"rowText", [NSValue valueWithPointer:@selector(useExistingAccount)], @"rowAction", nil];
    [account_rows addObject:signIn_row];
    
    //Register row
    NSDictionary *register_row = [[NSDictionary alloc] initWithObjectsAndKeys:@"Register using a new account", @"rowText", [NSValue valueWithPointer:@selector(createNewAccount)], @"rowAction", nil];
    [account_rows addObject:register_row];
    
    //Add section
    NSDictionary *account = [[NSDictionary alloc] initWithObjectsAndKeys:account_rows, @"sectionRows", @"", @"sectionFooter", @"", @"sectionHeader", nil];
    [sections addObject:account];
    
    [self.tableView reloadData];
}

- (void) useExistingAccount
{
    // Use existing account
    OKSignIn *si = [[OKSignIn alloc] initWithTitle:@"Title" style:UITableViewStyleGrouped forType:accountType];
    [si setDisplayViewController:display];
    [self.navigationController pushViewController:si animated:YES];
}

- (void) createNewAccount
{
    // Create new account
    OKNewAccount *na = [[OKNewAccount alloc] initWithTitle:@"Title" style:UITableViewStyleGrouped forType:accountType];
    [na setDisplayViewController:display];
    [self.navigationController pushViewController:na animated:YES];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView { return [sections count]; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return  [[[sections objectAtIndex:section] objectForKey:@"sectionRows"] count]; }

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //Display row
    NSArray *rows = [[sections objectAtIndex:[indexPath section]] objectForKey:@"sectionRows"];
    NSDictionary *row = [rows objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[row objectForKey:@"rowText"]];
    [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
    
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section { return [[sections objectAtIndex:section] objectForKey:@"sectionFooter"]; }

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { return [[sections objectAtIndex:section] objectForKey:@"sectionHeader"]; }

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *rows = [[sections objectAtIndex:[indexPath section]] objectForKey:@"sectionRows"];
    SEL action = [[[rows objectAtIndex:[indexPath row]] objectForKey:@"rowAction"] pointerValue];
    
    //Perform the selector for given row
    [self performSelector:action];
    
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
