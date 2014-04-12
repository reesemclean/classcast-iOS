//
//  RDMUser+Custom.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/6/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMUser+Custom.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

@implementation RDMUser (Custom)

-(void)setServerToken:(NSString*)token {
    
    NSString *tokenKey = @"serverToken";
    [UICKeyChainStore setString:token forKey:tokenKey];
}

-(NSString*)serverToken {
    
    NSString *tokenKey = @"serverToken";
    return [UICKeyChainStore stringForKey:tokenKey];
    
}

-(NSString*) subscriptionTimeLeftString {
    
    NSDate *now = [NSDate date];
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    if (self.subscriptionExpirationDate && [self.subscriptionExpirationDate compare:now] == NSOrderedAscending) {
        //Expired
        
        return @"Subscription Expired";
        
    } else if (self.subscriptionExpirationDate) {
        //More than a week
        return [NSString stringWithFormat:@"Expires %@", [dateFormatter stringFromDate:self.subscriptionExpirationDate]];
        
        
    } else {
        //Free account
        return @"Free Account";

    }

}

-(BOOL) hasValidSubscription {
    
    NSDate *now = [NSDate date];
    
    if (self.subscriptionExpirationDate && [self.subscriptionExpirationDate compare:now] == NSOrderedDescending) {
        return YES;
    } else {
        
        NSData *incompleteTransactionsData = [UICKeyChainStore dataForKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
        if (incompleteTransactionsData) {
            NSArray *incompleteTransactions = [NSKeyedUnarchiver unarchiveObjectWithData:incompleteTransactionsData];
            if ([incompleteTransactions count] > 0) {
                return YES;
            }
        }
        
        return NO;
    }
    
}

-(NSString*)usersDeviceToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
}

@end
