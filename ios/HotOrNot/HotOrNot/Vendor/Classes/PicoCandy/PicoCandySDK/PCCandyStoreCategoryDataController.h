//
//  PCCandyStoreCategoryDataController.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 6/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCCandyStoreCategorySearchResult.h"

@protocol PCCandyStoreCategoryDataControllerDelegate <NSObject>

-(void)categoryDataController:(id)controller fetchedAllCategories:(PCCandyStoreCategorySearchResult *)result;
-(void)categoryDataControllerFailedToFetchAllCategories:(id)controller;

@end

@interface PCCandyStoreCategoryDataController : NSObject

@property (nonatomic, strong) id<PCCandyStoreCategoryDataControllerDelegate> delegate;

-(void)fetchAllCategories;

-(void)fetchCategoryById:(NSString *)categoryId;

-(void)fetchCategoryByName:(NSString *)name;

@end
