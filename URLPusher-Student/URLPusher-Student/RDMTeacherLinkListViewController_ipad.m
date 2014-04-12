//
//  RDMTeacherLinkListViewController_ipad.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/10/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherLinkListViewController_ipad.h"

#import "RDMStudentRootViewController.h"

#import "RDMStudentDataController.h"

#import "RDMTeacher.h"
#import "RDMStudentLink.h"

#import "RDMLinkListURLAndNameCollectionViewCell.h"
#import "RDMLinkListURLOnlyCollectionViewCell.h"

#import "SSLabel.h"
#import "RDMLinkListActionViewController.h"
#import "RDMOpenLinkHandler.h"
#import "RDMStudentSyncEngine.h"

@interface RDMTeacherLinkListViewController_ipad () <RDMLinkListActionViewDelegate>

@property (nonatomic, strong) NSFetchedResultsController *linksFetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) RDMStudentLink *linkActionSheetShownFor;
@property (nonatomic, strong) UIPopoverController *actionPopoverController;

@property (nonatomic, strong) id syncCompleteObserver;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)refreshButtonPushed:(id)sender;
@property (nonatomic, strong) UIBarButtonItem *activityIndicatorBarButtonItem;

@end

@implementation RDMTeacherLinkListViewController_ipad {
    
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"%@'s Link List", self.teacher.displayName];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    UIImage *image = [RDMStudentRootViewController defaultImage];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(menuBarButtonItemPushed:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidChangeAlwaysShowMenuNotification:)
                                                 name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];
    self.syncCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMSyncEngineDidFinishNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification * note) {
                                                                                  
                                                                                  self.navigationItem.rightBarButtonItem = self.refreshButton;
                                                                                  self.activityIndicatorBarButtonItem = nil;
                                                                                  
                                                                              }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self.syncCompleteObserver];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self adjustLeftBarButtonItemAnimated:NO];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void) menuBarButtonItemPushed:(id) sender {
    
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES withCompletion:nil];
    
}

-(void) handleDidChangeAlwaysShowMenuNotification:(NSNotification*)note {
    
    [self adjustLeftBarButtonItemAnimated:YES];
    
}

-(void) adjustLeftBarButtonItemAnimated:(BOOL)animated {
    
    if ([self.rdm_rootViewController menuShouldAlwaysShow]) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    } else {
        UIImage *image = [RDMStudentRootViewController defaultImage];
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(menuBarButtonItemPushed:)];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:YES];
    }
    
}

#pragma mark - Fetched Results Controller

-(NSFetchedResultsController*) linksFetchedResultsController {
    
    if (_linksFetchedResultsController) {
        return _linksFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RDMStudentLink"];
    
    NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"device == %@", self.dataController.device];
    NSPredicate *teacherPredicate = [NSPredicate predicateWithFormat:@"teacher == %@", self.teacher];
    NSPredicate *notDeletedPredicate = [NSPredicate predicateWithFormat:@"hasBeenDeleted == %@", @NO];
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ devicePredicate, notDeletedPredicate, teacherPredicate ] ];
    [fetchRequest setPredicate:andPredicate];
    
    NSSortDescriptor *sortOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastSentOn" ascending:NO selector:@selector(compare:)];
    [fetchRequest setSortDescriptors:@[ sortOrderDescriptor] ];
    
    _linksFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                         managedObjectContext:self.dataController.managedObjectContext
                                                                           sectionNameKeyPath:nil
                                                                                    cacheName:nil];
    _linksFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_linksFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _linksFetchedResultsController;
    
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return [[self.linksFetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.linksFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RDMStudentLink *link = [self.linksFetchedResultsController objectAtIndexPath:indexPath];
    
    if (link.name.length > 0) {
        static NSString *RDMLinkListURLAndNameCollectionViewCellID = @"RDMLinkListURLAndNameCollectionViewCellID";
        
        RDMLinkListURLAndNameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RDMLinkListURLAndNameCollectionViewCellID forIndexPath:indexPath];
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    } else {
        
        static NSString *RDMLinkListURLOnlyCollectionViewCellID = @"RDMLinkListURLOnlyCollectionViewCellID";
        
        RDMLinkListURLOnlyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RDMLinkListURLOnlyCollectionViewCellID
                                                                                               forIndexPath:indexPath];
        
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }


}

