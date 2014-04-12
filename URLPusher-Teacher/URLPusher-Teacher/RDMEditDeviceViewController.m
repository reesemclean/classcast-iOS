//
//  RDMEditDeviceViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMEditDeviceViewController.h"

#import "RDMTeacherDataController.h"
#import "RDMDevice.h"

#import "RDMSyncEngine.h"

@interface RDMEditDeviceViewController ()

@property (nonatomic, strong) NSManagedObjectContext *temporaryContext;
@property (nonatomic, strong) RDMDevice *deviceInTemporaryContext;

- (IBAction)cancelButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *currentNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *editedNameTextField;
- (IBAction)newNameTextFieldDidChange:(id)sender;

@end

@implementation RDMEditDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.editedNameTextField.tintColor = [UIColor blackColor];
    }
    
    self.currentNameLabel.text = self.deviceToEdit.name;
    
    self.temporaryContext = [self.dataController createTemporaryContext];

    NSError *error = nil;
    self.deviceInTemporaryContext = (RDMDevice*)[self.temporaryContext existingObjectWithID:self.deviceToEdit.objectID
                                                                                        error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }

    [self adjustSaveButton];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.editedNameTextField becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.editedNameTextField resignFirstResponder];
}

-(void) showKeyboard {
    
    //Hack because I'm not using containment methods, adding directly to navigation view
    [self.editedNameTextField becomeFirstResponder];
    
}

-(UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (IBAction)cancelButtonPushed:(id)sender {
    [self.delegate editDeviceViewControllerDidPressCancel:self];
}

- (IBAction)saveButtonPushed:(id)sender {

    [self.dataController saveTemporaryContextAndPushToMainContext:self.temporaryContext
                                                   withCompletion:^(NSError* error) {
                                                       
                                                       [self.delegate editDeviceViewControllerDidPressSave:self];
                                                       [[RDMSyncEngine sharedEngine] startSync];
                                                       
                                                   }];

    
}

- (IBAction)newNameTextFieldDidChange:(id)sender {
    
    self.deviceInTemporaryContext.name = self.editedNameTextField.text;
    self.deviceInTemporaryContext.syncStatus = @1;
    [self adjustSaveButton];
    
}

-(void) adjustSaveButton {
    
    if (self.editedNameTextField.text.length > 0 && ![self.editedNameTextField.text isEqualToString:self.currentNameLabel.text]) {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}

@end
