//
//  RDMSetupDevicesViewController_iPad.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSetupDevicesViewController_iPad.h"

#import "RDMTeacherDataController.h"
#import "RDMUser.h"
#import "RDMGroup.h"
#import "RDMDevice.h"
#import "RDMDevice+Custom.h"

#import "RDMDevicesCollectionViewCell.h"

#import "SSLabel.h"
#import "RDMSyncEngine.h"

#import "RDMTeacherAccountController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import "UIAlertView+ErrorHelpers.h"

@interface RDMSetupDevicesViewController_iPad ()
- (IBAction)refreshButtonPushed:(id)sender;

@property (nonatomic, strong) UIBarButtonItem *activityIndicatorBarButtonItem;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *registrationCodeLabel;
@property (nonatomic, strong) NSFetchedResultsController *devicesFetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) UIPopoverController *actionPopoverController;
@property (nonatomic, strong) RDMDevice *deviceActionViewShownFor;

@property (nonatomic, strong) UIView *blackoutView;
@property (nonatomic, strong) UIView *editDeviceViewContainer;
@property (nonatomic, strong) RDMEditDeviceViewController *editDeviceViewController;
@property (nonatomic, strong) NSLayoutConstraint *verticalConstraintForEditView;

@property (nonatomic, strong) id syncCompleteObserver;

@property (strong, nonatomic) IBOutlet UIButton *codeRefreshButton;
- (IBAction)codeRefreshButtonPushed:(id)sender;

@property (nonatomic, strong) RDMTeacherAccountController *accountController;
@property (nonatomic, strong) id userDidChangeObserver;

@end

@implementation RDMSetupDevicesViewController_iPad {
    
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    [self adjustLeftBarButtonItemAnimated:NO];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    self.title = @"Setup Devices";
    self.registrationCodeLabel.text = self.dataController.currentUser.registrationToken;

    self.accountController = [[RDMTeacherAccountController alloc] initWithDataController:self.dataController];

    UIImage *buttonBackground = [[UIImage imageNamed:@"storeButtonBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.codeRefreshButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    
    self.userDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMUserDidChangeNotification
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *note) {
                                                                                   
                                                                                   self.devicesFetchedResultsController = nil;
                                                                                   [self.collectionView reloadData];
                                                                                   
                                                                                   [self.actionPopoverController dismissPopoverAnimated:NO];
                                                                                   self.deviceActionViewShownFor = nil;
                                                                                   
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

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}


-(void) menuBarButtonItemPushed:(id) sender {
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES
                                                 withCompletion:nil];
}

-(NSFetchedResultsController*) devicesFetchedResultsController {
    
    if (_devicesFetchedResultsController) {
        return _devicesFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RDMDevice"];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"user == %@", self.dataController.currentUser];
    NSPredicate *notDeletedPredicate = [NSPredicate predicateWithFormat:@"hasBeenDeleted == %@", @NO];
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ userPredicate, notDeletedPredicate ] ];
    [fetchRequest setPredicate:andPredicate];
    
    NSSortDescriptor *sortOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    [fetchRequest setSortDescriptors:@[ sortOrderDescriptor] ];
    
    _devicesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                           managedObjectContext:self.dataController.managedObjectContext
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
    _devicesFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_devicesFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _devicesFetchedResultsController;
    
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return [[self.devicesFetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.devicesFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RDMDevicesCollectionViewCell *cell = (RDMDevicesCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"RDMDevicesCollectionViewCellID"
                                                                                                            forIndexPath:indexPath];
    
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

-(void) configureCell:(RDMDevicesCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    
    RDMDevice *device = [self.devicesFetchedResultsController objectAtIndexPath:indexPath];
    cell.deviceNameLabel.text = device.name;
    
    NSString *imageName = @"phone";
    if ([device.deviceType intValue] == RDMDeviceTypePad) {
        imageName = @"pad";
    }
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        
        cell.deviceTypeImage.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        cell.deviceTypeImage.image = [UIImage imageNamed:imageName];
    }
    
}

#pragma mark - Collection View Flow Delegate

#define padding 10.0

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
    
    
    return CGSizeMake(widthToReturn, 130.0);

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
    
    self.deviceActionViewShownFor = [self.devicesFetchedResultsController objectAtIndexPath:indexPath];
    
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    CGRect convertedRect = [selectedCell.superview convertRect:selectedCell.frame toView:self.view];
    
    RDMSetupDevicesActionsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMSetupDevicesActionsViewControllerID"];
    vc.delegate = self;
    self.actionPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
    [self.actionPopoverController presentPopoverFromRect:convertedRect
                                                  inView:self.view
                                permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                                animated:YES];
    
    
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
                                RDMDevicesCollectionViewCell *cell = (RDMDevicesCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:obj[0]];
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

#pragma mark - Action View Delegate

-(void) actionViewControllerDidPressRename:(RDMSetupDevicesActionsViewController *)vc {
    
    [self.actionPopoverController dismissPopoverAnimated:NO];
    [self presentEditViewControllerForDevice:self.deviceActionViewShownFor];
    
}

-(void) actionViewControllerDidPressRemove:(RDMSetupDevicesActionsViewController *)vc {
    
    self.deviceActionViewShownFor.hasBeenDeleted = @YES;
    self.deviceActionViewShownFor.syncStatus = @1;
    self.deviceActionViewShownFor = nil;
    
    [self.dataController saveMainContextWithCompletion:^(NSError* error) {
        
        if (error) {
            NSLog(@"Error");
        }
        
        self.deviceActionViewShownFor = nil;
        [self.actionPopoverController dismissPopoverAnimated:NO];
        [[RDMSyncEngine sharedEngine] startSync];
    }];
    
}

#pragma mark - Edit View Presentation

-(void) presentEditViewControllerForDevice:(RDMDevice*)device {
    
    self.blackoutView = [[UIView alloc] initWithFrame:self.rdm_rootViewController.view.bounds];
    self.blackoutView.backgroundColor = [UIColor blackColor];
    self.blackoutView.alpha = 0.0;
    
    self.blackoutView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.rdm_rootViewController.view addSubview:self.blackoutView];
    
    self.editDeviceViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 254)];
    self.editDeviceViewContainer.backgroundColor = [UIColor whiteColor];
    self.editDeviceViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.editDeviceViewContainer.layer.shadowRadius = 10.0;
    self.editDeviceViewContainer.layer.shadowOpacity = 1.0;
    self.editDeviceViewContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.editDeviceViewContainer.bounds].CGPath;
    
    [self.rdm_rootViewController.view addSubview:self.editDeviceViewContainer];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.editDeviceViewContainer
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:400];
    [self.rdm_rootViewController.view addConstraint:widthConstraint];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.editDeviceViewContainer
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0 constant:254.0];
    [self.rdm_rootViewController.view addConstraint:heightConstraint];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.editDeviceViewContainer
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.rdm_rootViewController.view
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0 constant:0];
    [self.rdm_rootViewController.view addConstraint:centerXConstraint];
    
    self.verticalConstraintForEditView = [NSLayoutConstraint constraintWithItem:self.editDeviceViewContainer
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.rdm_rootViewController.view
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:0.0];
    [self.rdm_rootViewController.view addConstraint:self.verticalConstraintForEditView];
    [self.rdm_rootViewController.view layoutIfNeeded];
    
    
    //Change vertical constraint to animate down
    
    [self.rdm_rootViewController.view removeConstraint:self.verticalConstraintForEditView];
    self.verticalConstraintForEditView = [NSLayoutConstraint constraintWithItem:self.editDeviceViewContainer
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.rdm_rootViewController.view
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:100.0];
    [self.rdm_rootViewController.view addConstraint:self.verticalConstraintForEditView];
    
    //Add edit view controller to container
    self.editDeviceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMEditDeviceViewControllerID"];
    self.editDeviceViewController.deviceToEdit = device;
    self.editDeviceViewController.dataController = self.dataController;
    self.editDeviceViewController.delegate = self;
    
    self.editDeviceViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.editDeviceViewController.view.frame = self.editDeviceViewContainer.bounds;
    [self.editDeviceViewContainer addSubview:self.editDeviceViewController.view];
    
    [UIView animateWithDuration:.33
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.rdm_rootViewController.view layoutIfNeeded];
                         self.blackoutView.alpha = .75;
                     }
                     completion:^(BOOL finished) {
                         [self.editDeviceViewController showKeyboard];
                     }];
    
}

