//
//  RDMSelectGroupExpandingCell.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/31/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSelectGroupExpandingCell.h"

@implementation RDMSelectGroupExpandingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLoading:(BOOL)loading {
    
}

- (void)setExpansionStyle:(UIExpansionStyle)style animated:(BOOL)animated {
    void(^animationBlock)(void) = ^(void) {
        //self.accessoryView = self.disclosureIndicatorImageView;
        switch (style) {
            case UIExpansionStyleExpanded:
                //self.accessoryView.transform = CGAffineTransformIdentity;
                break;
            case UIExpansionStyleCollapsed:
                //self.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
                break;
                
            default:
                break;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animationBlock];
    } else {
        animationBlock();
    }
}

@end
