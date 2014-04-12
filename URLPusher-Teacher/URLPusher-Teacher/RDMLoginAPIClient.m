//
//  RDMLoginAPIClient.m
//  URLPusher-Shared
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMLoginAPIClient.h"

@implementation RDMLoginAPIClient

+ (RDMLoginAPIClient *)sharedClient {
    static RDMLoginAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[RDMLoginAPIClient alloc] init];
    });
    
    return _sharedClient;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(NSMutableURLRequest*) signupAccountRequestWithEmail:(NSString*)emailAddress
                                          andPassword:(NSString*)password
                                       andDisplayName:(NSString*)displayName {
    
    [self clearAuthorizationHeader];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (emailAddress) {
        [params setObject:emailAddress forKey:@"emailAddress"];
    } else {
        NSLog(@"Email Required");
        return nil;
    }
    
    if (password) {
        [params setObject:password forKey:@"password"];
    } else {
        NSLog(@"Password Required");
        return nil;
    }
    
    if (displayName) {
        [params setObject:displayName forKey:@"displayName"];
    }
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"account"
                           parameters:params ];
    return request;
    
}

-(NSMutableURLRequest*) loginAccountRequestWithEmail:(NSString*)emailAddress
                                         andPassword:(NSString*)password {
    
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:emailAddress password:password];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (emailAddress) {
        [params setObject:emailAddress forKey:@"emailAddress"];
    } else {
        NSLog(@"Email Required");
        return nil;
    }
    
    if (password) {
        [params setObject:password forKey:@"password"];
    } else {
        NSLog(@"Password Required");
        return nil;
    }
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"auth/token"
                           parameters:params ];
    return request;

}

-(NSMutableURLRequest*) requestPasswordResetRequestWithEmail:(NSString*)emailAddress {
    
    [self clearAuthorizationHeader];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (emailAddress) {
        [params setObject:emailAddress forKey:@"emailAddress"];
    } else {
        NSLog(@"Email Required");
        return nil;
    }
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"auth/forgot"
                           parameters:params ];
    return request;
}

-(NSMutableURLRequest*) confirmPasswordResetRequestWithResetCode:(NSString*)resetCode andNewPassword:(NSString*)newPassword {
    
    [self clearAuthorizationHeader];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (resetCode) {
        [params setObject:resetCode forKey:@"resetPasswordToken"];
    } else {
        NSLog(@"Email Required");
        return nil;
    }
    
    if (newPassword) {
        [params setObject:newPassword forKey:@"newPassword"];
    } else {
        NSLog(@"Email Required");
        return nil;
    }
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"auth/reset"
                           parameters:params ];
    return request;
    
}

-(NSMutableURLRequest*) changePasswordRequestWithEmailAddress:(NSString*)emailAddress
                                               andOldPassword:(NSString*)oldPassword
                                               andNewPassword:(NSString*)newPassword
                                             andLogoutDevices:(BOOL)logoutDevices {
    
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:emailAddress password:oldPassword];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (emailAddress) {
        [params setObject:emailAddress forKey:@"emailAddress"];
    } else {
        NSLog(@"Email Address Required");
        return nil;
    }
    
    if (oldPassword) {
        [params setObject:oldPassword forKey:@"oldPassword"];
    } else {
        NSLog(@"Old Password Required");
        return nil;
    }
    
    if (newPassword) {
        [params setObject:newPassword forKey:@"newPassword"];
    } else {
        NSLog(@"Old Password Required");
        return nil;
    }
    
    [params setObject:[NSNumber numberWithBool:logoutDevices] forKey:@"logoutDevices"];
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"auth/changePassword"
                           parameters:params ];
    return request;
}

@end
