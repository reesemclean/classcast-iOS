//
//  RDMGroupPlacement.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/16/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RDMUser;

@interface RDMGroupPlacement : NSManagedObject

@property (nonatomic, retain) NSString * groupGUID;
@property (nonatomic, retain) NSString * deviceID;
@property (nonatomic, retain) NSNumber * hasBeenProcessed;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * placementType;
@property (nonatomic, retain) RDMUser *user;

@end
