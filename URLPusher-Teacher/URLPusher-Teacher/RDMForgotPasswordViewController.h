//
//  RDMForgotPasswordViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"

@protocol RDMForgotPasswordViewControllerDelegate;

@interface RDMForgotPasswordViewController : UIViewController

@property (nonatomic, strong) NSString *resetToken;
@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, weak) id<RDMForgotPasswordViewControllerDelegate> delegate;
@end

@protocol RDMForgotPasswordViewControllerDelegate <NSObject>

-(void) forgotPasswordViewControllerDidPressCancel:(RDMForgotPasswordViewController*)vc;
-(void) forgotPasswordDidSuccessfullyReauthorize:(RDMForgotPasswordViewController*)vc;

@end
