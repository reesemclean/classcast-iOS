//
//  RDMPageViewDataSourceAndDelegate.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/22/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMPageViewDataSourceAndDelegate.h"

#import "RDMInstructionalImageViewController.h"

@interface RDMPageViewDataSourceAndDelegate ()

@property (nonatomic, strong) UIStoryboard *storyboard;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@end

@implementation RDMPageViewDataSourceAndDelegate

-(instancetype) initWithStoryboard:(UIStoryboard*)storyboard {
    
    self = [super init];
    if (self) {
        _storyboard = storyboard;
        
        RDMInstructionalImageViewController *firstController = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMInstructionalImageViewControllerID"];
        firstController.image = [UIImage imageNamed:@"page1"];
        RDMInstructionalImageViewController *secondController = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMInstructionalImageViewControllerID"];
        secondController.image = [UIImage imageNamed:@"page2"];

        _viewControllers = @[ firstController, secondController ];
        
    }
    return self;
}

-(void) setIntialPageForPageViewController:(UIPageViewController*)pageViewController {
    self.pageViewController = pageViewController;
    [pageViewController setViewControllers:@[self.viewControllers[0]]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:nil];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(nextPage:) userInfo:nil repeats:NO];
}

-(void) nextPage:(NSTimer*)timer {
    
    UIViewController *currentViewController = [self.pageViewController viewControllers][0];
    NSUInteger index = [self.viewControllers indexOfObject:currentViewController];
    index = (index + 1) % [self.viewControllers count];
    UIViewController *nextViewController = self.viewControllers[index];
    
    __weak typeof(self) weakSelf = self;
    
    [self.pageViewController setViewControllers:@[nextViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         
                                         if (finished) {
                                             weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                                           target:weakSelf
                                                                                         selector:@selector(nextPage:) userInfo:nil repeats:NO];
                                         }
                                         
                                     }];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    index = (index + 1) % [self.viewControllers count];
    return [self.viewControllers objectAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    index = (index - 1);
    if (index < 0) {
        index = [self.viewControllers count] - 1;
    }
    return [self.viewControllers objectAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return [self.viewControllers count];
    
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    UIViewController *viewController = [pageViewController viewControllers][0];
    return [self.viewControllers indexOfObject:viewController];
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}

@end
