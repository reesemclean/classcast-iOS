//
//  RDMLinkListURLAndNameTableViewCell.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/20/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDMLinkListURLAndNameTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *visitLinkButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *linkLabel;
@end
