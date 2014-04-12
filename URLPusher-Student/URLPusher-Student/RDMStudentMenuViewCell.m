//
//  RDMStudentMenuViewCell.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMStudentMenuViewCell.h"

@implementation RDMStudentMenuViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib {
    
    UIView *myBackgroundView = [[UIView alloc] init];
    myBackgroundView.frame = self.bounds;
    myBackgroundView.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = myBackgroundView;
    
}

-(void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.titleLabel.textColor = [UIColor colorWithWhite:.95 alpha:.60];
    } else {
        self.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
