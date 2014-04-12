//
//  RDMRegisterDeviceViewController.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMRegisterDeviceViewController.h"

#import "RDMRegistrationController.h"
#import "RDMStudentDataController.h"
#import "RDMStudentSyncEngine.h"

#import "RDMStudentRootViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface RDMRegisterDeviceViewController ()

@property (nonatomic, strong) RDMRegistrationController *registrationController;

- (IBAction)registrationCodeTextFieldDidChange:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *registrationCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;
- (IBAction)deviceNameTextFieldDidChange:(id)sender;
- (IBAction)registerButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@end

@implementation RDMRegisterDeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.registrationController = [[RDMRegistrationController alloc] initWithDataController:self.dataController];

    self.title = @"Add Teacher";
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    UIImage *image = [RDMStudentRootViewController defaultImage];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(menuBarButtonItemPushed:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    UIImage *buttonBackground = [[UIImage imageNamed:@"storeButtonBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.registerButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleViewDeckPanNotification:)
                                                 name:RDMRevealMenuPanDidStartNofification
                                               object:self.rdm_rootViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidChangeAlwaysShowMenuNotification:)
                                                 name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDMRevealMenuPanDidStartNofification object:self.rdm_rootViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self adjustLeftBarButtonItemAnimated:NO];
}

-(void) menuBarButtonItemPushed:(id) sender {
    
    [self.deviceNameTextField resignFirstResponder];
    [self.registrationCodeTextField resignFirstResponder];
    
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES withCompletion:nil];
    
}

-(void) handleDidChangeAlwaysShowMenuNotification:(NSNotification*)note {
    
    [self adjustLeftBarButtonItemAnimated:YES];
    
}

-(void) adjustLeftBarButtonItemAnimated:(BOOL)animated {
    
    if ([self.rdm_rootViewController menuShouldAlwaysShow]) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    } else {
        UIImage *image = [RDMStudentRootViewController defaultImage];
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(menuBarButtonItemPushed:)];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:YES];
    }
    
}

#pragma mark - Text Field Delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - View Deck Delegate

-(void) handleViewDeckPanNotification:(NSNotification*)note {
    
    [self.deviceNameTextField resignFirstResponder];
    [self.registrationCodeTextField resignFirstResponder];
    
}

- (IBAction)deviceNameTextFieldDidChange:(id)sender {
}

- (IBAction)registrationCodeTextFieldDidChange:(id)sender {
    
    
}

- (IBAction)registerButtonPushed:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Setting Up"];
    
    [self.registrationController attemptToRegisterDevice:self.dataController.device
                                        withProposedName:self.deviceNameTextField.text
                                    withRegistrationCode:self.registrationCodeTextField.text
                                          withSuccess:^(BOOL shouldResync) {
                                              
                                              [SVProgressHUD showSuccessWithStatus:@"All Done!"];
                                              
                                              if (shouldResync) {
                                                  [[RDMStudentSyncEngine sharedEngine] startFullResync];
                                              } else {
                                                  [[RDMStudentSyncEngine sharedEngine] startSync];
                                              }
                                                                                            
                                                }
                                              andFailure:^(NSError* error) {
                                            
                                                  [SVProgressHUD dismiss];

                                              }];
    
}



@end
