//
//  RDMStudentDataProcessort.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMStudentDataProcessor.h"

#import "RDMStudentDataController.h"
#import "RDMStudentDevice.h"
#import "RDMStudentLink.h"
#import "RDMTeacher.h"

NSString *const RDMDidProcessPushNotificationPayload = @"RDMDidProcessPushNotificationPayload";

@interface RDMStudentDataProcessor ()

@property (nonatomic, strong) RDMStudentDataController *dataController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation RDMStudentDataProcessor

+(instancetype)sharedInstance {

    static RDMStudentDataProcessor *_sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedController = [[RDMStudentDataProcessor alloc] initWithDataController:[RDMStudentDataController sharedInstance]];
    });
    
    return _sharedController;
    
}

-(id) initWithDataController:(RDMStudentDataController *)dataController {
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.name = @"Data Processing Queue";
        _queue.maxConcurrentOperationCount = 1;
        
        _dataController = dataController;
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        
    }
    return self;
}

-(void) updateDevice:(RDMStudentDevice*)device
withLinkDictionaries:(NSArray*) linkDictionaries
andTeacherDictionaries:(NSArray*)teacherDictionaries
      withCompletion:(RDMCoreDataSaveCompletionBlock)completion {
    
    [self.queue addOperationWithBlock:^{
       
        NSManagedObjectContext *temporaryContext = [self.dataController createTemporaryContext];
        
        NSError *error = nil;
        RDMStudentDevice *deviceInTemporaryContext = (RDMStudentDevice*)[temporaryContext existingObjectWithID:self.dataController.device.objectID
                                                                                                         error:&error];
        if (error) {
            NSLog(@"Could Not Find Device: %@", error);
        }
        
        [self processTeacherDictionaries:teacherDictionaries
                               forDevice:deviceInTemporaryContext
                               inContext:temporaryContext];
        
        [self processLinksDictionaries:linkDictionaries
                             forDevice:deviceInTemporaryContext
                             inContext:temporaryContext];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            
            NSError *error = nil;
            if (![self.dataController saveMainContextSyncronously:&error]) {
                if (completion) {
                    completion(error);
                }
                return;
            }
            if (completion) {
                completion(nil);
            }
            return;
            
        }];
        
        
        
    }];
    
    
}

-(void) processTeacherDictionaries:(NSArray*)teacherDictionaries forDevice:(RDMStudentDevice*)device inContext:(NSManagedObjectContext*)context {
    
    NSPredicate *guidPredicate = [NSPredicate predicateWithFormat:@"guid == $GUID"];
    
    for (NSDictionary *teacherDictionary in teacherDictionaries) {
        NSString *teacherGUID = teacherDictionary[@"guid"];
        NSString *displayName = teacherDictionary[@"displayName"];
        NSNumber *hasBeenDeleted = teacherDictionary[@"hasBeenDeleted"];
        NSDate *lastUpdated = [self.dateFormatter dateFromString:teacherDictionary[@"lastUpdated"]];

        NSDictionary *teacherSubstitution = @{ @"GUID" : teacherGUID };
        NSPredicate *teacherGUIDSerach = [guidPredicate predicateWithSubstitutionVariables:teacherSubstitution];
        
        NSSet *foundTeachers = [device.teachers filteredSetUsingPredicate:teacherGUIDSerach];
        RDMTeacher *teacher = [foundTeachers anyObject];
        if (!teacher) {
            teacher = [NSEntityDescription insertNewObjectForEntityForName:@"RDMTeacher"
                                                    inManagedObjectContext:context];
            teacher.device = device;
            teacher.guid = teacherGUID;
        }
        
        teacher.lastUpdated = lastUpdated;
        teacher.displayName = displayName;
        teacher.hasBeenDeleted = hasBeenDeleted;
    }
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error: %@", error);
        }
        
    }];
}