-(void) configureCell:(UICollectionViewCell*)theCell atIndexPath:(NSIndexPath*)indexPath {
    
    RDMStudentLink *link = [self.linksFetchedResultsController objectAtIndexPath:indexPath];

    if ([theCell isKindOfClass:[RDMLinkListURLAndNameCollectionViewCell class]]) {
        
        RDMLinkListURLAndNameCollectionViewCell *cell = (RDMLinkListURLAndNameCollectionViewCell*)theCell;
        
        cell.urlLabel.text = link.url;
        cell.nameLabel.text = link.name;
        
    } else {
    
        RDMLinkListURLOnlyCollectionViewCell *cell = (RDMLinkListURLOnlyCollectionViewCell*)theCell;
        
        cell.urlLabel.text = link.url;
        
    }
    
}

#pragma mark - Collection View Flow Delegate

#define padding 30.0

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (CGRectGetWidth(collectionView.bounds) > 768.0) {
        int viewWidth = CGRectGetWidth(self.view.bounds);
        int availableViewWidth = viewWidth - 4 * padding;
        CGFloat rawWidth = (float)availableViewWidth/3.0;
        int roundedDownCellWidth = floor(rawWidth);
        int remainder = availableViewWidth % roundedDownCellWidth;
        
        int widthToReturn = roundedDownCellWidth;
        
        switch (indexPath.row) {
            case 0:
                if (remainder == 2) {
                    widthToReturn = roundedDownCellWidth + 1;
                }
                break;
            case 1:
                
                if (remainder == 1) {
                    widthToReturn = roundedDownCellWidth + 1;
                }
                
                break;
            case 2:
                
                if (remainder == 2) {
                    widthToReturn = roundedDownCellWidth + 1;
                }
                break;
            default:
                break;
        }
        
        return CGSizeMake(widthToReturn, 140.0);
    }
    
    int viewWidth = CGRectGetWidth(self.view.bounds);
    int availableViewWidth = viewWidth - 3 * padding;
    CGFloat rawWidth = (float)availableViewWidth/2.0;
    int roundedDownCellWidth = floor(rawWidth);
    int remainder = availableViewWidth % roundedDownCellWidth;
    int widthToReturn = roundedDownCellWidth;
    
    if (indexPath.row % 2 == 0 && remainder) {
        widthToReturn = widthToReturn + 1;
    }
    
    return CGSizeMake(widthToReturn, 140.0);
    
}

-(UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(padding, padding, 0, padding);
}

-(CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return padding;
}

-(CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return padding;
}

#pragma mark - collection view delegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.linkActionSheetShownFor = [self.linksFetchedResultsController objectAtIndexPath:indexPath];
    
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    CGRect convertedRect = [selectedCell.superview convertRect:selectedCell.frame toView:self.view];
    
    RDMLinkListActionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMLinkListActionViewControllerID"];
    vc.delegate = self;
    self.actionPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
    [self.actionPopoverController presentPopoverFromRect:convertedRect
                                                  inView:self.view
                                permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                                animated:YES];
    
}

#pragma mark - Action View Delegate

-(void) didSelectCancelInActionViewController:(RDMLinkListActionViewController *)vc {
    
    [self.actionPopoverController dismissPopoverAnimated:YES];
    self.linkActionSheetShownFor = nil;
}

-(void) didSelectVisitInActionViewController:(RDMLinkListActionViewController *)vc {
    
    [self.actionPopoverController dismissPopoverAnimated:YES];
    
    if (![RDMOpenLinkHandler openLink:self.linkActionSheetShownFor]) {
        NSLog(@"Could Not Open Link");
    }
    
}

#pragma mark - Fetched Results Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove: {
                                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:obj[0]];
                                [self configureCell:cell atIndexPath:obj[1]];
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            }
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

- (IBAction)refreshButtonPushed:(id)sender {
    
    [[RDMStudentSyncEngine sharedEngine] startSync];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    
    self.navigationItem.rightBarButtonItem = self.activityIndicatorBarButtonItem;
    
    [indicatorView startAnimating];
}

@end
