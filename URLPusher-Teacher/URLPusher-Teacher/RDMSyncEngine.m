//
//  RDMSyncEngine.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/6/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSyncEngine.h"

#import "RDMTeacherDataController.h"

#import "RDMUser.h"
#import "RDMUser+Custom.h"
#import "RDMLink.h"
#import "RDMLink+Custom.h"
#import "RDMDevice.h"
#import "RDMDevice+Custom.h"
#import "RDMGroup+Custom.h"
#import "RDMGroup.h"
#import "RDMGroupPlacement.h"
#import "RDMGroupPlacement+Custom.h"

#import "RDMTokenAuthAPIClient.h"

#import "RDMDataProcessor.h"

#import "UIAlertView+ErrorHelpers.h"

NSString * const RDMSyncEngineDidFinishNotification = @"RDMSyncEngineDidFinishNotification";

@interface RDMSyncEngine ()

@property (nonatomic, strong) RDMDataProcessor *dataProcessor;
@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, assign, readwrite) BOOL isSyncing;
@property (nonatomic, assign) BOOL needsSyncingAfterSyncFinishes;

@end

@implementation RDMSyncEngine

+ (instancetype)sharedEngine {
    static RDMSyncEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[RDMSyncEngine alloc] init];
    });
    
    return _sharedEngine;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _dataController = [RDMTeacherDataController sharedInstance];
        _dataProcessor = [[RDMDataProcessor alloc] initWithDataController:_dataController];
    }
    return self;
    
}

-(void) startSync {
    
    if (!self.dataController.currentUser) {
        return;
    }
    
    if (self.isSyncing) {
        self.needsSyncingAfterSyncFinishes = YES;
        return;
    }
    
    self.isSyncing = YES;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdated" ascending:YES];
    
    NSArray *sortedLinksByDate = [self.dataController.currentUser.links sortedArrayUsingDescriptors:@[dateDescriptor]];
    RDMLink *lastLinkByDate = [sortedLinksByDate lastObject];
    
    NSArray *sortedGroupsByDate = [self.dataController.currentUser.groups sortedArrayUsingDescriptors:@[dateDescriptor]];
    RDMGroup *lastGroupByDate = [sortedGroupsByDate lastObject];
    
    NSArray *sortedDevicesByDate = [self.dataController.currentUser.devices sortedArrayUsingDescriptors:@[dateDescriptor]];
    RDMDevice *lastDeviceByDate = [sortedDevicesByDate lastObject];
    
    NSDate *dateToSend = [NSDate distantPast];
    
    if (lastLinkByDate.lastUpdated && [dateToSend compare:lastLinkByDate.lastUpdated] == NSOrderedAscending) {
        dateToSend = lastLinkByDate.lastUpdated;
    }
    
    if (lastDeviceByDate.lastUpdated && [dateToSend compare:lastDeviceByDate.lastUpdated] == NSOrderedAscending) {
        dateToSend = lastDeviceByDate.lastUpdated;
    }
    
    if (lastGroupByDate.lastUpdated && [dateToSend compare:lastGroupByDate.lastUpdated] == NSOrderedAscending) {
        dateToSend = lastGroupByDate.lastUpdated;
    }
    
    NSString *lastUpdated = [NSString stringWithFormat:@"%lld", (long long)([dateToSend timeIntervalSince1970] * 1000)];
    
    [parameters setObject:lastUpdated forKey:@"lastUpdated"];
    
    if ([self.dataController.currentUser usersDeviceToken]) {
        [parameters setObject:[self.dataController.currentUser usersDeviceToken] forKey:@"usersDeviceToken"];
    }
    
    NSMutableArray *linkDictionariesToSend = [NSMutableArray array];
    
    for (RDMLink *link in self.dataController.currentUser.links) {
        
        if ([link.syncStatus isEqualToNumber:@1]) {
            [linkDictionariesToSend addObject:[link linkDictionary]];
        }
        
    }
    
    [parameters setObject:linkDictionariesToSend forKey:@"links"];
    
    NSMutableArray *groupDictionariesToSend = [NSMutableArray array];

    for (RDMGroup *group in self.dataController.currentUser.groups) {
        
        if ([group.syncStatus isEqualToNumber:@1]) {
            
            NSMutableDictionary *groupDictionary = [NSMutableDictionary dictionary];
            [groupDictionary setObject:[group groupDictionary] forKey:@"groupInfo"];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupGUID == $GUID"];
            
            NSDictionary *substitution = [NSDictionary dictionaryWithObject:group.guid forKey:@"GUID"];
            NSPredicate *guidSearch = [predicate predicateWithSubstitutionVariables:substitution];
            
            NSSet *foundPlacementChanges = [self.dataController.currentUser.groupPlacements filteredSetUsingPredicate:guidSearch];
            
            NSMutableArray *placementChangesToSend = [NSMutableArray array];

            for (RDMGroupPlacement *groupPlacement in foundPlacementChanges) {
                [placementChangesToSend addObject:[groupPlacement groupPlacementDictionary]];
            }
            
            [groupDictionary setObject:placementChangesToSend forKey:@"groupPlacementChanges"];

            [groupDictionariesToSend addObject:groupDictionary];

        }
        
    }
    
    [parameters setObject:groupDictionariesToSend forKey:@"groups"];
        
    NSMutableArray *deviceDictionariesToSend = [NSMutableArray array];
    
    for (RDMDevice *device in self.dataController.currentUser.devices) {
        
        if ([device.syncStatus isEqualToNumber:@1]) {
            [deviceDictionariesToSend addObject:[device deviceDictionary]];
        }
    }
    
    [parameters setObject:deviceDictionariesToSend forKey:@"devices"];
    
    NSMutableURLRequest *request = [[RDMTokenAuthAPIClient sharedClient] updateRequestForUserWithToken:[self.dataController.currentUser serverToken]
                                                                                        withParameters:parameters];
    
    if (!request) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"There was a problem syncing your account. Please sign in again."];
        
        return;
    }
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.isSyncing = NO;

        NSLog(@"Response Object: %@", responseObject);
        
        [self.dataProcessor updateUser:self.dataController.currentUser
                    withUserDictionary:responseObject[@"user"]
           withArrayOfLinkDictionaries:responseObject[@"links"]
          andArrayOfDeviceDictionaries:responseObject[@"devices"]
           andArrayOfGroupDictionaries:responseObject[@"groups"]
                    andArrayOfGroupPlacementChanges:responseObject[@"groupPlacementChanges"]
                        withCompletion:^(NSError* error) {
                            
                            if (self.needsSyncingAfterSyncFinishes) {
                                self.needsSyncingAfterSyncFinishes = NO;
                                [self startSync];
                            }
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:RDMSyncEngineDidFinishNotification object:self];
                        }];
        
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        self.isSyncing = NO;
        self.needsSyncingAfterSyncFinishes = NO;
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *notificationInfo = nil;
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 401:
                notificationInfo = @{ @"ShouldLogoutUserDueToAuthenticationError" : @YES };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Finish Syncing",
                              NSLocalizedDescriptionKey : @"There was a problem logging into your account. Please sign in again." };
                break;
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version of the app is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Finish Syncing",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSLog(@"Error: %@", error);
        [UIAlertView showAlertWithTitle:userInfo[@"RDMErrorTitleKey"] andMessage:userInfo[NSLocalizedDescriptionKey]];

        [[NSNotificationCenter defaultCenter] postNotificationName:RDMSyncEngineDidFinishNotification object:self userInfo:notificationInfo];

    };
    
    AFHTTPRequestOperation *operation = [[RDMTokenAuthAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];

    
}

@end
