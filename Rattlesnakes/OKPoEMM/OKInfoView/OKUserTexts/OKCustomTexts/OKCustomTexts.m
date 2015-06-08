//
//  OKCustomTexts.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKCustomTexts.h"
#import "OKInfoViewProperties.h"
#import "OKPoEMMProperties.h"

#import "OKTextManager.h"
#import "OKTextComposer.h"

static float TEXTFIELD_PADDING = 10.0f;
static float SELECTION_TINT[] = {0.0f, 0.0f, 1.0f, 1.0f}; // Default
static CGRect DEFAULT_FRAME;


@interface OKCustomTexts ()
- (void) keyboardWillShow:(NSNotification*)aNotification;
- (void) keyboardWillHide:(NSNotification*)aNotification;
- (void) formatModalViewForKeyboard:(NSNotification*)aNotification willShow:(BOOL)willShow;
@end

@implementation OKCustomTexts

- (id) initWithStyle:(UITableViewStyle)aStyle title:(NSString *)aTitle
{
    self = [super initWithStyle:aStyle];
    if (self)
    {
        [self setTitle:aTitle];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        NSArray *selectionTint = [[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"SelectionTint"];
        
        SELECTION_TINT[0] = [[selectionTint objectAtIndex:0] floatValue];
        SELECTION_TINT[1] = [[selectionTint objectAtIndex:1] floatValue];
        SELECTION_TINT[2] = [[selectionTint objectAtIndex:2] floatValue];
        SELECTION_TINT[3] = [[selectionTint objectAtIndex:3] floatValue];
        
        // Load rows from file
        rows = [[NSMutableArray alloc] initWithArray:[[OKTextManager sharedInstance] loadTexts]];
        [self.tableView reloadData];
    }
    return self;
}

#pragma mark - UITextField

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(![textField.text isEqualToString:@""])
    {
        if(![rows containsObject:textField.text])
        {
            [rows addObject:textField.text];
            [self.tableView reloadData];
            
            OKTextComposer *composer = [[OKTextComposer alloc] initWithTitle:textField.text];
            [self.navigationController pushViewController:composer animated:YES];
        }
        else
        {            
            NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"0"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];            
            [alert show];
            
            // Show him the field
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[rows indexOfObject:textField.text] inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            [textField setText:@""];
        }
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void) keyboardWillShow:(NSNotification *)aNotification
{
    if(self.navigationController.visibleViewController != self) return;
    
    [self formatModalViewForKeyboard:aNotification willShow:YES];
}

- (void) keyboardWillHide:(NSNotification*)aNotification
{
    if (!keyboardIsShown || self.navigationController.visibleViewController != self) return;
    
    [self formatModalViewForKeyboard:aNotification willShow:NO];
}

- (void) formatModalViewForKeyboard:(NSNotification*)aNotification willShow:(BOOL)willShow
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval aDuration;
    UIViewAnimationCurve aCurve;
    CGRect kEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&aDuration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&aCurve];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kEndFrame];
    
    CGRect nFrame = self.tableView.frame;
    CGRect kFrame = [self.view convertRect:kEndFrame toView:nil];
    
    if(willShow)
    {
        // Set Default frame
        DEFAULT_FRAME = nFrame;
        
        // Calculate difference between keyboard and bottom of UITableView
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // Due to FormSheet modal view different calculations need to be taken into account
        {
            nFrame.size.height = (screen.size.width - kFrame.size.height - self.navigationController.navigationBar.frame.size.height); // screen.size.width is used here as values are inverted
        }
        else
        {
            nFrame.size.height -= (kFrame.size.height - self.tabBarController.tabBar.frame.size.height); // The tab bar needs to be taken into account to resize the table view
        }
    }
    else
    {
        nFrame = DEFAULT_FRAME;
    }
    
    [UIView beginAnimations:@"KeyboardResize" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:aDuration];
    [UIView setAnimationCurve:aCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.tableView setFrame:nFrame];
    
    [UIView commitAnimations];
    
    if(!willShow)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([rows count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    keyboardIsShown = willShow;
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [rows count] + 1; }

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if([indexPath row] == [rows count])
    {
        // Removes any text that can be inserted in the textLabel due to reuseIdentifier
        [[cell textLabel] setText:nil];
        
        // Removes any UITextField from content view if it exists already (reuseIdentifier)
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        // Add UITextField for adding new list
        UITextField *txt = [[UITextField alloc] initWithFrame:CGRectMake(TEXTFIELD_PADDING, 0.0, self.tableView.frame.size.width - (TEXTFIELD_PADDING * 2.0f), cell.frame.size.height)];
        [txt setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [txt setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [txt setAutocorrectionType:UITextAutocorrectionTypeNo];
        [txt setFont:[UIFont fontWithName:@"Dosis-Bold" size:16.0f]];
        [txt setBackgroundColor:[UIColor clearColor]];
        [txt setBorderStyle:UITextBorderStyleNone];
        [txt setReturnKeyType:UIReturnKeyNext];
        [txt setPlaceholder:[[OKInfoViewProperties objectForKey:@"Texts"] objectForKey:@"custom"]];
        [txt setDelegate:self];
        
        [[cell contentView] addSubview:txt];
    }
    else
    {
        // Removes UITextField from content view to avoid repeating cells (reuseIdentifier)
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        // Set name of list as an option
        [[cell textLabel] setFont:[UIFont fontWithName:@"Dosis-Bold" size:16.0f]];
        [[cell textLabel] setText:[rows objectAtIndex:[indexPath row]]];
        
        // Set selection background view for custom color instead of selection style
        UIView *customSelectionStyle = [[UIView alloc] init];
        [customSelectionStyle setBackgroundColor:[UIColor colorWithRed:SELECTION_TINT[0] green:SELECTION_TINT[1] blue:SELECTION_TINT[2] alpha:SELECTION_TINT[3]]];
        [cell setSelectedBackgroundView:customSelectionStyle];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Hide keyboard if shown
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[rows count] inSection:0]];
    
    for (UIView *view in cell.contentView.subviews)
    {
        if([view isKindOfClass:[UITextField class]])
            [view resignFirstResponder];
    }
    
    if([indexPath row] != [rows count])
    {
        NSString *textName = [rows objectAtIndex:[indexPath row]];
        NSString *text = [[OKTextManager sharedInstance] loadTextFile:textName forType:@"txt"];
        
        OKTextComposer *composer = [[OKTextComposer alloc] initWithTitle:textName andText:text];
        [self.navigationController pushViewController:composer animated:YES];
    }
    
    // Deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Select if active
    if([indexPath row] != [rows count])
    {
        if([[rows objectAtIndex:[indexPath row]] isEqualToString:[OKPoEMMProperties objectForKey:Title]])
        {
            [cell setSelected:YES animated:YES];
        }
        else
        {
            [cell setSelected:NO animated:YES];
        }
        
    }
}

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath { return ([indexPath row] == [rows count] ? NO : YES); }

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { return NO; }

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath { return ([indexPath row] == [rows count] ? NO : YES); }

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Get feed to be deleted
        NSString *dText = [rows objectAtIndex:[indexPath row]];
        
        // Delete feed
        [[OKTextManager sharedInstance] deleteTextFile:dText forType:@"txt"];
        
        // Remove from table view
        [rows removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    keyboardIsShown = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Remove ActivityView
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Push current view
    if(self.navigationController.visibleViewController == self)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
