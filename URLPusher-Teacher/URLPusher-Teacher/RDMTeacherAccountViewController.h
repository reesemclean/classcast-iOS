//
//  RDMTeacherAccountViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/12/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"

#import "RDMTeacherEditDisplayNameViewController.h"
#import "RDMTeacherChangePasswordViewController.h"
#import "RDMSubscriptionUpdateViewController.h"

@protocol RDMTeacherAccountViewControllerDelegate;

@interface RDMTeacherAccountViewController : UIViewController <RDMTeacherEditDisplayNameDelegate, RDMTeacherChangePasswordDelegate, UIAlertViewDelegate, RDMSubscriptionUpdateViewControllerDelegate>

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) RDMTeacherDataController *dataController;

@property (nonatomic, strong) id<RDMTeacherAccountViewControllerDelegate> delegate;

@end

@protocol RDMTeacherAccountViewControllerDelegate <NSObject>

-(void) teacherAccountViewDidPressCancel:(RDMTeacherAccountViewController*)vc;
-(void) teacherAccountViewDidLogOut:(RDMTeacherAccountViewController*)vc;

@end
