//
//  RDMTeacherAccountController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherAccountController.h"

#import "RDMLoginAPIClient.h"
#import "RDMUser.h"
#import "RDMUser+Custom.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

#import "RDMTokenAuthAPIClient.h"
#import "RDMGroup.h"

#import "UIAlertView+ErrorHelpers.h"

NSString * const RDMUserDidChangeNotification = @"RDMUserDidChangeNotification";

@interface RDMTeacherAccountController ()

@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) RDMLoginAPIClient *loginAPIClient;
@property (nonatomic, strong) RDMTokenAuthAPIClient *tokenBasedAPIClient;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation RDMTeacherAccountController

-(instancetype) initWithDataController:(RDMTeacherDataController*)dataController {
    self = [super init];
    if (self) {
        _dataController = dataController;
        _loginAPIClient = [RDMLoginAPIClient sharedClient];
        _tokenBasedAPIClient = [RDMTokenAuthAPIClient sharedClient];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        
    }
    return self;
}

-(BOOL) userInformationValidatesWithEmail:(NSString*)emailAddress andPassword:(NSString*)password {
    
    return YES;
    
}

-(void) attemptToCreateUserWithEmail:(NSString*)emailAddress
                                         andPassword:(NSString *)password
                                      andDisplayName:(NSString *)displayName
                                      withCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock {
    
    NSMutableURLRequest *urlRequest = [self.loginAPIClient signupAccountRequestWithEmail:emailAddress
                                                                             andPassword:password
                                                                          andDisplayName:displayName];
 
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
      
        NSLog(@"Response Object: %@", responseObject);
        NSString *token = [responseObject objectForKey:@"token"];
        NSDictionary *userDictionary = [responseObject objectForKey:@"user"];
        
        if (self.dataController.currentUser) {
            
            [self.dataController.managedObjectContext deleteObject:self.dataController.currentUser];
            self.dataController.currentUser = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:RDMUserDidChangeNotification object:nil];

        }
        
        RDMUser *user = [self setupUserWithUserDictionary:userDictionary
                                                 andToken:token];
        
        [self.dataController saveMainContextWithCompletion:^(NSError *error) {
            
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert)];

            if (error) {
                NSLog(@"Error: %@", error);
            }
            
            if (completionBlock) {
                completionBlock(user, nil);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RDMUserDidChangeNotification object:user];
        }];
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version of the app is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 409:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Create Account",
                              NSLocalizedDescriptionKey : @"This email address is already being used." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Create Account",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        if (completionBlock) {
            completionBlock(nil, localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.loginAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];
    
}

-(void) attemptToLoginUserWithEmail:(NSString*)emailAddress andPassword:(NSString*)password withCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock {
    
    NSMutableURLRequest *urlRequest = [self.loginAPIClient loginAccountRequestWithEmail:emailAddress
                                                                            andPassword:password];
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        NSString *token = [responseObject objectForKey:@"token"];
        NSDictionary *userDictionary = [responseObject objectForKey:@"user"];
        
        if (self.dataController.currentUser != nil && [self.dataController.currentUser.guid isEqualToString:[userDictionary objectForKey:@"_id"]]) {
            //We already have this user

            self.dataController.currentUser.emailAddress = [userDictionary objectForKey:@"emailAddress"];
            self.dataController.currentUser.displayName = [userDictionary objectForKey:@"displayName"];
            self.dataController.currentUser.registrationToken = [userDictionary objectForKey:@"registrationToken"];

            if (!userDictionary[@"subscriptionExpirationDate"] || userDictionary[@"subscriptionExpirationDate"] == [NSNull null]) {
                self.dataController.currentUser.subscriptionExpirationDate = nil;
            } else {
                self.dataController.currentUser.subscriptionExpirationDate = [self.dateFormatter dateFromString:userDictionary[@"subscriptionExpirationDate"]];
            }
            
            [self.dataController.currentUser setServerToken:token];
                        
            [self.dataController saveMainContextWithCompletion:^(NSError *error) {
                
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert)];
                
                if (completionBlock) {
                    completionBlock(self.dataController.currentUser, nil);
                }
            }];
            
            return;
        }
        
        if (self.dataController.currentUser) {
            
            [self.dataController.managedObjectContext deleteObject:self.dataController.currentUser];
            self.dataController.currentUser = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:RDMUserDidChangeNotification object:nil];

        }
        
        RDMUser *user = [self setupUserWithUserDictionary:userDictionary andToken:token];
        
        [self.dataController saveMainContextWithCompletion:^(NSError *error) {
            
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert)];
            
            if (error) {
                NSLog(@"Error: %@", error);
            }
            
            if (completionBlock) {
                completionBlock(user, nil);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RDMUserDidChangeNotification object:user];

        }];
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 401:
            case 404:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Login",
                              NSLocalizedDescriptionKey : @"Could not find a matching username and password." };
                break;
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version of the app is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Login",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        if (completionBlock) {
            completionBlock(nil, localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.loginAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];
    
}

