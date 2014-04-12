//
//  RDMStudentDevice+Custom.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMStudentDevice.h"

typedef NS_ENUM(NSUInteger, RDMDeviceType) {
    RDMDeviceTypePhone,
    RDMDeviceTypePad
};

@interface RDMStudentDevice (Custom)

-(NSDictionary *) deviceDictionary;
-(NSString*)deviceToken;
-(NSString*)guid;
-(RDMDeviceType)deviceType;

@end
