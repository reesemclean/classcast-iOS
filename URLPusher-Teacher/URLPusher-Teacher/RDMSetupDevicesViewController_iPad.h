//
//  RDMSetupDevicesViewController_iPad.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMRootViewController.h"

#import "RDMSetupDevicesActionsViewController.h"
#import "RDMEditDeviceViewController.h"

@class RDMTeacherDataController;

@interface RDMSetupDevicesViewController_iPad : UIViewController < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, RDMSetupDevicesActionViewControllerDelegate, RDMEditDeviceViewControllerDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@end
