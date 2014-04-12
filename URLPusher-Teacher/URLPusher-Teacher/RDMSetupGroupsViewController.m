//
//  RDMSetupDevicesViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMSetupGroupsViewController.h"

#import "RDMTeacherDataController.h"
#import "RDMUser.h"
#import "RDMGroup.h"
#import "RDMDevice.h"

#import "RDMSetupGroupsTableViewCell.h"

#import "RDMEditGroupViewController_iPad.h"
#import "RDMCreateGroupViewController.h"
#import "RDMSyncEngine.h"
#import "RDMTeacherAccountController.h"

@interface RDMSetupGroupsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *groupsFetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
- (IBAction)addButtonPushed:(id)sender;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) id syncCompleteObserver;
@property (nonatomic, strong) id userDidChangeObserver;

@end

@implementation RDMSetupGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    self.title = @"Setup Groups";

    self.userDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMUserDidChangeNotification
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *note) {
                                                                                   
                                                                                   self.groupsFetchedResultsController = nil;
                                                                                   [self.tableView reloadData];
                                                                                   
                                                                                   if (self.presentedViewController) {
                                                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                                                   }
                                                                                   
                                                                               }];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self.userDidChangeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.syncCompleteObserver];
}

-(void) menuBarButtonItemPushed:(id) sender {
    
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES
                                                 withCompletion:nil];
}

- (IBAction)addButtonPushed:(id)sender {
    
    [self performSegueWithIdentifier:@"groupCreateSegueID"
                              sender:nil];
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"editGroupSegueID"]) {
        
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        RDMGroup *group = [self.groupsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row
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
    } else if ([segue.identifier isEqualToString:@"tableViewEmbedSegueID"]) {
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

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.groupsFetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.groupsFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RDMSetupGroupsTableViewCellID = @"RDMSetupGroupsTableViewCellID";
    
    RDMSetupGroupsTableViewCell *cell = (RDMSetupGroupsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:RDMSetupGroupsTableViewCellID
                                                                                                      forIndexPath:indexPath];
    
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

-(void) configureCell:(RDMSetupGroupsTableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    RDMGroup *group = [self.groupsFetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = group.name;
    NSUInteger numberOfDevicesInGroup = [group.devices count];
    cell.numberOfDevicesLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)numberOfDevicesInGroup, numberOfDevicesInGroup == 1 ? @"Device" : @"Devices"];
    
}

#pragma mark - Table View Delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"editGroupSegueID"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
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
