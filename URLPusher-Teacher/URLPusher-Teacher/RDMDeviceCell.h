//
//  RDMDeviceCell.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDMDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *renameButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDevicesLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@end
