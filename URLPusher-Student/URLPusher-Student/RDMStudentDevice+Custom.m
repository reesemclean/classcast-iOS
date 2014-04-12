//
//  RDMStudentDevice+Custom.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMStudentDevice+Custom.h"

@implementation RDMStudentDevice (Custom)

-(NSDictionary *) deviceDictionary {
    
    NSString *deviceToken = [self deviceToken];
    NSString *guid = [self guid];
    NSNumber *deviceType = [NSNumber numberWithInt:[self deviceType]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (deviceToken) {
        [params setObject:deviceToken forKey:@"deviceToken"];
    }
    
    if (guid) {
        [params setObject:guid forKey:@"guid"];
    }
    
    [params setObject:deviceType forKey:@"deviceType"];
    
    return params;
    
}

-(NSString*)deviceToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
}

-(NSString*)guid {
    
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
}

-(RDMDeviceType) deviceType {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return RDMDeviceTypePad;
    } else {
        return RDMDeviceTypePhone;
    }
    
}

@end
