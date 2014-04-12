//
//  RDMDevicesCollectionViewCell.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMDevicesCollectionViewCell.h"

#import "SSLabel.h"

@implementation RDMDevicesCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib {
    if (RDM_IS_IOS7_BASED_ON_VIEW(self)) {
        self.tintColor = [UIColor blackColor];
    }

    self.deviceNameLabel.verticalTextAlignment = SSLabelVerticalTextAlignmentTop;
    
    
    UIImage *image = [UIImage imageNamed:@"cellBackground"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)];
    self.backgroundView = [[UIImageView alloc] initWithImage:image];
    
    UIImage *selectedImage = [UIImage imageNamed:@"cellBackgroundSelected"];
    selectedImage = [selectedImage resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedImage];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
