//
//  RDMStudentDevice.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RDMStudentLink, RDMTeacher;

@interface RDMStudentDevice : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *teachers;
@property (nonatomic, retain) NSSet *links;
@end

@interface RDMStudentDevice (CoreDataGeneratedAccessors)

- (void)addTeachersObject:(RDMTeacher *)value;
- (void)removeTeachersObject:(RDMTeacher *)value;
- (void)addTeachers:(NSSet *)values;
- (void)removeTeachers:(NSSet *)values;

- (void)addLinksObject:(RDMStudentLink *)value;
- (void)removeLinksObject:(RDMStudentLink *)value;
- (void)addLinks:(NSSet *)values;
- (void)removeLinks:(NSSet *)values;

@end
