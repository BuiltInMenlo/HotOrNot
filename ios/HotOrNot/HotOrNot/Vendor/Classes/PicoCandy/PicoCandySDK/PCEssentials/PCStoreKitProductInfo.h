//
//  PCStoreKitProductInfo.h
//  PCStoreKit
//
//  Created by PicoCandy Pte Ltd on 13/11/13.
//  Copyright (c) 2013 PicoCandy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface PCStoreKitProductInfo : NSObject

@property (nonatomic, strong) SKProduct *product;
@property (nonatomic, assign) BOOL purchased;

@end
