//
//  RDMInstructionalImageViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/25/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMInstructionalImageViewController.h"

@interface RDMInstructionalImageViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation RDMInstructionalImageViewController

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
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
