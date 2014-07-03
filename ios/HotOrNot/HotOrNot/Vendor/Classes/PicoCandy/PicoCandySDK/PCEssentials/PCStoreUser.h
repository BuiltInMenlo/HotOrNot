//
//  PCStoreUser.h
//  PCEssentials
//
//  Created by PicoCandy Pte Ltd on 18/11/13.
//  Copyright (c) 2013 PicoCandy. All rights reserved.
//

#import "PCModelObject.h"

@class PCUserAccountMeta, PCWallet;

@interface PCStoreUser : PCModelObject


@property (nonatomic, strong) NSString *store_user_id;
@property (nonatomic, strong) PCUserAccountMeta *account_meta;
@property (nonatomic, strong) PCWallet *wallet;

@end
