//
//  RDMRegistrationController.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/10/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDMStudentDevice;
@class RDMTeacher;
@class RDMStudentDataController;

typedef void (^RDMDeviceRegistrationSubmissionSuccessCompletionBlock)(BOOL shouldResync);
typedef void (^RDMDeviceRegistrationSubmissionFailureCompletionBlock)(NSError* error);

@interface RDMRegistrationController : NSObject

-(instancetype) initWithDataController:(RDMStudentDataController*)dataController;

-(void) attemptToRegisterDevice:(RDMStudentDevice *) device
               withProposedName:(NSString*) string
           withRegistrationCode:(NSString*)registrationCode
                    withSuccess:(RDMDeviceRegistrationSubmissionSuccessCompletionBlock)success
                     andFailure:(RDMDeviceRegistrationSubmissionFailureCompletionBlock)failure;

@end
