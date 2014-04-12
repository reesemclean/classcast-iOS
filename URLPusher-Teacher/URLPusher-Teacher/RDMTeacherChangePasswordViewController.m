//
//  RDMTeacherChangePasswordViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/12/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherChangePasswordViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import "RDMTeacherAccountController.h"

#import "UIAlertView+ErrorHelpers.h"

typedef void (^RDMAnimationCompletionBlock)(void);

@interface RDMTeacherChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
- (IBAction)backButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
- (IBAction)saveButtonPushed:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) RDMTeacherAccountController *accountController;

@end

@implementation RDMTeacherChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.accountController = [[RDMTeacherAccountController alloc] initWithDataController:self.dataController];
    
    [self animateOutContainer:NO completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self animateInContainer:YES completion:nil];
}

- (IBAction)backButtonPushed:(id)sender {
    
    [self animateOutContainer:YES
                   completion:^{
                       [self.delegate teacherChangePasswordDidPressCancel:self];
                   }];
    
}

- (IBAction)saveButtonPushed:(id)sender {
    
    NSString *currentPassword = self.currentPasswordTextField.text;
    NSString *newPassword = self.passwordTextField.text;
    NSString *newPasswordConfirmation = self.confirmPasswordTextField.text;
    
    if (currentPassword.length < 1) {
        [UIAlertView showAlertWithTitle:@"Missing Current Password"
                             andMessage:@"You must enter your current password to authorize the password change."];
        return;
    }
    
    if (newPassword.length < 1) {
        [UIAlertView showAlertWithTitle:@"Missing New Password"
                             andMessage:@"You must enter a new password in order to secure your account."];
        return;
    }
    
    if (![newPasswordConfirmation isEqualToString:newPassword]) {
        [UIAlertView showAlertWithTitle:@"Mismatched New Password"
                             andMessage:@"The new password and password confirmation do not match."];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Changing Password"
                         maskType:SVProgressHUDMaskTypeClear];
    
    [self.accountController sendPasswordChangeWithEmail:self.dataController.currentUser.emailAddress
                                         andOldPassword:currentPassword
                                         andNewPassword:newPassword
                                          andCompletion:^(RDMUser *user, NSError *error ) {
                                              
                                              [SVProgressHUD dismiss];
                                              
                                              if (error) {
                                                  NSDictionary *userInfo = error.userInfo;
                                                  
                                                  NSString *title = userInfo[@"RDMErrorTitleKey"];
                                                  if (!title) {
                                                      title = @"Error";
                                                  }
                                                  
                                                  [UIAlertView showAlertWithTitle:title
                                                                       andMessage:userInfo[NSLocalizedDescriptionKey]];
                                                  return;
                                              }
                                              
                                              [self animateOutContainer:YES
                                                             completion:^{
                                                                 [self.delegate teacherChangePasswordDidChangePassword:self];
                                                             }];
                                              
                                          }];
    
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
