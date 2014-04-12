//
//  RDMTeacherChangePasswordViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/12/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"

@protocol RDMTeacherChangePasswordDelegate;

@interface RDMTeacherChangePasswordViewController : UIViewController

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@property (nonatomic, weak) id<RDMTeacherChangePasswordDelegate> delegate;

@end

@protocol RDMTeacherChangePasswordDelegate <NSObject>

-(void) teacherChangePasswordDidPressCancel:(RDMTeacherChangePasswordViewController*)vc;
-(void) teacherChangePasswordDidChangePassword:(RDMTeacherChangePasswordViewController*)vc;

@end