//
//  RDMDevicesCollectionViewCell.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSLabel;

@interface RDMDevicesCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet SSLabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *deviceTypeImage;

@end
