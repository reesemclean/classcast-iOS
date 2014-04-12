//
//  RDMSubscriptionViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/13/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMTeacherDataController.h"

#import "RDMInAppPurchaseHelper.h"

@protocol RDMSubscriptionViewControllerDelegate;

@interface RDMSubscriptionViewController : UIViewController <IAPHelperDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, weak) id<RDMSubscriptionViewControllerDelegate> delegate;

@end

@protocol RDMSubscriptionViewControllerDelegate <NSObject>

-(void) subscriptionViewShouldDismiss:(RDMSubscriptionViewController*)vc;
-(void) subscriptionViewDidSelectFreeSubscription:(RDMSubscriptionViewController*)vc;
-(void) subscriptionViewDidSelectPaidSubscription:(RDMSubscriptionViewController *)vc;

@end
