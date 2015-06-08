//
//  OKTwitterProtocol.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OKTwitterProtocol <NSObject>

@required
- (void) twitterFeed:(NSString*)aFeed;

@end
