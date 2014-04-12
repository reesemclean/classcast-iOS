//
//  RDMSubscriptionUpdateViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/14/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSubscriptionUpdateViewController.h"

#import "UIAlertView+ErrorHelpers.h"

#import "RDMSyncEngine.h"
#import "RDMTeacherDataController.h"
#import "RDMUser.h"
#import "RDMUser+Custom.h"

typedef void (^RDMAnimationCompletionBlock)(void);

@interface RDMSubscriptionUpdateViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *oneYearSubscriptionButton;
- (IBAction)oneYearSubscriptionButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *oneMonthSubscriptionButton;
- (IBAction)oneMonthSubscriptionButtonPushed:(id)sender;

- (IBAction)backButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *accountStatusLabel;

@property (nonatomic, strong) id syncCompleteObserver;

@end

@implementation RDMSubscriptionUpdateViewController{
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.image = self.backgroundImage;
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    UIImage *buttonBackground = [[UIImage imageNamed:@"storeButtonBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.oneYearSubscriptionButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [self.oneMonthSubscriptionButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    
    self.containerView.layer.shadowRadius = 10.0;
    self.containerView.layer.shadowOpacity = 1.0;
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
    
    self.oneMonthSubscriptionButton.hidden = YES;
    self.oneYearSubscriptionButton.hidden = YES;
    [self reload];
    
    [self updateAccountStatus];
    
    self.syncCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMSyncEngineDidFinishNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification * note) {
                                                                                  
                                                                                  [self updateAccountStatus];
                                                                                  
                                                                              }];
    
    [self animateOutContainer:NO completion:nil];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.syncCompleteObserver];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self animateInContainer:YES completion:nil];
}

-(void) updateAccountStatus {
    
    RDMUser *user = [[RDMTeacherDataController sharedInstance] currentUser];
    
    if (!user) {
        self.accountStatusLabel.text = @"Not Logged In";
    }
    
    self.accountStatusLabel.text = [user subscriptionTimeLeftString];
    
}

- (void)reload {
    _products = nil;
    [[RDMInAppPurchaseHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            NSLog(@"Products: %@", products);
            
            [self.oneYearSubscriptionButton setHidden:NO];
            [self.oneMonthSubscriptionButton setHidden:NO];
            
            _products = products;
            
            [products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
                
                if ([product.productIdentifier isEqualToString:IAPHelperProductKeyOneMonthSubscription]) {
                    [_priceFormatter setLocale:product.priceLocale];
                    [self.oneMonthSubscriptionButton setTitle:[NSString stringWithFormat:@"%@ for 1 Month", [_priceFormatter stringFromNumber:product.price]]
                                                     forState:UIControlStateNormal];
                } else if ([product.productIdentifier isEqualToString:IAPHelperProductKeyOneYearSubscription]) {
                    [_priceFormatter setLocale:product.priceLocale];
                    [self.oneYearSubscriptionButton setTitle:[NSString stringWithFormat:@"%@ for 1 Year", [_priceFormatter stringFromNumber:product.price]]
                                                    forState:UIControlStateNormal];
                }
                
            }];
            
        }
    }];
}

- (IBAction)oneYearSubscriptionButtonPushed:(id)sender {
    
    __block SKProduct *foundProduct = nil;
    [_products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
        
        if ([product.productIdentifier isEqualToString:IAPHelperProductKeyOneYearSubscription]) {
            foundProduct = product;
            *stop = YES;
        }
        
    }];
    
    if (foundProduct) {
        [[RDMInAppPurchaseHelper sharedInstance] setDelegate:self];
        [[RDMInAppPurchaseHelper sharedInstance] buyProduct:foundProduct];
    } else {
        NSLog(@"No Product Found");
    }
    
}

- (IBAction)oneMonthSubscriptionButtonPushed:(id)sender {
    
    __block SKProduct *foundProduct = nil;
    [_products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
        
        if ([product.productIdentifier isEqualToString:IAPHelperProductKeyOneMonthSubscription]) {
            foundProduct = product;
            *stop = YES;
        }
        
    }];
    
    if (foundProduct) {
        [[RDMInAppPurchaseHelper sharedInstance] setDelegate:self];
        [[RDMInAppPurchaseHelper sharedInstance] buyProduct:foundProduct];
    } else {
        NSLog(@"No Product Found");
    }
    
}

- (IBAction)backButtonPushed:(id)sender {
    
    [self animateOutContainer:YES completion:^{
       
        [self.delegate subscriptionUpdateViewShouldDismiss:self];
        
    }];
    
}

#pragma In App Purchase Delegate

-(void) didFinishSubscriptionTransaction:(IAPHelper*)helper {
    
    [[RDMInAppPurchaseHelper sharedInstance] setDelegate:nil];
        
    [self updateAccountStatus];
    
    [self backButtonPushed:nil];
    
}

-(void) couldNotCompleteSubscriptionTransactionWithError:(NSError*)error {
    
    NSDictionary *userInfo = error.userInfo;
    
    NSString *title = userInfo[@"RDMErrorTitleKey"];
    if (!title) {
        title = @"Error";
    }
    
    [UIAlertView showAlertWithTitle:title
                         andMessage:userInfo[NSLocalizedDescriptionKey]];
    
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
