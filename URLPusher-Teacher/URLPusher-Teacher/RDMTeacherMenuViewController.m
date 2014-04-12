//
//  RDMTeacherMenuViewController.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/30/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherMenuViewController.h"
#import "RDMMenuViewCell.h"

#import "RDMTeacherDataController.h"
#import "RDMGroup.h"

#import "RDMTeacherSaveLinkViewController.h"
#import "RDMTeacherLinkLibraryViewController.h"
#import "RDMTeacherLinkLibraryViewController_iPad.h"
#import "RDMSetupDevicesViewController.h"
#import "RDMSetupGroupsViewController.h"
#import "RDMSetupDevicesViewController_iPad.h"

#import "RDMLinkLibraryDelegate.h"
#import "RDMTeacherAccountViewController.h"
#import "RDMSendLinkViewController.h"

#import "RDMRootViewController.h"

#import "UIImage+ImageEffects.h"

#import "RDMUser.h"

#import "RDMSyncEngine.h"

#import "RDMInAppPurchaseHelper.h"

@interface RDMTeacherMenuViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, RDMLinkLibraryDelegate, RDMSendLinkViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeadingConstraint;
@property (nonatomic, strong) NSIndexPath *currentlySelectedPath;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *subscribeRenewButton;
- (IBAction)subscribeRenewButtonPushed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *accountStatusLabel;

@property (nonatomic, strong) id syncCompleteObserver;
@property (nonatomic, strong) id purchaseCompleteObserver;


@end

@implementation RDMTeacherMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentlySelectedPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    
    if (!RDM_IS_IOS7_BASED_ON_VIEW(self.view)) {
        //Hacking the margin for group table view
        
        CGFloat marginDelta = 40.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            marginDelta = 8.0;
        }
        
        self.tableViewLeadingConstraint.constant = -marginDelta;
    }
    
    self.tableView.backgroundView = nil;
//    self.tableView.backgroundColor = [UIColor colorWithRed:244.0/255.0
//                                                     green:244.0/255.0
//                                                      blue:246.0/255.0
//                                                     alpha:1.0];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIImage *buttonBackground = [[UIImage imageNamed:@"buttonBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.subscribeRenewButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    
    self.purchaseCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:IAPHelperProductPurchasedNotification
                                                                                     object:nil
                                                                                      queue:nil
                                                                                 usingBlock:^(NSNotification * note) {
                                                                                     
                                                                                     [self adjustSubscribeButton];
                                                                                     
                                                                                 }];
    
    self.syncCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName:RDMSyncEngineDidFinishNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * note) {
                                                      
                                                      [self adjustSubscribeButton];
                                                      
                                                  }];
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self adjustSubscribeButton];
    
}

-(void) adjustSubscribeButton {
    
    RDMUser *user = [[RDMTeacherDataController sharedInstance] currentUser];
    
    if (!user) {
        return;
    }
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:7];
    NSDate *sevenDaysFromNow = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                                             toDate:now options:0];
    
    if (user.subscriptionExpirationDate && [user.subscriptionExpirationDate compare:now] == NSOrderedAscending) {
        //Expired
        
        self.accountStatusLabel.hidden = NO;
        self.subscribeRenewButton.hidden = NO;
        
        self.accountStatusLabel.text = @"Subscription Expired";
        [self.subscribeRenewButton setTitle:@"Renew"
                                   forState:UIControlStateNormal];
        
    } else if (user.subscriptionExpirationDate && [user.subscriptionExpirationDate compare:sevenDaysFromNow] == NSOrderedAscending) {
        //Less than a week
        self.accountStatusLabel.hidden = NO;
        self.subscribeRenewButton.hidden = NO;;
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSDayCalendarUnit | NSHourCalendarUnit
                                                   fromDate:user.subscriptionExpirationDate
                                                     toDate:now
                                                    options:0];
        
        if (components.day > 0) {
            self.accountStatusLabel.text = [NSString stringWithFormat:@"Subscription Will Expire in %ld Days", (long)components.day];
        } else {
            self.accountStatusLabel.text = @"Subscription Will Expire in Less than a Day.";
        }
        
        [self.subscribeRenewButton setTitle:@"Renew"
                                   forState:UIControlStateNormal];
        
    } else if (user.subscriptionExpirationDate) {
        //More than a week
        self.accountStatusLabel.hidden = YES;
        self.subscribeRenewButton.hidden = YES;
        
    } else {
        //Free account
        self.accountStatusLabel.hidden = NO;
        self.subscribeRenewButton.hidden = NO;
        
        self.accountStatusLabel.text = @"Free Account";
        [self.subscribeRenewButton setTitle:@"Subscribe"
                                   forState:UIControlStateNormal];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.syncCompleteObserver];
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 3;
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
            return 0;
            break;
        case 2:
            return 0;
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
            return nil;
            break;
        case 2:
            return nil;
            break;
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RDMMenuViewCellID = @"RDMMenuViewCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RDMMenuViewCellID
                                                            forIndexPath:indexPath];

    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

