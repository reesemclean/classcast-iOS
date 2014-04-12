//
//  RDMRevealMenuViewContainerController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/30/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMRevealMenuViewContainerController.h"

#import <objc/runtime.h>

NSString * const RDMRevealMenuPanDidStartNofification = @"RDMRevealMenuPanDidStartNofification";
NSString * const RDMRevealMenuAlwaysShowMenuDidChangeNotification = @"RDMRevealMenuAlwaysShowMenuDidChangeNotification";

@interface RDMRevealMenuViewContainerController ()

@property (nonatomic, strong) UIView *menuViewContainer;
@property (nonatomic, strong) UIView *centerViewContainer;

@property (nonatomic, strong) NSLayoutConstraint *centerViewsLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *centerViewsWidthConstraint;

@property (nonatomic, assign) BOOL menuShowing;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation RDMRevealMenuViewContainerController

-(void) awakeFromNib {
    [super awakeFromNib];
    self.menuShowing = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.menuWidth = 240.0;
    } else {
        self.menuWidth = 280.0;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.menuViewContainer];
    
    if (self.menuViewController) {
        [self addChildViewController:self.menuViewController];
        self.menuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.menuViewController.view];
        [self.menuViewController didMoveToParentViewController:self];
    }
    
    [self setupCenterView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupCenterView {
    
    self.centerViewContainer = [[UIView alloc] init];
    self.centerViewContainer.autoresizingMask = UIViewAutoresizingNone;
    self.centerViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.centerViewContainer];
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[centerView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{ @"centerView" : self.centerViewContainer}];
    [self.view addConstraints:verticalLayoutConstraints];
    
    if (self.centerViewController) {
        [self addChildViewController:self.centerViewController];
        [self.centerViewController.view setFrame:self.centerViewContainer.bounds];
        self.centerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.centerViewContainer addSubview:self.centerViewController.view];
        [self.centerViewController didMoveToParentViewController:self];
        self.menuShowing = YES;
    }
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.centerViewContainer addGestureRecognizer:self.panGesture];
}

-(void) applyShadowToView:(UIView*)view {
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.centerViewContainer.bounds].CGPath;
    view.layer.masksToBounds = NO;
    view.layer.shadowRadius = 2.0;
    view.layer.shadowOpacity = 0.75;
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeZero;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self applyShadowToView:self.centerViewContainer];

}

-(void) viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    [self applyShadowToView:self.centerViewContainer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self];
    
    [self adjustTapperView];
}

-(void) updateViewConstraints {
    
    [super updateViewConstraints];
    
    [self.view removeConstraint:self.centerViewsLeftConstraint];
    [self.view removeConstraint:self.centerViewsWidthConstraint];

    if (self.menuShouldAlwaysShow) {
        
        self.menuShowing = YES;
        self.centerViewsLeftConstraint = [NSLayoutConstraint constraintWithItem:self.centerViewContainer
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.menuViewContainer
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0 constant:self.menuWidth];
        [self.view addConstraint:self.centerViewsLeftConstraint];
        
        self.centerViewsWidthConstraint = [NSLayoutConstraint constraintWithItem:self.centerViewContainer
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.menuViewContainer
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0 constant:-self.menuWidth];
        [self.view addConstraint:self.centerViewsWidthConstraint];
        
    } else {
        
        self.centerViewsLeftConstraint = [NSLayoutConstraint constraintWithItem:self.centerViewContainer
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.menuViewContainer
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0 constant:self.menuShowing ? self.menuWidth : 0.0];
        [self.view addConstraint:self.centerViewsLeftConstraint];
        
        self.centerViewsWidthConstraint = [NSLayoutConstraint constraintWithItem:self.centerViewContainer
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.menuViewContainer
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0 constant:0.0];
        [self.view addConstraint:self.centerViewsWidthConstraint];

    }
    
}

-(BOOL) menuShouldAlwaysShow {
    return CGRectGetWidth(self.menuViewContainer.bounds) > 768.0;
}

-(void) adjustTapperView {
    
    if (self.menuShouldAlwaysShow) {
        [self.centerViewContainer removeGestureRecognizer:self.tapGesture];
        self.tapGesture = nil;
        self.centerViewController.view.userInteractionEnabled = YES;
        return;
    }
    
    if (self.menuShowing) {
        if (self.tapGesture) {
            return;
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.centerViewContainer addGestureRecognizer:self.tapGesture];
        self.centerViewController.view.userInteractionEnabled = NO;
    } else {
        
        [self.centerViewContainer removeGestureRecognizer:self.tapGesture];
        self.tapGesture = nil;
        self.centerViewController.view.userInteractionEnabled = YES;

    }
    
    
    
}

