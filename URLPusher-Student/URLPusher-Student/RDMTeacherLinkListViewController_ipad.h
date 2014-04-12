//
//  RDMTeacherLinkListViewController_ipad.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/10/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDMStudentDataController;
@class RDMTeacher;

@interface RDMTeacherLinkListViewController_ipad : UIViewController <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) RDMTeacher *teacher;
@property (nonatomic, strong) RDMStudentDataController *dataController;

@end
