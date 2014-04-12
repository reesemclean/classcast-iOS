//
//  RDMSubscriptionUpdateViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/14/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"

#import "RDMInAppPurchaseHelper.h"

@protocol RDMSubscriptionUpdateViewControllerDelegate;

@interface RDMSubscriptionUpdateViewController : UIViewController <IAPHelperDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, weak) id<RDMSubscriptionUpdateViewControllerDelegate> delegate;

@end

@protocol RDMSubscriptionUpdateViewControllerDelegate <NSObject>

-(void) subscriptionUpdateViewShouldDismiss:(RDMSubscriptionUpdateViewController*)vc;

@end