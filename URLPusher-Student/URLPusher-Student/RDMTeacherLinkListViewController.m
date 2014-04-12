//
//  RDMTeacherLinkListViewController.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/10/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherLinkListViewController.h"

#import "RDMStudentRootViewController.h"
#import "RDMStudentDataController.h"

#import "RDMLinkListNameOnlyTableViewCell.h"
#import "RDMLinkListURLAndNameTableViewCell.h"

#import "RDMTeacher.h"
#import "RDMStudentLink.h"

#import "RDMOpenLinkHandler.h"
#import "RDMStudentSyncEngine.h"

@interface RDMTeacherLinkListViewController ()

@property (nonatomic, strong) NSFetchedResultsController *linksFetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) id syncCompleteObserver;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation RDMTeacherLinkListViewController

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
    
    self.syncCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMSyncEngineDidFinishNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification * note) {
                                                                                  
                                                                                  [self.refreshControl endRefreshing];
                                                                                  
                                                                                  if ([self.teacher.hasBeenDeleted boolValue] || self.teacher.isDeleted || !self.teacher.managedObjectContext) {
#warning dismiss teacher view
                                                                                      
                                                                                      
                                                                                  }
                                                                                  
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
    
    if ([segue.identifier isEqualToString:@"embedTableViewSegueID"]) {
        UITableViewController *tableViewController = [segue destinationViewController];
        [tableViewController.refreshControl addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = tableViewController.refreshControl;
        self.tableView = tableViewController.tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
}

-(void) refreshTableData:(id) sender {
    
    [[RDMStudentSyncEngine sharedEngine] startSync];
    
}

-(void) menuBarButtonItemPushed:(id) sender {
    
    [self.rdm_rootViewController openMenuViewControllerAnimated:YES withCompletion:nil];
    
}

-(void) visitLinkButtonPushed:(id) sender {
    
    RDMStudentLink *link = [self.linksFetchedResultsController objectAtIndexPath:self.selectedIndexPath];
    [RDMOpenLinkHandler openLink:link];
    
}

-(void) cancelButtonPushed:(id) sender {
    
    if (self.selectedIndexPath) {
        self.selectedIndexPath = nil;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
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

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ![self.selectedIndexPath isEqual:indexPath];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RDMStudentLink *link = [self.linksFetchedResultsController objectAtIndexPath:indexPath];
    
    if (link.name.length > 0) {
        static NSString *RDMLinkListURLAndNameTableViewCellID = @"RDMLinkListURLAndNameTableViewCellID";
        
        RDMLinkListURLAndNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RDMLinkListURLAndNameTableViewCellID
                                                                          forIndexPath:indexPath];
        
        [cell.visitLinkButton addTarget:self action:@selector(visitLinkButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cancelButton addTarget:self action:@selector(cancelButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
        cell.linkLabel.text = link.url;
        cell.nameLabel.text = link.name;
        
        return cell;
    } else {
        
        static NSString *RDMLinkListNameOnlyTableViewCellID = @"RDMLinkListNameOnlyTableViewCellID";
        
        RDMLinkListNameOnlyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RDMLinkListNameOnlyTableViewCellID
                                                                       forIndexPath:indexPath];
        
        [cell.visitLinkButton addTarget:self action:@selector(visitLinkButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cancelButton addTarget:self action:@selector(cancelButtonPushed:) forControlEvents:UIControlEventTouchUpInside];

        cell.linkLabel.text = link.url;
        
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
