//
//  RDMForgotPasswordViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMForgotPasswordViewController.h"

#import "RDMTeacherAccountController.h"

#import "RDMSyncEngine.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "UIAlertView+ErrorHelpers.h"

typedef void (^RDMAnimationCompletionBlock)(void);

@interface RDMForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *sendResetActivityView;
@property (weak, nonatomic) IBOutlet UIButton *sendResetButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *confirmChangeActivityView;
@property (weak, nonatomic) IBOutlet UIButton *confirmChangeButton;
@property (nonatomic, strong) RDMTeacherAccountController *accountController;

@property (weak, nonatomic) IBOutlet UIView *sendPasswordContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendPasswordVerticalConstraint;
@property (weak, nonatomic) IBOutlet UIView *resetPasswordContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resetPasswordVerticalConstraint;
@property (weak, nonatomic) IBOutlet UIView *forgotPasswordContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgotPasswordVerticalConstraint;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)getPasswordButtonPushed:(id)sender;
- (IBAction)changePasswordButtonPushed:(id)sender;
- (IBAction)confirmChangeButtonPushed:(id)sender;
- (IBAction)resetPasswordBackButtonPushed:(id)sender;
- (IBAction)sendPasswordResetCodeButtonPushed:(id)sender;
- (IBAction)changePasswordBackButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *resetCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation RDMForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accountController = [[RDMTeacherAccountController alloc] initWithDataController:self.dataController];

    [self animateOutForgotPasswordContainerAnimated:NO completion:nil];
    [self animateOutResetPasswordContainerAnimated:NO completion:nil];
    [self animateOutSendPasswordContainerAnimated:NO completion:nil];
    
    self.sendPasswordContainerView.layer.shadowRadius = 10.0;
    self.sendPasswordContainerView.layer.shadowOpacity = 1.0;
    self.sendPasswordContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.sendPasswordContainerView.bounds].CGPath;
    
    self.resetPasswordContainerView.layer.shadowRadius = 10.0;
    self.resetPasswordContainerView.layer.shadowOpacity = 1.0;
    self.resetPasswordContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.resetPasswordContainerView.bounds].CGPath;

    self.forgotPasswordContainerView.layer.shadowRadius = 10.0;
    self.forgotPasswordContainerView.layer.shadowOpacity = 1.0;
    self.forgotPasswordContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.forgotPasswordContainerView.bounds].CGPath;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self animateOutForgotPasswordContainerAnimated:NO completion:nil];
    [self animateOutResetPasswordContainerAnimated:NO completion:nil];
    [self animateOutSendPasswordContainerAnimated:NO completion:nil];
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.resetToken) {
        self.resetCodeTextField.text = self.resetToken;
        self.resetToken = nil;
        [self animateInResetPasswordContainerAnimated:YES completion:nil];
    } else {
        [self animateInForgotPasswordContainerAnimated:YES completion:nil];
    }
    

}

#define distanceFromTop 14.0
#define animationSpeed .25
#define springDamping 1.5
#define springVelocity 10.0

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

-(void) animateInForgotPasswordContainerAnimated:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    CGFloat constant = distanceFromTop + 20.0;
    if (!RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        constant = distanceFromTop;
    }
    
    [self.view removeConstraint:self.forgotPasswordVerticalConstraint];
    self.forgotPasswordVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.forgotPasswordContainerView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0 constant:constant];
    [self.view addConstraint:self.forgotPasswordVerticalConstraint];
    
    [self updateConstraintsAnimated:animated withCompletion:completionBlock];
}

-(void) animateOutForgotPasswordContainerAnimated:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    [self.view removeConstraint:self.forgotPasswordVerticalConstraint];
    self.forgotPasswordVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.forgotPasswordContainerView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0 constant:-40.0];
    [self.view addConstraint:self.forgotPasswordVerticalConstraint];
    
    [self updateConstraintsAnimated:animated withCompletion:completionBlock];
    
}

-(void) animateInResetPasswordContainerAnimated:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    CGFloat constant = distanceFromTop + 20.0;
    if (!RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        constant = distanceFromTop;
    }
    
    [self.view removeConstraint:self.resetPasswordVerticalConstraint];
    self.resetPasswordVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.resetPasswordContainerView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:constant];
    [self.view addConstraint:self.resetPasswordVerticalConstraint];
    
    [self updateConstraintsAnimated:animated withCompletion:completionBlock];
    
}