-(void) processLinksDictionaries:(NSArray*)linkDictionaries forDevice:(RDMStudentDevice*)device inContext:(NSManagedObjectContext*)context {
    
    NSPredicate *linkPredicate = [NSPredicate predicateWithFormat:@"guid == $GUID"];

    for (NSDictionary *linkDictionary in linkDictionaries) {
        
        NSString *linkGUID = linkDictionary[@"guid"];
        NSNumber *hasBeenDeleted = linkDictionary[@"hasBeenDeleted"];
        NSDate *lastUpdated = [self.dateFormatter dateFromString:linkDictionary[@"lastUpdated"]];
        NSDate *lastSentOn = [self.dateFormatter dateFromString:linkDictionary[@"lastSentOn"]];
        NSString *teacherGUID = linkDictionary[@"user"];
        NSString *url = linkDictionary[@"url"];
        NSString *name = linkDictionary[@"name"];
        
        NSDictionary *linkSubstitution = [NSDictionary dictionaryWithObject:linkGUID forKey:@"GUID"];
        NSPredicate *linkGuidSearch = [linkPredicate predicateWithSubstitutionVariables:linkSubstitution];
        
        NSDictionary *teacherSubstitution = @{ @"GUID" : teacherGUID };
        NSPredicate *teacherGUIDSerach = [linkPredicate predicateWithSubstitutionVariables:teacherSubstitution];
        
        NSSet *foundTeachers = [device.teachers filteredSetUsingPredicate:teacherGUIDSerach];
        RDMTeacher *teacher = [foundTeachers anyObject];
        if (!teacher) {
            //We are getting a link from an unknown teacher;
        }
        
        NSSet *foundLinks = [device.links filteredSetUsingPredicate:linkGuidSearch];
        RDMStudentLink *link = [foundLinks anyObject];
        if (!link) {
            link = [NSEntityDescription insertNewObjectForEntityForName:@"RDMStudentLink"
                                                 inManagedObjectContext:context];
            link.guid = linkGUID;
            link.device = device;
            link.teacher = teacher;
        }
        
        link.name = name;
        link.url = url;
        link.lastSentOn = lastSentOn;
        link.lastUpdated = lastUpdated;
        link.hasBeenDeleted = hasBeenDeleted;
     
    }
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error: %@", error);
        }
        
        
    }];
    
}

-(void) processPushNotificationPayload:(NSDictionary*)payload showImmediately:(BOOL)immediately {

    [self.queue addOperationWithBlock:^{
        
        NSManagedObjectContext *temporaryContext = [self.dataController createTemporaryContext];
        
        NSError *error = nil;
        RDMStudentDevice *deviceInTemporaryContext = (RDMStudentDevice*)[temporaryContext existingObjectWithID:self.dataController.device.objectID
                                                                                     error:&error];
        if (error) {
            NSLog(@"Could Not Find Device: %@", error);
        }
        
        NSString *linkURL = payload[@"linkUrl"];
        NSString *linkName = payload[@"linkName"];
        NSString *linkGUID = payload[@"linkGUID"];
        NSString *teacherGUID = payload[@"teacherGUID"];
        NSDate *lastSentOn = [self.dateFormatter dateFromString:payload[@"lastSentOn"]];

        NSPredicate *linkPredicate = [NSPredicate predicateWithFormat:@"guid == $GUID"];

        NSDictionary *linkSubstitution = [NSDictionary dictionaryWithObject:linkGUID forKey:@"GUID"];
        NSPredicate *linkGuidSearch = [linkPredicate predicateWithSubstitutionVariables:linkSubstitution];
        
        NSSet *foundLinks = [deviceInTemporaryContext.links filteredSetUsingPredicate:linkGuidSearch];
        
        NSDictionary *teacherSubstitution = @{ @"GUID" : teacherGUID };
        NSPredicate *teacherGUIDSerach = [linkPredicate predicateWithSubstitutionVariables:teacherSubstitution];
        
        NSSet *foundTeachers = [deviceInTemporaryContext.teachers filteredSetUsingPredicate:teacherGUIDSerach];
        RDMTeacher *teacher = [foundTeachers anyObject];
        if (!teacher) {
            //We are getting a notification from an unknown teacher;
        }
        
        RDMStudentLink *link = nil;
        
        if ([foundLinks count] > 0) {
            //Update the link
            link = [foundLinks anyObject];
    
        } else {
            //Create the link
            
            link = [NSEntityDescription insertNewObjectForEntityForName:@"RDMStudentLink"
                                                 inManagedObjectContext:temporaryContext];
            link.guid = linkGUID;
            link.device = deviceInTemporaryContext;
            link.teacher = teacher;
        }

        link.url = linkURL;
        link.name = linkName;
        link.lastSentOn = lastSentOn;
        //lastUpdated is untouched so that next sync we get the actual object

        [self.dataController saveTemporaryContextAndPushToMainContext:temporaryContext
                                                       withCompletion:^(NSError* error) {
                                                          
                                                           if (error) {
                                                               NSLog(@"Error: %@", error);
                                                           }
                                                           
                                                           NSError *obtainPermanantIDsError = nil;
                                                           if (![temporaryContext obtainPermanentIDsForObjects:@[link] error:&obtainPermanantIDsError]) {
                                                               NSLog(@"Error %@", obtainPermanantIDsError);
                                                           }
                                                           
                                                           RDMStudentLink *permanentLink = (RDMStudentLink*)[self.dataController.managedObjectContext existingObjectWithID:link.objectID error:&obtainPermanantIDsError];
                                                           
                                                           if (permanentLink) {
                                                               
                                                               [[NSNotificationCenter defaultCenter] postNotificationName:RDMDidProcessPushNotificationPayload object:self userInfo:@{ @"link" : permanentLink, @"showImmediately": @(immediately) }];
                                                           }
                                                           


                                                           
                                                       }];
        
    }];
    
    
}

@end
