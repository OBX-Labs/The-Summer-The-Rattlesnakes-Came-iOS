//
//  OKShareScrollView.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-03.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKShareScrollView.h"
#import "OKInfoViewProperties.h"

#import "OKShareItem.h"

static float PADDING = 0.0f;
static float IPAD_PADDING = 10.0f;
static float IPHONE_PADDING = 5.0f;
static float DEFAULT_COLOR[] = {1.0, 1.0, 1.0, 1.0};
static float SELECTED_COLOR[] = {1.0, 1.0, 1.0, 1.0};

@implementation OKShareScrollView

- (id) initWithFrame:(CGRect)frame andPageSize:(CGSize)size
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        NSArray *selectionTint = [[OKInfoViewProperties objectForKey:@"Style"] objectForKey:@"SelectionTint"];
        
        SELECTED_COLOR[0] = [[selectionTint objectAtIndex:0] floatValue];
        SELECTED_COLOR[1] = [[selectionTint objectAtIndex:1] floatValue];
        SELECTED_COLOR[2] = [[selectionTint objectAtIndex:2] floatValue];
        SELECTED_COLOR[3] = [[selectionTint objectAtIndex:3] floatValue];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            PADDING = IPAD_PADDING;
        }
        else
        {
            PADDING = IPHONE_PADDING;
        }
        
        pageSize = size;
        pages = [[NSMutableArray alloc] init];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((self.frame.size.width - pageSize.width) / 2.0f, (self.frame.size.height - pageSize.height) / 2.0f, pageSize.width, pageSize.height)];
        [scrollView setClipsToBounds:NO];
        [scrollView setPagingEnabled:YES];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setDelegate:self];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:scrollView];
    }
    return self;
}

- (void) setPages:(NSArray*)aPages forScrollingDirection:(ContentScrollDirection)aContentScrollDirection
{
    contentScrollDirection = aContentScrollDirection;
    
    if([pages count] > 0)
        [pages removeAllObjects];
    
    int p = 0;
    for(NSString *page in aPages)
    {
        CGRect frame;
        if(contentScrollDirection == ContentScrollDirectionHorizontal) frame = CGRectMake((pageSize.width * p) + PADDING, PADDING, pageSize.width - (PADDING * 2.0f), pageSize.height - (PADDING * 2.0f));
        else if(contentScrollDirection == ContentScrollDirectionVertical) frame = CGRectMake(PADDING, (pageSize.height * p) + PADDING, pageSize.width - (PADDING * 2.0f), pageSize.height - (PADDING * 2.0f));
        
        OKShareItem *item = [[OKShareItem alloc] initWithFrame:frame andImage:[UIImage imageNamed:page]];
        
        // Set selected
        if(contentScrollDirection == ContentScrollDirectionHorizontal)
        {
            if(p == 0) [item setBackgroundColor:[UIColor colorWithRed:SELECTED_COLOR[0] green:SELECTED_COLOR[1] blue:SELECTED_COLOR[2] alpha:SELECTED_COLOR[3]]];
            else [item setBackgroundColor:[UIColor colorWithRed:DEFAULT_COLOR[0] green:DEFAULT_COLOR[1] blue:DEFAULT_COLOR[2] alpha:DEFAULT_COLOR[3]]];
        }
        else if(contentScrollDirection == ContentScrollDirectionVertical)
        {
            if(p == 0) [item setBackgroundColor:[UIColor colorWithRed:SELECTED_COLOR[0] green:SELECTED_COLOR[1] blue:SELECTED_COLOR[2] alpha:SELECTED_COLOR[3]]];
            else [item setBackgroundColor:[UIColor colorWithRed:DEFAULT_COLOR[0] green:DEFAULT_COLOR[1] blue:DEFAULT_COLOR[2] alpha:DEFAULT_COLOR[3]]];
        }
        
        [scrollView addSubview:item];
        [pages addObject:item];
        p++;
    }
    
    if(contentScrollDirection == ContentScrollDirectionHorizontal) [scrollView setContentSize:CGSizeMake((scrollView.frame.size.width * [pages count]), scrollView.frame.size.height)];
    else if(contentScrollDirection == ContentScrollDirectionVertical) [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, (scrollView.frame.size.height * [pages count]))];
}

- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(!CGRectContainsPoint(scrollView.frame, point))
    {
		return scrollView;
	}

	return [super hitTest:point	withEvent:event];
}

- (int) currentPage
{
    CGSize pSize = scrollView.frame.size;
    int page = 0;
    
    if(contentScrollDirection == ContentScrollDirectionHorizontal) page = floor((scrollView.contentOffset.x - pSize.width / 2) / pSize.width) + 1;
    else if(contentScrollDirection == ContentScrollDirectionVertical) page = floor((scrollView.contentOffset.y - pSize.height / 2) / pSize.height) + 1;
    
    return page;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Get Page
    int page = [self currentPage];
    
    OKShareItem *item = [pages objectAtIndex:page];
    
    [UIView beginAnimations:@"deselect" context:nil];    
    [UIView setAnimationDuration:[[[OKInfoViewProperties objectForKey:@"Animations"] objectForKey:@"share_selection_duration"] floatValue]];
    
    [item setBackgroundColor:[UIColor colorWithRed:DEFAULT_COLOR[0] green:DEFAULT_COLOR[1] blue:DEFAULT_COLOR[2] alpha:DEFAULT_COLOR[3]]];
    
    [UIView commitAnimations];

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Get Page
    int page = [self currentPage];
    
    OKShareItem *item = [pages objectAtIndex:page];
    
    [UIView beginAnimations:@"select" context:nil];
    [UIView setAnimationDuration:[[[OKInfoViewProperties objectForKey:@"Animations"] objectForKey:@"share_selection_duration"] floatValue]];
    
    [item setBackgroundColor:[UIColor colorWithRed:SELECTED_COLOR[0] green:SELECTED_COLOR[1] blue:SELECTED_COLOR[2] alpha:SELECTED_COLOR[3]]];
    
    [UIView commitAnimations];
}

@end






















