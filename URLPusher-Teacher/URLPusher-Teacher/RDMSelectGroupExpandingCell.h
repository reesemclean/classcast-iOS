//
//  RDMSelectGroupExpandingCell.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/31/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIExpandableTableView.h"

@interface RDMSelectGroupExpandingCell : UITableViewCell <UIExpandingTableViewCell>

@property (weak, nonatomic) IBOutlet UIImageView *isSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;

@end
