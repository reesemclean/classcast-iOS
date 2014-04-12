//
//  RDMLink+Custom.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/7/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMLink+Custom.h"

@implementation RDMLink (Custom)

-(void) awakeFromInsert {
    
    [super awakeFromInsert];
    
    self.guid = [[NSUUID UUID] UUIDString];
    
}

-(NSDictionary*)linkDictionary {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.guid) {
        [dictionary setObject:self.guid forKey:@"guid"];
    }
    
    if (self.url) {
        [dictionary setObject:self.url forKey:@"url"];
    }
    
    if (self.name) {
        [dictionary setObject:self.name forKey:@"name"];
    }
    
    if (self.lastUpdated) {
        NSString *lastUpdated = [NSString stringWithFormat:@"%lld", (long long)([self.lastUpdated timeIntervalSince1970] * 1000)];
        [dictionary setObject:lastUpdated forKey:@"lastUpdated"];
    }
    
    if (self.lastSentOn) {
        NSString *lastSentOn = [NSString stringWithFormat:@"%lld", (long long)([self.lastSentOn timeIntervalSince1970] * 1000)];
        [dictionary setObject:lastSentOn forKey:@"lastSentOn"];
    }
    
    if (self.savedByUser) {
        [dictionary setObject:self.savedByUser forKey:@"savedByUser"];
    }
    
    if (self.hasBeenDeleted) {
        [dictionary setObject:self.hasBeenDeleted forKey:@"hasBeenDeleted"];
    }
    
    return [dictionary copy];
}
@end
