//
//  RDMStudentMenuViewController.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMStudentMenuViewController.h"

#import "RDMStudentMenuViewCell.h"
#import "RDMRegisterDeviceViewController.h"
#import "RDMTeacher.h"

#import "RDMTeacherLinkListViewController.h"
#import "RDMTeacherLinkListViewController_ipad.h"

@interface RDMStudentMenuViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingTableViewConstraint;
@property (nonatomic, strong) RDMTeacher *currentlySelectedTeacher;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSFetchedResultsController *teachersFetchedResultsController;

@end

@implementation RDMStudentMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.currentlySelectedTeacher = nil;
    self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];

    if (!RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        //Hacking the margin for group table view
        
        CGFloat marginDelta = 40.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            marginDelta = 8.0;
        }
        
        self.leadingTableViewConstraint.constant = -marginDelta;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetched Results Controller

-(NSFetchedResultsController*) teachersFetchedResultsController {
    
    if (_teachersFetchedResultsController) {
        return _teachersFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RDMTeacher"];
    
    NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"device == %@", self.dataController.device];
    NSPredicate *notDeletedPredicate = [NSPredicate predicateWithFormat:@"hasBeenDeleted == %@", @NO];
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ devicePredicate, notDeletedPredicate ] ];
    [fetchRequest setPredicate:andPredicate];
    
    NSSortDescriptor *sortOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdated" ascending:NO selector:@selector(compare:)];
    [fetchRequest setSortDescriptors:@[ sortOrderDescriptor] ];
    
    _teachersFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                           managedObjectContext:self.dataController.managedObjectContext
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
    _teachersFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_teachersFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _teachersFetchedResultsController;
    
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1: {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.teachersFetchedResultsController sections] objectAtIndex:section -1];
            return [sectionInfo numberOfObjects];
        }
            break;
        default:
            break;
    }
    return 0;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0;
            break;
        case 1:
            return 44.0;
            break;

        default:
            break;
    }
    return 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return nil;
            break;
        case 1:
            return @"Teachers";
            break;
        default:
            break;
    }
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), [self tableView:tableView heightForHeaderInSection:section])];
        container.backgroundColor = [UIColor clearColor];
        
        CGFloat padding = 16.0;
        if (!RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
            //Hacking the margin for group table view
            
            padding = 60.0;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                padding = 26.0;
            }
            
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, CGRectGetWidth(container.frame)-padding, CGRectGetHeight(container.frame))];
        label.backgroundColor = [UIColor clearColor];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        label.textColor = [UIColor colorWithWhite:1.0 alpha:.90];
        
        [container addSubview:label];
        
        return container;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RDMStudentMenuViewCellID = @"RDMStudentMenuViewCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RDMStudentMenuViewCellID
                                                            forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

-(void) configureCell:(UITableViewCell*)theCell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    RDMStudentMenuViewCell *cell = (RDMStudentMenuViewCell*)theCell;
    
    switch (indexPath.section) {
        case 0:
            cell.titleLabel.text = @"Add Teacher";
            break;
        case 1: {
         
            RDMTeacher *teacher = [self.teachersFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                                              inSection:0]];
            cell.titleLabel.text = teacher.displayName;
        }
            break;
        default:
            break;
    }
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)theCell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RDMStudentMenuViewCell *cell = (RDMStudentMenuViewCell*)theCell;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    
}

#pragma mark - Table View Delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RDMStudentRootViewController *rootVC = (RDMStudentRootViewController*)self.rdm_rootViewController;
    
    UIViewController *newViewController = nil;
    
    switch (indexPath.section) {
        case 0: {
            
            if (!self.currentlySelectedTeacher) {
                [rootVC closeMenuViewControllerAnimated:YES withCompletion:nil];
                return;
            }
            
            self.currentlySelectedTeacher = nil;

            UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMRegisterDeviceViewControllerID"];
            RDMRegisterDeviceViewController *vc = (RDMRegisterDeviceViewController*)[navVC topViewController];
            vc.dataController = self.dataController;
            newViewController = navVC;
            
        }
            break;
        case 1: {
            
            RDMTeacher *teacher = [self.teachersFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                                              inSection:indexPath.section - 1]];
            
            if ([self.currentlySelectedTeacher isEqual:teacher]) {
                [rootVC closeMenuViewControllerAnimated:YES withCompletion:nil];
                return;
            }
            
            self.currentlySelectedTeacher = teacher;
            UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherLinkListViewControllerID"];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                RDMTeacherLinkListViewController *vc = (RDMTeacherLinkListViewController*)[navVC topViewController];
                vc.dataController = self.dataController;
                vc.teacher = teacher;
            } else {
                RDMTeacherLinkListViewController_ipad *vc = (RDMTeacherLinkListViewController_ipad*)[navVC topViewController];
                vc.dataController = self.dataController;
                vc.teacher = teacher;
            }
            
            newViewController = navVC;
            
        }
            break;
        default:
            break;
    }
    
    [rootVC replaceCenterViewControllerAnimated:YES withCenterViewController:newViewController withCompletion:nil];
   
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
    
    NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
    NSIndexPath *adjustedNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section + 1];

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:adjustedNewIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:adjustedIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[ adjustedIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:adjustedIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:adjustedNewIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
