//
//  RDMTeacherLinkLibraryCell.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSLabel;

@interface RDMTeacherLinkLibraryURLAndNameCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet SSLabel *nameLabel;
@property (weak, nonatomic) IBOutlet SSLabel *urlLabel;
@end
