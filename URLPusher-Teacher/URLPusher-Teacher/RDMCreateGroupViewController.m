//
//  RDMCreateGroupViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/4/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMCreateGroupViewController.h"

#import "RDMCreateGroupPickDevicesViewController.h"

#import "RDMTeacherDataController.h"
#import "RDMGroup.h"
#import "RDMUser.h"

@interface RDMCreateGroupViewController ()

@property (nonatomic, strong) NSManagedObjectContext *temporaryContext;
@property (nonatomic, strong) RDMGroup *groupInTemporaryContext;
@property (nonatomic, strong) RDMUser *userInTemporaryContext;

- (IBAction)cancelButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
- (IBAction)groupNameTextFieldDidChange:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
- (IBAction)nextButtonPressed:(id)sender;

@end

@implementation RDMCreateGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Create Group";
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    self.temporaryContext = [self.dataController createTemporaryContext];
    
    self.groupInTemporaryContext = [NSEntityDescription insertNewObjectForEntityForName:@"RDMGroup"
                                                    inManagedObjectContext:self.temporaryContext];
    
    NSError *error = nil;
    self.userInTemporaryContext = (RDMUser*)[self.temporaryContext existingObjectWithID:self.dataController.currentUser.objectID
                                                                                        error:&error];
    if (error) {
        NSLog(@"Could Not Find User: %@", error);
    }    
    
    self.groupInTemporaryContext.user = self.userInTemporaryContext;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPushed:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)groupNameTextFieldDidChange:(id)sender {
    
    self.groupInTemporaryContext.name = self.groupNameTextField.text;
    
    if (self.groupNameTextField.text.length > 0) {
        self.nextButton.hidden = NO;
    } else {
        self.nextButton.hidden = YES;
    }
    
}

- (IBAction)nextButtonPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"ChooseDevicesSegueID"
                              sender:nil];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ChooseDevicesSegueID"]) {
        
        RDMCreateGroupPickDevicesViewController *vc = (RDMCreateGroupPickDevicesViewController*)[segue destinationViewController];
        vc.dataController = self.dataController;
        vc.temporaryContext = self.temporaryContext;
        vc.groupInTemporaryContext = self.groupInTemporaryContext;
        vc.userInTemporaryContext = self.userInTemporaryContext;
        
    }
    
}

@end
