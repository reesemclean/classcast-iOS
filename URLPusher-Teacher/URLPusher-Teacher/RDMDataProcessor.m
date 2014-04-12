//
//  RDMDataProcessor.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/7/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMDataProcessor.h"

#import "RDMTeacherDataController.h"
#import "RDMUser.h"
#import "RDMLink.h"
#import "RDMDevice.h"
#import "RDMGroup.h"
#import "RDMGroupPlacement+Custom.h"
#import "RDMGroupPlacement.h"

@interface RDMDataProcessor ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation RDMDataProcessor

-(id) initWithDataController:(RDMTeacherDataController *)dataController {
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

-(void) updateUser:(RDMUser*)user
withUserDictionary:(NSDictionary*)userDictionary
withArrayOfLinkDictionaries:(NSArray*)linkDictionaries
andArrayOfDeviceDictionaries:(NSArray*)deviceDictionaries
andArrayOfGroupDictionaries:(NSArray*)groupDictionaries
andArrayOfGroupPlacementChanges:(NSArray*)groupPlacementChangesDictionaries
    withCompletion:(RDMCoreDataSaveCompletionBlock)completion {
    
    [self.queue addOperationWithBlock:^{
        
        NSManagedObjectContext *temporaryContext = [self.dataController createTemporaryContext];
        [temporaryContext performBlockAndWait:^{
            
            NSError *error = nil;
            RDMUser *userInTemporaryContext = (RDMUser*)[temporaryContext existingObjectWithID:user.objectID
                                                                                         error:&error];
            if (error) {
                NSLog(@"Could Not Find User: %@", error);
            }
            
            if (userDictionary[@"subscriptionExpirationDate"] == [NSNull null]) {
                userInTemporaryContext.subscriptionExpirationDate = nil;
            } else {
                userInTemporaryContext.subscriptionExpirationDate = [self.dateFormatter dateFromString:userDictionary[@"subscriptionExpirationDate"]];
            }
            userInTemporaryContext.displayName = userDictionary[@"displayName"];
            userInTemporaryContext.emailAddress = userDictionary[@"emailAddress"];
            userInTemporaryContext.registrationToken = userDictionary[@"registrationToken"];
            
            [self processLinkDictionaries:linkDictionaries forUser:userInTemporaryContext inContext:temporaryContext];
            [self processDeviceDictionaries:deviceDictionaries forUser:userInTemporaryContext inContext:temporaryContext];
            [self processGroupDictionaries:groupDictionaries forUser:userInTemporaryContext inContext:temporaryContext];
            [self cleanupGroupPlacementsForUser:userInTemporaryContext inContext:temporaryContext];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                
                NSError *error = nil;
                if (![self.dataController saveMainContextSyncronously:&error]) {
                    NSLog(@"Error: %@", error);
                    if (completion) {
                        completion(error);
                    }
                    return;
                }
                
                if (completion) {
                    completion(nil);
                }
            }];
            
        }];
        
    }];
    
}

-(void) processLinkDictionaries:(NSArray*)linkDictionaries forUser:(RDMUser*)user inContext:(NSManagedObjectContext*)context {
    
    NSPredicate *linkPredicate = [NSPredicate predicateWithFormat:@"guid == $GUID"];
    
    for (NSDictionary *linkDictionary in linkDictionaries) {
        
        BOOL hasBeenDeleted = [linkDictionary[@"hasBeenDeleted"] boolValue];
        NSString *guid = linkDictionary[@"guid"];
        NSString *url = linkDictionary[@"url"];
        NSString *name = linkDictionary[@"name"];
        BOOL savedByUser = [linkDictionary[@"savedByUser"] boolValue];
        NSDate *lastUpdated = [self.dateFormatter dateFromString:linkDictionary[@"lastUpdated"]];
        NSDate *lastSentOn = [self.dateFormatter dateFromString:linkDictionary[@"lastSentOn"]];

        NSDictionary *substitution = [NSDictionary dictionaryWithObject:guid forKey:@"GUID"];
        NSPredicate *guidSearch = [linkPredicate predicateWithSubstitutionVariables:substitution];
        
        NSSet *foundLinks = [user.links filteredSetUsingPredicate:guidSearch];
        
        if ([foundLinks count] > 0) {
            //Update the link
            RDMLink *link = [foundLinks anyObject];
            link.hasBeenDeleted = @(hasBeenDeleted);
            link.url = url;
            link.name = name;
            link.savedByUser = @(savedByUser);
            link.user = user;
            link.lastUpdated = lastUpdated;
            link.lastSentOn = lastSentOn;
            link.syncStatus = @0;
            
        } else {
            //Create the link
            RDMLink *link = [NSEntityDescription insertNewObjectForEntityForName:@"RDMLink" inManagedObjectContext:context];
            link.hasBeenDeleted = @(hasBeenDeleted);
            link.url = url;
            link.name = name;
            link.savedByUser = @(savedByUser);
            link.user = user;
            link.lastUpdated = lastUpdated;
            link.lastSentOn = lastSentOn;
            link.guid = guid;
            link.syncStatus = @0;
            
        }
        
    }
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error: %@", error);
        }
        
    }];
    
}

