//
//  RDMUser.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/16/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RDMDevice, RDMGroup, RDMLink;

@interface RDMUser : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * registrationToken;
@property (nonatomic, retain) NSDate * subscriptionExpirationDate;
@property (nonatomic, retain) NSSet *devices;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *links;
@property (nonatomic, retain) NSSet *groupPlacements;
@end

@interface RDMUser (CoreDataGeneratedAccessors)

- (void)addDevicesObject:(RDMDevice *)value;
- (void)removeDevicesObject:(RDMDevice *)value;
- (void)addDevices:(NSSet *)values;
- (void)removeDevices:(NSSet *)values;

- (void)addGroupsObject:(RDMGroup *)value;
- (void)removeGroupsObject:(RDMGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addLinksObject:(RDMLink *)value;
- (void)removeLinksObject:(RDMLink *)value;
- (void)addLinks:(NSSet *)values;
- (void)removeLinks:(NSSet *)values;

- (void)addGroupPlacementsObject:(NSManagedObject *)value;
- (void)removeGroupPlacementsObject:(NSManagedObject *)value;
- (void)addGroupPlacements:(NSSet *)values;
- (void)removeGroupPlacements:(NSSet *)values;

@end
