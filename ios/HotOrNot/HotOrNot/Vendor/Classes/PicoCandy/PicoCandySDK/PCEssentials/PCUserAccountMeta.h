//
//  PCUserAccountMeta.h
//  PCEssentials
//
//  Created by PicoCandy Pte Ltd on 18/11/13.
//  Copyright (c) 2013 PicoCandy. All rights reserved.
//

#import "PCModelObject.h"

@interface PCUserAccountMeta : PCModelObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *device_identifier;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *fb_user_id;
@property (nonatomic, strong) NSString *twitter_user_id;
@property (nonatomic, strong) NSString *clientapp_user_id;
@property (nonatomic, strong) NSString *store_user_id;


@end
