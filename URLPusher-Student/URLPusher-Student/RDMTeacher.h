//
//  RDMTeacher.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/19/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RDMStudentDevice, RDMStudentLink;

@interface RDMTeacher : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * hasBeenDeleted;
@property (nonatomic, retain) RDMStudentDevice *device;
@property (nonatomic, retain) NSSet *sentLinks;
@end

@interface RDMTeacher (CoreDataGeneratedAccessors)

- (void)addSentLinksObject:(RDMStudentLink *)value;
- (void)removeSentLinksObject:(RDMStudentLink *)value;
- (void)addSentLinks:(NSSet *)values;
- (void)removeSentLinks:(NSSet *)values;

@end
