//
//  RDMEditGroupViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/4/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMRootViewController.h"

@class RDMGroup;
@class RDMTeacherDataController;

@interface RDMEditGroupViewController_iPad : UIViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) RDMGroup *groupToEdit;
@property (nonatomic, strong) RDMTeacherDataController *dataController;

@end
