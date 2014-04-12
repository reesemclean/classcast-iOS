//
//  RDMTokenAuthAPIClient.m
//  URLPusher-Shared
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTokenAuthAPIClient.h"

#import "NSData+NSString_Conversion.h"

@implementation RDMTokenAuthAPIClient

+ (RDMTokenAuthAPIClient *)sharedClient {
    static RDMTokenAuthAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[RDMTokenAuthAPIClient alloc] init];
    });
    
    return _sharedClient;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
}

-(NSMutableURLRequest*) updateRequestForUserWithToken:(NSString*)token
                                       withParameters:(NSDictionary*)incomingParameters {
    
    if (!token) {
        return nil;
    }
    
    [self setAuthorizationHeaderWithToken:token];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:incomingParameters];
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"account/sync"
                           parameters:parameters ];
    return request;

}

-(NSMutableURLRequest*) sendLinkRequestForUserWithToken:(NSString*)token
                                         withParameters:(NSDictionary*)incomingParameters {
    
    if (!token) {
        return nil;
    }
    
    [self setAuthorizationHeaderWithToken:token];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:incomingParameters];
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"account/sendLink"
                           parameters:parameters ];
    return request;

                                 
}

-(NSMutableURLRequest*) changeDisplayNameRequestForUserWithToken:(NSString*)token
                                              withNewDisplayName:(NSString*)displayName {
    
    if (!token) {
        return nil;
    }
    
    [self setAuthorizationHeaderWithToken:token];
    
    NSDictionary *parameters = @{ @"displayName" : displayName };
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"account/changeDisplayName"
                           parameters:parameters ];
    return request;
    
}

-(NSMutableURLRequest*) sendVerifyReceiptRequestForUserWithToken:(NSString*)token
                                                 withReceiptData:(NSData*)receiptData {
    
    if (!token) {
        return nil;
    }
    
    [self setAuthorizationHeaderWithToken:token];

    NSDictionary *parameters = @{ @"receipt" : [receiptData hexadecimalString] };
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"account/verify_iap"
                           parameters:parameters ];
    return request;
    
}

-(NSMutableURLRequest*) sendLogoutRequestForUserWithToken:(NSString*)token
                                          withDeviceToken:(NSString*)deviceToken {
    
    [self setAuthorizationHeaderWithToken:token];
    
    NSDictionary *parameters = @{ @"usersDeviceToken" : deviceToken };
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"account/deviceDidLogout"
                           parameters:parameters ];
    return request;
    
}

-(NSMutableURLRequest*) sendRegistrationCodeChangeRequest:(NSString*)token {
    
    if (!token) {
        return nil;
    }
    
    [self setAuthorizationHeaderWithToken:token];
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"account/requestNewRegistrationToken"
                           parameters:@{} ];
    return request;
}

-(NSMutableURLRequest*) sendGroupRegistrationCodeChangeRequestWithToken:(NSString*)token
                                                       forGroupWithGUID:(NSString *)groupGUID {
    
    if (!token) {
        return nil;
    }
    
    if (!groupGUID) {
        return nil;
    }
    
    [self setAuthorizationHeaderWithToken:token];
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"account/requestNewGroupRegistrationToken"
                           parameters:@{ @"groupGUID": groupGUID } ];
    return request;

}

@end
