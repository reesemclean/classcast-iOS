//
//  RDMIntroInitialViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"
#import "RDMTeacherCreateAccountViewController.h"
#import "RDMTeacherSignInViewController.h"
#import "RDMForgotPasswordViewController.h"

@interface RDMIntroInitialViewController : UIViewController <RDMTeacherCreateAccountViewControllerDelegate, RDMTeacherSignInViewControllerDelegate, RDMForgotPasswordViewControllerDelegate>

@property (nonatomic, strong) NSString *resetToken;
@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) UIImage *backgroundImage;

@end
