//
//  RDMGroup+Custom.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/8/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMGroup+Custom.h"

#import "RDMDevice.h"

@implementation RDMGroup (Custom)

-(void) awakeFromInsert {
    
    [super awakeFromInsert];
    
    self.guid = [[NSUUID UUID] UUIDString];
    
}

-(NSDictionary*)groupDictionary {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.guid) {
        [dictionary setObject:self.guid forKey:@"guid"];
    }
    
    if (self.hasBeenDeleted) {
        [dictionary setObject:self.hasBeenDeleted forKey:@"hasBeenDeleted"];
    }
    
    if (self.lastUpdated) {
        NSString *lastUpdated = [NSString stringWithFormat:@"%lld", (long long)([self.lastUpdated timeIntervalSince1970] * 1000)];
        [dictionary setObject:lastUpdated forKey:@"lastUpdated"];
    }
    
    if (self.name) {
        [dictionary setObject:self.name forKey:@"name"];
    }
    
    if (self.devices) {
        
        NSMutableArray *deviceGUIDs = [NSMutableArray array];
        for (RDMDevice *device in self.devices) {
            [deviceGUIDs addObject:device.guid];
        }
        
        [dictionary setObject:deviceGUIDs forKey:@"deviceGUIDs"];
        
    }

    return [dictionary copy];
}

@end
