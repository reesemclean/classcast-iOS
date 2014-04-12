//
//  RDMSendLinkViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/31/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"
#import "UIExpandableTableView.h"

#import "RDMLink.h"

@protocol RDMSendLinkViewControllerDelegate;

#import "RDMRootViewController.h"

@class RDMTokenAuthAPIClient;

@interface RDMSendLinkViewController : UIViewController <UIExpandableTableViewDelegate, UIExpandableTableViewDatasource, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) RDMLink *link;

@property (nonatomic, weak) id<RDMSendLinkViewControllerDelegate> delegate;

@end

@protocol RDMSendLinkViewControllerDelegate <NSObject>

-(void) sendLinkViewShouldShowSubscriptionOptions:(RDMSendLinkViewController*)sendLinkVC;

@end

