//
//  RDMSetupDevicesViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMRootViewController.h"

#import "RDMEditDeviceViewController.h"

@class RDMTeacherDataController;

@interface RDMSetupDevicesViewController : UIViewController < NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, RDMEditDeviceViewControllerDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@end
