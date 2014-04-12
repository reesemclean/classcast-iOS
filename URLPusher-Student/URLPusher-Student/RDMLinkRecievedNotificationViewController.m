//
//  RDMLinkRecievedNotificationViewController.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/21/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMLinkRecievedNotificationViewController.h"

@interface RDMLinkRecievedNotificationViewController ()

@property (strong, nonatomic) IBOutlet UIButton *visitLinkButton;
- (IBAction)visitLinkButtonPushed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
- (IBAction)dismissButtonPushed:(id)sender;
@end

@implementation RDMLinkRecievedNotificationViewController

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
    
    UIImage *buttonBackground = [[UIImage imageNamed:@"buttonBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.visitLinkButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [self.dismissButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)visitLinkButtonPushed:(id)sender {
    [self.delegate linkReceivedViewDidPressVisit:self];
}
- (IBAction)dismissButtonPushed:(id)sender {
    [self.delegate linkReceivedViewDidPressDismiss:self];
}
@end
