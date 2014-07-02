//
//  PCCandyStoreCategorySearchResult.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 6/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import "PCEssentials/PCEssentials.h"

@interface PCCandyStoreCategorySearchResult : PCModelObject

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSNumber *per_page;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSNumber *total_count;

@end
