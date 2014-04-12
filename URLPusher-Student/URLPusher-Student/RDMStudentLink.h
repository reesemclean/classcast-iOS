//
//  RDMStudentLink.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/10/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RDMStudentDevice, RDMTeacher;

@interface RDMStudentLink : NSManagedObject

@property (nonatomic, retain) NSDate *lastSentOn;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * hasBeenDeleted;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) RDMStudentDevice *device;
@property (nonatomic, retain) RDMTeacher *teacher;

@end
