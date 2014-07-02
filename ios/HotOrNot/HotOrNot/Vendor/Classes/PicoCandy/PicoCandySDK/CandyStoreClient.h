//
//  CandyStoreClient.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 8/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicoHTTPClient.h"

@class PCStoreUser, PCCurrency, PCContentGroup, PCStore;

@interface CandyStoreClient : PicoHTTPClient

+(CandyStoreClient *)sharedClient;

- (void)getInformationOfStoreWithSuccess:(void(^)(PCStore *store))successBlock
                                 failure:(void(^)(NSError *error))failureBlock;

- (void)validateInAppPurchaseReceiptForCurrency:(PCCurrency *)currencyProduct
                                   withVendorId:(NSString *)vendorId
                         withTransactionReceipt:(NSData *)receiptData
                            withSKTransactionId:(NSString *)transactionIdentifier
                          withSKTransactionDate:(NSDate *)transactionDate
                                        success:(void (^)(PCStoreUser *storeUser, BOOL transactionValid))successBlock
                                        failure:(void (^)(NSError *error))failureBlock;

-(void)validateInAppPurchaseReceiptForContentGroup: (PCContentGroup *)contentGroup
                            withTransactionReceipt: (NSData *)receiptData
                               withSKTransactionId: (NSString *)transactionIdentifier
                             withSKTransactionDate: (NSDate *)transactionDate
                                           success: (void (^)(PCContentGroup *contentGroup, BOOL transactionValid, NSString *message))successBlock
                                           failure: (void (^)(PCContentGroup *contentGroup, NSError *error))failureBlock;

- (void)purchaseContentWithId:(NSString *)contentId
                      success:(void (^)(NSString *message))successBlock
                      failure:(void (^)(NSString *message))failureBlock;

- (void)purchaseContentGroupWithId:(NSString *)contentGroupId
                           success:(void (^)(NSString *message))successBlock
                           failure:(void (^)(NSString *message))failureBlock;

@end
