//
//  RDMSetupGroupsViewController_iPad.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/4/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSetupGroupsViewController_iPad.h"

#import "RDMTeacherDataController.h"
#import "RDMUser.h"
#import "RDMGroup.h"
#import "RDMDevice.h"

#import "RDMSetupGroupCell.h"
#import "RDMNewGroupCell.h"

#import "SSLabel.h"

#import "RDMEditGroupViewController_iPad.h"
#import "RDMCreateGroupViewController.h"
#import "RDMSyncEngine.h"
#import "RDMTeacherAccountController.h"

@interface RDMSetupGroupsViewController_iPad ()

@property (nonatomic, strong) UIBarButtonItem *activityIndicatorBarButtonItem;

@property (nonatomic, strong) UIPopoverController *actionPopoverController;
@property (nonatomic, strong) RDMGroup *groupActionViewShownFor;

@property (nonatomic, strong) NSFetchedResultsController *groupsFetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)refreshButtonPushed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, strong) id syncCompleteObserver;
@property (nonatomic, strong) id userDidChangeObserver;

@end

@implementation RDMSetupGroupsViewController_iPad {
    
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    [self adjustLeftBarButtonItemAnimated:NO];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    self.title = @"Groups";

    self.userDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMUserDidChangeNotification
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *note) {
                                                                                   
                                                                                   self.groupsFetchedResultsController = nil;
                                                                                   [self.collectionView reloadData];
                                                                                   
                                                                                   if (self.presentedViewController) {
                                                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                                                   }
                                                                               }];
    
    self.syncCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMSyncEngineDidFinishNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification * note) {
                                                                                  
                                                                                  self.navigationItem.rightBarButtonItem = self.refreshButton;
                                                                                  self.activityIndicatorBarButtonItem = nil;
                                                                                  
                                                                              }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidChangeAlwaysShowMenuNotification:)
                                                 name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];
}



-(void) handleDidChangeAlwaysShowMenuNotification:(NSNotification*)note {
    
    [self adjustLeftBarButtonItemAnimated:YES];
    
}

-(void) adjustLeftBarButtonItemAnimated:(BOOL)animated {
    
    if ([self.rdm_rootViewController menuShouldAlwaysShow]) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    } else {
        UIImage *image = [RDMRootViewController defaultImage];
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(menuBarButtonItemPushed:)];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self.userDidChangeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.syncCompleteObserver];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"editGroupSegueID"]) {
        
        UICollectionViewCell *cell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        RDMGroup *group = [self.groupsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row - 1
                                                                                                     inSection:indexPath.section]];
        UINavigationController *navController = (UINavigationController*)segue.destinationViewController;
        RDMEditGroupViewController_iPad *vc = (RDMEditGroupViewController_iPad*)[navController topViewController];
        vc.dataController = self.dataController;
        vc.groupToEdit = group;
        
        if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
            navController.view.tintColor = [UIColor whiteColor];
        }
        
    } else if ([segue.identifier isEqualToString:@"groupCreateSegueID"]) {
        
        UINavigationController *navController = (UINavigationController*)segue.destinationViewController;
        RDMCreateGroupViewController *vc = (RDMCreateGroupViewController*)[navController topViewController];
        vc.dataController = self.dataController;

        if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
            navController.view.tintColor = [UIColor whiteColor];
        }
    }
    
}

-(void) menuBarButtonItemPushed:(id) sender {
    
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES
                                                 withCompletion:nil];
}

-(NSFetchedResultsController*) groupsFetchedResultsController {
    
    if (_groupsFetchedResultsController) {
        return _groupsFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RDMGroup"];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"user == %@", self.dataController.currentUser];
    NSPredicate *notDeletedPredicate = [NSPredicate predicateWithFormat:@"hasBeenDeleted == %@", @NO];
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ userPredicate, notDeletedPredicate ] ];
    [fetchRequest setPredicate:andPredicate];
    
    NSSortDescriptor *sortOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    [fetchRequest setSortDescriptors:@[ sortOrderDescriptor] ];
    
    _groupsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                           managedObjectContext:self.dataController.managedObjectContext
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
    _groupsFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_groupsFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _groupsFetchedResultsController;
    
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return [[self.groupsFetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.groupsFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects] + 1;
    
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        RDMNewGroupCell *cell = (RDMNewGroupCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"RDMNewGroupCellID"
                                                                                            forIndexPath:indexPath];
        return cell;
    }
    
    RDMSetupGroupCell *cell = (RDMSetupGroupCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"RDMSetupGroupCellID"
                                                                                            forIndexPath:indexPath];
    
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

-(void) configureCell:(RDMSetupGroupCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    
    NSIndexPath *adjustIndexPath = [NSIndexPath indexPathForItem:indexPath.row - 1
                                                       inSection:indexPath.section];
    RDMGroup *group = [self.groupsFetchedResultsController objectAtIndexPath:adjustIndexPath];
    
    cell.groupNameLabel.text = group.name;
    
    NSUInteger numberOfDevices = [group.devices count];
    NSString *deviceText = numberOfDevices == 1 ? @"Device" : @"Devices";
    cell.numberOfDevicesLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[group.devices count], deviceText];

}

#pragma mark - Collection View Flow Delegate

#define padding 30.0

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
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

-(UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(padding, padding, 0, padding);
}

-(CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return padding;
}

-(CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return padding;
}

#pragma mark - Collection View Delegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"groupCreateSegueID"
                                  sender:indexPath];
        return;
    }
    
    [self performSegueWithIdentifier:@"editGroupSegueID"
                              sender:[collectionView cellForItemAtIndexPath:indexPath]];
    
}

#pragma mark - Fetched Results Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForItem:indexPath.row + 1 inSection:indexPath.section];
    NSIndexPath *adjustedNewIndexPath = [NSIndexPath indexPathForItem:newIndexPath.row + 1 inSection:newIndexPath.section];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = adjustedNewIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = adjustedIndexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = adjustedIndexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[adjustedIndexPath, adjustedNewIndexPath];
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

                                RDMSetupGroupCell *cell = (RDMSetupGroupCell*)[self.collectionView cellForItemAtIndexPath:obj[0]];
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
    [[RDMSyncEngine sharedEngine] startSync];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    
    self.navigationItem.rightBarButtonItem = self.activityIndicatorBarButtonItem;
    
    [indicatorView startAnimating];
}
@end
