//
//  RDMInAppPurchaseHelper.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/13/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMInAppPurchaseHelper.h"

@implementation RDMInAppPurchaseHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static RDMInAppPurchaseHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      IAPHelperProductKeyOneMonthSubscription,
                                      IAPHelperProductKeyOneYearSubscription,
                                
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
