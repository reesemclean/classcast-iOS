//
//  RDMSendLinkViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/31/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSendLinkViewController.h"

#import "RDMSelectDeviceCell.h"
#import "RDMSelectGroupExpandingCell.h"

#import "RDMGroup.h"
#import "RDMDevice.h"
#import "RDMUser.h"
#import "RDMUser+Custom.h"
#import "RDMLink.h"
#import "RDMLink+Custom.h"

#import "RDMTokenAuthAPIClient.h"
#import "RDMSyncEngine.h"
#import "RDMTeacherAccountController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import "UIAlertView+ErrorHelpers.h"

#import "RDMConfiguration.h"

@interface RDMSendLinkViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
- (IBAction)sendButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *linkURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *linkNameTextField;
@property (nonatomic, strong) NSMutableSet *selectedDevices;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIExpandableTableView *tableView;
@property (nonatomic, strong) NSNumber *expandedSection;

@property (nonatomic, strong) NSFetchedResultsController *devicesFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *groupsFetchedResultsController;
@property (nonatomic, strong) NSArray *groups;

- (IBAction)selectAllButtonPushed:(id)sender;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) id syncCompleteObserver;
@property (nonatomic, strong) id userDidChangeObserver;

@end

@implementation RDMSendLinkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupGroupsArray];

    if (self.link) {
        
        self.linkURLTextField.text = self.link.url;
        self.linkNameTextField.text = self.link.name;
        
    }
    
    self.selectedDevices = [NSMutableSet set];
    
    self.title = @"Send Link";
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    self.userDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMUserDidChangeNotification
                                                                                 object:nil
                                                                                  queue:[NSOperationQueue mainQueue]
                                                                             usingBlock:^(NSNotification *note) {
                                                                                 
                                                                                 self.groupsFetchedResultsController = nil;
                                                                                 self.devicesFetchedResultsController = nil;
                                                                                 [self setupGroupsArray];
                                                                                 [self.tableView reloadData];
                                                                                 
                                                                             }];
    
    self.syncCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMSyncEngineDidFinishNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification * note) {
                                                                                  
                                                                                  [self.refreshControl endRefreshing];
                                                                                  
                                                                              }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleViewDeckPanNotification:)
                                                 name:RDMRevealMenuPanDidStartNofification
                                               object:self.rdm_rootViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidChangeAlwaysShowMenuNotification:)
                                                 name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];

    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self adjustLeftBarButtonItemAnimated:NO];

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
    [[NSNotificationCenter defaultCenter] removeObserver:self.userDidChangeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.syncCompleteObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDMRevealMenuPanDidStartNofification object:self.rdm_rootViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDMRevealMenuAlwaysShowMenuDidChangeNotification object:self.rdm_rootViewController];

}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"tableViewEmbedSegueID"]) {
        UITableViewController *tableViewController = [segue destinationViewController];
        [tableViewController.refreshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = tableViewController.refreshControl;
        self.tableView = (UIExpandableTableView*)tableViewController.tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
}

-(void) menuBarButtonItemPushed:(id) sender {
    
    [self.linkURLTextField resignFirstResponder];
    [self.linkNameTextField resignFirstResponder];
    
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES withCompletion:nil];
    
}

#pragma mark Text Field Delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - View Deck Delegate

-(void) handleViewDeckPanNotification:(NSNotification*)note {
    [self.linkURLTextField resignFirstResponder];
    [self.linkNameTextField resignFirstResponder];

}

