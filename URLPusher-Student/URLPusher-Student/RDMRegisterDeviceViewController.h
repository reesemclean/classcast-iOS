//
//  RDMRegisterDeviceViewController.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMStudentDataController.h"

@interface RDMRegisterDeviceViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) RDMStudentDataController *dataController;

@end
