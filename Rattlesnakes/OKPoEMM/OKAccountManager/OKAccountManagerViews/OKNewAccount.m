//
//  OKNewAccount.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKNewAccount.h"
#import "OKInfoViewProperties.h"

#import "OKInfoView.h"
#import "OKRegistration.h"
#import "DejalActivityView.h"

static CGRect DEFAULT_FRAME;

@interface OKNewAccount ()
- (void) buildRowsForTableView;
- (void) registerAccount;
- (void) performRegistration;
- (void) notificationReceived:(NSNotification*)aNotification;
- (void) validateEmailFields:(NSArray*)aFields;
- (void) validatePasswordFields:(NSArray*)aFields;
- (UITextField*) getFirstResponder;
- (void) keyboardWillShow:(NSNotification *)aNotification;
- (void) keyboardWillHide:(NSNotification*)aNotification;
- (void) formatModalViewForKeyboard:(NSNotification*)aNotification willShow:(BOOL)willShow;
- (void) scrollToActiveTextField;
@end

@implementation OKNewAccount

- (id) initWithTitle:(NSString*)aTitle style:(UITableViewStyle)aStyle forType:(OKAccountType)aType
{
    self = [super initWithStyle:aStyle];
    if (self)
    {
        [self setTitle:aTitle];
        
        // Turn off selection
        [self.tableView setAllowsSelection:NO];
        
        // Account Type
        accountType = aType;
        
        // Validation errors
        validationErrors = [[NSMutableArray alloc] init];
                
        // Build rows for view
        [self buildRowsForTableView];
        
        // Add Register button
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Register" style:UIBarButtonItemStyleDone target:self action:@selector(registerAccount)]];
    }
    return self;
}

- (void) setDisplayViewController:(OKInfoView*)aDisplay { display = aDisplay; }

