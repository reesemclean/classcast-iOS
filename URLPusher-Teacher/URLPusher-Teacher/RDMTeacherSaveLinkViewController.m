//
//  RDMTeacherSaveLinkViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/1/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherSaveLinkViewController.h"

#import "RDMTeacherDataController.h"
#import "RDMLink.h"

#import "RDMRootViewController.h"

#import "RDMSyncEngine.h"

@interface RDMTeacherSaveLinkViewController ()

@property (nonatomic, strong) NSString *incomingURL;
@property (nonatomic, strong) NSString *incomingName;

@property (weak, nonatomic) IBOutlet UITextField *linkURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *linkNameTextField;

- (IBAction)saveButtonPushed:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)linkURLTextFieldDidChange:(id)sender;
- (IBAction)linkNameTextFieldDidChange:(id)sender;

@end

@implementation RDMTeacherSaveLinkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.link) {
        self.incomingURL = self.link.url;
        self.incomingName = self.link.name;
        
        self.linkURLTextField.text = self.link.url;
        self.linkNameTextField.text = self.link.name;
        
    }
    
    [self adjustLeftBarButtonItemAnimated:NO];
    [self adjustSaveButton];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    self.title = @"Save Link";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleViewDeckPanNotification:)
                                                 name:RDMRevealMenuPanDidStartNofification
                                               object:self.rdm_rootViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidChangeAlwaysShowMenuNotification:)
                                                 name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];

}



-(void) handleDidChangeAlwaysShowMenuNotification:(NSNotification*)note {
    
    
    
    [self adjustLeftBarButtonItemAnimated:YES];
    
}

-(void) adjustLeftBarButtonItemAnimated:(BOOL)animated {
    
    if ([self.rdm_rootViewController menuShouldAlwaysShow]) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    } else {
        UIImage *image = [RDMRootViewController defaultImage];
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(menuBarButtonItemPushed:)];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDMRevealMenuPanDidStartNofification object:self.rdm_rootViewController];
}

-(void) menuBarButtonItemPushed:(id) sender {
    
    [self.linkURLTextField resignFirstResponder];
    [self.linkNameTextField resignFirstResponder];
    
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES
                                                 withCompletion:nil];
    
}

#pragma mark - TextField Delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - View Deck Delegate

-(void) handleViewDeckPanNotification:(NSNotification*)note {
    
    [self.linkURLTextField resignFirstResponder];
    [self.linkNameTextField resignFirstResponder];
}

-(void) adjustSaveButton {
    
    if (self.linkURLTextField.text.length < 1 || (self.link && [self.incomingURL isEqualToString:self.linkURLTextField.text] && [self.incomingName isEqualToString:self.linkNameTextField.text]) ) {
        
        self.navigationItem.rightBarButtonItem = nil;
        
    } else {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    
}

- (IBAction)saveButtonPushed:(id)sender {
    
    if (!self.link || self.link.isDeleted || self.link.managedObjectContext == nil) {
        self.link = [NSEntityDescription insertNewObjectForEntityForName:@"RDMLink"
                                                  inManagedObjectContext:self.dataController.managedObjectContext];
    }
    
    self.link.url = self.linkURLTextField.text;
    self.link.name = self.linkNameTextField.text;
    self.link.user = self.dataController.currentUser;
    self.link.dateUpdatedOnDevice = [NSDate date];
    self.link.savedByUser = @YES;
    self.link.syncStatus = @1;
    
    [self.dataController saveMainContextWithCompletion:^(NSError* error) {
    
        self.link = nil;
        self.linkNameTextField.text = @"";
        self.linkURLTextField.text = @"";
        
        [[RDMSyncEngine sharedEngine] startSync];
        
    }];

                       
}

- (IBAction)linkURLTextFieldDidChange:(id)sender {
    
    [self adjustSaveButton];
    
}

- (IBAction)linkNameTextFieldDidChange:(id)sender {

    [self adjustSaveButton];

}


@end
