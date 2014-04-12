//
//  RDMAPIClient.h
//  URLPusher-Student
//
//  Created by Reese McLean on 7/30/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "AFHTTPClient.h"

@interface RDMAPIClient : AFHTTPClient

+(instancetype) sharedClient;

-(NSMutableURLRequest*)syncRequestWithParameters:(NSDictionary*)parameters;

-(NSMutableURLRequest*)sendRegistrationCodeRequestWithRegistrationCode:(NSString*)registrationCode
                                                         andDeviceName:(NSString*)deviceName
                                                        andDeviceToken:(NSString*)deviceToken
                                                               andGUID:(NSString*)guid;

@end
