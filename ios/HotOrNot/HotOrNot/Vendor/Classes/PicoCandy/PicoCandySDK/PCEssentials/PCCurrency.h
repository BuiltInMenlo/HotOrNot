//
//  PCCurrency.h
//  CandyStoreDemoApp
//
//  Created by PicoCandy Pte Ltd on 12/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import "PCModelObject.h"

@interface PCCurrency : PCModelObject
//{
//    "price": "0.99",
//    "product_id": "com.picocandy.currency.527df037c4a90923e6000088.1000",
//    "quantity": 1000
//}
@property (strong, nonatomic) NSString *currency_product_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *vendor_id;
@property (strong, nonatomic) NSNumber *quantity;

@end
