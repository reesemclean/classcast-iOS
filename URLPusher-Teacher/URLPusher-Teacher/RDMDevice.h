//
//  RDMDevice.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/8/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RDMGroup, RDMUser;

@interface RDMDevice : NSManagedObject

@property (nonatomic, retain) NSNumber * deviceType;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * hasBeenDeleted;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pushToken;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) RDMUser *user;
@end

@interface RDMDevice (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(RDMGroup *)value;
- (void)removeGroupsObject:(RDMGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
