//
//  HONStoreProductsViewController.h
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "HONViewController.h"

@interface HONStoreProductsViewController : HONViewController <SKProductsRequestDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end