-(void) processDeviceDictionaries:(NSArray*)deviceDictionaries forUser:(RDMUser*)user inContext:(NSManagedObjectContext*)context {

    NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"guid == $GUID"];
    
    for (NSDictionary *deviceDictionary in deviceDictionaries) {
        
        NSDictionary *deviceInformation = deviceDictionary[@"device"];
        
        NSString *pushToken = deviceInformation[@"pushToken"];
        NSString *guid = deviceInformation[@"_id"];
        NSArray *groupGUIDs = deviceInformation[@"groups"];
        int deviceType = [deviceInformation[@"deviceType"] intValue];
        
        NSDate *lastUpdated = [self.dateFormatter dateFromString:deviceDictionary[@"lastUpdated"]];
        NSString *name = deviceDictionary[@"deviceName"];
        NSNumber *hasBeenDeleted = deviceDictionary[@"hasBeenDeleted"];

        NSDictionary *substitution = [NSDictionary dictionaryWithObject:guid forKey:@"GUID"];
        NSPredicate *guidSearch = [devicePredicate predicateWithSubstitutionVariables:substitution];
        
        NSSet *foundDevices = [user.devices filteredSetUsingPredicate:guidSearch];

        
        RDMDevice *device;
        
        if ([foundDevices count] > 0) {
            device = [foundDevices anyObject];
        } else {
            device = [NSEntityDescription insertNewObjectForEntityForName:@"RDMDevice" inManagedObjectContext:context];
            device.guid = guid;
        }
        
        device.lastUpdated = lastUpdated;
        
        device.pushToken = pushToken;
        device.name = name;
        device.deviceType = @(deviceType);
        device.syncStatus = @0;
        device.hasBeenDeleted = hasBeenDeleted;
        device.user = user;
        
        //Search groupGUIDs see if we have them, if not they should be coming with the groups array coming next
        NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"guid = $GUID"];
        
        for (NSString *groupGUID in groupGUIDs) {
            
            NSDictionary *groupSubstitution = [NSDictionary dictionaryWithObject:groupGUID forKey:@"GUID"];
            NSPredicate *groupGUIDSearch = [groupPredicate predicateWithSubstitutionVariables:groupSubstitution];
            NSSet *foundGroups = [user.groups filteredSetUsingPredicate:groupGUIDSearch];
            
            if ([foundGroups count] > 0) {
                
                [device addGroupsObject:[foundDevices anyObject]];
                
            }
            
        }

    }
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error: %@", error);
        }
        
    }];
    
}

-(void) processGroupDictionaries:(NSArray*)groupDictionaries forUser:(RDMUser*)user inContext:(NSManagedObjectContext*)context {

    NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"guid == $GUID"];
    
    for (NSDictionary *groupDictionary in groupDictionaries) {
        
        BOOL hasBeenDeleted = [groupDictionary[@"hasBeenDeleted"] boolValue];
        NSString *guid = groupDictionary[@"guid"];
        NSString *name = groupDictionary[@"name"];
        NSString *registrationCode = groupDictionary[@"registrationToken"];
        NSDate *lastUpdated = [self.dateFormatter dateFromString:groupDictionary[@"lastUpdated"]];

        NSArray *deviceGUIDs = groupDictionary[@"devices"];
        
        NSDictionary *substitution = [NSDictionary dictionaryWithObject:guid forKey:@"GUID"];
        NSPredicate *guidSearch = [groupPredicate predicateWithSubstitutionVariables:substitution];
        
        NSSet *foundGroups = [user.groups filteredSetUsingPredicate:guidSearch];
        
        RDMGroup *group;
        
        if ([foundGroups count] > 0) {
            group = [foundGroups anyObject];
        } else {
            group = [NSEntityDescription insertNewObjectForEntityForName:@"RDMGroup" inManagedObjectContext:context];
            group.guid = guid;
        }
        
        group.user = user;
        group.hasBeenDeleted = @(hasBeenDeleted);
        group.lastUpdated = lastUpdated;
        group.registrationToken = registrationCode;
        group.name = name;
        group.syncStatus = @0;
        
        NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"guid = $GUID"];
        
        [group setDevices:nil];
        
        for (NSString *deviceGUID in deviceGUIDs) {
            
            NSDictionary *deviceSubstitution = [NSDictionary dictionaryWithObject:deviceGUID forKey:@"GUID"];
            NSPredicate *deviceGUIDSearch = [devicePredicate predicateWithSubstitutionVariables:deviceSubstitution];
            NSSet *foundDevices = [user.devices filteredSetUsingPredicate:deviceGUIDSearch];
            
            RDMDevice *device;
            
            if ([foundDevices count] > 0) {
                
                device = [foundDevices anyObject];
                [group addDevicesObject:device];
                
            } else {
                NSLog(@"Don't have the device yet! This shouldn't happen!");
            }
            
        }
        
    }
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error: %@", error);
        }
        
    }];
}

-(void)cleanupGroupPlacementsForUser:(RDMUser*)user inContext:(NSManagedObjectContext*)context {
    
    //Assume they got there...?
    for (RDMGroupPlacement *placement in user.groupPlacements) {
        [context deleteObject:placement];
    }
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error: %@", error);
        }
        
    }];
    
}

@end