-(void) animateOutResetPasswordContainerAnimated:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    [self.view removeConstraint:self.resetPasswordVerticalConstraint];
    self.resetPasswordVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.resetPasswordContainerView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:-40.0];
    [self.view addConstraint:self.resetPasswordVerticalConstraint];
    
    [self updateConstraintsAnimated:animated withCompletion:completionBlock];
    
}

-(void) animateInSendPasswordContainerAnimated:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    CGFloat constant = distanceFromTop + 20.0;
    if (!RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        constant = distanceFromTop;
    }
    
    [self.view removeConstraint:self.sendPasswordVerticalConstraint];
    self.sendPasswordVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.sendPasswordContainerView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:constant];
    [self.view addConstraint:self.sendPasswordVerticalConstraint];
    
    [self updateConstraintsAnimated:animated withCompletion:completionBlock];
    
}

-(void) animateOutSendPasswordContainerAnimated:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    [self.view removeConstraint:self.sendPasswordVerticalConstraint];
    self.sendPasswordVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.sendPasswordContainerView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0 constant:-40.0];
    [self.view addConstraint:self.sendPasswordVerticalConstraint];
    
    [self updateConstraintsAnimated:animated withCompletion:completionBlock];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self animateOutForgotPasswordContainerAnimated:YES completion:^{
        
        [self.delegate forgotPasswordViewControllerDidPressCancel:self];
        
    }];
    
}

- (IBAction)getPasswordButtonPushed:(id)sender {

    [self animateOutForgotPasswordContainerAnimated:YES
                                         completion:^{
                                            [self animateInSendPasswordContainerAnimated:YES
                                                                              completion:nil];
                                         }];
    
}

- (IBAction)changePasswordButtonPushed:(id)sender {
    
    [self animateOutForgotPasswordContainerAnimated:YES completion:^{
        [self animateInResetPasswordContainerAnimated:YES completion:nil];
    }];
    
}

- (IBAction)sendPasswordResetCodeButtonPushed:(id)sender {
    
    NSString *emailAddress = self.emailAddressTextField.text;
    
    //Send Email with password reset code
    if (emailAddress.length < 1) {
        [UIAlertView showAlertWithTitle:@"Missing Email Address"
                             andMessage:@"You must enter your email address to receive your password reset code."];
        
        return;
    }
    
    emailAddress = [emailAddress lowercaseString];
    
    [SVProgressHUD showWithStatus:@"Send Password Reset" maskType:SVProgressHUDMaskTypeClear];
    
    [self.accountController sendPasswordResetRequestWithEmail:emailAddress
                                               withCompletion:^(NSError *error) {
                                                   
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
                                                   
                                                   [UIAlertView showAlertWithTitle:@"Reset Code Sent"
                                                                        andMessage:@"Your password reset code has been sent to your email address — it will expire in 2 hours. You can use this code to enter a new password.\n\nMake sure to check your spam/junk folders if you do not see it immediately."];
                                                
                                               }];
    
    
}

- (IBAction)resetPasswordBackButtonPushed:(id)sender {
    
    [self animateOutSendPasswordContainerAnimated:YES completion:^{
        [self animateInForgotPasswordContainerAnimated:YES completion:nil];
    }];
    
}

- (IBAction)confirmChangeButtonPushed:(id)sender {
    
    NSString *password = self.passwordTextField.text;
    NSString *resetCode = self.resetCodeTextField.text;
    
    //Send Email with password reset code
    if (password.length < 1) {
        
        [UIAlertView showAlertWithTitle:@"Missing Password"
                             andMessage:@"You must enter a new password in order to secure your account."];
        
        return;
        
    }
    
    if (self.resetCodeTextField.text.length < 1) {
        [UIAlertView showAlertWithTitle:@"Missing Reset Code"
                             andMessage:@"You must enter the reset password code that was sent to your email address."];
        
        return;
    }
    
    resetCode = [resetCode uppercaseString];
    
    [SVProgressHUD showWithStatus:@"Saving Password" maskType:SVProgressHUDMaskTypeClear];
    
    [self.accountController sendPasswordResetConfirmationWithCode:resetCode
                                                   andNewPassword:password
                                                   withCompletion:^(RDMUser *user, NSError *error) {
                                                       
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
                                                       

                                                        self.dataController.currentUser = user;
                                                        [[RDMSyncEngine sharedEngine] startSync];
                                                        [self.delegate forgotPasswordDidSuccessfullyReauthorize:self];
                                                       
                                                   }];
    
}

- (IBAction)changePasswordBackButtonPushed:(id)sender {

    [self animateOutResetPasswordContainerAnimated:YES
                                        completion:^{
                                            [self animateInForgotPasswordContainerAnimated:YES completion:nil];
                                        }];
    
}


@end
