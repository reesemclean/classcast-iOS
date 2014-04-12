//
//  RDMRegistrationController.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/10/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMRegistrationController.h"

#import "RDMStudentDataController.h"
#import "RDMAPIClient.h"

#import "RDMStudentDevice.h"
#import "RDMStudentDevice+Custom.h"

#import <AFNetworking/AFNetworking.h>

@interface RDMRegistrationController ()

@property (nonatomic, strong) RDMStudentDataController *dataController;
@property (nonatomic, strong) RDMAPIClient *apiClient;

@end

@implementation RDMRegistrationController

-(instancetype) initWithDataController:(RDMStudentDataController*)dataController {
    
    self = [super init];
    if (self) {
        _dataController = dataController;
        _apiClient = [RDMAPIClient sharedClient];
        
    }
    return self;
    
}

-(void) attemptToRegisterDevice:(RDMStudentDevice *) device
               withProposedName:(NSString*) proposedName
           withRegistrationCode:(NSString*)registrationCode
                    withSuccess:(RDMDeviceRegistrationSubmissionSuccessCompletionBlock)success
                     andFailure:(RDMDeviceRegistrationSubmissionFailureCompletionBlock)failure {
    
    NSMutableURLRequest *urlRequest = [self.apiClient sendRegistrationCodeRequestWithRegistrationCode:registrationCode
                                                                                        andDeviceName:proposedName
                                                                                       andDeviceToken:[device deviceToken]
                                                                                              andGUID:[device guid]];
                                       
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        BOOL shouldResync = (operation.response.statusCode == 200);
        
        NSLog(@"Response Object: %@", responseObject);
        if (success) {
            success(shouldResync);
        }
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 401:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Find this Device",
                              NSLocalizedDescriptionKey : @"There was a problem finding information about this device." };
                break;
            case 404:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Find Registration Code",
                              NSLocalizedDescriptionKey : @"There was a problem finding this registration code. Double check that you have typed it correctly and try again." };
                break;
            case 409:
                userInfo = @{ @"RDMErrorTitleKey": @"Already Setup",
                              NSLocalizedDescriptionKey : @"You have already used this registration code. You should be ready to go!" };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Could Not Setup",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. Please try again." };
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];

        
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(localError);
        }
        
    };
    
    AFHTTPRequestOperation *operation = [self.apiClient HTTPRequestOperationWithRequest:urlRequest
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    [operation start];

    
}

@end
