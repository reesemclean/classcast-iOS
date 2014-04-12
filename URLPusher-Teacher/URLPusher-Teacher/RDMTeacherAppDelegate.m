//
//  RDMAppDelegate.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/30/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMTeacherAppDelegate.h"

#import "RDMSyncEngine.h"
#import "RDMInAppPurchaseHelper.h"
#import "NSData+NSString_Conversion.h"
#import "RDMTeacherDataController.h"

#import <AFNetworkActivityIndicatorManager.h>

@implementation RDMTeacherAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    [RDMInAppPurchaseHelper sharedInstance];
    
    if ([[RDMTeacherDataController sharedInstance] currentUser]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert)];
    }
    
    // Override point for customization after application launch
    if (RDM_IS_IOS7_BASED_ON_VIEW(self.window)) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(89.0/255.0) green:(147.0/255.0) blue:(181.0/255.0) alpha:1.0]];
    } else {
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:(89.0/255.0) green:(147.0/255.0) blue:(181.0/255.0) alpha:1.0]];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"RDM_HAS_BOTHERED_USER_ABOUT_SUBSCRIPTION_ON_THIS_DEVICE" : @NO }];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[RDMSyncEngine sharedEngine] startSync];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{

    NSString *tokenAsString = [deviceToken hexadecimalString];
    
    [[NSUserDefaults standardUserDefaults] setObject:tokenAsString forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[RDMSyncEngine sharedEngine] startSync];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)payload {
    // Detect if APN is received on Background or Foreground state
    NSLog(@"Payload: %@", payload);
    
    [[RDMSyncEngine sharedEngine] startSync];
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if (![[url host] isEqualToString:@"resetpassword"]) {
        return NO;
    }
    
    if ([[url pathComponents] count] < 2) {
        return NO;
    }
    
    NSString *resetToken = [[url pathComponents] objectAtIndex:1];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RDM_SHOULD_SHOW_PASSWORD_RESET_VIEW" object:resetToken];
    
    return YES;
}

@end
