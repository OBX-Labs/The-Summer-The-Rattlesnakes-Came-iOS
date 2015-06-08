//
//  OKTwitter.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-18.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "OKTwitterProtocol.h"

typedef enum
{
    OKTextCapitalizationTypeNone,
    OKTextCapitalizationTypeWords,
    OKTextCapitalizationTypeSentences,
    OKTextCapitalizationTypeAllCharacters,
} OKTextCapitalizationType;

@interface OKTwitter : NSObject

@property (nonatomic, setter = setDelegate:) id<OKTwitterProtocol> delegate;
@property (nonatomic, setter = setTextCapitalizationType:) OKTextCapitalizationType capitalizationType;

+ (OKTwitter*) sharedInstance;

- (void) search:(NSString*)aQuery maxResults:(int)aMaxResults language:(NSString*)aLanguage;
- (void) timeline:(NSString*)aUser maxResults:(int)aMaxResults;

@end
