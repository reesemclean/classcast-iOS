//
//  RDMSetupGroupsViewController_iPad.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/4/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMRootViewController.h"

@class RDMTeacherDataController;

@interface RDMSetupGroupsViewController_iPad : UIViewController <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@end
