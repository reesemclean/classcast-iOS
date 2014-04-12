//
//  RDMLinkLibraryActionViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMLinkLibraryActionViewController.h"

@interface RDMLinkLibraryActionViewController ()

- (IBAction)sendButtonPushed:(id)sender;
- (IBAction)editButtonPushed:(id)sender;
- (IBAction)deleteButtonPushed:(id)sender;
@end

@implementation RDMLinkLibraryActionViewController

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

- (IBAction)sendButtonPushed:(id)sender {
    
    [self.delegate actionViewControllerDidPressSend:self];
    
}

- (IBAction)editButtonPushed:(id)sender {
    [self.delegate actionViewControllerDidPressEdit:self];
}

- (IBAction)deleteButtonPushed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm Delete"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Link"
                                                    otherButtonTitles:nil];
    
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        [self.delegate actionViewControllerDidPressDelete:self];
    }
    
}

@end
