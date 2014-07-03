//
//  PCStoreCurrency.h
//  CandyStoreDemoApp
//
//  Created by PicoCandy Pte Ltd on 12/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import "PCModelObject.h"

@interface PCStoreCurrency : PCModelObject
{
    
}

@property (strong, nonatomic) NSString *currency_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *products;

@end
