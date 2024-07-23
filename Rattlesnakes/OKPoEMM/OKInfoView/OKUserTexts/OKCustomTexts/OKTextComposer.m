//
//  OKTextComposer.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKTextComposer.h"
#import "OKAppProperties.h"
#import "OKInfoViewProperties.h"

#import "OKTextManager.h"
#import "DejalActivityView.h"
#import "OKNavigationController.h"
#import <OBXKit/AppDelegate.h>
#import "EAGLView.h"

static float UITEXTVIEW_EDGEINSET = 16.0f; // Hard coded value, Apple does not provide this answer but it works for iOS 4.0+ and iPhone and iPad
static NSString *VALID_CHAR_SET = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890\"!`?'.,;:()[]{}<>|/@\\^$-%—+=#_&~*¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ ";
static CGRect DEFAULT_FRAME;
static int MAX_LINES;
static int MAX_CHARS_PER_LINE;

@interface OKTextComposer ()
- (void) saveText;
- (void) prepareToPublish;
- (void) publish;
- (void) keyboardWillShow:(NSNotification*)aNotification;
- (void) keyboardWillHide:(NSNotification*)aNotification;
- (void) formatModalViewForKeyboard:(NSNotification*)aNotification willShow:(BOOL)willShow;
- (NSInteger) currentLineForUITextView:(UITextView*)textView;
- (NSString*) formatText:(NSString*)text forUITextView:(UITextView*)textView startingAtLine:(NSInteger)line;
- (BOOL) textContainsValidCharacters:(NSString*)text;
- (void) toggleCounters;
- (void) updateCounters;
- (void) repositionCounters;
@end

@implementation OKTextComposer

