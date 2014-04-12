//
//  IAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductKeyOneMonthSubscription;
UIKIT_EXTERN NSString *const IAPHelperProductKeyOneYearSubscription;

@protocol IAPHelperDelegate;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

@property (nonatomic, weak) id<IAPHelperDelegate> delegate;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

-(int)daysRemainingOnSubscription;
-(NSString *)getExpiryDateString;
-(NSDate *)getExpiryDateForMonths:(int)months;

@end

@protocol IAPHelperDelegate <NSObject>

-(void) didFinishSubscriptionTransaction:(IAPHelper*)helper;
-(void) couldNotCompleteSubscriptionTransactionWithError:(NSError*)error;
@end