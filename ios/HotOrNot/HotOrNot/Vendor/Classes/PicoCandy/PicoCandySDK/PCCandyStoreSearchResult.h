//
//  PCCandyStoreSearchResult.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 16/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import "PCEssentials/PCEssentials.h"

@interface PCCandyStoreSearchResult : PCModelObject

@property (nonatomic, strong) PCContentTag *category;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSNumber *per_page;
@property (nonatomic, strong) NSNumber *total_count;
@property (nonatomic, strong) NSArray *results;

@end
