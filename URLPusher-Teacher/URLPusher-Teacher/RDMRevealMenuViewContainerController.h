//
//  RDMRevealMenuViewContainerController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/30/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RDMRevealMenuViewControllerBlock) (UIViewController *controller);

extern NSString * const RDMRevealMenuPanDidStartNofification;
extern NSString * const RDMRevealMenuAlwaysShowMenuDidChangeNotification;

@protocol RDMRevealMenuContainerDelegate;

@interface RDMRevealMenuViewContainerController : UIViewController

-(void) openMenuViewControllerAnimated:(BOOL)animated withCompletion:(RDMRevealMenuViewControllerBlock)completion;
-(void) closeMenuViewControllerAnimated:(BOOL)animated withCompletion:(RDMRevealMenuViewControllerBlock)completion;
-(void) replaceCenterViewControllerAnimated:(BOOL)animated
                   withCenterViewController:(UIViewController*)newCenterViewController
                             withCompletion:(RDMRevealMenuViewControllerBlock)completion;

+ (UIImage *)defaultImage;

@property (nonatomic, assign) CGFloat menuWidth;

@property (nonatomic, strong) UIViewController *menuViewController;
@property (nonatomic, strong) UIViewController *centerViewController;

@property (nonatomic, readonly) BOOL menuShouldAlwaysShow;

@end

@protocol RDMRevealMenuContainerDelegate <NSObject>
@optional

-(void) revealMenuViewControllerdidBeginPan:(RDMRevealMenuViewContainerController*)vc;

@end

@interface UIViewController (RDMViewDeckItem)
@property(nonatomic,readonly,retain) RDMRevealMenuViewContainerController *rdm_rootViewController;

@end