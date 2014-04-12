//
//  RDMRootViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/31/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMRootViewController.h"

#import "RDMTeacherDataController.h"

#import "RDMIntroInitialViewController.h"

#import "RDMSyncEngine.h"

#import "UIImage+ImageEffects.h"

#import "RDMNavigationWithBackgroundImageViewController.h"

#import "RDMUser.h"

#import "RDMSendLinkViewController.h"
#import "RDMTeacherAccountViewController.h"
#import "RDMTeacherMenuViewController.h"
#import "RDMSubscriptionViewController.h"
#import "RDMSubscriptionUpdateViewController.h"

#import "RDMTeacherAccountController.h"

@interface RDMRootViewController () <RDMTeacherMenuDelegate, RDMTeacherAccountViewControllerDelegate, RDMSubscriptionViewControllerDelegate, RDMSubscriptionUpdateViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@property (nonatomic, strong) UIView *signInLoginContainerView;
@property (nonatomic, strong) UIImageView *signInLoginBackgroundImageView;
@property (nonatomic, strong) UIViewController *signInLoginRootController;

@property (nonatomic, assign) BOOL showingResetViewFromLink;

@end

@implementation RDMRootViewController {
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

    self.dataController = [RDMTeacherDataController sharedInstance];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [self.view setTintColor:[UIColor whiteColor]];
    }
    
    self.showingResetViewFromLink = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBadTokenNotification:)
                                                 name:@"RDMDidReceive401WithTokenBasedAuthentication"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPasswordResetViewIfNeeded:)
                                                 name:@"RDM_SHOULD_SHOW_PASSWORD_RESET_VIEW"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didReceiveBadTokenNotification:(NSNotification*)note {
    
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            
            [self presentSignInLoginFlowAnimated:YES withResetToken:nil];
            
        }];
    } else {
        
        [self presentSignInLoginFlowAnimated:YES withResetToken:nil];

    }
    
}

-(void) showPasswordResetViewIfNeeded:(NSNotification *)note {
    
    if (self.dataController.currentUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged in User"
                                   message:@"There is already someone logged into this device. Please log out before trying to reset your password."
                                  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil];
        [alert show];
        return;
    }
    
    self.showingResetViewFromLink = YES;

    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            
            [self presentSignInLoginFlowAnimated:YES withResetToken:note.object];
            self.showingResetViewFromLink = NO;
        }];
    } else {
        [self presentSignInLoginFlowAnimated:YES withResetToken:note.object];
        self.showingResetViewFromLink = NO;
    }
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

-(void) viewDidAppear:(BOOL)animated  {
    
    [super viewDidAppear:animated];

    if (self.showingResetViewFromLink) {
        return;
    }
    
    if (!self.dataController.currentUser) {
        
        [self presentSignInLoginFlowAnimated:YES withResetToken:nil];
        return;
    }
    
}

-(void) awakeFromNib {
    
    [super awakeFromNib];
    
    RDMTeacherMenuViewController *menuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherMenuViewControllerID"];
    menuVC.dataController = [RDMTeacherDataController sharedInstance];
    menuVC.delegate = self;
    
    UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMSendLinkViewControllerID"];
    RDMSendLinkViewController *sendLinkVC = (RDMSendLinkViewController*)navVC.topViewController;
    sendLinkVC.dataController = [RDMTeacherDataController sharedInstance];
    
    self.menuViewController = menuVC;
    self.centerViewController = navVC;

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        
        RDMTeacherAccountController *accountController = [[RDMTeacherAccountController alloc] initWithDataController:self.dataController];
        [accountController logoutUserWithCompletion:^(RDMUser *user, NSError* error) {
           
            [self presentSignInLoginFlowAnimated:YES withResetToken:nil];
            
        }];
        
    }
}

-(void) viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
}

-(void) presentSignInLoginFlowAnimated:(BOOL)animated withResetToken:(NSString *)resetToken {
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.f);
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    } else {
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    RDMIntroInitialViewController *vc = (RDMIntroInitialViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMIntroInitialViewControllerID"];
    vc.dataController = self.dataController;
    vc.backgroundImage = [snapshot applyDarkEffect];
    vc.resetToken = resetToken;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:animated completion:nil];
    
}

-(void) teacherMenuShouldShowAccountVC:(UIViewController *)menuVC {
    
    [self presentAccountViewController];
    
}

-(void) presentAccountViewController {
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.f);
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    } else {
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    RDMTeacherAccountViewController *vc = (RDMTeacherAccountViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherAccountViewControllerID"];
    vc.dataController = self.dataController;
    vc.delegate = self;
    vc.backgroundImage = [snapshot applyDarkEffect];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
    
}

-(void) teacherMenuShouldShowSubscriptionUpdateVC:(UIViewController *)vc {
    [self presentSubscriptionUpdateViewAnimated:YES];
}

-(void) teacherAccountViewDidPressCancel:(RDMTeacherAccountViewController *)vc {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) teacherAccountViewDidLogOut:(RDMTeacherAccountViewController *)vc {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentSignInLoginFlowAnimated:YES withResetToken:nil];
    }];
    
}

-(void) presentSubscriptionViewAnimated:(BOOL)animated {
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.f);
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    } else {
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    RDMSubscriptionViewController *vc = (RDMSubscriptionViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMSubscriptionViewControllerID"];
    vc.dataController = self.dataController;
    vc.delegate = self;
    vc.backgroundImage = [snapshot applyDarkEffect];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
    
}

-(void) subscriptionViewDidSelectFreeSubscription:(RDMSubscriptionViewController *)vc {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void) subscriptionViewDidSelectPaidSubscription:(RDMSubscriptionViewController *)vc {
 
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void) subscriptionViewShouldDismiss:(RDMSubscriptionViewController *)vc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) presentSubscriptionUpdateViewAnimated:(BOOL)animated {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.f);
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    } else {
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    RDMSubscriptionUpdateViewController *vc = (RDMSubscriptionUpdateViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMSubscriptionUpdateViewControllerID"];
    vc.dataController = self.dataController;
    vc.delegate = self;
    vc.backgroundImage = [snapshot applyDarkEffect];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void) subscriptionUpdateViewShouldDismiss:(RDMSubscriptionUpdateViewController *)vc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