- (void) buildRowsForTableView
{
    sections = [[NSMutableArray alloc] init];
    
    ///////////////////////
    //     NAMES ROWS    //
    ///////////////////////
    NSMutableArray *names_rows = [[NSMutableArray alloc] init];
    
    // First Name Field
    UITextField *fName = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 21.0)]; // Hard coded values
    [fName setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [fName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [fName setAutocorrectionType:UITextAutocorrectionTypeNo];
    [fName setKeyboardType:UIKeyboardTypeDefault];
    [fName setTextAlignment:NSTextAlignmentRight];
    [fName setBorderStyle:UITextBorderStyleNone];
    [fName setReturnKeyType:UIReturnKeyNext];
    [fName setPlaceholder:@"First Name"];
    [fName setDelegate:self];
    [fName setTag:1];
    
    //Create First Name Row
    NSDictionary *fName_row = [[NSDictionary alloc] initWithObjectsAndKeys:@"First Name", @"rowText", fName, @"rowAccessoryView", nil];
    [names_rows addObject:fName_row];
    
    // Last Name Field
    UITextField *lName = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 21.0)]; // Hard coded values
    [lName setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [lName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [lName setAutocorrectionType:UITextAutocorrectionTypeNo];
    [lName setKeyboardType:UIKeyboardTypeDefault];
    [lName setTextAlignment:NSTextAlignmentRight];
    [lName setBorderStyle:UITextBorderStyleNone];
    [lName setReturnKeyType:UIReturnKeyNext];
    [lName setPlaceholder:@"Last Name"];
    [lName setDelegate:self];
    [lName setTag:2];
    
    //Create Last Name Row
    NSDictionary *lName_row = [[NSDictionary alloc] initWithObjectsAndKeys:@"Last Name", @"rowText", lName, @"rowAccessoryView", nil];
    [names_rows addObject:lName_row];
    
    //Add section
    NSDictionary *names = [[NSDictionary alloc] initWithObjectsAndKeys:names_rows, @"sectionRows", @"", @"sectionFooter", @"", @"sectionHeader", [NSNull null], @"validationAction", [NSNull null], @"validationFields", nil];
    [sections addObject:names];
    
    //////////////////////
    //     EMAIL ROW    //
    //////////////////////
    NSMutableArray *email_rows = [[NSMutableArray alloc] init];
    
    // Email Field
    UITextField *email = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 21.0)]; // Hard coded values
    [email setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [email setClearButtonMode:UITextFieldViewModeWhileEditing];
    [email setAutocorrectionType:UITextAutocorrectionTypeNo];
    [email setKeyboardType:UIKeyboardTypeEmailAddress];
    [email setTextAlignment:NSTextAlignmentRight];
    [email setBorderStyle:UITextBorderStyleNone];
    [email setReturnKeyType:UIReturnKeyNext];
    [email setPlaceholder:@"Email"];
    [email setDelegate:self];
    [email setTag:3];
    
    //Create Email Row
    NSDictionary *email_row = [[NSDictionary alloc] initWithObjectsAndKeys:@"Email", @"rowText", email, @"rowAccessoryView", nil];
    [email_rows addObject:email_row];
    
    //Add section
    NSDictionary *emails = [[NSDictionary alloc] initWithObjectsAndKeys:email_rows, @"sectionRows", @"", @"sectionFooter", @"", @"sectionHeader",  [NSValue valueWithPointer:@selector(validateEmailFields:)], @"validationAction", [NSArray arrayWithObjects:email, nil], @"validationFields", nil];
    [sections addObject:emails];
    
    //////////////////////////
    //     PASSWORD ROWS    //
    //////////////////////////
    NSMutableArray *passwords_rows = [[NSMutableArray alloc] init];
    
    // Password Field
    UITextField *password = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 21.0)]; // Hard coded values
    [password setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [password setClearButtonMode:UITextFieldViewModeWhileEditing];
    [password setAutocorrectionType:UITextAutocorrectionTypeNo];
    [password setKeyboardType:UIKeyboardTypeDefault];
    [password setTextAlignment:NSTextAlignmentRight];
    [password setBorderStyle:UITextBorderStyleNone];
    [password setReturnKeyType:UIReturnKeyNext];
    [password setPlaceholder:@"Password"];
    [password setSecureTextEntry:YES];
    [password setDelegate:self];
    [password setTag:4];
    
    //Create Password Row
    NSDictionary *password_row = [[NSDictionary alloc] initWithObjectsAndKeys:@"Password", @"rowText", password, @"rowAccessoryView", nil];
    [passwords_rows addObject:password_row];
    
    // Password Field
    UITextField *verify = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 21.0)]; // Hard coded values
    [verify setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [verify setClearButtonMode:UITextFieldViewModeWhileEditing];
    [verify setAutocorrectionType:UITextAutocorrectionTypeNo];
    [verify setKeyboardType:UIKeyboardTypeDefault];
    [verify setTextAlignment:NSTextAlignmentRight];
    [verify setBorderStyle:UITextBorderStyleNone];
    [verify setReturnKeyType:UIReturnKeyDone];
    [verify setPlaceholder:@"Retype your password"];
    [verify setSecureTextEntry:YES];
    [verify setDelegate:self];
    
    //Create Verify Row
    NSDictionary *verify_row = [[NSDictionary alloc] initWithObjectsAndKeys:@"Verify", @"rowText", verify, @"rowAccessoryView", nil];
    [passwords_rows addObject:verify_row];
    
    //Add section
    NSDictionary *passwords = [[NSDictionary alloc] initWithObjectsAndKeys:passwords_rows, @"sectionRows", @"", @"sectionFooter", @"", @"sectionHeader", [NSValue valueWithPointer:@selector(validatePasswordFields:)], @"validationAction", [NSArray arrayWithObjects:password, verify, nil], @"validationFields", nil];
    [sections addObject:passwords];
    
    // Manage first responders
    firstResponders = [[NSMutableArray alloc] init];
    
    for(NSDictionary *section in sections)
    {
        for(NSDictionary *row in [section objectForKey:@"sectionRows"])
        {
            if([row objectForKey:@"rowAccessoryView"] != [NSNull null])
                [firstResponders addObject:[row objectForKey:@"rowAccessoryView"]];
        }
    }
    
    [self.tableView reloadData];
}

