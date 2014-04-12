//
//  RDMMenuViewCellCell.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/30/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMMenuViewCell.h"

@implementation RDMMenuViewCell

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
    myBackgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.0];
    
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
