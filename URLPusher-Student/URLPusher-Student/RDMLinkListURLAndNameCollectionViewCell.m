//
//  RDMLinkListURLAndNameCollectionViewCell.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/20/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMLinkListURLAndNameCollectionViewCell.h"

#import "SSLabel.h"

@implementation RDMLinkListURLAndNameCollectionViewCell

-(void) awakeFromNib {
    
    [super awakeFromNib];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.contentView)) {
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0];
    }
    
    self.urlLabel.verticalTextAlignment = SSLabelVerticalTextAlignmentTop;
    self.nameLabel.verticalTextAlignment = SSLabelVerticalTextAlignmentTop;
    
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
