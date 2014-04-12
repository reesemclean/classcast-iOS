//
//  RDMLinkListURLAndNameCollectionViewCell.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/20/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSLabel;

@interface RDMLinkListURLAndNameCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet SSLabel *nameLabel;
@property (strong, nonatomic) IBOutlet SSLabel *urlLabel;
@end
