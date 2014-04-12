//
//  RDMDevice+Custom.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/8/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMDevice+Custom.h"

#import "RDMGroup.h"

@implementation RDMDevice (Custom)


-(void) awakeFromInsert {
    
    [super awakeFromInsert];
    
    self.guid = [[NSUUID UUID] UUIDString];
    
}

-(NSDictionary*)deviceDictionary {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.guid) {
        [dictionary setObject:self.guid forKey:@"guid"];
    }
    
    if (self.lastUpdated) {
        NSString *lastUpdated = [NSString stringWithFormat:@"%lld", (long long)([self.lastUpdated timeIntervalSince1970] * 1000)];
        [dictionary setObject:lastUpdated forKey:@"lastUpdated"];
    }
    
    if (self.deviceType) {
        [dictionary setObject:self.deviceType forKey:@"deviceType"];
    }
    
    if (self.name) {
        [dictionary setObject:self.name forKey:@"name"];
    }
    
    if (self.pushToken) {
        [dictionary setObject:self.pushToken forKey:@"pushToken"];
    }
    
    if (self.hasBeenDeleted) {
        [dictionary setObject:self.hasBeenDeleted forKey:@"hasBeenDeleted"];
    }
    
    if (self.groups) {
        
        NSMutableArray *groupGUIDs = [NSMutableArray array];
        for (RDMGroup *group in self.groups) {
            [groupGUIDs addObject:group.guid];
        }
        
        [dictionary setObject:groupGUIDs forKey:@"groupGUIDs"];
        
    }
    
    return [dictionary copy];
}

@end