-(void) configureCell:(UITableViewCell*)theCell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    RDMMenuViewCell *cell = (RDMMenuViewCell*)theCell;
    
    switch (indexPath.section) {
        case 0:
            cell.titleLabel.text = @"Send Link";
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"Save Link for Later";
                    break;
                case 1:
                    cell.titleLabel.text = @"Link Library";
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"Setup Devices";
                    break;
                case 1:
                    cell.titleLabel.text = @"Groups";
                    break;
                case 2:
                    cell.titleLabel.text = @"Account";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }

}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)theCell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RDMMenuViewCell *cell = (RDMMenuViewCell*)theCell;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    
}

#pragma mark - Table View Delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RDMRootViewController *rootVC = (RDMRootViewController*)self.rdm_rootViewController;

    if ([indexPath isEqual:self.currentlySelectedPath]) {
        [rootVC closeMenuViewControllerAnimated:YES withCompletion:nil];
        return;
    }
    
    self.currentlySelectedPath = indexPath;
    
    UIViewController *newViewController = nil;
    
    switch (indexPath.section) {
        case 0: {
            
            UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMSendLinkViewControllerID"];
            RDMSendLinkViewController *vc = (RDMSendLinkViewController*)[navVC topViewController];
            vc.delegate = self;
            vc.dataController = self.dataController;
            newViewController = navVC;
            
        }
            break;
        case 1:
            switch (indexPath.row) {
                case 0: {
                    UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherSaveLinkViewControllerID"];
                    RDMTeacherSaveLinkViewController *vc = (RDMTeacherSaveLinkViewController*)[navVC topViewController];
                    vc.dataController = self.dataController;
                    newViewController = navVC;
                }
                    break;
                case 1: {
                    UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherLinkLibraryViewControllerID"];
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                        RDMTeacherLinkLibraryViewController *vc = (RDMTeacherLinkLibraryViewController*)[navVC topViewController];
                        vc.delegate = self;
                        vc.dataController = self.dataController;
                        newViewController = navVC;
                    } else {
                        RDMTeacherLinkLibraryViewController_iPad *vc = (RDMTeacherLinkLibraryViewController_iPad*)[navVC topViewController];
                        vc.delegate = self;
                        vc.dataController = self.dataController;
                        newViewController = navVC;
                    }
                }
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0: {
                    UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMSetupDevicesViewControllerID"];
                    RDMSetupDevicesViewController *vc = (RDMSetupDevicesViewController*)[navVC topViewController];
                    vc.dataController = self.dataController;
                    newViewController = navVC;
                }
                    break;
                case 1: {
                    UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMSetupGroupsViewControllerID"];
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                        RDMSetupGroupsViewController *vc = (RDMSetupGroupsViewController*)[navVC topViewController];
                        vc.dataController = self.dataController;
                        newViewController = navVC;
                    } else {
                        RDMSetupDevicesViewController_iPad *vc = (RDMSetupDevicesViewController_iPad*)[navVC topViewController];
                        vc.dataController = self.dataController;
                        newViewController = navVC;
                    }
                    
                    
                }
                    break;
                case 2: {
                    self.currentlySelectedPath = nil;
                    [self presentAccountViewControllerAnimated:YES];
                    return;
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }

    [rootVC replaceCenterViewControllerAnimated:YES
                       withCenterViewController:newViewController
                                 withCompletion:^(UIViewController *controller) {
                                     
                                 }];

}

-(void) presentAccountViewControllerAnimated:(BOOL)animated {
    
    [self.delegate teacherMenuShouldShowAccountVC:self];
    
}

#pragma mark - Link Library View Delegate

-(void) linkLibraryVC:(RDMTeacherLinkLibraryViewController *)libraryViewController shouldShowEditViewForLink:(RDMLink *)link {
    
    self.currentlySelectedPath = [NSIndexPath indexPathForRow:0 inSection:1];

    RDMRootViewController *rootVC = (RDMRootViewController*)self.rdm_rootViewController;

    UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMTeacherSaveLinkViewControllerID"];
    RDMTeacherSaveLinkViewController *vc = (RDMTeacherSaveLinkViewController*)[navVC topViewController];
    vc.dataController = self.dataController;
    vc.link = link;
    
    [rootVC replaceCenterViewControllerAnimated:YES
                       withCenterViewController:navVC
                                 withCompletion:nil];
    
}

-(void) linkLibraryVC:(RDMTeacherLinkLibraryViewController *)libraryViewController showShowSendViewForLink:(RDMLink *)link {
    
    self.currentlySelectedPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    RDMRootViewController *rootVC = (RDMRootViewController*)self.rdm_rootViewController;

    UINavigationController *navVC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RDMSendLinkViewControllerID"];
    RDMSendLinkViewController *vc = (RDMSendLinkViewController*)[navVC topViewController];
    vc.delegate = self;
    vc.dataController = self.dataController;
    vc.link = link;

    [rootVC replaceCenterViewControllerAnimated:YES
                       withCenterViewController:navVC
                                 withCompletion:nil];
    
}

- (IBAction)subscribeRenewButtonPushed:(id)sender {
    
    [self.delegate teacherMenuShouldShowSubscriptionUpdateVC:self];
    
}

#pragma mark Send Link Delegate

-(void) sendLinkViewShouldShowSubscriptionOptions:(RDMSendLinkViewController *)sendLinkVC {
    [self.delegate teacherMenuShouldShowSubscriptionUpdateVC:self];
}
@end
