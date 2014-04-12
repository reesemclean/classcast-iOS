//
//  RDMTeacherEditDisplayNameViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/12/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"

@protocol RDMTeacherEditDisplayNameDelegate;

@interface RDMTeacherEditDisplayNameViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@property (nonatomic, weak) id<RDMTeacherEditDisplayNameDelegate> delegate;

@end

@protocol RDMTeacherEditDisplayNameDelegate <NSObject>

-(void) teacherEditDisplayNameDidPressCancel:(RDMTeacherEditDisplayNameViewController*)vc;
-(void) teacherEditDisplayNameDidChangeDisplayName:(RDMTeacherEditDisplayNameViewController*)vc;
@end