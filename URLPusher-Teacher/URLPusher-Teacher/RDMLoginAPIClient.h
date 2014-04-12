//
//  RDMLoginAPIClient.h
//  URLPusher-Shared
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMBaseAPIClient.h"

@interface RDMLoginAPIClient : RDMBaseAPIClient

+(instancetype) sharedClient;

-(NSMutableURLRequest*) changePasswordRequestWithEmailAddress:(NSString*)emailAddress
                                               andOldPassword:(NSString*)oldPassword
                                               andNewPassword:(NSString*)newPassword
                                             andLogoutDevices:(BOOL)logoutDevices;

-(NSMutableURLRequest*) confirmPasswordResetRequestWithResetCode:(NSString*)resetCode andNewPassword:(NSString*)newPassword;

-(NSMutableURLRequest*) requestPasswordResetRequestWithEmail:(NSString*)emailAddress;

-(NSMutableURLRequest*) signupAccountRequestWithEmail:(NSString*)emailAddress
                                          andPassword:(NSString*)password
                                       andDisplayName:(NSString*)displayName;
-(NSMutableURLRequest*) loginAccountRequestWithEmail:(NSString*)emailAddress
                                         andPassword:(NSString*)password;

@end
