//
//  HONStoreTransactionObserver.h
//  HotOrNot
//
//  Created by BIM  on 8/21/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface HONStoreTransactionObserver : NSObject <SKPaymentTransactionObserver>
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
-(void)failedTransaction:(SKPaymentTransaction *)transaction;
-(void)restoreTransaction:(SKPaymentTransaction *)transaction;
-(void)completeTransaction:(SKPaymentTransaction *)transaction;
@end