- (void) registerAccount
{
    // Hide Keyboard if shown
    [[self getFirstResponder] resignFirstResponder];
    
    // Go through all rows and check if validation is needed, validate if so
    for(NSDictionary *section in sections)
    {
        if([section objectForKey:@"validationAction"] != [NSNull null])
        {
            SEL selector = [[section objectForKey:@"validationAction"] pointerValue];
            NSArray *objects = [section objectForKey:@"validationFields"];
            
            [self performSelector:selector withObject:objects];
        }
    }
    
    // If no errors
    if([validationErrors count] == 0)
    {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        // Show ActivityView
        [DejalBezelActivityView activityViewForView:self.view];
        // Manage account registration in 1 second so that the activity view is shown before we process
        [self performSelector:@selector(performRegistration) withObject:nil afterDelay:1.0];
    }
    else // Errors were found so show warnings
    {        
        NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"Registration"] objectForKey:@"16"]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) performRegistration
{
    //Go through all rows, grab the info, create a dictionary
    NSMutableDictionary *credentials = [[NSMutableDictionary alloc] init];
    
    for(NSDictionary *section in sections)
    {
        for(NSDictionary *row in [section objectForKey:@"sectionRows"])
        {
            if([row objectForKey:@"rowAccessoryView"] != [NSNull null])
            {
                UIView *rowAccessoryView = [row objectForKey:@"rowAccessoryView"];
                
                switch (rowAccessoryView.tag)
                {
                    case 1: //First name
                    {
                        UITextField *t = [row objectForKey:@"rowAccessoryView"];
                        [credentials setObject:(t.text == nil ? @"" : t.text) forKey:@"fName"];
                        break;
                    }
                        
                    case 2: //Last name
                    {
                        UITextField *t = [row objectForKey:@"rowAccessoryView"];
                        [credentials setObject:(t.text == nil ? @"" : t.text) forKey:@"lName"];
                        break;
                    }
                        
                    case 3: //Email
                    {
                        UITextField *t = [row objectForKey:@"rowAccessoryView"];
                        [credentials setObject:(t.text == nil ? @"" : t.text) forKey:@"email"];
                        break;
                    }
                        
                    case 4: //Password
                    {
                        UITextField *t = [row objectForKey:@"rowAccessoryView"];
                        [credentials setObject:(t.text == nil ? @"" : t.text) forKey:@"password"];
                        break;
                    }
                        
                    default:
                        break;
                }
            }
        }
    }
    
    [[OKRegistration sharedInstance] registerUser:credentials forType:accountType];
}

