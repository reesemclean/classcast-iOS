//
//  RDMTeacherCreateAccountViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"

@protocol RDMTeacherCreateAccountViewControllerDelegate;

@interface RDMTeacherCreateAccountViewController : UIViewController

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@property (nonatomic, weak) id<RDMTeacherCreateAccountViewControllerDelegate> delegate;

@end

@protocol RDMTeacherCreateAccountViewControllerDelegate <NSObject>

-(void) createAccountVCDidPressCancel:(RDMTeacherCreateAccountViewController*)vc;

@end
