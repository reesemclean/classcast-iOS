//
//  RDMLinkLibraryActionViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RDMLinkLibraryActionViewControllerDelegate;

@interface RDMLinkLibraryActionViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, weak) id<RDMLinkLibraryActionViewControllerDelegate> delegate;

@end

@protocol RDMLinkLibraryActionViewControllerDelegate <NSObject>

-(void) actionViewControllerDidPressSend:(RDMLinkLibraryActionViewController*)vc;
-(void) actionViewControllerDidPressEdit:(RDMLinkLibraryActionViewController*)vc;
-(void) actionViewControllerDidPressDelete:(RDMLinkLibraryActionViewController*)vc;

@end