-(void) refreshTableData:(id) sender {
    
    [[RDMSyncEngine sharedEngine] startSync];
    
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

-(void) setupGroupsArray {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (RDMGroup *group in self.groupsFetchedResultsController.fetchedObjects) {
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSSortDescriptor *sortOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSArray *sortedDeviceArray = [group.devices sortedArrayUsingDescriptors:@[sortOrderDescriptor]];
        
        for (RDMDevice *device in sortedDeviceArray) {
            [array addObject:device];
        }
        
        [tempArray addObject:array];
    }
    
    [tempArray addObject:self.devicesFetchedResultsController.fetchedObjects];
    
    self.groups = [NSArray arrayWithArray:tempArray];
    
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    // return YES, if the section should be expandable
    return YES;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    // return YES, if you need to download data to expand this section. tableView will call tableView:downloadDataForExpandableSection: for this section
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *RDMSelectGroupExpandingCellID = @"RDMSelectGroupExpandingCellID";
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    RDMSelectGroupExpandingCell *cell = (RDMSelectGroupExpandingCell *)[tableView dequeueReusableCellWithIdentifier:RDMSelectGroupExpandingCellID
                                                                                                         forIndexPath:indexPath];
    
    [self configureExpansionCell:cell forSection:section];
    
    return cell;
}

#define SELECT_ALL_BUTTON_TEXT_COLOR [UIColor colorWithRed:(89.0/255.0) green:(147.0/255.0) blue:(181.0/255.0) alpha:1.0]

-(void) configureExpansionCell:(RDMSelectGroupExpandingCell*)cell forSection:(NSUInteger)section {
    
    [cell.selectAllButton addTarget:self action:@selector(selectAllButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.groupsFetchedResultsController sections][0];
    if (section < [sectionInfo numberOfObjects]) {
        
        RDMGroup *group = [self.groupsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:section inSection:0]];
        cell.titleLabel.text = group.name;
        
    } else {
        
        cell.titleLabel.text = @"All Devices";
        
    }
    
    NSSet *group = [NSSet setWithArray:[self.groups objectAtIndex:section]];
    
    if ([group count] < 1) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.titleLabel.text = [NSString stringWithFormat:@"%@ (No Devices in Group)", cell.titleLabel.text];
        } else {
            cell.titleLabel.text = [NSString stringWithFormat:@"%@ (0 Devices)", cell.titleLabel.text];
        }
        
    }
    
    if ([group isSubsetOfSet:self.selectedDevices]) {
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentRight];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Deselect All"
                                                                                  attributes:@{ NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : SELECT_ALL_BUTTON_TEXT_COLOR}];
        [cell.selectAllButton setAttributedTitle:title forState:UIControlStateNormal];
        
        if ([group count] < 1) {
            cell.selectAllButton.hidden = YES;
            
            if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
                cell.isSelectedImageView.image = [[UIImage imageNamed:@"deselectedCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                cell.isSelectedImageView.image = [UIImage imageNamed:@"deselectedCircle"];
            }
            
        } else {
            cell.selectAllButton.hidden = NO;
            
            if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
                cell.isSelectedImageView.image = [[UIImage imageNamed:@"selectedCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                cell.isSelectedImageView.image = [UIImage imageNamed:@"selectedCircle"];
            }
            
        }
        
    } else {
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentRight];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Select All"
                                                                                  attributes:@{ NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : SELECT_ALL_BUTTON_TEXT_COLOR}];
        [cell.selectAllButton setAttributedTitle:title forState:UIControlStateNormal];

        if ([group count] < 1) {
            cell.selectAllButton.hidden = YES;
            
            if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
                cell.isSelectedImageView.image = [[UIImage imageNamed:@"deselectedCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                cell.isSelectedImageView.image = [UIImage imageNamed:@"deselectedCircle"];
            }
            
        } else {
            
            cell.selectAllButton.hidden = NO;

            __block BOOL foundOne = NO;
            [group enumerateObjectsUsingBlock:^(RDMDevice *device, BOOL *stop) {
                
                if ([self.selectedDevices containsObject:device]) {
                    
                    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
                        cell.isSelectedImageView.image = [[UIImage imageNamed:@"partiallySelectedCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    } else {
                        cell.isSelectedImageView.image = [UIImage imageNamed:@"partiallySelectedCircle"];
                    }
                    
                    foundOne = YES;
                    *stop = YES;
                }
                
            }];
            
            if (!foundOne) {
                
                if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
                    cell.isSelectedImageView.image = [[UIImage imageNamed:@"deselectedCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                } else {
                    cell.isSelectedImageView.image = [UIImage imageNamed:@"deselectedCircle"];
                }
                
            }
            
        }
        
        
    }

}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    
}