-(RDMUser *)setupUserWithUserDictionary:(NSDictionary*)userDictionary andToken:(NSString*)token {
    
    RDMUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"RDMUser"
                                                  inManagedObjectContext:self.dataController.managedObjectContext];
    user.emailAddress = [userDictionary objectForKey:@"emailAddress"];
    user.displayName = [userDictionary objectForKey:@"displayName"];
    user.guid = [userDictionary objectForKey:@"_id"];

    if (!userDictionary[@"subscriptionExpirationDate"] || userDictionary[@"subscriptionExpirationDate"] == [NSNull null]) {
        user.subscriptionExpirationDate = nil;
    } else {
        user.subscriptionExpirationDate = [self.dateFormatter dateFromString:userDictionary[@"subscriptionExpirationDate"]];
    }
    
    user.registrationToken = [userDictionary objectForKey:@"registrationToken"];
    [user setServerToken:token];
    return user;
}

-(void) sendPasswordResetRequestWithEmail:(NSString*)emailAddress withCompletion:(RDMTeacherAccountPasswordResetRequestCompletionBlock)completionBlock {
    
    NSMutableURLRequest *urlRequest = [self.loginAPIClient requestPasswordResetRequestWithEmail:emailAddress];
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        if (completionBlock) {
            completionBlock(nil);
        }
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version of the app is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Send Password Reset",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        if (completionBlock) {
            completionBlock(localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.loginAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];
    
}

-(void) sendPasswordResetConfirmationWithCode:(NSString*)resetCode andNewPassword:(NSString*)newPassword withCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock {
    
    NSMutableURLRequest *urlRequest = [self.loginAPIClient confirmPasswordResetRequestWithResetCode:resetCode
                                                                                     andNewPassword:newPassword];
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        NSString *token = [responseObject objectForKey:@"token"];
        NSDictionary *userDictionary = [responseObject objectForKey:@"user"];
        
        if (self.dataController.currentUser != nil && [self.dataController.currentUser.guid isEqualToString:[userDictionary objectForKey:@"_id"]]) {
            //We already have this user
            
            self.dataController.currentUser.emailAddress = [userDictionary objectForKey:@"emailAddress"];
            self.dataController.currentUser.displayName = [userDictionary objectForKey:@"displayName"];
            self.dataController.currentUser.registrationToken = [userDictionary objectForKey:@"registrationToken"];
            if (!userDictionary[@"subscriptionExpirationDate"] || userDictionary[@"subscriptionExpirationDate"] == [NSNull null]) {
                self.dataController.currentUser.subscriptionExpirationDate = nil;
            } else {
                self.dataController.currentUser.subscriptionExpirationDate = [self.dateFormatter dateFromString:userDictionary[@"subscriptionExpirationDate"]];
            }            [self.dataController.currentUser setServerToken:token];
            
            [self.dataController saveMainContextWithCompletion:^(NSError *error) {
                
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                
                if (completionBlock) {
                    completionBlock(self.dataController.currentUser, nil);
                }
            }];
            
            return;
        }
        
        if (self.dataController.currentUser) {
            
            [self.dataController.managedObjectContext deleteObject:self.dataController.currentUser];
            self.dataController.currentUser = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:RDMUserDidChangeNotification object:nil];

        }
        
        RDMUser *user = [self setupUserWithUserDictionary:userDictionary andToken:token];
        
        [self.dataController saveMainContextWithCompletion:^(NSError *error) {
            
            if (error) {
                NSLog(@"Error: %@", error);
            }
            
            if (completionBlock) {
                completionBlock(user, nil);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:RDMUserDidChangeNotification object:user];

        }];
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 401:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Reset Password",
                              NSLocalizedDescriptionKey : @"This password reset code has expired for your security. Please request a new password reset and try again." };
                break;
            case 404:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Reset Password",
                              NSLocalizedDescriptionKey : @"This does not appear to be a valid password reset code." };
                break;
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version of the app is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Reset Password",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        if (completionBlock) {
            completionBlock(nil, localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.loginAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];

    
}

