//
//  RDMEditDeviceViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDMDevice;
@class RDMTeacherDataController;

@protocol RDMEditDeviceViewControllerDelegate;

@interface RDMEditDeviceViewController : UIViewController <UIBarPositioningDelegate>

-(void) showKeyboard;

@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) RDMDevice *deviceToEdit;

@property (nonatomic, weak) id<RDMEditDeviceViewControllerDelegate> delegate;

@end

@protocol RDMEditDeviceViewControllerDelegate <NSObject>

-(void) editDeviceViewControllerDidPressCancel:(RDMEditDeviceViewController*)vc;
-(void) editDeviceViewControllerDidPressSave:(RDMEditDeviceViewController*)vc;

@end
