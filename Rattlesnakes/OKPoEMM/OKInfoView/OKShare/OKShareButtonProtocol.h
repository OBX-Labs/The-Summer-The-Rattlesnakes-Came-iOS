//
//  OKShareButtonProtocol.h
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-03-03.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    OKShareButtonTypeFacebook,
    OKShareButtonTypeTwitter,
    OKShareButtonTypeMail,
} OKShareButtonType;

@protocol OKShareButtonProtocol <NSObject>

@required
- (void) shareWithType:(OKShareButtonType)type;

@end
