//
//  PCCandyStoreTagResult.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 25/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import "PCEssentials/PCEssentials.h"

@interface PCCandyStoreTagResult : NSObject

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSNumber *per_page;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSArray *results;

@end
