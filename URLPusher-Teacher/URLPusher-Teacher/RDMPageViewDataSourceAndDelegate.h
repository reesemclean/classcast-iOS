//
//  RDMPageViewDataSourceAndDelegate.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/22/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDMPageViewDataSourceAndDelegate : NSObject <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

-(instancetype) initWithStoryboard:(UIStoryboard*)storyboard;
-(void) setIntialPageForPageViewController:(UIPageViewController*)pageViewController;

@end
