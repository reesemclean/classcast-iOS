//
//  RDMUser+Custom.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/6/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMUser.h"

@interface RDMUser (Custom)

-(void)setServerToken:(NSString*)token;
-(NSString*)serverToken;

-(NSString*) subscriptionTimeLeftString;
-(BOOL) hasValidSubscription;
-(NSString*)usersDeviceToken;
@end
