//
//  RDMTokenAuthAPIClient.h
//  URLPusher-Shared
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMBaseAPIClient.h"

@interface RDMTokenAuthAPIClient : RDMBaseAPIClient

+ (RDMTokenAuthAPIClient *)sharedClient;

-(NSMutableURLRequest*) changeDisplayNameRequestForUserWithToken:(NSString*)token
                                              withNewDisplayName:(NSString*)displayName;

-(NSMutableURLRequest*) updateRequestForUserWithToken:(NSString*)token
                              withParameters:(NSDictionary*)incomingParameters;

-(NSMutableURLRequest*) sendLinkRequestForUserWithToken:(NSString*)token
                                         withParameters:(NSDictionary*)incomingParameters;

-(NSMutableURLRequest*) sendVerifyReceiptRequestForUserWithToken:(NSString*)token
                                                 withReceiptData:(NSData*)receiptData;
-(NSMutableURLRequest*) sendLogoutRequestForUserWithToken:(NSString*)token
                                          withDeviceToken:(NSString*)deviceToken;
-(NSMutableURLRequest*) sendRegistrationCodeChangeRequest:(NSString*)token;

-(NSMutableURLRequest*) sendGroupRegistrationCodeChangeRequestWithToken:(NSString*)token
                                                       forGroupWithGUID:(NSString *)groupGUID;

@end
