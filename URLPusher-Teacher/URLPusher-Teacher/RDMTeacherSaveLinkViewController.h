//
//  RDMTeacherSaveLinkViewController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/1/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMRootViewController.h"

@class RDMLink;
@class RDMTeacherDataController;

@interface RDMTeacherSaveLinkViewController : UIViewController

@property (nonatomic, strong) RDMTeacherDataController *dataController;
@property (nonatomic, strong) RDMLink *link;

@end
