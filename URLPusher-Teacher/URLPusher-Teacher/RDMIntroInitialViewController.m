//
//  RDMIntroInitialViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/5/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMIntroInitialViewController.h"

#import "RDMTeacherCreateAccountViewController.h"
#import "RDMTeacherSignInViewController.h"
#import "RDMPageViewDataSourceAndDelegate.h"

@interface RDMIntroInitialViewController ()

- (IBAction)signUpButtonPushed:(id)sender;
- (IBAction)loginButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIImageView *teacherImageView;

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIView *pageViewContainer;
@property (nonatomic, strong) RDMPageViewDataSourceAndDelegate *pageViewDataSourceAndDelegate;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *loginButtonVerticalConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *signupButtonVerticalConstraint;
@end

@implementation RDMIntroInitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.backgroundImageView.image = self.backgroundImage;

    UIImage *buttonBackground = [[UIImage imageNamed:@"buttonBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.signUpButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    
    self.pageViewDataSourceAndDelegate = [[RDMPageViewDataSourceAndDelegate alloc] initWithStoryboard:self.storyboard];
    [self.pageViewDataSourceAndDelegate setIntialPageForPageViewController:self.pageViewController];
    self.pageViewController.dataSource = self.pageViewDataSourceAndDelegate;
    self.pageViewController.delegate = self.pageViewDataSourceAndDelegate;

}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self animateOutButtonsAnimated:NO];
    [self animateOutLabelsAnimated:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.resetToken) {
        [self presentForgotPasswordViewWithResetToken:self.resetToken];
        self.resetToken = nil;
        return;
    }
    
    [self animateInButtonsAnimated:animated];
    [self animateInLabelsAnimated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PageViewControllerSegueID"]) {
        
        self.pageViewController = segue.destinationViewController;
    }
    
}

-(void) animateInLabelsAnimated:(BOOL)animated {
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
             usingSpringWithDamping:1.5
              initialSpringVelocity:2.0
                            options:0
                         animations:^{
                             self.teacherImageView.alpha = 1.0;
                             self.pageViewContainer.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.teacherImageView.alpha = 1.0;
                             self.pageViewContainer.alpha = 1.0;
                         }
                         completion:nil];
    }

}

-(void) animateOutLabelsAnimated:(BOOL)animated {
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
             usingSpringWithDamping:1.5
              initialSpringVelocity:2.0
                            options:0
                         animations:^{
                             self.teacherImageView.alpha = 0.0;
                             self.pageViewContainer.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.teacherImageView.alpha = 0.0;
                             self.pageViewContainer.alpha = 0.0;
                         }
                         completion:nil];
    }
    
}

-(void) animateInButtonsAnimated:(BOOL)animated {
    
    [self.view removeConstraint:self.loginButtonVerticalConstraint];
    self.loginButtonVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0 constant:-20];
    [self.view addConstraint:self.loginButtonVerticalConstraint];
    
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
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
        
    [self.view removeConstraint:self.signupButtonVerticalConstraint];
    
    self.signupButtonVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.signUpButton
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0 constant:-20.0];
    [self.view addConstraint:self.signupButtonVerticalConstraint];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:animated ? 0.1 : 0.0
             usingSpringWithDamping:1.5
              initialSpringVelocity:2.0
                            options:0
                         animations:^{
                             
                             [self.view layoutIfNeeded];
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:animated ? 0.1 : 0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
    
}

-(void) animateOutButtonsAnimated:(BOOL)animated {
    
    [self.view removeConstraint:self.signupButtonVerticalConstraint];
    self.signupButtonVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.signUpButton
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0 constant:0];
    [self.view addConstraint:self.signupButtonVerticalConstraint];
    
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
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
    
    [self.view removeConstraint:self.loginButtonVerticalConstraint];
    self.loginButtonVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1.0 constant:0];
    [self.view addConstraint:self.loginButtonVerticalConstraint];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:animated ? .1 : 0.0
             usingSpringWithDamping:1.5
              initialSpringVelocity:2.0
                            options:0
                         animations:^{
                             
                             [self.view layoutIfNeeded];
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:animated ? 0.1 : 0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
    
}

-(void) setBackgroundImage:(UIImage *)backgroundImage {
    
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
    
}

- (IBAction)signUpButtonPushed:(id)sender {
    
    [self presentSignUpForm];
    
}

- (IBAction)loginButtonPushed:(id)sender {

    [self presentLoginForm];
}

-(void) presentSignUpForm {
    
    [self animateOutButtonsAnimated:YES];
    [self animateOutLabelsAnimated:YES];
    
    RDMTeacherCreateAccountViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherCreateAccountViewControllerID"];
    [self addChildViewController:vc];
    self.currentViewController = vc;
    vc.delegate = self;
    vc.dataController = self.dataController;
    vc.view.frame = self.view.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
}

-(void) createAccountVCDidPressCancel:(RDMTeacherCreateAccountViewController*)vc {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self animateInButtonsAnimated:YES];
    [self animateInLabelsAnimated:YES];
    
}

-(void) presentLoginForm {
    
    [self animateOutButtonsAnimated:YES];
    [self animateOutLabelsAnimated:YES];
    
    RDMTeacherSignInViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherSignInViewControllerID"];
    [self addChildViewController:vc];
    self.currentViewController = vc;
    vc.delegate = self;
    vc.dataController = self.dataController;
    vc.view.frame = self.view.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];

    
}

-(void) signInVCDidPressCancel:(RDMTeacherSignInViewController*)vc {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self animateInButtonsAnimated:YES];
    [self animateInLabelsAnimated:YES];
    
}

-(void) signInVCDidPressForgotPassword:(RDMTeacherSignInViewController *)signInVC {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self presentForgotPasswordViewWithResetToken:self.resetToken];
    self.resetToken = nil;
    
}

-(void) presentForgotPasswordViewWithResetToken:(NSString*)resetToken {
    
    RDMForgotPasswordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMForgotPasswordViewControllerID"];
    [self addChildViewController:vc];
    self.currentViewController = vc;
    vc.delegate = self;
    vc.dataController = self.dataController;
    vc.resetToken = resetToken;
    vc.view.frame = self.view.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
}

-(void) forgotPasswordViewControllerDidPressCancel:(RDMForgotPasswordViewController *)vc {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
    
    [self presentLoginForm];
}

-(void) forgotPasswordDidSuccessfullyReauthorize:(RDMForgotPasswordViewController*)vc {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
