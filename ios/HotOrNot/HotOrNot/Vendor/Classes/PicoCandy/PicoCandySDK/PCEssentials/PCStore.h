//
//  PCStore.h
//  CandyStoreDemoApp
//
//  Created by PicoCandy Pte Ltd on 12/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import "PCModelObject.h"
#import "PCStoreCurrency.h"

// {
//    "title":"PicoCandy Store",
//    "created_at":"2013-04-17T09:12:36-00:00",
//    "update_at":"2013-04-17T09:12:36-00:00",
//    "description":"This is the awesome PicoCandy Sticker Store."
// }

@class PCCurrency;

@interface PCStore : PCModelObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *updated_at;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) PCStoreCurrency *currency;


// Returns an array of available products for a store
- (NSArray *)availableProducts;
// Returns an array of vendor_id of available products for a store
- (NSArray *)availableVendorIds;
// Returns the currency product with a product id (vendor_id)
- (PCCurrency *)currencyProductWithVendorId:(NSString *)vendorId;

@end
