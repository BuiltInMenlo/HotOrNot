//
//  HONStoreProductViewController.h
//  HotOrNot
//
//  Created by BIM  on 11/3/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "HONViewController.h"
#import "HONStoreProductVO.h"

@class HONStoreProductViewController;
@protocol HONStoreProductViewControllerDelegate <NSObject>
- (void)storeProductViewController:(HONStoreProductViewController *)storeProductViewController didDownloadProduct:(HONStoreProductVO *)storeProductVO;
- (void)storeProductViewController:(HONStoreProductViewController *)storeProductViewController didPurchaseProduct:(HONStoreProductVO *)storeProductVO;
@end

@interface HONStoreProductViewController : HONViewController <SKProductsRequestDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
- (id)initWithStoreProduct:(HONStoreProductVO *)storeProductVO;

@property (nonatomic, assign) id <HONStoreProductViewControllerDelegate> delegate;
@end
