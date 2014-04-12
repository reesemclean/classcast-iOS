//
//  RDMNavigationWithBackgroundImageViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/11/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMNavigationWithBackgroundImageViewController.h"

@interface RDMNavigationWithBackgroundImageViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation RDMNavigationWithBackgroundImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    imageView.image = self.backgroundImage;
    self.backgroundImageView = imageView;
    [self.view insertSubview:imageView atIndex:0];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setBackgroundImage:(UIImage *)backgroundImage {
    
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
    
}

@end