-(void) handleTap:(UITapGestureRecognizer*)tapGesture {
    
    [self.centerViewContainer removeGestureRecognizer:self.tapGesture];
    self.tapGesture = nil;
    [self closeMenuViewControllerAnimated:YES withCompletion:nil];
    
}

static const UIViewAnimationOptions DefaultSwipedAnimationCurve = UIViewAnimationOptionCurveEaseOut;

static NSTimeInterval durationToAnimate(CGFloat pointsToAnimate, CGFloat velocity)
{
    NSTimeInterval animationDuration = pointsToAnimate / fabsf(velocity);
    // adjust duration for easing curve, if necessary
    if (DefaultSwipedAnimationCurve != UIViewAnimationOptionCurveLinear) animationDuration *= 1.25;
    return animationDuration;
}

-(void) didPan:(UIPanGestureRecognizer*)panGesture {
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RDMRevealMenuPanDidStartNofification object:self];
        
    }
    
    UIView *viewToMove = [panGesture view];
    CGPoint proposedTranslation = [panGesture translationInView:[viewToMove superview]];
    CGPoint velocity = [panGesture velocityInView:[viewToMove superview]];
    [panGesture setTranslation:CGPointZero inView:[viewToMove superview]];
    
    CGFloat proposedNewConstant = self.centerViewsLeftConstraint.constant + proposedTranslation.x;
    
    CGFloat actualTranslation = proposedTranslation.x;
    if (proposedNewConstant > self.menuWidth || proposedNewConstant < 0) {
        
        CGFloat distanceFromBoundary;
       //Need to adjust the translation so it feels elastic
        if (proposedNewConstant > self.menuWidth) {
            distanceFromBoundary = proposedNewConstant - self.menuWidth;
        } else {
            distanceFromBoundary = -proposedNewConstant;
        }
        
        CGFloat amountToAdjustTranslation = (20/(distanceFromBoundary));
        amountToAdjustTranslation = MIN(amountToAdjustTranslation, 1.0);
        actualTranslation = amountToAdjustTranslation * proposedTranslation.x;
    }
    
    self.centerViewsLeftConstraint.constant = self.centerViewsLeftConstraint.constant + actualTranslation;
    [self.view setNeedsLayout];
    
    if (panGesture.state == UIGestureRecognizerStateEnded ||
        panGesture.state == UIGestureRecognizerStateFailed ||
        panGesture.state == UIGestureRecognizerStateCancelled) {
        //Check if should open of close menu
        
        if (self.menuShouldAlwaysShow) {
            [self openMenuViewControllerAnimated:YES withCompletion:nil];
            return;
        }
        
        //Close if constant is 2/3 of the way to the edge
        //OR
        //Open if velocity is higher than 500
        //Close if velocity is lower than -500
        
        if (ABS(velocity.x) < 500) {
            CGFloat boundary = self.menuWidth * 2.0/3.0;
            
            if (self.centerViewsLeftConstraint.constant < boundary) {
                [self closeMenuViewControllerAnimated:YES
                                       withCompletion:nil];
            } else {
                [self openMenuViewControllerAnimated:YES withCompletion:nil];
            }
            
        } else {
            
            //Check direction
            if (velocity.x < 0) {
                //Swipe left
                CGFloat pointsToAnimate = self.centerViewsLeftConstraint.constant;
                NSTimeInterval animationDuration = fabsf(durationToAnimate(pointsToAnimate, velocity.x));
                
                [self closeMenuViewControllerAnimated:YES
                                         withDuration:animationDuration
                                       withCompletion:nil];
            } else {
                //Swipe right
                CGFloat pointsToAnimate = self.menuWidth - self.centerViewsLeftConstraint.constant;
                NSTimeInterval animationDuration = fabsf(durationToAnimate(pointsToAnimate, velocity.x));
                [self openMenuViewControllerAnimated:YES withDuration:animationDuration withCompletion:nil];
            }
            
        }

    }
}

-(void) openMenuViewControllerAnimated:(BOOL)animated withCompletion:(RDMRevealMenuViewControllerBlock)completion {
    [self openMenuViewControllerAnimated:animated withDuration:animated ? .25 : 0.0 withCompletion:completion];
}

