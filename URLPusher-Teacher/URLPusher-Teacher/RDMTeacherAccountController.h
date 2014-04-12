//
//  RDMTeacherAccountController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RDMTeacherDataController.h"
#import "RDMUser.h"

extern NSString * const RDMUserDidChangeNotification;

@class RDMGroup;

typedef void (^RDMTeacherAccountPasswordResetRequestCompletionBlock)(NSError* error);
typedef void (^RDMTeacherAccountSubmissionCompletionBlock)(RDMUser *user, NSError *error);
typedef void (^RDMTeacherAccountGroupRegistrationCodeChangeCompletionBlock)(RDMGroup* group, NSError *error);

@interface RDMTeacherAccountController : NSObject

-(instancetype) initWithDataController:(RDMTeacherDataController*)dataController;

-(BOOL) userInformationValidatesWithEmail:(NSString*)emailAddress andPassword:(NSString*)password;
-(void) attemptToCreateUserWithEmail:(NSString*)emailAddress
                         andPassword:(NSString *)password
                      andDisplayName:(NSString *)displayName
                      withCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock;
-(void) attemptToLoginUserWithEmail:(NSString*)emailAddress andPassword:(NSString*)password withCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock;

-(void) sendPasswordResetRequestWithEmail:(NSString*)emailAddress withCompletion:(RDMTeacherAccountPasswordResetRequestCompletionBlock)completionBlock;
-(void) sendPasswordResetConfirmationWithCode:(NSString*)resetCode andNewPassword:(NSString*)newPassword withCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock;

-(void) sendPasswordChangeWithEmail:(NSString*)emailAddress andOldPassword:(NSString*)oldPassword andNewPassword:(NSString*)newPassword andCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock;
-(void) sendDisplayNameChange:(NSString*)newDisplayName withCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock;

-(void) logoutUserWithCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completion;
-(void) sendRegistrationTokenChangeRequestWithCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock;
-(void) sendGroupRegistrationTokenChangeRequestForGroup:(RDMGroup*)group
                                         WithCompletion:(RDMTeacherAccountGroupRegistrationCodeChangeCompletionBlock)completionBlock;
@end
