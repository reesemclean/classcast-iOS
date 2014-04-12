//
//  IAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "RDMTeacherDataController.h"
#import "RDMUser+Custom.h"

#import <AFNetworking/AFNetworking.h>

#import "RDMTokenAuthAPIClient.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "UIAlertView+ErrorHelpers.h"

#import "RDMConfiguration.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductKeyOneMonthSubscription = ONE_MONTH_IN_APP_SUBSCRIPTION_KEY;
NSString *const IAPHelperProductKeyOneYearSubscription = ONE_YEAR_IN_APP_SUBSCRIPTION_KEY;

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation IAPHelper {
    
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        NSData *transactionsData = [[UICKeyChainStore keyChainStore] dataForKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
        
        if (transactionsData) {
            NSArray *incompleteTransactions = [NSKeyedUnarchiver unarchiveObjectWithData:transactionsData];
            for (NSData *receiptData in incompleteTransactions) {
                
                [self validateReceiptData:receiptData forTransaction:nil];
                
            }
        }
        
        
    }
    return self;
    
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

-(int) numberOfMonthsForTransaction:(SKPaymentTransaction*) transaction {
    
    if ([transaction.transactionIdentifier isEqualToString:IAPHelperProductKeyOneMonthSubscription]) {
        return 1;
    } else if ([transaction.transactionIdentifier isEqualToString:IAPHelperProductKeyOneYearSubscription]) {
        return 12;
    }
    
    return 0;
}

-(void) validateReceiptData:(NSData*)receiptData forTransaction:(SKPaymentTransaction*) transaction {
    
    NSMutableURLRequest *urlRequest = [[RDMTokenAuthAPIClient sharedClient] sendVerifyReceiptRequestForUserWithToken:[[[RDMTeacherDataController sharedInstance] currentUser] serverToken]
                                                                                                     withReceiptData:receiptData];
    
    if (!urlRequest) {
        NSData *transactionsData = [[UICKeyChainStore keyChainStore] dataForKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
        
        if (transactionsData) {
            NSMutableArray *incompleteTransactions = [[NSKeyedUnarchiver unarchiveObjectWithData:transactionsData] mutableCopy];
            [incompleteTransactions addObject:receiptData];
            NSData *transactions = [NSKeyedArchiver archivedDataWithRootObject:incompleteTransactions];
            [[UICKeyChainStore keyChainStore] setData:transactions forKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RDMDidReceive401WithTokenBasedAuthentication" object:nil];
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"There was a problem syncing your account. Please sign in again."];
        
        return;
    }
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response Object: %@", responseObject);
        NSDictionary *userDictionary = responseObject;
        
        RDMUser *user = [[RDMTeacherDataController sharedInstance] currentUser];
        
        user.emailAddress = [userDictionary objectForKey:@"emailAddress"];
        user.displayName = [userDictionary objectForKey:@"displayName"];
        user.registrationToken = [userDictionary objectForKey:@"registrationToken"];
        if (userDictionary[@"subscriptionExpirationDate"] == [NSNull null]) {
            user.subscriptionExpirationDate = nil;
        } else {
            user.subscriptionExpirationDate = [self.dateFormatter dateFromString:userDictionary[@"subscriptionExpirationDate"]];
        }
        
        [[RDMTeacherDataController sharedInstance] saveMainContextWithCompletion:^(NSError *error) {
            
            if (error) {
                NSLog(@"Error: %@", error);
            }
            
            [self.delegate didFinishSubscriptionTransaction:self];
            if (transaction) {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }

            NSData *transactionsData = [[UICKeyChainStore keyChainStore] dataForKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
            if (transactionsData) {
                NSMutableArray *incompleteTransactions = [[NSKeyedUnarchiver unarchiveObjectWithData:transactionsData] mutableCopy];
                [incompleteTransactions removeObject:receiptData];
                if ([incompleteTransactions count] == 0) {
                    [[UICKeyChainStore keyChainStore] removeItemForKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
                } else {
                    NSData *transactions = [NSKeyedArchiver archivedDataWithRootObject:incompleteTransactions];
                    [[UICKeyChainStore keyChainStore] setData:transactions forKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
                }
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:nil userInfo:nil];

        }];
        
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSDictionary *userInfo;
        switch (response.statusCode) {
            case 401:
                userInfo = @{ @"RDMErrorTitleKey": @"Could not Verify",
                              NSLocalizedDescriptionKey : @"This appears to be an invalid purchase. Please try again." };
                break;
            case 500:
            default: {
        
                NSData *transactionsData = [[UICKeyChainStore keyChainStore] dataForKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
                NSMutableArray *incompleteTransactions = nil;
                if (transactionsData) {
                   incompleteTransactions = [[NSKeyedUnarchiver unarchiveObjectWithData:transactionsData] mutableCopy];
                } else {
                    incompleteTransactions = [NSMutableArray array];
                }
                
                [incompleteTransactions addObject:receiptData];
                NSData *transactions = [NSKeyedArchiver archivedDataWithRootObject:incompleteTransactions];
                [[UICKeyChainStore keyChainStore] setData:transactions forKey:@"RDM_INCOMPLETE_TRANSACTIONS"];
                

                userInfo = @{ @"RDMErrorTitleKey": @"Could not Verify",
                              NSLocalizedDescriptionKey : @"There appears to be something wrong with the server. We will try again later to activate your account — your account will be active on this device in the meantime." };
            }
                break;
        }
        
        NSError *localError = [NSError errorWithDomain:@"com.lunchboxapps"
                                                  code:response.statusCode
                                              userInfo:userInfo];
        
        NSLog(@"Error: %@", error);
        [self.delegate couldNotCompleteSubscriptionTransactionWithError:localError];
        if (transaction) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    };
    
    AFHTTPRequestOperation *operation = [[RDMTokenAuthAPIClient sharedClient] HTTPRequestOperationWithRequest:urlRequest
                                                                                                      success:successBlock
                                                                                                      failure:failureBlock];
    [operation start];
    
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {

    [self validateReceiptData:transaction.transactionReceipt forTransaction:transaction];
    
}

-(int)daysRemainingOnSubscription {
    
    NSDate * expiryDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    [dateformatter setDateFormat:@"dd MM yyyy"];
    NSTimeInterval timeInt = [[dateformatter dateFromString:[dateformatter stringFromDate:expiryDate]] timeIntervalSinceDate: [dateformatter dateFromString:[dateformatter stringFromDate:[NSDate date]]]]; //Is this too complex and messy?
    int days = timeInt / 60 / 60 / 24;
    
    if (days >= 0) {
        return days;
    } else {
        return 0;
    }
}

-(NSString *)getExpiryDateString {
    if ([self daysRemainingOnSubscription] > 0) {
        NSDate *today = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        return [NSString stringWithFormat:@"Subscribed! \nExpires: %@ (%i Days)",[dateFormat stringFromDate:today],[self daysRemainingOnSubscription]];
    } else {
        return @"Not Subscribed";
    }
}

-(NSDate *)getExpiryDateForMonths:(int)months {
    
    NSDate *originDate;
    
    if ([self daysRemainingOnSubscription] > 0) {
        originDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    } else {
        originDate = [NSDate date];
    }
	NSDateComponents *dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:months];
	[dateComp setDay:1]; //an extra days grace because I am nice...
	return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp toDate:originDate options:0];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self validateReceiptForTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        
        [self.delegate couldNotCompleteSubscriptionTransactionWithError:transaction.error];
        
    }
    
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end