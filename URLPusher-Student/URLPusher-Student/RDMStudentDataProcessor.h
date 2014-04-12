//
//  RDMStudentDataProcessort.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RDMStudentDataController.h"

extern NSString * const RDMDidProcessPushNotificationPayload;

@class RDMStudentLink;
@class RDMStudentDevice;

typedef void (^RDMStudentDataProcessedNotificationPayloadSuccessCompletionBlock)(RDMStudentLink* link);
typedef void (^RDMStudentDataProcessedNotificationPayloadFailedCompletionBlock)(NSError* error);

@interface RDMStudentDataProcessor : NSObject

+(instancetype)sharedInstance;

-(void) updateDevice:(RDMStudentDevice*)device
withLinkDictionaries:(NSArray*)linkDictionaries
andTeacherDictionaries:(NSArray*)teacherDictionaries
withCompletion:(RDMCoreDataSaveCompletionBlock)completion;

-(void) processPushNotificationPayload:(NSDictionary*)payload showImmediately:(BOOL)immediately;

@end
