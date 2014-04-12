//
//  RDMAPIClient.m
//  URLPusher-Student
//
//  Created by Reese McLean on 7/30/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMAPIClient.h"

#import <AFNetworking.H>

#import "RDMConfiguration.h"

static NSString * const kAPIBaseURLString = RDM_API_BASE_URL;

@implementation RDMAPIClient

+ (instancetype)sharedClient {
    static RDMAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[RDMAPIClient alloc] init];
    });
    
    return _sharedClient;
}

-(instancetype) init {
    self = [super initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    if (self) {
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"API-Version" value:@"1.0"];
    }
    return self;
}

-(NSMutableURLRequest*)syncRequestWithParameters:(NSDictionary*)parameters {
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"device/sync"
                           parameters:parameters ];
    return request;
    
}

-(NSMutableURLRequest*)sendRegistrationCodeRequestWithRegistrationCode:(NSString*)registrationCode
                                                         andDeviceName:(NSString*)deviceName
                                                        andDeviceToken:(NSString*)deviceToken
                                                               andGUID:(NSString*)guid {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (registrationCode) {
        [params setObject:registrationCode forKey:@"registrationCode"];
    }
    
    if (deviceName) {
        [params setObject:deviceName forKey:@"deviceName"];
    } else {
        [params setObject:[[UIDevice currentDevice] name] forKey:@"deviceName"];
    }
    
    if (deviceToken) {
        [params setObject:deviceToken forKey:@"deviceToken"];
    }
    
    if (guid) {
        [params setObject:guid forKey:@"guid"];
    }
    
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST"
                                 path:@"device/registerToUser"
                           parameters:params ];
    return request;
}

@end
