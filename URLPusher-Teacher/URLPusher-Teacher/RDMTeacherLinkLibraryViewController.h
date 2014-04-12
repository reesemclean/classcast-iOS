//
//  RDMTeacherLinkLibraryViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/1/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMRootViewController.h"

@protocol RDMLinkLibraryDelegate;

@class RDMTeacherDataController;
@class RDMLink;

@interface RDMTeacherLinkLibraryViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@property (nonatomic, weak) id<RDMLinkLibraryDelegate> delegate;

@end

