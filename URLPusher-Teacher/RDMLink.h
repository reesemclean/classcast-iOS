//
//  RDMLink.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/1/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RDMUser;

@interface RDMLink : NSManagedObject

@property (nonatomic, retain) NSDate * dateUpdatedOnDevice;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber *syncStatus;
@property (nonatomic, retain) NSNumber * hasBeenDeleted;
@property (nonatomic, retain) NSDate * lastSentOn;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * savedByUser;
@property (nonatomic, retain) RDMUser *user;

@end
