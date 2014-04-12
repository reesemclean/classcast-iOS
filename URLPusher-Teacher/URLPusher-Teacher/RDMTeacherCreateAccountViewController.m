//
//  RDMTeacherCreateAccountViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherCreateAccountViewController.h"

#import "RDMTeacherAccountController.h"

#import "RDMTeacherCreateAccountViewController.h"

#import "RDMSyncEngine.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "UIAlertView+ErrorHelpers.h"

typedef void (^RDMAnimationCompletionBlock)(void);

@interface RDMTeacherCreateAccountViewController ()

@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalContainerConstraint;
@property (nonatomic, strong) RDMTeacherAccountController *accountController;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
- (IBAction)createAccountButtonPushed:(id)sender;
- (IBAction)cancelButtonPushed:(id)sender;
@end

@implementation RDMTeacherCreateAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self animateOutContainerAnimated:NO completion:nil];

    self.accountController = [[RDMTeacherAccountController alloc] initWithDataController:self.dataController];
    
    self.containerView.layer.shadowRadius = 10.0;
    self.containerView.layer.shadowOpacity = 1.0;
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.emailAddressTextField becomeFirstResponder];
    [self animateInContainerAnimated:YES];
}

-(void) animateOutContainerAnimated:(BOOL)animated completion:(RDMAnimationCompletionBlock)completionBlock {
    
    [self.view removeConstraint:self.verticalContainerConstraint];
    self.verticalContainerConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1.0 constant:-40.0];
    [self.view addConstraint:self.verticalContainerConstraint];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
             usingSpringWithDamping:1.5
              initialSpringVelocity:2.0
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
        [UIView animateWithDuration:animated ? .25 : 0.0
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

-(void) animateInContainerAnimated:(BOOL)animated {
    
    CGFloat constant = 34.0;
    if (!RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        constant = 14.0;
    }
    
    [self.view removeConstraint:self.verticalContainerConstraint];
    self.verticalContainerConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0 constant:constant];
    [self.view addConstraint:self.verticalContainerConstraint];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
             usingSpringWithDamping:1.5
              initialSpringVelocity:10.0
                            options:0
                         animations:^{
                             
                             [self.view layoutIfNeeded];
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        [UIView animateWithDuration:.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
    
}

- (IBAction)createAccountButtonPushed:(id)sender {

    NSString *emailAddress = self.emailAddressTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *displayName = self.displayNameTextField.text;
    
    if (emailAddress.length < 1) {
        [UIAlertView showAlertWithTitle:@"Missing Email Address"
                             andMessage:@"Please enter an email address in order to create your account."];
        return;
    }
    
    if (password.length < 1) {
        [UIAlertView showAlertWithTitle:@"Missing Password"
                             andMessage:@"Please enter a password to secure your account."];
        return;
    }
    
    emailAddress = [emailAddress lowercaseString];
    
    [SVProgressHUD showWithStatus:@"Creating Account"
                         maskType:SVProgressHUDMaskTypeClear];
    
    [self.accountController attemptToCreateUserWithEmail:emailAddress
                                             andPassword:password
                                          andDisplayName:displayName
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
                                              
                                              if (user) {
                                                  NSLog(@"Logged In!");
                                                  self.dataController.currentUser = user;
                                                  [[RDMSyncEngine sharedEngine] startSync];
                                                  [self dismissViewControllerAnimated:YES
                                                                           completion:nil];
                                              }
                                              
                                          }];
    
}

- (IBAction)cancelButtonPushed:(id)sender {
    
    [self animateOutContainerAnimated:YES completion:^{
       
        [self.delegate createAccountVCDidPressCancel:self];
        
    }];
    
}

@end
