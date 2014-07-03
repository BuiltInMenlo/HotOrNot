//
//  PCStoreKitManager.h
//  PCStoreKit
//
//  Created by PicoCandy Pte Ltd on 12/11/13.
//  Copyright (c) 2013 PicoCandy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCStoreKitManager.h"
#import <StoreKit/StoreKit.h>

@class PCContentGroup;

typedef enum {
    kPCStoreKitUnknownError,
    kPCStoreKitManagerBusy,
    kPCStoreKitConnectionError,
    kPCStoreKitServerError,
    kPCStoreKitInvalidClient,
    kPCStoreKitStoreNotFound,
    kPCStoreKitProductRetrievalError,
    kPCStoreKitIncorrectProductID,
    kPCStoreKitAlreadyPurchased,
    kPCStoreKitInsufficientFund,
    kPCStoreKitPaymentCancelled,
    kPCStoreKitPaymentNotAllowed,
    kPCStoreKitPaymentNotAvailable,
    kPCStoreKitServerCannotProcessTransaction,
    kPCStoreKitRestorationFailed
} kPCStoreKitError;

// For currencies
typedef void (^PCStoreKitGetStoreSuccessBlock)(NSString *title, NSString *desc);
typedef void (^PCStoreKitGetStoreFailureBlock)(kPCStoreKitError errorType);
typedef void (^PCStoreKitGotCurrenciesBlock)(NSArray *products);
typedef void (^PCStoreKitGetCurrenciesFailBlock)(kPCStoreKitError errorType);
typedef void (^PCStoreKitPurchaseSuccessBlock)(NSString *productId, SKPaymentTransaction *transaction);
typedef void (^PCStoreKitPurchaseFailureBlock)(NSString *productId, kPCStoreKitError errorType);
typedef void (^PCStoreKitRestoreSuccessBlock)(SKPaymentQueue *queue);
typedef void (^PCStoreKitRestoreFailureBlock)(kPCStoreKitError errorType);
// For contents
typedef void (^PCStoreKitPurchaseContentSuccessBlock)(NSString *productId, SKPaymentTransaction *transaction, NSString *message);
typedef void (^PCStoreKitPurchaseContentFailureBlock)(NSString *productId, kPCStoreKitError errorType, NSString *message);

@interface PCStoreKitManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, readonly) BOOL busy;
@property (nonatomic, strong) NSArray *availableVendorIds;

+(PCStoreKitManager *)sharedManager;
/**
 *  Description
 *
 *  @param success <#success description#>
 *  @param fail    <#fail description#>
 */
-(void)retrieveCurrenciesWithCompletion:(PCStoreKitGotCurrenciesBlock)success fail:(PCStoreKitGetCurrenciesFailBlock)fail;

/**
 *  Description
 *
 *  @param productId <#productId description#>
 *  @param success   <#success description#>
 *  @param fail      <#fail description#>
 */
-(void)purchaseCurrencies:(NSString *)productId withSuccess:(PCStoreKitPurchaseSuccessBlock)success fail:(PCStoreKitPurchaseFailureBlock)fail;

/**
 *  Description
 *
 *  @param contentGroup <#contentGroup description#>
 *  @param successBlock <#successBlock description#>
 *  @param failureBlock <#failureBlock description#>
 */
-(void)purchaseContentGroup:(PCContentGroup *)contentGroup
                    success:(PCStoreKitPurchaseContentSuccessBlock)successBlock
                    failure:(PCStoreKitPurchaseContentFailureBlock)failureBlock;

/**
 *  Description
 *
 *  @param success <#success description#>
 *  @param fail    <#fail description#>
 */
-(void)restorePreviousPurchasesWithSuccess:(PCStoreKitRestoreSuccessBlock)success fail:(PCStoreKitRestoreFailureBlock)fail;

@end
