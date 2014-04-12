//
//  RDMSetupDevicesActionsViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RDMSetupDevicesActionViewControllerDelegate;

@interface RDMSetupDevicesActionsViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, weak) id<RDMSetupDevicesActionViewControllerDelegate> delegate;

@end

@protocol RDMSetupDevicesActionViewControllerDelegate <NSObject>

-(void) actionViewControllerDidPressRename:(RDMSetupDevicesActionsViewController*)vc;
-(void) actionViewControllerDidPressRemove:(RDMSetupDevicesActionsViewController*)vc;

@end
