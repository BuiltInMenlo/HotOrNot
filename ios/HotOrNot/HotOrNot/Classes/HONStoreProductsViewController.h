//
//  HONStoreProductsViewController.h
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "HONViewController.h"

@class HONStoreProductsViewController;
@protocol HONStoreProductsViewControllerDelegate <NSObject>
- (void)storeProductsViewController:(HONStoreProductsViewController *)storeProductsViewController didDownloadProduct:(HONStoreProductVO *)storeProductVO;
- (void)storeProductsViewController:(HONStoreProductsViewController *)storeProductsViewController didPurchaseProduct:(HONStoreProductVO *)storeProductVO;
@end

@interface HONStoreProductsViewController : HONViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) id <HONStoreProductsViewControllerDelegate> delegate;
@end
