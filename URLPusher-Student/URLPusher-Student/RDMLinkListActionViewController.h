//
//  RDMLinkListActionViewController.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/20/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RDMLinkListActionViewDelegate;

@interface RDMLinkListActionViewController : UIViewController

@property (nonatomic, weak) id<RDMLinkListActionViewDelegate> delegate;

@end

@protocol RDMLinkListActionViewDelegate <NSObject>

-(void) didSelectVisitInActionViewController:(RDMLinkListActionViewController *)vc;
-(void) didSelectCancelInActionViewController:(RDMLinkListActionViewController *)vc;

@end
