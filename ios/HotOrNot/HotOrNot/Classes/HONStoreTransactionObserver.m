//
//  HONStoreTransactionObserver.m
//  HotOrNot
//
//  Created by BIM  on 8/21/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONStoreTransactionObserver.h"

@implementation HONStoreTransactionObserver
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	NSLog(@"[*:*] paymentQueue:(%@) [*:*]", queue.description);
	
	for (SKPaymentTransaction *transaction in transactions) {
		NSLog(@"      transaction:(%@) [*:*]", transaction.description);
		if (transaction.transactionState == SKPaymentTransactionStateFailed) {
			[self failedTransaction:transaction];
			
		} else if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
			[self completeTransaction:transaction];
			
		} else if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
		} else if (transaction.transactionState == SKPaymentTransactionStateRestored) {
			[self restoreTransaction:transaction];
		}
	}
}

-(void)failedTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"[*:*] failedTransaction:(%@) [*:*]", transaction.description);
	
	if (transaction.error.code != SKErrorPaymentCancelled) {
		[[[UIAlertView alloc] initWithTitle:@"Failed Transaction"
									message:transaction.error.description
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
	
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)restoreTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"[*:*] restoreTransaction:(%@) [*:*]", transaction.description);
	
	//If you want to save the transaction
	// [self recordTransaction: transaction];
	
	//Provide the new content
	// [self provideContent: transaction.originalTransaction.payment.entifier];
	
	//Finish the transaction
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
}


	
-(void)completeTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"[*:*] completeTransaction:(%@) [*:*]", transaction.description);
	
	//If you want to save the transaction
	//[self recordTransaction: transaction];
	
	//Provide the new content
	//[self provideContent: transaction.payment.productIdentifier];
	
	[[[UIAlertView alloc] initWithTitle:@"Completed Transaction"
								message:@"Your payment has been processed"
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
					  otherButtonTitles:nil] show];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"Y" forKey:@"iap_01"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RELOAD_EMOTION_PICKER"
														object:nil];
	
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
@end
