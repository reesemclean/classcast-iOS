//
//  RDMGroup.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/8/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RDMDevice, RDMUser;

@interface RDMGroup : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * hasBeenDeleted;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSSet *devices;
@property (nonatomic, retain) RDMUser *user;
@property (nonatomic, retain) NSString *registrationToken;

@end

@interface RDMGroup (CoreDataGeneratedAccessors)

- (void)addDevicesObject:(RDMDevice *)value;
- (void)removeDevicesObject:(RDMDevice *)value;
- (void)addDevices:(NSSet *)values;
- (void)removeDevices:(NSSet *)values;

@end
