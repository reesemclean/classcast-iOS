//
//  RDMTeacherAccountViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/12/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherAccountViewController.h"

#import "RDMUser.h"
#import "RDMTeacherAccountController.h"
#import "RDMSubscriptionUpdateViewController.h"

typedef void (^RDMAnimationCompletionBlock)(void);

@interface RDMTeacherAccountViewController ()

@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, strong) RDMTeacherAccountController *accountController;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
- (IBAction)cancelButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
- (IBAction)editButtonPushed:(id)sender;
- (IBAction)changePasswordButtonPushed:(id)sender;
- (IBAction)logoutButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *subscriptionButton;
- (IBAction)subscriptionButtonPushed:(id)sender;
@end

@implementation RDMTeacherAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.accountController = [[RDMTeacherAccountController alloc] initWithDataController:self.dataController];
    self.backgroundImageView.image = self.backgroundImage;

    [self updateLabels];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self animateOutContainer:NO completion:nil];

}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self animateInContainer:YES completion:nil];
}

-(void) updateLabels {
    
    self.emailAddressLabel.text = self.dataController.currentUser.emailAddress;
    self.displayNameLabel.text = self.dataController.currentUser.displayName;
    
}

- (IBAction)cancelButtonPushed:(id)sender {
    
    [self animateOutContainer:YES completion:^{
        [self.delegate teacherAccountViewDidPressCancel:self];
    }];
    
}

-(void) teacherEditDisplayNameDidPressCancel:(RDMTeacherEditDisplayNameViewController *)vc {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self animateInContainer:YES completion:nil];
    
    [self updateLabels];
}

-(void) teacherEditDisplayNameDidChangeDisplayName:(RDMTeacherEditDisplayNameViewController *)vc {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self animateInContainer:YES completion:nil];
    
    [self updateLabels];

}

-(void) teacherChangePasswordDidPressCancel:(RDMTeacherChangePasswordViewController *)vc {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self animateInContainer:YES completion:nil];
    
    [self updateLabels];
}

-(void) teacherChangePasswordDidChangePassword:(RDMTeacherChangePasswordViewController *)vc {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self animateInContainer:YES completion:nil];
    
    [self updateLabels];
    
}

- (IBAction)editButtonPushed:(id)sender {
    
    RDMTeacherEditDisplayNameViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherEditDisplayNameViewControllerID"];
    [self addChildViewController:vc];
    self.currentViewController = vc;
    vc.delegate = self;
    vc.dataController = self.dataController;
    vc.view.frame = self.view.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;

    
    [self animateOutContainer:YES completion:^{
        
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }];

    
}

- (IBAction)changePasswordButtonPushed:(id)sender {
    
    RDMTeacherChangePasswordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherChangePasswordViewControllerID"];
    [self addChildViewController:vc];
    self.currentViewController = vc;
    vc.delegate = self;
    vc.dataController = self.dataController;
    vc.view.frame = self.view.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self animateOutContainer:YES completion:^{
        
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }];
    
}

- (IBAction)logoutButtonPushed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout?"
                                                    message:@"Do you really want to logout?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Logout", nil];
    [alert show];
    
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.accountController logoutUserWithCompletion:^(RDMUser *user, NSError *error) {
            
            if (error) {
                NSLog(@"Error: %@", error);
            }
            
            [self animateOutContainer:YES completion:^{
                [self.delegate teacherAccountViewDidPressCancel:self];
            }];
            
        }];
    }
    
}

- (IBAction)subscriptionButtonPushed:(id)sender {

    RDMSubscriptionUpdateViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMSubscriptionUpdateViewControllerID"];
    [self addChildViewController:vc];
    self.currentViewController = vc;
    vc.delegate = self;
    vc.dataController = self.dataController;
    vc.view.frame = self.view.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self animateOutContainer:YES completion:^{
        
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }];
    
}

-(void) subscriptionUpdateViewShouldDismiss:(RDMSubscriptionUpdateViewController *)vc {

    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self animateInContainer:YES completion:nil];
    
    [self updateLabels];
    
}

#define distanceFromTop 14.0
#define animationSpeed .25
#define springDamping 1.5
#define springVelocity 10.0

-(void) animateInContainer:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    CGFloat constant = distanceFromTop + 20.0;
    if (!RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        constant = distanceFromTop;
    }
    
    [self.view removeConstraint:self.verticalLayoutConstraint];
    self.verticalLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:constant];
    [self.view addConstraint:self.verticalLayoutConstraint];
    
    [self updateConstraintsAnimated:animated withCompletion:completionBlock];
}

-(void) animateOutContainer:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    [self.view removeConstraint:self.verticalLayoutConstraint];
    self.verticalLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:-40.0];
    [self.view addConstraint:self.verticalLayoutConstraint];
    
    [self updateConstraintsAnimated:animated withCompletion:completionBlock];
    
}

-(void) updateConstraintsAnimated:(BOOL) animated withCompletion:(RDMAnimationCompletionBlock)completionBlock {
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [UIView animateWithDuration:animated ? animationSpeed : 0.0
                              delay:0.0
             usingSpringWithDamping:springDamping
              initialSpringVelocity:springVelocity
                            options:0
                         animations:^{
                             
                             [self.view layoutIfNeeded];
                             
                         }
                         completion:^(BOOL finished) {
                             
                             if (completionBlock) {
                                 completionBlock();
                             }
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? animationSpeed : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             
                             if (completionBlock) {
                                 completionBlock();
                             }
                             
                         }];
    }
    
}

@end