- (void) notificationReceived:(NSNotification*)aNotification
{
    // When data is received notification is posted, post the appropriate message
    NSDictionary *rData = [aNotification object];
    
    if([[rData objectForKey:@"STATE"] isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"Registration"] objectForKey:[rData objectForKey:@"VALUE"]]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
        
        if([[rData objectForKey:@"VALUE"] isEqualToString:@"7"]) //Email exists already, send to sign in
            [alert setTag:98];
        else
            [alert setTag:99];
        
        [alert show];
    }
    else if([[rData objectForKey:@"STATE"] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        if(accountType == OKAccountTypeLimitedEdition)
        {
            [[OKRegistration sharedInstance] registerVersion:[rData objectForKey:@"VALUE"]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Version" message:[NSString stringWithFormat:@"Your version number is %@.", [rData objectForKey:@"VALUE"]] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        [display dismiss];
    }
    
    [DejalBezelActivityView removeViewAnimated:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void) validateEmailFields:(NSArray*)aFields
{
    for(UITextField *tf in aFields)
    {
        //Remove if existing
        if([validationErrors containsObject:tf])
            [validationErrors removeObject:tf];
        
        //Check if any text was entered
        if([tf.text length] == 0)
            [validationErrors addObject:tf];
        
        //Remove spaces
        tf.text = [tf.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        //Check if valid email
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        if(![emailTest evaluateWithObject:tf.text])
            [validationErrors addObject:tf];
    }
    
    [self.tableView reloadData];
}

- (void) validatePasswordFields:(NSArray*)aFields
{
    for(UITextField *tf in aFields)
    {
        //Remove if existing
        if([validationErrors containsObject:tf])
            [validationErrors removeObject:tf];
        
        //Check if any text was entered
        if([tf.text length] == 0)
            [validationErrors addObject:tf];
    }
    
    //Compare passwords
    if([aFields count] == 2)
    {
        UITextField *password = [aFields objectAtIndex:0];
        UITextField *verify = [aFields objectAtIndex:1];
        
        if(![password.text isEqualToString:verify.text])
        {
            [validationErrors addObject:password];
            [validationErrors addObject:verify];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - UIAlertView

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Default error message
    if(alertView.tag == 99)
    {
        //Contact Us
        if(buttonIndex == 1)
        {
            NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
            
            [properties setObject:[NSArray arrayWithObjects:@"dev@poemm.net", nil] forKey:@"Recipients"];
            [properties setObject:@"Bastard Limited Edition - Error Message" forKey:@"Subject"];
            [properties setObject:[NSString stringWithFormat:@"I received the following error message: \n\n%@", alertView.message] forKey:@"Body"];
            
            [display presentMFMailComposeViewControllerAnimatied:YES withProperties:properties];
        }
    }
    else if(alertView.tag == 98) //Email is already registered
    {
        if(buttonIndex == 0)
            [self.navigationController popViewControllerAnimated:YES];
        else if(buttonIndex == 1)
        {
            NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
            
            [properties setObject:[NSArray arrayWithObjects:@"dev@poemm.net", nil] forKey:@"Recipients"];
            [properties setObject:@"Bastard Limited Edition - Error Message" forKey:@"Subject"];
            [properties setObject:[NSString stringWithFormat:@"I received the following error message: \n\n%@", alertView.message] forKey:@"Body"];
            
            [display presentMFMailComposeViewControllerAnimatied:YES withProperties:properties];
        }
    }
}

#pragma mark - UITextField

- (UITextField*) getFirstResponder
{    
    for(NSDictionary *section in sections)
    {
        for(NSDictionary *row in [section objectForKey:@"sectionRows"])
        {
            if([row objectForKey:@"rowAccessoryView"] != [NSNull null])
            {
                UITextField *responder = [row objectForKey:@"rowAccessoryView"];
                
                if([responder isFirstResponder])
                    return responder;
            }
        }
    }
    
    return nil;
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
    
    if(willShow)
        [UIView setAnimationDidStopSelector:@selector(scrollToActiveTextField)];
    
    [self.tableView setFrame:nFrame];
    
    [UIView commitAnimations];
    
    
    keyboardIsShown = willShow;
}

- (void) scrollToActiveTextField { [self.tableView scrollToRowAtIndexPath:sRow atScrollPosition:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UITableViewScrollPositionMiddle : UITableViewScrollPositionTop) animated:YES]; }

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell*)[textField superview];
    
    if(keyboardIsShown)
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    else
        sRow = [self.tableView indexPathForCell:cell];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    int i = [firstResponders indexOfObject:textField];
    
    if(i < ([firstResponders count] - 1))
        [[firstResponders objectAtIndex:(i + 1)] becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView { return [sections count]; }

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section { return  [[[sections objectAtIndex:section] objectForKey:@"sectionRows"] count]; }

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *rows = [[sections objectAtIndex:[indexPath section]] objectForKey:@"sectionRows"];
    NSDictionary *row = [rows objectAtIndex:[indexPath row]];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    [[cell textLabel] setText:[row objectForKey:@"rowText"]];
    [[cell textLabel] setTextAlignment:NSTextAlignmentLeft];
    [cell setAccessoryView:[row objectForKey:@"rowAccessoryView"]];
    
    if([validationErrors containsObject:[row objectForKey:@"rowAccessoryView"]])
        [[cell textLabel] setTextColor:[UIColor redColor]];
    else
        [[cell textLabel] setTextColor:[UIColor blackColor]];
    
    return cell;
}

#pragma mark - Table view delegate

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { return [[sections objectAtIndex:section] objectForKey:@"sectionHeader"]; }

- (NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section { return [[sections objectAtIndex:section] objectForKey:@"sectionFooter"]; }

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
    
    // register for HandleDataReceived notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"HandleNotificationReceived" object:nil];
    
    keyboardIsShown = NO;    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Cancel connection
    [[OKRegistration sharedInstance] cancel];
    
    // Remove ActivityView
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    // unregister for HandleDataReceived notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HandleNotificationReceived" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
