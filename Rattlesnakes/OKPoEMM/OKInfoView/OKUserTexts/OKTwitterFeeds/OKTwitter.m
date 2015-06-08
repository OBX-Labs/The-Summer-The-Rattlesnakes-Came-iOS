//
//  OKTwitter.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-18.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKTwitter.h"
#import "OKAppProperties.h"

static OKTwitter *sharedInstance;

static NSString *VALID_CHAR_SET = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890\"!`?'.,;:()[]{}<>|/@\\^$-%—+=#_&~*¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ ";

@interface OKTwitter ()
- (void) formatSearch:(NSDictionary*)aResponse;
- (void) formatTimeline:(NSArray*)aResponse;
- (void) formatResponse:(NSArray*)aResponse;
- (NSString*) removeUnsupportedCharacters:(NSString*)string;
@end

@implementation OKTwitter
@synthesize delegate, capitalizationType;

+ (OKTwitter*) sharedInstance
{
    @synchronized(self)
	{
		if (sharedInstance == nil)
			sharedInstance = [[OKTwitter alloc] init];
	}
	return sharedInstance;
}

- (void) search:(NSString*)aQuery maxResults:(int)aMaxResults language:(NSString*)aLanguage
{    
    // URL
    NSURL *url = [NSURL URLWithString:@"http://search.twitter.com/search.json"];
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:aQuery forKey:@"q"];
    [parameters setObject:[NSString stringWithFormat:@"%i", aMaxResults] forKey:@"count"];
    [parameters setObject:aLanguage forKey:@"lang"];
    
    // Request
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:parameters];
    
    // Perform
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {         
         if(responseData == nil)
         {
             NSLog(@"Error: Twitter request error (%@)", [error localizedDescription]);
         }
         else
         {
             NSError *JSONError = nil;
             // Search returns a dictionary
             NSDictionary *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&JSONError];
             
             if(timeline == nil)
             {
                 NSLog(@"Error: JSON response error (%@)", [JSONError localizedDescription]);
             }
             else
             {
                 [self formatSearch:timeline];
             }
         }
     }];
}

- (void) timeline:(NSString*)aUser maxResults:(int)aMaxResults
{    
    // URL
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/user_timeline.json"];
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:aUser forKey:@"screen_name"];
    [parameters setObject:[NSString stringWithFormat:@"%i", aMaxResults] forKey:@"count"];
    
    // Request
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:parameters];
    
    // Perform
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if(responseData == nil)
         {
             NSLog(@"Error: Twitter request error (%@)", [error localizedDescription]);
         }
         else
         {
             NSError *JSONError = nil;
             // Timeline returns an array
             NSArray *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&JSONError];
             
             if(timeline == nil)
             {
                 NSLog(@"Error: JSON response error (%@)", [JSONError localizedDescription]);
             }
             else
             {
                 [self formatTimeline:timeline];
             }
         }
     }];
}

- (void) formatSearch:(NSDictionary*)aResponse { [self formatResponse:[aResponse objectForKey:@"results"]]; }

- (void) formatTimeline:(NSArray*)aResponse { [self formatResponse:aResponse]; }

- (void) formatResponse:(NSArray*)aResponse
{
    // Mutable string to store the response as a usable text file
    NSMutableString *feed = [[NSMutableString alloc] init];
    
    // If small than 2, there's an error
    if([aResponse count] >= 2)
    {
        // Go through response data
        for(NSDictionary *data in aResponse)
        {
            // Get the Tweet
            NSString *tweet = [data objectForKey:@"text"];
            
            // Remove http urls
            NSRange httpRange = [tweet rangeOfString:@"http://"];
            if(httpRange.location != NSNotFound)
            {
                int end = [tweet length];
                NSRange spaceRange = [tweet rangeOfString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(httpRange.location, [tweet length] - httpRange.location)];
                
                if(spaceRange.location != NSNotFound)
                {
                    end = spaceRange.location + 1;
                }
                
                // Update tweet
                tweet = [tweet stringByReplacingCharactersInRange:NSMakeRange(httpRange.location, end - httpRange.location) withString:@""];
            }
            
            // Remove https urls
            NSRange httpsRange = [tweet rangeOfString:@"https://"];
            if(httpsRange.location != NSNotFound)
            {
                int end = [tweet length];
                NSRange spaceRange = [tweet rangeOfString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(httpsRange.location, [tweet length] - httpsRange.location)];
                
                if(spaceRange.location != NSNotFound)
                {
                    end = spaceRange.location + 1;
                }
                
                // Update tweet
                tweet = [tweet stringByReplacingCharactersInRange:NSMakeRange(httpsRange.location, end - httpsRange.location) withString:@""];
            }
            
            // Format Capitalization based on type
            if(capitalizationType == OKTextCapitalizationTypeNone)
            {
                // Set all chars to lowercase
                tweet = [tweet lowercaseString];
            }
            else if(capitalizationType == OKTextCapitalizationTypeWords)
            {
                NSArray *sentence = [tweet componentsSeparatedByString:@" "];
                NSString *nTweet;
                for(NSString *word in sentence)
                {
                    // Capitalize each first letter
                    [nTweet stringByAppendingString:[NSString stringWithFormat:@"%C%@", [[word uppercaseString] characterAtIndex:0], [[word substringFromIndex:1] lowercaseString]]];
                    
                    // Add space if not last word
                    if(word != [sentence lastObject]) [nTweet stringByAppendingString:@" "];
                }
                // Set tweet to new format
                tweet = nTweet;
            }
            else if(capitalizationType == OKTextCapitalizationTypeSentences)
            {
                // Capitalize first letter of first word of sentence
                tweet = [NSString stringWithFormat:@"%C%@", [[tweet uppercaseString] characterAtIndex:0], [[tweet substringFromIndex:1] lowercaseString]];
            }
            else if(capitalizationType == OKTextCapitalizationTypeAllCharacters)
            {
                // Set all chars to uppercase
                tweet = [tweet uppercaseString];
            }
            
            // Remove white space if any
            tweet = [tweet stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            // Remove return lines if any
            tweet = [tweet stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // Remove unsupported characters
            tweet = [self removeUnsupportedCharacters:tweet];
            
            // Check to see if we still have a valid line
            if([tweet length] == 0) continue;
            
            // Convert string to ASCII equivalent
            NSData *convertedTweet = [tweet dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:NO];
            
            if(convertedTweet != nil)
            {
                // Add formatted tweet to feed
                [feed appendString:[[NSString alloc] initWithData:convertedTweet encoding:NSISOLatin1StringEncoding]];
                
                // If tweet (data) is not the last object, add return line
                if(data != [aResponse lastObject])
                {
                    [feed appendString:@"\r\n"];
                }
            }
        }
        
        // Return the feed to the delegate
        [delegate twitterFeed:feed];
    }
    else
    {
        // Return nil which will be notify of error
        [delegate twitterFeed:nil];
    }
}

- (NSString*) removeUnsupportedCharacters:(NSString*)string
{
    // Get valid characters (this should according to font for app)
    NSMutableCharacterSet *validCharSet = [NSMutableCharacterSet characterSetWithCharactersInString:VALID_CHAR_SET];
    [validCharSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
    
    // Filter the incoming text and check for non-valid characters
    NSString *filteredText = [[string componentsSeparatedByCharactersInSet:[validCharSet invertedSet]] componentsJoinedByString:@""];
    
    return filteredText;
}

@end
