//
//  RDMTeacherLinkLibraryViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/1/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherLinkLibraryViewController.h"

#import "RDMTeacherDataController.h"
#import "RDMLink.h"

#import "RDMLibraryLinkAndNameCell.h"
#import "RDMLibraryLinkOnlyCell.h"

#import "RDMLinkLibraryDelegate.h"

#import "RDMSyncEngine.h"
#import "RDMTeacherAccountController.h"

typedef NS_ENUM(NSInteger, RDMLibraryFilterType) {
    RDMLibrarySavedFilter,
    RDMLibraryHistoryFilter
};

@interface RDMTeacherLinkLibraryViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentedControlDidChange:(id)sender;
@property (nonatomic, strong) NSFetchedResultsController *linksFetchedResultsController;

- (IBAction)sendButtonPushed:(id)sender;
- (IBAction)editButtonPushed:(id)sender;
- (IBAction)deleteButtonPushed:(id)sender;

@property (nonatomic, strong) UIActionSheet *deleteActionSheet;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) id syncCompleteObserver;
@property (nonatomic, strong) id userDidChangeObserver;
@end

@implementation RDMTeacherLinkLibraryViewController

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
    } else {
        self.segmentedControl.tintColor = self.navigationController.navigationBar.tintColor;
    }
    
    self.title = @"Link Library";

    self.userDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMUserDidChangeNotification
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *note) {
                                                                                   
                                                                                   self.linksFetchedResultsController = nil;
                                                                                   self.selectedIndexPath = nil;

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
    if (self.selectedIndexPath) {
        self.selectedIndexPath = nil;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
}

#pragma mark - View Deck Delegate

-(void) handleViewDeckPanNotification:(NSNotification*)note {
    if (self.selectedIndexPath) {
        self.selectedIndexPath = nil;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (IBAction)segmentedControlDidChange:(id)sender {
    
    self.linksFetchedResultsController = nil;
    [self.tableView reloadData];
    
}

-(NSFetchedResultsController*) linksFetchedResultsController {
    
    if (_linksFetchedResultsController) {
        return _linksFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RDMLink"];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"user == %@", self.dataController.currentUser];
    NSPredicate *notDeletedPredicate = [NSPredicate predicateWithFormat:@"hasBeenDeleted == %@", @NO];
    
    if (self.segmentedControl.selectedSegmentIndex == RDMLibrarySavedFilter) {
        NSPredicate *hasBeenSavedPredicate = [NSPredicate predicateWithFormat:@"savedByUser == %@", @YES];
        
        NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ userPredicate, notDeletedPredicate, hasBeenSavedPredicate ] ];
        [fetchRequest setPredicate:andPredicate];
        
        NSSortDescriptor *sortOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateUpdatedOnDevice" ascending:YES selector:@selector(compare:)];
        [fetchRequest setSortDescriptors:@[ sortOrderDescriptor] ];

    } else {
        NSPredicate *hasBeenSentPredicate = [NSPredicate predicateWithFormat:@"lastSentOn != $LAST_SENT_ON"];
        hasBeenSentPredicate = [hasBeenSentPredicate predicateWithSubstitutionVariables: @{ @"LAST_SENT_ON" : [NSNull null] }];
        
        NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ userPredicate, notDeletedPredicate, hasBeenSentPredicate ] ];
        [fetchRequest setPredicate:andPredicate];
        
        NSSortDescriptor *sortOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastSentOn" ascending:NO selector:@selector(compare:)];
        [fetchRequest setSortDescriptors:@[ sortOrderDescriptor] ];

                                
    }
        
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

- (IBAction)sendButtonPushed:(id)sender {
    
    RDMLink *link = [self.linksFetchedResultsController objectAtIndexPath:self.selectedIndexPath];
    [self.delegate linkLibraryVC:self showShowSendViewForLink:link];
    
}

- (IBAction)editButtonPushed:(id)sender {
    
    RDMLink *link = [self.linksFetchedResultsController objectAtIndexPath:self.selectedIndexPath];
    [self.delegate linkLibraryVC:self shouldShowEditViewForLink:link];
    
}

- (IBAction)deleteButtonPushed:(id)sender {
    
    self.deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm Delete"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:@"Delete"
                                                otherButtonTitles:nil];
    [self.deleteActionSheet showInView:self.view];
    
}

#pragma mark - Action Sheet Delegate

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
    
        RDMLink *link = [self.linksFetchedResultsController objectAtIndexPath:self.selectedIndexPath];
        link.hasBeenDeleted = @YES;
        link.syncStatus = @1;
        
        [self.dataController saveMainContextWithCompletion:^(NSError* error) {
           
            [[RDMSyncEngine sharedEngine] startSync];
            
            if (error) {
                NSLog(@"Error");
            }
            
        }];
        
    }
    
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.linksFetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.linksFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedIndexPath && [self.selectedIndexPath isEqual:indexPath]) {
        return 88.0;
    }
    
    return 44.0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RDMLink *link = [self.linksFetchedResultsController objectAtIndexPath:indexPath];
        
    if (link.name.length > 0) {
        static NSString *RDMLibraryLinkAndNameCellID = @"RDMLibraryLinkAndNameCellID";
        
        RDMLibraryLinkAndNameCell *cell = [tableView dequeueReusableCellWithIdentifier:RDMLibraryLinkAndNameCellID
                                                                          forIndexPath:indexPath];
        
        [cell.sendButton addTarget:self
                            action:@selector(sendButtonPushed:)
                  forControlEvents:UIControlEventTouchUpInside];
        [cell.editButton addTarget:self
                            action:@selector(editButtonPushed:)
                  forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteButton addTarget:self
                            action:@selector(deleteButtonPushed:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        cell.linkLabel.text = link.url;
        cell.nameLabel.text = link.name;
        
        return cell;
    } else {
        
        static NSString *RDMLibraryLinkOnlyCellID = @"RDMLibraryLinkOnlyCellID";

        RDMLibraryLinkOnlyCell *cell = [tableView dequeueReusableCellWithIdentifier:RDMLibraryLinkOnlyCellID
                                                                       forIndexPath:indexPath];
        
        cell.linkLabel.text = link.url;
        [cell.sendButton addTarget:self
                            action:@selector(sendButtonPushed:)
                  forControlEvents:UIControlEventTouchUpInside];
        [cell.editButton addTarget:self
                            action:@selector(editButtonPushed:)
                  forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteButton addTarget:self
                              action:@selector(deleteButtonPushed:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
}

#pragma mark - Table View Delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![self.selectedIndexPath isEqual:indexPath]) {
        self.selectedIndexPath = indexPath;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    
}

#pragma mark - Scroll View Delegate

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.selectedIndexPath) {
        self.selectedIndexPath = nil;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
}

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ![self.selectedIndexPath isEqual:indexPath];
    
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
