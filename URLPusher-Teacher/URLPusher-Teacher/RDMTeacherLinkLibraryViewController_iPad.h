//
//  RDMTeacherLinkLibraryViewController-iPad.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDMLinkLibraryActionViewController.h"

@protocol RDMLinkLibraryDelegate;

@class RDMTeacherDataController;
@class RDMLink;

@interface RDMTeacherLinkLibraryViewController_iPad : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, RDMLinkLibraryActionViewControllerDelegate>

@property (nonatomic, strong) RDMTeacherDataController *dataController;

@property (nonatomic, weak) id<RDMLinkLibraryDelegate> delegate;

@end
