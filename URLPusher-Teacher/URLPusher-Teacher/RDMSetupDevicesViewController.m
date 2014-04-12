//
//  RDMSetupDevicesViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSetupDevicesViewController.h"

#import "RDMDeviceCell.h"

#import "RDMTeacherDataController.h"
#import "RDMUser.h"
#import "RDMGroup.h"
#import "RDMDevice.h"
#import "RDMSyncEngine.h"
#import "RDMTeacherAccountController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import "UIAlertView+ErrorHelpers.h"

@interface RDMSetupDevicesViewController ()

@property (weak, nonatomic) IBOutlet UILabel *registrationCodeLabel;
@property (nonatomic, strong) NSFetchedResultsController *devicesFetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) RDMDevice *selectedDevice;

@property (nonatomic, strong) UIActionSheet *deleteActionSheet;

- (IBAction)renameButtonPushed:(id)sender;
- (IBAction)removeButtonPushed:(id)sender;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) id syncCompleteObserver;
- (IBAction)helpButtonPushed:(id)sender;

@property (nonatomic, strong) RDMTeacherAccountController *accountController;
@property (nonatomic, strong) id userDidChangeObserver;

@end

@implementation RDMSetupDevicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accountController = [[RDMTeacherAccountController alloc] initWithDataController:self.dataController];
    
	// Do any additional setup after loading the view.
    UIImage *image = [RDMRootViewController defaultImage];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(menuBarButtonItemPushed:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    self.title = @"Setup Devices";
    self.registrationCodeLabel.text = self.dataController.currentUser.registrationToken;
    
    self.userDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMUserDidChangeNotification
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *note) {
                                                                                   
                                                                                   self.devicesFetchedResultsController = nil;
                                                                                   [self.tableView reloadData];
                                                                                   
                                                                                   self.selectedDevice = nil;
                                                                                   
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

}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"tableViewEmbedSegueID"]) {
        UITableViewController *tableViewController = [segue destinationViewController];
        [tableViewController.refreshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = tableViewController.refreshControl;
        self.tableView = tableViewController.tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
}

-(void) refreshTableData:(id) sender {
    
    [[RDMSyncEngine sharedEngine] startSync];
    
}


-(void) menuBarButtonItemPushed:(id) sender {
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES
                                                 withCompletion:nil];
}


- (IBAction)renameButtonPushed:(id)sender {
    
    RDMEditDeviceViewController *editDeviceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RDMEditDeviceViewControllerID"];
    editDeviceViewController.deviceToEdit = self.selectedDevice;
    editDeviceViewController.dataController = self.dataController;
    editDeviceViewController.delegate = self;

    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        editDeviceViewController.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    [self presentViewController:editDeviceViewController animated:YES completion:nil];
}

- (IBAction)removeButtonPushed:(id)sender {

    self.deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm Removal"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Remove Device"
                                                    otherButtonTitles:nil];

    [self.deleteActionSheet showInView:self.view];
    
}

#pragma mark - Edit Device View Delegate

-(void) editDeviceViewControllerDidPressCancel:(RDMEditDeviceViewController *)vc {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

-(void) editDeviceViewControllerDidPressSave:(RDMEditDeviceViewController *)vc {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Action Sheet Delegate

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        self.selectedDevice.hasBeenDeleted = @YES;
        self.selectedDevice.syncStatus = @1;
        self.selectedDevice = nil;
        //[self.dataController.managedObjectContext deleteObject:self.selectedDevice];
        [self.dataController saveMainContextWithCompletion:^(NSError *error) {

            [[RDMSyncEngine sharedEngine] startSync];

        }];
        
    }
    
}

-(void) handleViewDeckPanNotification:(NSNotification*)note {
    
    if (self.selectedDevice) {
        self.selectedDevice = nil;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
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

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.devicesFetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.devicesFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RDMDevice *device = [self.devicesFetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.selectedDevice && device == self.selectedDevice) {
        return 88.0;
    }
    
    return 44.0;
    
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Registered Devices";
    
}

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.selectedDevice) {
        return YES;
    }
    
    NSIndexPath *selectedIndexPath = [self.devicesFetchedResultsController indexPathForObject:self.selectedDevice];
    if (!selectedIndexPath) {
        return YES;
    }
    
    return ![selectedIndexPath isEqual:indexPath];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RDMDeviceCellID = @"RDMDeviceCellID";
    
    RDMDeviceCell *cell = (RDMDeviceCell*)[tableView dequeueReusableCellWithIdentifier:RDMDeviceCellID
                                                            forIndexPath:indexPath];
    
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

-(void) configureCell:(RDMDeviceCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    RDMDevice *device = [self.devicesFetchedResultsController objectAtIndexPath:indexPath];
    [cell.renameButton addTarget:self action:@selector(renameButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.removeButton addTarget:self action:@selector(removeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    cell.deviceNameLabel.text = device.name;
        
}

#pragma mark - Table View Delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RDMDevice *device = [self.devicesFetchedResultsController objectAtIndexPath:indexPath];

    if (device != self.selectedDevice) {
        self.selectedDevice = device;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

#pragma mark - Scroll View Delegate

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.selectedDevice) {
        self.selectedDevice = nil;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
}

#pragma mark - Fetched Results Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (IBAction)helpButtonPushed:(id)sender {
    
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
