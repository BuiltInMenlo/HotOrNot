//
//  PCContentPrice.h
//  PCEssentials
//
//  Created by PicoCandy Pte Ltd on 16/11/13.
//  Copyright (c) 2013 PicoCandy. All rights reserved.
//

#import "PCModelObject.h"
#import "PCStoreCurrency.h"

@interface PCContentPrice : PCModelObject

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) PCStoreCurrency *currency;

@end
