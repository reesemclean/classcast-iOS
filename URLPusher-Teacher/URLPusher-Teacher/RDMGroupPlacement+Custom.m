//
//  RDMGroupPlacement+Custom.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/16/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMGroupPlacement+Custom.h"

@implementation RDMGroupPlacement (Custom)

-(void) awakeFromInsert {
    
    [super awakeFromInsert];
    
    self.guid = [[NSUUID UUID] UUIDString];
    
}

-(NSDictionary*)groupPlacementDictionary {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.guid) {
        [dictionary setObject:self.guid forKey:@"guid"];
    }
    
    if (self.groupGUID) {
        [dictionary setObject:self.groupGUID forKey:@"groupGUID"];
    }
    
    if (self.deviceID) {
        [dictionary setObject:self.deviceID forKey:@"deviceID"];
    }
    
    if (self.hasBeenProcessed) {
        [dictionary setObject:self.hasBeenProcessed forKey:@"hasBeenProcessed"];
    }
    
    if (self.placementType) {
        [dictionary setObject:self.placementType forKey:@"placementType"];
    }
    
    return [dictionary copy];
    
}

@end
