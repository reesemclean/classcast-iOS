//
//  RDMTeacherMenuViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/30/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RDMTeacherMenuDelegate;

@class RDMTeacherDataController;

@interface RDMTeacherMenuViewController : UIViewController 

@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, weak) id<RDMTeacherMenuDelegate> delegate;

@end

@protocol RDMTeacherMenuDelegate <NSObject>

-(void) teacherMenuShouldShowAccountVC:(UIViewController*)vc;
-(void) teacherMenuShouldShowSubscriptionUpdateVC:(UIViewController*)vc;

@end