//
//  RDMSetupDevicesViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMRootViewController.h"

@class RDMTeacherDataController;

@interface RDMSetupGroupsViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@end
