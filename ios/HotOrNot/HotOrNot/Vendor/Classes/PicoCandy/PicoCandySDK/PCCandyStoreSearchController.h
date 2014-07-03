//
//  PCCandyStoreSearchController.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 15/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import "PCCandyStoreSearchResult.h"

@class PCContent, PCContentGroup;

typedef enum {
    kCandyStoreSearchUnknown,
    kCandyStoreSearchNewestStickers,
    kCandyStoreSearchNewestStickerPacks,
    kCandyStoreSearchFeaturedStickers,
    kCandyStoreSearchPopularStickers,
    kCandyStoreSearchMostPurchasedStickers
} kCandyStoreSearchType;

/**
 *  PCCandyStoreSearchControllerDelegate is a delegate protocol for getting callbacks when requests made 
 *  through PCCandyStoreSearchController are completed.
 */
@protocol PCCandyStoreSearchControllerDelegate <NSObject>

@optional
/**
 *  Description
 *
 *  @param controller <#controller description#>
 *  @param result     <#result description#>
 *  @param searchType <#searchType description#>
 */
-(void)candyStoreSearchController:(id)controller fetchedStickers:(PCCandyStoreSearchResult *)result forSearchType:(kCandyStoreSearchType)searchType;

/**
 *  Description
 *
 *  @param controller <#controller description#>
 *  @param searchType <#searchType description#>
 */
-(void)candyStoreSearchController:(id)controller failedToFetchStickersForSearchType:(kCandyStoreSearchType)searchType;

/**
 *  Description
 *
 *  @param controller <#controller description#>
 *  @param result     <#result description#>
 *  @param text       <#text description#>
 */
-(void)candyStoreSearchController:(id)controller fetchedStickers:(PCCandyStoreSearchResult *)result withSearchTerms:(NSString *)text;

/**
 *  <#Description#>
 *
 *  @param controller <#controller description#>
 *  @param text       <#text description#>
 */
-(void)candyStoreSearchController:(id)controller failedToFetchStickersForSearchTerms:(NSString *)text;

/**
 *  <#Description#>
 *
 *  @param controller <#controller description#>
 *  @param result     <#result description#>
 *  @param text       <#text description#>
 */
-(void)candyStoreSearchController:(id)controller fetchedStickerPacks:(PCCandyStoreSearchResult *)result withSearchTerms:(NSString *)text;

/**
 *  <#Description#>
 *
 *  @param controller <#controller description#>
 *  @param text       <#text description#>
 */
-(void)candyStoreSearchController:(id)controller failedToFetchStickerPacksForSearchTerms:(NSString *)text;

/**
 *  <#Description#>
 *
 *  @param controller <#controller description#>
 *  @param result     <#result description#>
 *  @param categoryId <#categoryId description#>
 */
-(void)candyStoreSearchController:(id)controller fetchedStickers:(PCCandyStoreSearchResult *)result withCategory:(NSString *)categoryId;

/**
 *  <#Description#>
 *
 *  @param controller <#controller description#>
 *  @param categoryId <#categoryId description#>
 */
-(void)candyStoreSearchController:(id)controller failedToFetchStickersForCategory:(NSString *)categoryId;

/**
 *  <#Description#>
 *
 *  @param controller <#controller description#>
 *  @param result     <#result description#>
 *  @param text       <#text description#>
 */
-(void)candyStoreSearchController:(id)controller fetchedAllContents:(PCCandyStoreSearchResult *)result withSearchTerms:(NSString *)text;

/**
 *  <#Description#>
 *
 *  @param controller <#controller description#>
 *  @param text       <#text description#>
 */
-(void)candyStoreSearchController:(id)controller failedToFetchAllContentsForSearchTerms:(NSString *)text;

@end

/**
 *  PCCandyStoreSearchController is a data controller that allows you to query your CandyStore. There are 
 *  various request methods that are provided by the class so you can retrieve your store's content. These
 *  request methods will require network connection and so are asynchronous operations. 
 *
 *  By using the delegation protocol PCCandyStoreSearchControllerDelegate, you can perform User Interface
 *  operations only when the request is completed and data for you request is avaliable.
 *
 */
