//
//  RDMSetupDevicesActionsViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSetupDevicesActionsViewController.h"

@interface RDMSetupDevicesActionsViewController ()
- (IBAction)renameButtonPushed:(id)sender;

- (IBAction)removeButtonPushed:(id)sender;
@end

@implementation RDMSetupDevicesActionsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)renameButtonPushed:(id)sender {
    [self.delegate actionViewControllerDidPressRename:self];
}

- (IBAction)removeButtonPushed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm Removal"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Remove Device"
                                                    otherButtonTitles:nil];

    [actionSheet showInView:self.view];
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        [self.delegate actionViewControllerDidPressRemove:self];
    }
    
}

@end