- (void)tableView:(UIExpandableTableView *)tableView willExpandSection:(NSUInteger)section animated:(BOOL)animated
{
    if (self.expandedSection) {
        [tableView collapseSection:[self.expandedSection intValue]
                          animated:YES];
    }
    
    self.expandedSection = @(section);
    
}

- (void)tableView:(UIExpandableTableView *)tableView didExpandSection:(NSUInteger)section animated:(BOOL)animated
{
}

- (void)tableView:(UIExpandableTableView *)tableView willCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
}

- (void)tableView:(UIExpandableTableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.groups count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *group = [self.groups objectAtIndex:section];
    return [group count] + 1; //+1 For Section Expansion
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RDMSelectDeviceCellID = @"RDMSelectDeviceCellID";
    
    RDMSelectDeviceCell *cell = (RDMSelectDeviceCell*)[tableView dequeueReusableCellWithIdentifier:RDMSelectDeviceCellID
                                                                                      forIndexPath:indexPath];
    
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

-(void) configureCell:(RDMSelectDeviceCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    NSArray *group = [self.groups objectAtIndex:indexPath.section];
    RDMDevice *device = [group objectAtIndex:indexPath.row - 1];
    
    cell.titleLabel.text = device.name;
    
    if ([self.selectedDevices containsObject:device]) {
        
        if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
            cell.isSelectedImageView.image = [[UIImage imageNamed:@"selectedCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            cell.isSelectedImageView.image = [UIImage imageNamed:@"selectedCircle"];
        }
        
    } else {
        
        if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
            cell.isSelectedImageView.image = [[UIImage imageNamed:@"deselectedCircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            cell.isSelectedImageView.image = [UIImage imageNamed:@"deselectedCircle"];
        }
        
    }
    
    
}

-(UIView*) headerView {
    
    if (_headerView) {
        return _headerView;
    }

    CGFloat height = 22.0;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, height)];
    [containerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat padding = 15.0;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, containerView.frame.size.width - 2 *padding, containerView.frame.size.height)];
    label.text = @"Devices to Send To:";
    label.textColor = [UIColor colorWithWhite:.1 alpha:.90];
    label.font = [UIFont systemFontOfSize:14.0];
    [containerView addSubview:label];
    
    _headerView =  containerView;
    
    return _headerView;
    
}

#pragma mark - Table View Delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *group = [self.groups objectAtIndex:indexPath.section];
    RDMDevice *device = [group objectAtIndex:indexPath.row - 1];
    
    if ([self.selectedDevices containsObject:device]) {
        [self.selectedDevices removeObject:device];
    } else {
        [self.selectedDevices addObject:device];
    }
    
    RDMSelectDeviceCell *cell = (RDMSelectDeviceCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    RDMSelectGroupExpandingCell *expansionCell = (RDMSelectGroupExpandingCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    [self configureExpansionCell:expansionCell forSection:indexPath.section];
    
    [self.groups enumerateObjectsUsingBlock:^(NSArray *group, NSUInteger idx, BOOL *stop) {
        
        if (idx != indexPath.section && [group containsObject:device]) {

            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:idx]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        
    }];
    
}

#pragma mark - Fetched Results Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    

}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self setupGroupsArray];
    [self.tableView reloadData];
}

#pragma Select All Cell Button Pushed

- (IBAction)selectAllButtonPushed:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath)
    {
        NSUInteger section = indexPath.section;
        
        NSSet *group = [NSSet setWithArray:[self.groups objectAtIndex:section]];
        
        if ([group isSubsetOfSet:self.selectedDevices]) {
            //Deselect all devices
            for (RDMDevice *device in group) {
                [self.selectedDevices removeObject:device];
            }
            
        } else {
            //Select all devices
            for (RDMDevice *device in group) {
                [self.selectedDevices addObject:device];
            }
        }
        
        [self.tableView reloadData];
        
    }

    
}

