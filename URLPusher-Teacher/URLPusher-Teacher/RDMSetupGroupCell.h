//
//  RDMSetupGroupCell.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/4/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSLabel;

@interface RDMSetupGroupCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet SSLabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDevicesLabel;
@end