-(void) sendPasswordChangeWithEmail:(NSString*)emailAddress andOldPassword:(NSString*)oldPassword andNewPassword:(NSString*)newPassword andCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock {
    
    NSMutableURLRequest *urlRequest = [self.loginAPIClient changePasswordRequestWithEmailAddress:emailAddress
                                                                                  andOldPassword:oldPassword
                                                                                  andNewPassword:newPassword
                                                                                andLogoutDevices:NO];
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        NSString *token = [responseObject objectForKey:@"token"];
        NSDictionary *userDictionary = [responseObject objectForKey:@"user"];
        
        if (self.dataController.currentUser != nil && [self.dataController.currentUser.guid isEqualToString:[userDictionary objectForKey:@"_id"]]) {
            //We already have this user
            
            self.dataController.currentUser.emailAddress = [userDictionary objectForKey:@"emailAddress"];
            self.dataController.currentUser.displayName = [userDictionary objectForKey:@"displayName"];
            self.dataController.currentUser.registrationToken = [userDictionary objectForKey:@"registrationToken"];
            if (!userDictionary[@"subscriptionExpirationDate"] || userDictionary[@"subscriptionExpirationDate"] == [NSNull null]) {
                self.dataController.currentUser.subscriptionExpirationDate = nil;
            } else {
                self.dataController.currentUser.subscriptionExpirationDate = [self.dateFormatter dateFromString:userDictionary[@"subscriptionExpirationDate"]];
            }
            [self.dataController.currentUser setServerToken:token];
            
            [self.dataController saveMainContextWithCompletion:^(NSError *error) {
                
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                
                if (completionBlock) {
                    completionBlock(self.dataController.currentUser, nil);
                }
            }];
            
            return;
        }
        
        NSLog(@"Got a different user — shouldn't happen");
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 401:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Change Password",
                              NSLocalizedDescriptionKey : @"Please make sure you have the correct current password." };
                break;
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version of the app is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Change Password",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        if (completionBlock) {
            completionBlock(nil, localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.loginAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];
    
}

-(void) sendDisplayNameChange:(NSString*)newDisplayName withCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock {
    
    NSMutableURLRequest *urlRequest = [self.tokenBasedAPIClient changeDisplayNameRequestForUserWithToken:self.dataController.currentUser.serverToken
                                                                                   withNewDisplayName:newDisplayName];
    
    if (!urlRequest) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"There was a problem syncing your account. Please sign in again."];
        
        return;
    }
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        NSDictionary *userDictionary = responseObject;
        
        if (self.dataController.currentUser != nil && [self.dataController.currentUser.guid isEqualToString:[userDictionary objectForKey:@"_id"]]) {
            //We already have this user
            
            self.dataController.currentUser.emailAddress = [userDictionary objectForKey:@"emailAddress"];
            self.dataController.currentUser.displayName = [userDictionary objectForKey:@"displayName"];
            self.dataController.currentUser.registrationToken = [userDictionary objectForKey:@"registrationToken"];
            if (!userDictionary[@"subscriptionExpirationDate"] || userDictionary[@"subscriptionExpirationDate"] == [NSNull null]) {
                self.dataController.currentUser.subscriptionExpirationDate = nil;
            } else {
                self.dataController.currentUser.subscriptionExpirationDate = [self.dateFormatter dateFromString:userDictionary[@"subscriptionExpirationDate"]];
            }
            
            [self.dataController saveMainContextWithCompletion:^(NSError *error) {
                
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                
                if (completionBlock) {
                    completionBlock(self.dataController.currentUser, nil);
                }
            }];
            
            return;
        }
        
        NSLog(@"Got a different user — shouldn't happen");
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 401:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Change Display Name",
                              NSLocalizedDescriptionKey : @"There was a problem logging into your account. Please sign in again." };
                break;
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version of the app is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Change Display Name",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        if (completionBlock) {
            completionBlock(nil, localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.loginAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];
    
}

