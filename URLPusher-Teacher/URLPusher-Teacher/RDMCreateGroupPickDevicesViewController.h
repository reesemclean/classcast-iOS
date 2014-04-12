//
//  RDMCreateGroupPickDevicesViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/4/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDMTeacherDataController;
@class RDMGroup;
@class RDMUser;

@interface RDMCreateGroupPickDevicesViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *temporaryContext;
@property (nonatomic, strong) RDMGroup *groupInTemporaryContext;
@property (nonatomic, strong) RDMUser *userInTemporaryContext;

@end
