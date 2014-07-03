//
//  PCWallet.h
//  PCEssentials
//
//  Created by PicoCandy Pte Ltd on 18/11/13.
//  Copyright (c) 2013 PicoCandy. All rights reserved.
//

#import "PCModelObject.h"
#import "PCStoreCurrency.h"

@interface PCWallet : PCModelObject

@property (nonatomic, strong) NSString *store_id;
@property (nonatomic, strong) PCStoreCurrency *currency;
@property (nonatomic, strong) NSNumber *balance;

@end
