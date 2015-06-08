//
//  OKShareScrollView.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-03.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OKShareItem;

typedef enum
{
    ContentScrollDirectionVertical,
    ContentScrollDirectionHorizontal,
} ContentScrollDirection;

@interface OKShareScrollView : UIView <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    NSMutableArray *pages;
    CGSize pageSize;
    
    ContentScrollDirection contentScrollDirection;
    
    CGPoint lastContentOffset;
}

- (id) initWithFrame:(CGRect)frame andPageSize:(CGSize)size;
- (void) setPages:(NSArray*)aPages forScrollingDirection:(ContentScrollDirection)aContentScrollDirection;
- (int) currentPage;

@end
