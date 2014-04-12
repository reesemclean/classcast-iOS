//
//  RDMLinkRecievedNotificationViewController.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/21/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RDMLinkReceivedNotificationViewControllerDelegate;

@interface RDMLinkRecievedNotificationViewController : UIViewController

@property (nonatomic, weak) id<RDMLinkReceivedNotificationViewControllerDelegate> delegate;

@end

@protocol RDMLinkReceivedNotificationViewControllerDelegate <NSObject>

-(void) linkReceivedViewDidPressDismiss:(RDMLinkRecievedNotificationViewController*)vc;
-(void) linkReceivedViewDidPressVisit:(RDMLinkRecievedNotificationViewController*)vc;

@end
