//
//  RDMStudentRootViewController.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMStudentRootViewController.h"

#import "RDMStudentDataController.h"

#import "RDMRegisterDeviceViewController.h"
#import "RDMStudentMenuViewController.h"
#import "RDMStudentSyncEngine.h"
#import "RDMStudentDataProcessor.h"
#import "RDMStudentLink.h"

#import "UIImage+ImageEffects.h"

#import "RDMOpenLinkHandler.h"

#import "RDMLinkRecievedNotificationViewController.h"

@interface RDMStudentRootViewController () <RDMLinkReceivedNotificationViewControllerDelegate>

@property (nonatomic, strong) RDMStudentDataController *dataController;
@property (nonatomic, strong) id pushNotificationProcessedObserver;

@property (nonatomic, strong) UIView *notificationViewContainer;
@property (nonatomic, strong) RDMLinkRecievedNotificationViewController *notificationViewController;
@property (nonatomic, strong) RDMStudentLink *linkNotificationIsShowFor;
@property (nonatomic, assign) BOOL showingNotificationView;
@end

@implementation RDMStudentRootViewController {
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showingNotificationView = NO;
    
	// Do any additional setup after loading the view.
    self.dataController = [RDMStudentDataController sharedInstance];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view))
    {
        // method exists
        [self.view setTintColor:[UIColor whiteColor]];

    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.pushNotificationProcessedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMDidProcessPushNotificationPayload
                                                                                               object:nil
                                                                                                queue:nil
                                                                                           usingBlock:^(NSNotification *note) {
                                                                                               
                                                                                               BOOL showImmediately = [note.userInfo[@"showImmediately"] boolValue];
                                                                                               RDMStudentLink *link = note.userInfo[@"link"];
                                                                                               
                                                                                               if (showImmediately) {
                                                                                                   NSLog(@"Show Immediately");
                                                                                                   [RDMOpenLinkHandler openLink:link];
                                                                                                   
                                                                                               } else {
                                                                                                   
                                                                                                   [self showLinkReceivedNotificationForLink:link];
                                                                                               }
                                                                                               
                                                                                           }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.pushNotificationProcessedObserver];
}

-(void) awakeFromNib {
    
    [super awakeFromNib];

    RDMStudentMenuViewController *menuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMStudentMenuViewControllerID"];
    menuVC.dataController = [RDMStudentDataController sharedInstance];
    
    UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMRegisterDeviceViewControllerID"];
    RDMRegisterDeviceViewController *registerDeviceVC = (RDMRegisterDeviceViewController*)navVC.topViewController;
    registerDeviceVC.dataController = [RDMStudentDataController sharedInstance];
    
    self.menuViewController = menuVC;
    self.centerViewController = navVC;
    
}

-(void) viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];

}

#define notificationHeight 131.0
#define notificationWidthIpad 480.0

-(void) showLinkReceivedNotificationForLink:(RDMStudentLink*)link {
    
    self.linkNotificationIsShowFor = link;
    
    if (!self.notificationViewContainer) {
        
        CGFloat widthToShow = CGRectGetWidth(self.view.bounds);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            widthToShow = notificationWidthIpad;
        }
        
        CGFloat heightToShow = notificationHeight;
        if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
            //For Status Bar
            heightToShow += 20.0;
        }
        
        CGFloat xValue = CGRectGetWidth(self.view.bounds)/2.0 - widthToShow/2.0;
        self.notificationViewContainer = [[UIView alloc] initWithFrame:CGRectMake(xValue, -heightToShow, widthToShow, heightToShow)];
        self.notificationViewContainer.backgroundColor = [UIColor clearColor];
        UIBezierPath* newShadowPath = [UIBezierPath bezierPathWithRect:self.notificationViewContainer.bounds];
        self.notificationViewContainer.layer.masksToBounds = NO;
        self.notificationViewContainer.layer.shadowRadius = 2.0;
        self.notificationViewContainer.layer.shadowOpacity = 0.75;
        self.notificationViewContainer.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.notificationViewContainer.layer.shadowOffset = CGSizeZero;
        self.notificationViewContainer.layer.shadowPath = [newShadowPath CGPath];
        self.notificationViewContainer.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.view addSubview:self.notificationViewContainer];
        
        RDMLinkRecievedNotificationViewController *vc = (RDMLinkRecievedNotificationViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMLinkRecievedNotificationViewControllerID"];
        self.notificationViewController = vc;
        self.notificationViewController.delegate = self;
        [self addChildViewController:vc];
        vc.view.frame = self.notificationViewContainer.bounds;
        [self.notificationViewContainer addSubview:vc.view];
    }
    
    [UIView animateWithDuration:.33
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.notificationViewContainer.frame = CGRectMake(CGRectGetMinX(self.notificationViewContainer.frame), 0, CGRectGetWidth(self.notificationViewContainer.bounds), CGRectGetHeight(self.notificationViewContainer.bounds));
                     }
                     completion:^(BOOL finished) {
                         [self.notificationViewController didMoveToParentViewController:self];
                     }];
    
}

-(void) linkReceivedViewDidPressDismiss:(RDMLinkRecievedNotificationViewController *)vc {
    
    self.linkNotificationIsShowFor = nil;
    [self.notificationViewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:.33
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        
                         self.notificationViewContainer.frame = CGRectMake(CGRectGetMinX(self.notificationViewContainer.frame), -CGRectGetHeight(self.notificationViewContainer.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.notificationViewContainer.bounds));
                         
                     }
                     completion:^(BOOL finished) {
                         
                         if (finished) {
                             [self.notificationViewController removeFromParentViewController];
                             [self.notificationViewContainer removeFromSuperview];
                             self.notificationViewContainer = nil;
                             self.notificationViewController = nil;
                         }
                         
                     }];
    
}

-(void) linkReceivedViewDidPressVisit:(RDMLinkRecievedNotificationViewController *)vc {
    
    self.showingNotificationView = NO;
    [RDMOpenLinkHandler openLink:self.linkNotificationIsShowFor];
    self.linkNotificationIsShowFor = nil;
    [self.notificationViewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:.33
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.notificationViewContainer.frame = CGRectMake(CGRectGetMinX(self.notificationViewContainer.frame), -CGRectGetHeight(self.notificationViewContainer.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.notificationViewContainer.bounds));
                         
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.notificationViewController removeFromParentViewController];
                             [self.notificationViewContainer removeFromSuperview];
                             self.notificationViewContainer = nil;
                             self.notificationViewController = nil;
                         }
                     }];
    
}

@end
