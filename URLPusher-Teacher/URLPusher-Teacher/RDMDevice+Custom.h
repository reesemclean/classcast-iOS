//
//  RDMDevice+Custom.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/8/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMDevice.h"

typedef NS_ENUM(NSUInteger, RDMDeviceType) {
    RDMDeviceTypePhone,
    RDMDeviceTypePad
};

@interface RDMDevice (Custom)

-(NSDictionary*)deviceDictionary;

@end