- (id) initWithTitle:(NSString*)aTitle
{
    self = [super init];
    if (self)
    {
        [self setTitle:aTitle];
        
        MAX_LINES = [[[OKAppProperties objectForKey:@"DeviceSpecific"] objectForKey:@"max_lines"] intValue];
        MAX_CHARS_PER_LINE = [[[OKAppProperties objectForKey:@"DeviceSpecific"] objectForKey:@"max_char_per_line"] intValue];
        
        // Composer
        composer = [[UITextView alloc] init];
        [composer setAutocorrectionType:UITextAutocorrectionTypeNo];
        [composer setFont:[UIFont systemFontOfSize:12.0]];
        [composer setTextColor:[UIColor blackColor]];
        [composer setDelegate:self];
                
        [self.view addSubview:composer];
        
        // Line counter
        lineCounters = [[UIScrollView alloc] init];
        [lineCounters setBackgroundColor:[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f]];
        [lineCounters setScrollEnabled:NO];
        
        [self.view insertSubview:lineCounters belowSubview:composer];
        
        lineCountersAr = [[NSMutableArray alloc] init];
        
        // Character per line counter
        characterCounters = [[UIScrollView alloc] init];
        [characterCounters setBackgroundColor:[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.0f]];
        [characterCounters setScrollEnabled:NO];
        
        [self.view insertSubview:characterCounters belowSubview:composer];
        
        characterCountersAr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithTitle:(NSString*)aTitle andText:(NSString*)aText
{
    self = [self initWithTitle:aTitle];
    if (self)
    {
        [self setTitle:aTitle];
        [composer setText:aText];
    }
    return self;
}

- (void) saveText
{
    // Save text
    [[OKTextManager sharedInstance] createFolder:@"CustomTexts"];
    [[OKTextManager sharedInstance] saveTextFile:self.title forType:@"txt" withContent:composer.text];
}

- (void) prepareToPublish
{
    [composer resignFirstResponder];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    [self performSelector:@selector(publish) withObject:nil afterDelay:0.25];
}

- (void) publish
{
    // Save text
    [self saveText];
    
    // Create package
    if([[OKTextManager sharedInstance] saveCustomText:composer.text forTitle:self.title])
    {
        // Switch the text        
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [[delegate eaglView] setup];
    }
    else
    {
        NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"8"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
        [alert show];
    }
    
    // dismiss
    OKNavigationController *navController = (OKNavigationController*)self.navigationController;
    [navController dismiss];
    
    [DejalBezelActivityView removeViewAnimated:YES];
}

#pragma mark Keyboard

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
    
    CGRect nFrame = composer.frame;
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
        
        nFrame.origin.x = lineCounters.frame.size.width;
        nFrame.size.width -= (lineCounters.frame.size.width + characterCounters.frame.size.width);
        countersVisible = YES;
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
    
    [composer setFrame:nFrame];
    
    // Update line counter frame and content size (to scroll with UITextView)
    [lineCounters setFrame:CGRectMake(lineCounters.frame.origin.x, lineCounters.frame.origin.y, lineCounters.frame.size.width, nFrame.size.height)];
    
    // Update character per line counter frame
    [characterCounters setFrame:CGRectMake(characterCounters.frame.origin.x, characterCounters.frame.origin.y, characterCounters.frame.size.width, nFrame.size.height)];
    
    [UIView commitAnimations];
        
    keyboardIsShown = willShow;
}

- (NSInteger) currentLineForUITextView:(UITextView*)textView
{
    NSRange cursor = [textView selectedRange];
    NSString *stringBeforeCursor = [textView.text substringToIndex:cursor.location];
    NSArray *cursorSplit = [stringBeforeCursor componentsSeparatedByString:@"\n"];
    
    return [cursorSplit indexOfObject:[cursorSplit lastObject]];
}

- (NSString*) formatText:(NSString*)text forUITextView:(UITextView*)textView startingAtLine:(NSInteger)line
{
    NSArray *lines = [textView.text componentsSeparatedByString:@"\n"];
    int maxLines = MAX_LINES - ([lines count] - 1);
    
    NSMutableString *formatedText = [[NSMutableString alloc] init];
        
    int charIndex = 0; // Index of character in incoming text
    for(int i = 0; i < maxLines; i++)
    {
        int length = (i == 0 ? [[lines objectAtIndex:line] length] : 0); // length of line (this will give us a split based on where the user is pasting)
        for(int j = length; j < MAX_CHARS_PER_LINE; j++)
        {
            // Add character to line
            [formatedText appendString:[NSString stringWithFormat:@"%C", [text characterAtIndex:charIndex]]];
            
            // Check if we have more characters to add
            if(charIndex < ([text length] - 1)) charIndex++;
            else break;
        }
        // Check if we have more characters to add        
        if(charIndex < ([text length] - 1) && i < (maxLines - 1)) [formatedText appendString:@"\n"];
        else break;
    }
            
    return formatedText;
}

- (BOOL) textContainsValidCharacters:(NSString*)text
{
    // Get valid characters (this should according to font for app)
    NSMutableCharacterSet *validCharSet = [NSMutableCharacterSet characterSetWithCharactersInString:VALID_CHAR_SET];
    [validCharSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
    
    // Filter the incoming text and check for non-valid characters
    NSString *filteredText = [[text componentsSeparatedByCharactersInSet:[validCharSet invertedSet]] componentsJoinedByString:@""];
    BOOL valid = [text isEqualToString:filteredText];
    
    return valid;
}

#pragma mark Counters

- (void) toggleCounters
{    
    CGRect nFrame = composer.frame;
    
    // Hide counters
    if(composer.frame.origin.x > 0)
    {
        nFrame.origin.x -= lineCounters.frame.size.width;
        nFrame.size.width += (lineCounters.frame.size.width + characterCounters.frame.size.width);
        countersVisible = NO;
    }
    else // Show counters
    {
        nFrame.origin.x = lineCounters.frame.size.width;
        nFrame.size.width -= (lineCounters.frame.size.width + characterCounters.frame.size.width);
        countersVisible = YES;
    }
    
    [UIView beginAnimations:@"ToggleCounters" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:[[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Animations"] objectForKey:@"text_composer_toggle_duration"] floatValue]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [composer setFrame:nFrame];
    
    [UIView commitAnimations];
    
    // Update counter position
    [self updateCounters];
}

- (void) updateCounters
{
    // Count the amount of lines and ignore word wrapping
    NSArray *lines = [composer.text componentsSeparatedByString:@"\n"];
    int realLineCount = [lines count];
    
    // Update current positions (in case wrapping is removed)
    if(realLineCount == [lineCountersAr count])
    {
        [self repositionCounters];
    }
    else if(realLineCount > [lineCountersAr count]) // An item has been added
    {
        // Padding for wrapping
        float lPadding = 0.0f;
        for(int i = 0; i < realLineCount; i++)
        {
            // Checks and position based on wrapping
            if(i > 0)
            {
                float prewLineHeight = [[lines objectAtIndex:(i-1)] sizeWithFont:composer.font constrainedToSize:CGSizeMake(composer.contentSize.width - UITEXTVIEW_EDGEINSET, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
                
                if(prewLineHeight > composer.font.lineHeight)
                {
                    lPadding += (prewLineHeight - composer.font.lineHeight);
                }
            }
            
            if(i >= [lineCountersAr count])
            {
                // Line Counter
                UILabel *lCounter = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (composer.font.lineHeight * i) + lPadding, lineCounters.frame.size.width, composer.font.lineHeight)];
                [lCounter setFont:composer.font];
                [lCounter setBackgroundColor:[UIColor clearColor]];
                [lCounter setText:[NSString stringWithFormat:@"%i/%i", (i + 1), MAX_LINES]];
                [lCounter setTextColor:[UIColor lightGrayColor]];
                
                [lineCountersAr addObject:lCounter];
                [lineCounters addSubview:lCounter];
                
                // Char per line Counter
                float lineHeight = [[lines objectAtIndex:i] sizeWithFont:composer.font constrainedToSize:CGSizeMake(composer.contentSize.width - UITEXTVIEW_EDGEINSET, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
                float cPadding;
                if(lineHeight > composer.font.lineHeight) cPadding = lPadding + composer.font.lineHeight;
                else cPadding = lPadding;
                                
                int charCount = [[lines objectAtIndex:i] length];
                UILabel *cCounter = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (composer.font.lineHeight * i) + lPadding, characterCounters.frame.size.width, composer.font.lineHeight)];
                [cCounter setTextAlignment:NSTextAlignmentRight];
                [cCounter setFont:composer.font];
                [cCounter setBackgroundColor:[UIColor clearColor]];
                [cCounter setText:[NSString stringWithFormat:@"%i/%i", charCount, MAX_CHARS_PER_LINE]];
                [cCounter setTextColor:[UIColor lightGrayColor]];
                
                [characterCountersAr addObject:cCounter];
                [characterCounters addSubview:cCounter];
            }
        }
        
        [self repositionCounters];
    }
    else
    {        
        for(int i = ([lineCountersAr count] - 1); i >= realLineCount; i--)
        {
            // Line counter
            UILabel *lCounter = [lineCountersAr objectAtIndex:i];
            [lCounter removeFromSuperview];
            [lineCountersAr removeObjectAtIndex:i];
            
            // Char counter
            UILabel *cCounter = [characterCountersAr objectAtIndex:i];
            [cCounter removeFromSuperview];
            [characterCountersAr removeObjectAtIndex:i];
        }
        
        // Reposition
        [self repositionCounters];
    }
    
    // Update UIScrollViews content (to scroll with UITextView)
    [characterCounters setContentSize:CGSizeMake(characterCounters.contentSize.width, composer.contentSize.height)];
    [lineCounters setContentSize:CGSizeMake(lineCounters.contentSize.width, composer.contentSize.height)];
}

- (void) repositionCounters
{
    // Count the amount of lines and ignore word wrapping
    NSArray *lines = [composer.text componentsSeparatedByString:@"\n"];
    int realLineCount = [lines count];
    
    // Padding for wrapping
    float lPadding = 0.0;
    //float cPadding = 0.0f;
    for(int i = 0; i < realLineCount; i++)
    {
        // Checks and position based on wrapping
        if(i > 0)
        {
            float prewLineHeight = [[lines objectAtIndex:(i-1)] sizeWithFont:composer.font constrainedToSize:CGSizeMake(composer.contentSize.width - UITEXTVIEW_EDGEINSET, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
            
            if(prewLineHeight > composer.font.lineHeight)
            {
                lPadding += (prewLineHeight - composer.font.lineHeight);
            }
        }
        
        // Line Counter
        UILabel *lCounter = [lineCountersAr objectAtIndex:i];
        CGRect nFrameL = CGRectMake(0.0f, (composer.font.lineHeight * i) + lPadding, lineCounters.frame.size.width, composer.font.lineHeight);
        
        if(!CGRectEqualToRect(lCounter.frame, nFrameL))
        {
            [lCounter setFrame:nFrameL];
        }
        
        // Char per line Counter
        float lineHeight = [[lines objectAtIndex:i] sizeWithFont:composer.font constrainedToSize:CGSizeMake(composer.contentSize.width - UITEXTVIEW_EDGEINSET, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
        float cPadding;
        if(lineHeight > composer.font.lineHeight) cPadding = lPadding + composer.font.lineHeight;
        else cPadding = lPadding;
        
        UILabel *cCounter = [characterCountersAr objectAtIndex:i];
        CGRect nFrameC = CGRectMake(0.0f, (composer.font.lineHeight * i) + cPadding, characterCounters.frame.size.width, composer.font.lineHeight);
        
        if(!CGRectEqualToRect(cCounter.frame, nFrameC))
        {
            [cCounter setFrame:nFrameC];
        }
        
        int charCount = [[lines objectAtIndex:i] length];
        [cCounter setText:[NSString stringWithFormat:@"%i/%i", charCount, MAX_CHARS_PER_LINE]];
    }
}

#pragma mark UITextView

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{    
    // Ignore auto creation of dot space ('. ')
    if([text isEqualToString:@". "]) return NO;
    
    NSArray *lines = [composer.text componentsSeparatedByString:@"\n"];
    int currentLine = [self currentLineForUITextView:textView];
    NSString *line = [lines objectAtIndex:currentLine];
    
    // We can still add some text to this line
    if([line length] < MAX_CHARS_PER_LINE)
    {
        // Check length of incoming text
        // Legnth > 1 assume its either a copy paste of a text of a quick spacebar that formats for '. '
        if([text length] > 1)
        {
            // Reformat
            NSString *formatedText = [self formatText:text forUITextView:textView startingAtLine:currentLine];
            
            int maxLength = (MAX_LINES * MAX_CHARS_PER_LINE) - [composer.text length];
            if([text length] > maxLength)
            {
                NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"3"]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
                [alert show];
            }
            
            if([self textContainsValidCharacters:formatedText]) [textView insertText:formatedText];
            else
            {
                NSDictionary *error = [[NSDictionary alloc] initWithDictionary:[[[OKInfoViewProperties objectForKey:@"Errors"] objectForKey:@"OKInfoView"] objectForKey:@"4"]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"value"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:([[error objectForKey:@"action"] boolValue] ? @"Contact us" : nil), nil];
                [alert show];
            }
            
            [self updateCounters];
            
            if([textView.text length] > 0) [publish setEnabled:YES];
            else [publish setEnabled:NO];
            
            return NO;
        }
        else
        {
            // Make sure the character is not return line if we have reached the maximum lines
            if([text isEqualToString:@"\n"] && [lines count] == MAX_LINES)
            {
                [textView resignFirstResponder];
                return NO;
            }
        }
    }
    else // We can't add text to this line
    {
        // Check if it's backspace (remove character on that line)
        if([text length] == 0) return YES;
        
        // Check if we can create a new line
        if([lines count] < MAX_LINES)
        {
            // Create a new line
            [textView insertText:@"\n"];
        }
        else // We can't create a new line
        {
            [textView resignFirstResponder];
            return NO;
        }
    }
    
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{    
    // NSTimer to make counters invisible if innactive for amount of time
    if([counterToggle isValid])
    {
        [counterToggle invalidate];
    }
    
    counterToggle = [NSTimer scheduledTimerWithTimeInterval:[[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Animations"] objectForKey:@"text_composer_auto_hide_delay"] floatValue] target:self selector:@selector(toggleCounters) userInfo:nil repeats:NO];
}

- (void) textViewDidChange:(UITextView *)textView
{
    if([textView.text length] > 0) [publish setEnabled:YES];
    else [publish setEnabled:NO];
    
    [self updateCounters];
    
    // Make counter visible if not
    if(!countersVisible)
    {
        [self toggleCounters];
    }
    
    // NSTimer to make counters invisible if innactive for amount of time
    if([counterToggle isValid])
    {
        [counterToggle invalidate];
    }
    
    counterToggle = [NSTimer scheduledTimerWithTimeInterval:[[[[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"Animations"] objectForKey:@"text_composer_auto_hide_delay"] floatValue] target:self selector:@selector(toggleCounters) userInfo:nil repeats:NO];
}

#pragma mark UIScrollView (UITextView)

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == composer)
    {
        [lineCounters setContentOffset:composer.contentOffset animated:NO];
        [characterCounters setContentOffset:composer.contentOffset animated:NO];
    }
}

#pragma mark View

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    publish = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStyleBordered target:self action:@selector(prepareToPublish)];
    [self.navigationItem setRightBarButtonItem:publish animated:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Reformat UITextView to appear in modal view
    [composer setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    
    // publish
    if([composer.text length] == 0) [publish setEnabled:NO];
    
    // Reformat UIScrollViews to appear in modal view
    float lineCountersWidth = [[NSString stringWithFormat:@"%i/%i", MAX_LINES, MAX_LINES] sizeWithFont:composer.font].width;
    [lineCounters setFrame:CGRectMake(0.0f, 0.0f, lineCountersWidth, composer.frame.size.height)];
    
    float characterCountersWidth = [[NSString stringWithFormat:@"%i/%i", MAX_CHARS_PER_LINE, MAX_CHARS_PER_LINE] sizeWithFont:composer.font].width;
    [characterCounters setFrame:CGRectMake(composer.frame.size.width - characterCountersWidth, 0.0f, characterCountersWidth, composer.frame.size.height)];
    
    [self updateCounters];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    keyboardIsShown = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [composer resignFirstResponder];
    
    // Save Text
    [self saveText];
    
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
        // Save Text
        [self saveText];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