- (IBAction)sendButtonPushed:(id)sender {
    
    if (self.linkURLTextField.text.length < 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Link"
                                                        message:@"The link to share can not be blank."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
        
    }
    
    [self.linkURLTextField resignFirstResponder];
    [self.linkNameTextField resignFirstResponder];
    
    if ([self.selectedDevices count] < 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Devices Selected"
                                                        message:@"You must choose at least one device in order to send the link."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    RDMUser *user = [self.dataController currentUser];
    
    if ([self.selectedDevices count] > RDM_NUMBER_OF_DEVICES_FOR_FREE_ACCOUNT && ![user hasValidSubscription]) {
        
        NSString *devicesString = [NSString stringWithFormat:@"%d %@", RDM_NUMBER_OF_DEVICES_FOR_FREE_ACCOUNT, RDM_NUMBER_OF_DEVICES_FOR_FREE_ACCOUNT == 1 ? @"Device" : @"Devices"];
        NSString *message = [NSString stringWithFormat:@"With a free account you may only send links to %@ at a time.\n Subscribe to send links to up to 100 devices at a time.", devicesString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Free Account Limit"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"No Thanks"
                                              otherButtonTitles:@"Subscribe", nil];
        [alert show];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Sending Link"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSMutableArray *deviceGUIDsToSendTo = [NSMutableArray array];
    for (RDMDevice *device in self.selectedDevices) {
        [deviceGUIDsToSendTo addObject:device.guid];
    }
    [parameters setObject:deviceGUIDsToSendTo forKey:@"deviceGUIDs"];
    
    if (!self.link) {
        
        self.link = [NSEntityDescription insertNewObjectForEntityForName:@"RDMLink"
                                                  inManagedObjectContext:self.dataController.managedObjectContext];
        self.link.user = self.dataController.currentUser;
        
    }
    
    self.link.name = self.linkNameTextField.text;
    self.link.url = self.linkURLTextField.text;
    self.link.dateUpdatedOnDevice = [NSDate date];
    self.link.syncStatus = @1;
    [parameters setObject:[self.link linkDictionary]
                   forKey:@"link"];
    
    NSMutableURLRequest *request = [[RDMTokenAuthAPIClient sharedClient] sendLinkRequestForUserWithToken:[self.dataController.currentUser serverToken]
                                                                                          withParameters:parameters];
    
    if (!request) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"There was a problem syncing your account. Please sign in again."];
        
        return;
    }
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        
        [SVProgressHUD showSuccessWithStatus:@"Link Sent!"];
        
        self.link = nil;
        self.linkNameTextField.text = @"";
        self.linkURLTextField.text = @"";
        [self.selectedDevices removeAllObjects];
        [[self tableView] reloadData];
        
        [[RDMSyncEngine sharedEngine] startSync];
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 406:
                userInfo = @{ @"RDMErrorTitleKey": @"Please Upgrade",
                              NSLocalizedDescriptionKey : @"It looks like this version of the app is out of date. Please upgrade to the latest version through the App Store." };
                break;
            case 500:
            default:
                userInfo = @{ @"RDMErrorTitleKey": @"Couldn't Send",
                              NSLocalizedDescriptionKey : @"There was an error sending your link. Please try again." };
                break;
        }
        
        NSLog(@"Error: %@", error);
        [UIAlertView showAlertWithTitle:userInfo[@"RDMErrorTitleKey"] andMessage:userInfo[NSLocalizedDescriptionKey]];
        
        [SVProgressHUD dismiss];
        
    };
    
    AFHTTPRequestOperation *operation = [[RDMTokenAuthAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                                      success:successBlock
                                                                                                      failure:failureBlock];
    [operation start];

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    [self.delegate sendLinkViewShouldShowSubscriptionOptions:self];
    
}

@end