-(void) logoutUserWithCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completion {
    
    if (self.dataController.currentUser.serverToken && [self.dataController.currentUser usersDeviceToken]) {
        
        //Attempt to remove device token
        NSMutableURLRequest *urlRequest = [self.tokenBasedAPIClient sendLogoutRequestForUserWithToken:self.dataController.currentUser.serverToken
                                                                                      withDeviceToken:[self.dataController.currentUser usersDeviceToken]];
        
        if (!urlRequest) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
            [UIAlertView showAlertWithTitle:@"Error" andMessage:@"There was a problem syncing your account. Please sign in again."];
            
            return;
        }
        
        void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
        };
        
        void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
        };
        
        AFHTTPRequestOperation *operation = [self.loginAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                         success:successBlock
                                                                                         failure:failureBlock];
        [operation start];
    }

    [self.dataController.managedObjectContext deleteObject:self.dataController.currentUser];
    self.dataController.currentUser = nil;

    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"RDM_HAS_BOTHERED_USER_ABOUT_SUBSCRIPTION_ON_THIS_DEVICE"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.dataController saveMainContextWithCompletion:^(NSError *error) {
        
        if (completion) {
            completion(nil, nil);
        }
    
        [[NSNotificationCenter defaultCenter] postNotificationName:RDMUserDidChangeNotification object:nil];

    }];


}

-(void) sendRegistrationTokenChangeRequestWithCompletion:(RDMTeacherAccountSubmissionCompletionBlock)completionBlock {
    
    NSMutableURLRequest *urlRequest = [self.tokenBasedAPIClient sendRegistrationCodeChangeRequest:self.dataController.currentUser.serverToken];
    
    if (!urlRequest) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"There was a problem syncing your account. Please sign in again."];
        
        return;
    }
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        NSDictionary *userDictionary = responseObject;
        
        if (self.dataController.currentUser != nil && [self.dataController.currentUser.guid isEqualToString:[userDictionary objectForKey:@"_id"]]) {
            //We already have this user
            
            self.dataController.currentUser.registrationToken = [userDictionary objectForKey:@"registrationToken"];
            
            [self.dataController saveMainContextWithCompletion:^(NSError *error) {
                
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                
                if (completionBlock) {
                    completionBlock(self.dataController.currentUser, nil);
                }
            }];
            
            return;
        }
        
        NSLog(@"Got a different user — shouldn't happen");
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Change Registration Code",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        if (completionBlock) {
            completionBlock(nil, localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.tokenBasedAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];
}

-(void) sendGroupRegistrationTokenChangeRequestForGroup:(RDMGroup*)group
                                         WithCompletion:(RDMTeacherAccountGroupRegistrationCodeChangeCompletionBlock)completionBlock {
    
    NSMutableURLRequest *urlRequest = [self.tokenBasedAPIClient sendGroupRegistrationCodeChangeRequestWithToken:self.dataController.currentUser.serverToken
                                                                                               forGroupWithGUID:group.guid];
    
    if (!urlRequest) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"There was a problem syncing your account. Please sign in again."];
        
        return;
    }
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        NSDictionary *groupDictionary = responseObject;
        
        
        group.registrationToken = groupDictionary[@"registrationToken"];
            
            [self.dataController saveMainContextWithCompletion:^(NSError *error) {
                
                if (error) {
                    NSLog(@"Error: %@", error);
                    if (completionBlock) {
                        completionBlock(nil, error);
                    }
                }
                
                if (completionBlock) {
                    completionBlock(group, nil);
                }
            }];

    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 404:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Change Registration Code",
                              NSLocalizedDescriptionKey : @"Could not find this group. It may have been deleted." };
                break;
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Change Registration Code",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        if (completionBlock) {
            completionBlock(nil, localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.tokenBasedAPIClient HTTPRequestOperationWithRequest:urlRequest
                                                                                          success:successBlock
                                                                                          failure:failureBlock];
    [operation start];
    
}


@end