-(void) openMenuViewControllerAnimated:(BOOL)animated withDuration:(NSTimeInterval)duration withCompletion:(RDMRevealMenuViewControllerBlock)completion {
    
    [self.view removeConstraint:self.centerViewsLeftConstraint];
        
    self.centerViewsLeftConstraint = [NSLayoutConstraint constraintWithItem:self.centerViewContainer
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.menuViewContainer
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0 constant:self.menuWidth];
    [self.view addConstraint:self.centerViewsLeftConstraint];
    
    if ([UIView respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
        [UIView animateWithDuration:animated ? duration : 0.0
                              delay:0.0
             usingSpringWithDamping:50.0
              initialSpringVelocity:50.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             self.menuShowing = YES;
                             [self adjustTapperView];
                             
                             if (completion) {
                                 completion(self.centerViewController);
                             }
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? duration : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             self.menuShowing = YES;
                             
                             [self adjustTapperView];
                             
                             if (completion) {
                                 completion(self.centerViewController);
                             }
                             
                         }];
    }
    
}

-(void) closeMenuViewControllerAnimated:(BOOL)animated withCompletion:(RDMRevealMenuViewControllerBlock)completion {
    
    [self closeMenuViewControllerAnimated:animated withDuration:animated ? .25 : 0 withCompletion:completion];
    
}

-(void) closeMenuViewControllerAnimated:(BOOL)animated withDuration:(NSTimeInterval)duration withCompletion:(RDMRevealMenuViewControllerBlock)completion {
    
    if (self.menuShouldAlwaysShow) {
        [self openMenuViewControllerAnimated:YES withCompletion:nil];
        return;
    }
    
    [self.view removeConstraint:self.centerViewsLeftConstraint];
    
    self.centerViewsLeftConstraint = [NSLayoutConstraint constraintWithItem:self.centerViewContainer
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.menuViewContainer
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0.0];
    [self.view addConstraint:self.centerViewsLeftConstraint];
    
    if ([UIView respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
        [UIView animateWithDuration:animated ? duration : 0.0
                              delay:0.0
             usingSpringWithDamping:50.0
              initialSpringVelocity:50.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             self.menuShowing = NO;
                             
                             [self adjustTapperView];
                             
                             if (completion) {
                                 completion(self.centerViewController);
                             }
                             
                         }];
    } else {
        [UIView animateWithDuration:animated ? duration : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             
                             self.menuShowing = NO;
                             
                             [self adjustTapperView];
                             
                             if (completion) {
                                 completion(self.centerViewController);
                             }
                             
                         }];
    }
    
}

-(void) replaceCenterViewControllerAnimated:(BOOL)animated
                   withCenterViewController:(UIViewController*)newCenterViewController
                             withCompletion:(RDMRevealMenuViewControllerBlock)completion {
    
    UIViewController *oldViewController = self.centerViewController;
    UIViewController *newViewController = newCenterViewController;
    
    [oldViewController willMoveToParentViewController:nil];
    [self addChildViewController:newViewController];
    
    [self.view removeConstraint:self.centerViewsLeftConstraint];
    self.centerViewsLeftConstraint = [NSLayoutConstraint constraintWithItem:self.centerViewContainer
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.menuViewContainer
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:0.0];
    [self.view addConstraint:self.centerViewsLeftConstraint];
    
    void(^firstAnimation)(void) = ^{
        [self.view layoutIfNeeded];
    };
    
    void(^afterFirstAnimation)(BOOL) = ^(BOOL finished){
        
        [oldViewController.view removeFromSuperview];
        [oldViewController removeFromParentViewController];
        
        [newViewController.view setFrame:self.centerViewContainer.bounds];
        newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.centerViewContainer addSubview:newViewController.view];
        [newViewController didMoveToParentViewController:self];
        self.centerViewController = newViewController;
        
        [self closeMenuViewControllerAnimated:YES withCompletion:^(UIViewController *controller) {
           
            if (completion) {
                completion(newViewController);
            }
            
        }];
        
    };
    
    if ([UIView respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
             usingSpringWithDamping:50.0
              initialSpringVelocity:50.0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:firstAnimation
                         completion:afterFirstAnimation];
    } else {
        [UIView animateWithDuration:animated ? .25 : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:firstAnimation
                         completion:afterFirstAnimation];
    }
}

+ (UIImage *)defaultImage {
	static UIImage *defaultImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 13.f), NO, 0.0f);
		
		[[UIColor blackColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 5, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 10, 20, 1)] fill];
		
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 1, 20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 6,  20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 11, 20, 2)] fill];
		
		defaultImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
	});
    return defaultImage;
}

@end

@implementation UIViewController (RDMViewDeckItem)

- (RDMRevealMenuViewContainerController*)rdm_rootViewController {
    
    if ([self.parentViewController isKindOfClass:[RDMRevealMenuViewContainerController class]]) {
        return (RDMRevealMenuViewContainerController*)self.parentViewController;
    } else {
        return [self.parentViewController rdm_rootViewController];
    }
}

@end
