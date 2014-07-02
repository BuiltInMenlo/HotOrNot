//
//  CandyBoxService.h
//  PicoCandySDK
//
//  Created by khangtoh on 13/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CandyBoxContent;

typedef enum
{
    CandyBoxContentSortOptionNewest,
    CandyBoxContentSortOptionMostUsed,
    CandyBoxContentSortOptionFavourite
    
} CandyBoxContentSortOption;


@interface CandyBoxService : NSObject

/**
 * If value is YES, means that CandyBoxService is running indexing service in the background
 */
@property (nonatomic, readonly) BOOL lookupReady;

+(CandyBoxService *)shared;
+(BOOL)ping;

+(CandyBoxContent *)candyBoxContentFromDictionary:(NSDictionary *)data;

-(void)addPurchasedContentToCandyBox:(CandyBoxContent *)content;
-(void)addPurchasedContentOfGroupToCandyBox:(CandyBoxContent *)content;
-(BOOL)updatePurchasedContentWithContentId:(NSString *)contentId usingInfo:(NSDictionary *)info;

-(CandyBoxContent *)contentWithContentId:(NSString *)contentId;
-(NSDictionary *)dictionaryWithContentId:(NSString *)contentId;

-(NSArray *)contentsWithSortOption:(CandyBoxContentSortOption)sortOption;
-(NSArray *)contentsWithSortOption:(CandyBoxContentSortOption)sortOption
                         sortOrder:(NSComparisonResult)sortOrder
                           withTag:(NSString *)tag;

-(BOOL)deleteContentWithContentId:(NSString *)contentId;

-(NSString *)contentGroupIdForContent:(NSString *)contentId;

/**
 * Returns list of CandyBoxContent objects belonging to content group
 * @param contentGroupId Content Group ID
 */
-(NSArray *)candyBoxContentsOfContentGroup:(NSString *)contentGroupId;

/**
 * Returns content groups purchased by user
 */
-(NSDictionary *)contentGroups;

/**
 * Returns IDs of content groups purchased by user
 */
-(NSArray *)contentGroupIds;

/**
 * Returns contents with matching tag
 */
-(NSArray *)contentsByTag:(NSString *)tag;

@end
