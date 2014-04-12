//
//  RDMStudentSyncEngine.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMStudentSyncEngine.h"

#import <AFNetworking/AFNetworking.h>

#import "RDMStudentDataProcessor.h"
#import "RDMStudentDataController.h"

#import "RDMStudentDevice.h"
#import "RDMStudentDevice+Custom.h"
#import "RDMTeacher.h"
#import "RDMStudentLink.h"

#import "RDMAPIClient.h"

#import "UIAlertView+ErrorHelpers.h"

NSString * const RDMSyncEngineDidFinishNotification = @"RDMSyncEngineDidFinishNotification";

@interface RDMStudentSyncEngine ()

@property (nonatomic, strong) RDMStudentDataProcessor *dataProcessor;
@property (nonatomic, strong) RDMStudentDataController *dataController;
@property (nonatomic, assign, readwrite) BOOL isSyncing;

@property (nonatomic, assign) BOOL needsFullResyncAfterSync;
@property (nonatomic, assign) BOOL needsSyncingAfterSyncFinishes;

@property (nonatomic, strong) id didBecomeActiveObserver;

@end

@implementation RDMStudentSyncEngine

+ (instancetype)sharedEngine {
    static RDMStudentSyncEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[RDMStudentSyncEngine alloc] init];
    });
    
    return _sharedEngine;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _dataController = [RDMStudentDataController sharedInstance];
        _dataProcessor =  [RDMStudentDataProcessor sharedInstance];
        
        _didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                     object:nil
                                                                                      queue:nil
                                                                                 usingBlock:^(NSNotification *note) {
                                                                                     [self startSync];
                                                                                 }];
        
    }
    return self;
    
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.didBecomeActiveObserver];
}

-(void) startFullResync {
    
    if (!self.dataController.device) {
        return;
    }
    
    if (self.isSyncing) {
        self.needsFullResyncAfterSync = YES;
        return;
    }
    
    self.isSyncing = YES;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    NSDate *dateToSend = [NSDate distantPast];
    NSString *lastUpdated = [NSString stringWithFormat:@"%lld", (long long)([dateToSend timeIntervalSince1970] * 1000)];
    [parameters setObject:lastUpdated forKey:@"lastUpdated"];
    
    [parameters setObject:[self.dataController.device deviceDictionary] forKey:@"device"];
    
    NSMutableURLRequest *request = [[RDMAPIClient sharedClient] syncRequestWithParameters:parameters];
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.isSyncing = NO;
        
        NSLog(@"Response Object: %@", responseObject);
        [self.dataProcessor updateDevice:self.dataController.device
                    withLinkDictionaries:responseObject[@"links"]
                  andTeacherDictionaries:responseObject[@"teachers"]
                          withCompletion:^(NSError *error) {
                              [self checkIfNeedsResyncing];
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
    
    AFHTTPRequestOperation *operation = [[RDMAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                             success:successBlock
                                                                                             failure:failureBlock];
    [operation start];
    
}

-(void) startSync {
    
    if (!self.dataController.device) {
        return;
    }
    
    if (self.isSyncing) {
        self.needsSyncingAfterSyncFinishes = YES;
        return;
    }
    
    self.isSyncing = YES;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdated" ascending:YES];
    
    NSArray *sortedLinksByDate = [self.dataController.device.links sortedArrayUsingDescriptors:@[dateDescriptor]];
    RDMStudentLink *lastLinkByDate = [sortedLinksByDate lastObject];
    
    NSArray *sortedTeachersByDate = [self.dataController.device.teachers sortedArrayUsingDescriptors:@[dateDescriptor]];
    RDMTeacher *lastTeacherByDate = [sortedTeachersByDate lastObject];
    
    NSDate *dateToSend = [NSDate distantPast];
    
    if (lastLinkByDate.lastUpdated && [dateToSend compare:lastLinkByDate.lastUpdated] == NSOrderedAscending) {
        dateToSend = lastLinkByDate.lastUpdated;
    }
    
    if (lastTeacherByDate.lastUpdated && [dateToSend compare:lastTeacherByDate.lastUpdated] == NSOrderedAscending) {
        dateToSend = lastTeacherByDate.lastUpdated;
    }
    
    NSString *lastUpdated = [NSString stringWithFormat:@"%lld", (long long)([dateToSend timeIntervalSince1970] * 1000)];
    [parameters setObject:lastUpdated forKey:@"lastUpdated"];
    
    [parameters setObject:[self.dataController.device deviceDictionary] forKey:@"device"];
    
    NSMutableURLRequest *request = [[RDMAPIClient sharedClient] syncRequestWithParameters:parameters];
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.isSyncing = NO;
        
        NSLog(@"Response Object: %@", responseObject);
        [self.dataProcessor updateDevice:self.dataController.device
                    withLinkDictionaries:responseObject[@"links"]
                  andTeacherDictionaries:responseObject[@"teachers"]
                          withCompletion:^(NSError *error) {
                              [self checkIfNeedsResyncing];
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
    
    AFHTTPRequestOperation *operation = [[RDMAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                                      success:successBlock
                                                                                                      failure:failureBlock];
    [operation start];
    
    
}

-(void) checkIfNeedsResyncing {
    
    if (self.needsFullResyncAfterSync) {
        self.needsFullResyncAfterSync = NO;
        self.needsSyncingAfterSyncFinishes = NO;
        [self startFullResync];
    } else if (self.needsSyncingAfterSyncFinishes) {
        self.needsSyncingAfterSyncFinishes = NO;
        [self startSync];
    }
    
}

@end