-(void) dismissEditViewController {
    
    [self.rdm_rootViewController.view removeConstraint:self.verticalConstraintForEditView];
    self.verticalConstraintForEditView = [NSLayoutConstraint constraintWithItem:self.editDeviceViewContainer
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.rdm_rootViewController.view
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:0.0];
    [self.rdm_rootViewController.view addConstraint:self.verticalConstraintForEditView];
    
    [UIView animateWithDuration:.33
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.rdm_rootViewController.view layoutIfNeeded];
                         self.blackoutView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         [self.blackoutView removeFromSuperview];
                         self.blackoutView = nil;
                         
                         [self.editDeviceViewContainer removeFromSuperview];
                         self.editDeviceViewContainer = nil;
                         
                         self.editDeviceViewController = nil;
                         self.verticalConstraintForEditView = nil;
                         
                     }];
    
}

#pragma mark - Edit Device View Delegate

-(void) editDeviceViewControllerDidPressCancel:(RDMEditDeviceViewController *)vc {
    [self dismissEditViewController];
}

-(void) editDeviceViewControllerDidPressSave:(RDMEditDeviceViewController *)vc {
    [self dismissEditViewController];
}

- (IBAction)refreshButtonPushed:(id)sender {
    [[RDMSyncEngine sharedEngine] startSync];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    
    self.navigationItem.rightBarButtonItem = self.activityIndicatorBarButtonItem;
    
    [indicatorView startAnimating];
}
- (IBAction)codeRefreshButtonPushed:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Requesting New Registration Code"];
    
    [self.accountController sendRegistrationTokenChangeRequestWithCompletion:^(RDMUser *user, NSError* error) {
        
        if (error) {
            
            [SVProgressHUD dismiss];
            [UIAlertView showAlertWithTitle:error.userInfo[@"RDMErrorTitleKey"] andMessage:error.userInfo[NSLocalizedDescriptionKey]];
            
        } else {
            self.registrationCodeLabel.text = user.registrationToken;
            [SVProgressHUD showSuccessWithStatus:@"All Done!"];
        }
        
    }];
    
}
@end
