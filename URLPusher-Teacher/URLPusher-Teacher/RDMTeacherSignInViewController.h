//
//  RDMTeacherSignInViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"

@protocol RDMTeacherSignInViewControllerDelegate;

@interface RDMTeacherSignInViewController : UIViewController

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@property (nonatomic, weak) id<RDMTeacherSignInViewControllerDelegate> delegate;

@end

@protocol RDMTeacherSignInViewControllerDelegate <NSObject>

-(void) signInVCDidPressCancel:(RDMTeacherSignInViewController*)vc;
-(void) signInVCDidPressForgotPassword:(RDMTeacherSignInViewController *)vc;
@end