@interface PCCandyStoreSearchController : NSObject

@property (nonatomic, strong) id<PCCandyStoreSearchControllerDelegate> delegate;
/**
 *  Description
 */
-(void)fetchNewestStickers;

/**
 *  Description
 *
 *  @param page    <#page description#>
 *  @param perPage <#perPage description#>
 */
-(void)fetchNewestStickersAtPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  <#Description#>
 */
-(void)fetchNewestStickerPacks;

/**
 *  Description
 *
 *  @param page    <#page description#>
 *  @param perPage <#perPage description#>
 */
-(void)fetchNewestStickerPacksAtPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  Description
 */
-(void)fetchMostPurchasedStickers;

/**
 *  Description
 *
 *  @param page    <#page description#>
 *  @param perPage <#perPage description#>
 */
-(void)fetchMostPurchasedStickersAtPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  Description
 */
-(void)fetchFeaturedStickers;

/**
 *  <#Description#>
 *
 *  @param page    <#page description#>
 *  @param perPage <#perPage description#>
 */
-(void)fetchFeaturedStickersAtPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  Description
 */
-(void)fetchPopularStickers;

/**
 *  Description
 *
 *  @param page    <#page description#>
 *  @param perPage <#perPage description#>
 */
-(void)fetchPopularStickersAtPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  Description
 *
 *  @param text          <#text description#>
 *  @param page          <#page description#>
 *  @param perPage       <#perPage description#>
 *  @param completeBlock <#completeBlock description#>
 */
-(void)fetchAllContentsWithSearchTerms:(NSString *)text atPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage
                            completion:(void (^)(BOOL success, id responseObject))completeBlock;

/**
 *  Description
 *
 *  @param text <#text description#>
 */
-(void)fetchAllContentsWithSearchTerms:(NSString *)text;

/**
 *  Description
 *
 *  @param text    <#text description#>
 *  @param page    <#page description#>
 *  @param perPage <#perPage description#>
 */
-(void)fetchAllContentsWithSearchTerms:(NSString *)text atPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  <#Description#>
 *
 *  @param text <#text description#>
 */
-(void)fetchStickersWithSearchTerms:(NSString *)text;

/**
 *  <#Description#>
 *
 *  @param text    <#text description#>
 *  @param page    <#page description#>
 *  @param perPage <#perPage description#>
 */
-(void)fetchStickersWithSearchTerms:(NSString *)text atPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  <#Description#>
 *
 *  @param text <#text description#>
 */
-(void)fetchStickerPacksWithSearchTerms:(NSString *)text;

/**
 *  <#Description#>
 *
 *  @param text    <#text description#>
 *  @param page    <#page description#>
 *  @param perPage <#perPage description#>
 */
-(void)fetchStickerPacksWithSearchTerms:(NSString *)text atPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  <#Description#>
 *
 *  @param categoryId <#categoryId description#>
 */
-(void)fetchStickersWithCategory:(NSString *)categoryId;

/**
 *  <#Description#>
 *
 *  @param categoryId <#categoryId description#>
 *  @param page       <#page description#>
 *  @param perPage    <#perPage description#>
 */
-(void)fetchStickersWithCategory:(NSString *)categoryId atPage:(NSUInteger)page itemsPerPage:(NSUInteger)perPage;

/**
 *  <#Description#>
 *
 *  @param contentId <#contentId description#>
 *  @param complete  <#complete description#>
 */
-(void)fetchStickerInfo:(NSString *)contentId completion:(void (^)(BOOL success, PCContent *content))complete;

/**
 *  <#Description#>
 *
 *  @param contentGroupId <#contentGroupId description#>
 *  @param complete       <#complete description#>
 */
-(void)fetchStickerPackInfo:(NSString *)contentGroupId completion:(void (^)(BOOL success, PCContentGroup *contentGroup))complete;

@end
