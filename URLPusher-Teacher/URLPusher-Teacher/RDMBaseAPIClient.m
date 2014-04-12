//
//  RDMRDMAPIClient.m
//  URLPusher-Shared
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMBaseAPIClient.h"

#import "RDMConfiguration.h"

static NSString * const kAPIBaseURLString = RDM_API_BASE_URL;

@implementation RDMBaseAPIClient

-(instancetype) init {
    NSLog(@"URL: %@", kAPIBaseURLString);
    self = [super initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    if (self) {
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"API-Version" value:@"1.0"];
    }
    return self;
}

@end
