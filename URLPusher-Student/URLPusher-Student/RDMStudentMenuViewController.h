//
//  RDMStudentMenuViewController.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMStudentRootViewController.h"

@class RDMStudentDataController;

@interface RDMStudentMenuViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RDMStudentDataController *dataController;

@end
