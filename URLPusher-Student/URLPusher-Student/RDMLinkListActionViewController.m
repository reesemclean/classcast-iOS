//
//  RDMLinkListActionViewController.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/20/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMLinkListActionViewController.h"

@interface RDMLinkListActionViewController ()

- (IBAction)visitButtonPushed:(id)sender;
- (IBAction)cancelButtonPushed:(id)sender;
@end

@implementation RDMLinkListActionViewController

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

- (IBAction)visitButtonPushed:(id)sender {
    [self.delegate didSelectVisitInActionViewController:self];
}

- (IBAction)cancelButtonPushed:(id)sender {
    [self.delegate didSelectCancelInActionViewController:self];
}
@end
