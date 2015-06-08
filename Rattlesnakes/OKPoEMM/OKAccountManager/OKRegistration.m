//
//  OKRegistration.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-13.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKRegistration.h"
#import "OKAppProperties.h"
#import "OKInfoViewProperties.h"

static OKRegistration *instance;

//Timeout
static float REQUEST_TIMEOUT = 15.0f;

@implementation OKRegistration

+ (OKRegistration*) sharedInstance
{
    @synchronized([OKRegistration class])
    {
        if(instance == nil)
            instance = [[OKRegistration alloc] init];
    }
    
    return instance;
}

- (void) setTrustedHost:(NSArray *)aTrustedHosts { trustedHosts = [[NSArray alloc] initWithArray:aTrustedHosts]; }

#pragma mark - Register User

- (void) registerUser:(NSDictionary *)aDict forType:(OKAccountType)aType
{
    if(aType == OKAccountTypeLimitedEdition)
    {
        NSString *url;
        if([[OKAppProperties objectForKey:@"Development"] boolValue]) url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"le_register_dev"];
        else url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"le_register_live"];
                
        [self sendRequestToURL:[NSURL URLWithString:url] withData:[[NSString stringWithFormat:@"first_name=%@&last_name=%@&username=%@&password=%@&subscribe=%i", [aDict objectForKey:@"fName"], [aDict objectForKey:@"lName"], [aDict objectForKey:@"email"], [aDict objectForKey:@"password"], [[aDict objectForKey:@"subscribe"] intValue]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        
    }
}

#pragma mark - Sign In

- (void) signIn:(NSDictionary *)aDict forType:(OKAccountType)aType
{
    if(aType == OKAccountTypeLimitedEdition)
    {
        NSString *url;
        if([[OKAppProperties objectForKey:@"Development"] boolValue]) url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"le_signin_dev"];
        else url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"le_signin_live"];
            
        [self sendRequestToURL:[NSURL URLWithString:url] withData:[[NSString stringWithFormat:@"uname=%@&pwd=%@", [aDict objectForKey:@"username"], [aDict objectForKey:@"password"]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        
    }
}

#pragma mark - Request Password

- (void) requestPassword:(NSDictionary *)aDict forType:(OKAccountType)aType
{
    if(aType == OKAccountTypeLimitedEdition)
    {
        NSString *url;
        if([[OKAppProperties objectForKey:@"Development"] boolValue]) url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"le_request_password_dev"];
        else url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"le_request_password_live"];
        
        [self sendRequestToURL:[NSURL URLWithString:url] withData:[[NSString stringWithFormat:@"email=%@", [aDict objectForKey:@"email"]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        
    }
}

#pragma mark - Reset Password

- (void) resetPassword:(NSDictionary *)aDict forType:(OKAccountType)aType
{
    if(aType == OKAccountTypeLimitedEdition)
    {
        NSString *url;
        if([[OKAppProperties objectForKey:@"Development"] boolValue]) url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"le_reset_password_dev"];
        else url = [[OKAppProperties objectForKey:@"Links"] objectForKey:@"le_reset_password_live"];
        
        [self sendRequestToURL:[NSURL URLWithString:url] withData:[[NSString stringWithFormat:@"email=%@&tPassword=%@&nPassword=%@", [aDict objectForKey:@"email"], [aDict objectForKey:@"tPassword"], [aDict objectForKey:@"nPassword"]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        
    }
}

#pragma mark - Register version

- (void) registerVersion:(NSString *)aVersion
{
    //Save the version
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if(![prefs stringForKey:@"version"])
    {
        [prefs setObject:aVersion forKey:@"version"];
        [prefs synchronize];
    }
}

#pragma mark - Request

- (void) sendRequestToURL:(NSURL *)aURL withData:(NSData *)aData
{    
    //Check internet connection    
    if(![self checkNetworkStatus])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HandleNotificationReceived" object:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"STATE", @"0", @"VALUE", nil]];
    
    //Build request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:aData];
    [request setTimeoutInterval:REQUEST_TIMEOUT];
    
    if(connection)
    {
        [connection cancel];
    }
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    didCancel = NO;
    
    //Start connection
    [connection start];
}

- (void) cancel { didCancel = YES; }

#pragma mark - NSURLConnection Delegate

- (void) connection:(NSURLConnection*)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    if(didCancel)
        [connection cancel];
    
    //every response could mean a redirect
    receivedData = nil;
}

- (void) connection:(NSURLConnection*)aConnection didReceiveData:(NSData*)aData
{
    if(didCancel)
        [connection cancel];
    
    //Add received data
	if (!receivedData)
		receivedData = [[NSMutableData alloc] initWithData:aData];
	else
		[receivedData appendData:aData];
}

- (void) connectionDidFinishLoading:(NSURLConnection*)aConnection
{
    //Once connection is finished, post notification with content
    NSString *sError = nil;
    NSPropertyListFormat format;
    
    NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:receivedData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&sError];
    
    if(!didCancel)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HandleNotificationReceived" object:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[dict objectForKey:@"STATE"] intValue]], @"STATE", [dict objectForKey:@"VALUE"], @"VALUE", nil]];
}

- (void) connection:(NSURLConnection *)aConnection didFailWithError:(NSError*)aError
{
    //Connection fail, post notifiacation with error
    if(!didCancel)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HandleNotificationReceived" object:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"STATE", @"17", @"VALUE", nil]];
}

//SSL Authentification
- (BOOL) connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if([trustedHosts containsObject:challenge.protectionSpace.host])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        else
            [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

#pragma mark - Connectivity

- (BOOL) checkNetworkStatus
{
    NSString *networkStatus = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.apple.com"] encoding:NSUTF8StringEncoding error:nil];
    
    return ( networkStatus != NULL ) ? YES : NO;
}

@end
