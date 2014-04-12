//
//  RDMCreateGroupPickDevicesViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/4/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMCreateGroupPickDevicesViewController.h"

#import "RDMCreateGroupDeviceCell.h"

#import "RDMGroup.h"
#import "RDMGroupPlacement+Custom.h"

#import "RDMGroup.h"
#import "RDMDevice.h"
#import "RDMTeacherDataController.h"

#import "RDMSyncEngine.h"

@interface RDMCreateGroupPickDevicesViewController ()

@property (nonatomic, strong) NSMutableSet *selectedDevices;
@property (nonatomic, strong) NSFetchedResultsController *devicesFetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)doneButtonPressed:(id)sender;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) id syncCompleteObserver;

@end

@implementation RDMCreateGroupPickDevicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Select Devices";
    
    self.selectedDevices = [NSMutableSet set];
    
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
    }
    
    self.syncCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMSyncEngineDidFinishNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification * note) {
                                                                                  
                                                                                  [self.refreshControl endRefreshing];
                                                                                  
                                                                              }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.syncCompleteObserver];
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

- (IBAction)doneButtonPressed:(id)sender {
    
    //These devices are already in the temporary context
    for (RDMDevice *device in self.selectedDevices) {
        
        RDMGroupPlacement *groupPlacement = [NSEntityDescription insertNewObjectForEntityForName:@"RDMGroupPlacement"
                                                                          inManagedObjectContext:self.temporaryContext];
        groupPlacement.hasBeenProcessed = @NO;
        groupPlacement.groupGUID = self.groupInTemporaryContext.guid;
        groupPlacement.deviceID = device.guid;
        groupPlacement.placementType = @(RDMGroupPlacementTypeAdded);
        groupPlacement.user = device.user;
        
    }
    
    [self.groupInTemporaryContext addDevices:self.selectedDevices];
    
    [self.dataController saveTemporaryContextAndPushToMainContext:self.temporaryContext
                                                   withCompletion:^(NSError* error) {
                                                    
                                                       [[RDMSyncEngine sharedEngine] startSync];
                                                       [self dismissViewControllerAnimated:YES
                                                                                completion:nil];
                                                       
                                                   }];

}

-(NSFetchedResultsController*) devicesFetchedResultsController {
    
    if (_devicesFetchedResultsController) {
        return _devicesFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RDMDevice"];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"user == %@", self.userInTemporaryContext];
    NSPredicate *notDeletedPredicate = [NSPredicate predicateWithFormat:@"hasBeenDeleted == %@", @NO];
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ userPredicate, notDeletedPredicate ] ];
    [fetchRequest setPredicate:andPredicate];
    
    NSSortDescriptor *sortOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    [fetchRequest setSortDescriptors:@[ sortOrderDescriptor] ];
    
    _devicesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:self.temporaryContext
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

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Registered Devices";
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RDMCreateGroupDeviceCellID = @"RDMCreateGroupDeviceCellID";
    
    RDMCreateGroupDeviceCell *cell = (RDMCreateGroupDeviceCell*)[tableView dequeueReusableCellWithIdentifier:RDMCreateGroupDeviceCellID
                                                                                                forIndexPath:indexPath];
    
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

-(void) configureCell:(RDMCreateGroupDeviceCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    RDMDevice *device = [self.devicesFetchedResultsController objectAtIndexPath:indexPath];
    
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

#pragma mark - Table View Delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RDMDevice *device = [self.devicesFetchedResultsController objectAtIndexPath:indexPath];
    
    if ([self.selectedDevices containsObject:device]) {
        [self.selectedDevices removeObject:device];
    } else {
        [self.selectedDevices addObject:device];
    }
    
    RDMCreateGroupDeviceCell *cell = (RDMCreateGroupDeviceCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];

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

@end
