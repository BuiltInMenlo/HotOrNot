//
//  HONStickerAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 13:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "CandyBox.h"
#import "PCStore.h"
#import "PicoManager.h"
#import "PicoUser.h"
#import "PicoSticker.h"

#import "PCCandyStoreSearchController.h"
#import "PCCandyStorePurchaseController.h"

extern NSString * const kFreeStickerPak;
extern NSString * const kInviteStickerPak;
extern NSString * const kAvatarStickerPak;
extern NSString * const kSelfieclubStickerPak;
extern NSString * const kClubCoverStickerPak;
extern NSString * const kPaidStickerPak;

typedef NS_ENUM(NSUInteger, HONStickerPakType) {
	HONStickerPakTypeAll = 0,
	HONStickerPakTypeSelfieclub,
	HONStickerPakTypeAvatars,
	HONStickerPakTypeClubCovers,
	HONStickerPakTypeInviteBonus,
	HONStickerPakTypeFree,
	HONStickerPakTypePaid
};


@interface HONStickerAssistant : NSObject
+ (HONStickerAssistant *)sharedInstance;

- (void)registerStickerStore;
- (NSDictionary *)fetchStickerStoreInfo;
- (void)nameForContentGroupID:(NSString *)contentGroupID completion:(void (^)(NSString *result))completion;
- (NSArray *)retrieveStickerStoreProducts;
- (void)retrieveAllStickerPakTypesWithDelay:(CGFloat)delay ignoringCache:(BOOL)ignoreCache;
- (void)retrieveStickersWithPakType:(HONStickerPakType)stickerPakType ignoringCache:(BOOL)ignoreCache completion:(void (^)(BOOL success))completion;
- (void)purchaseStickerWithContentID:(NSString *)contentID usingDelegate:(id<PCCandyStorePurchaseControllerDelegate>)delegate;
- (void)purchaseStickerPakWithContentGroupID:(NSString *)contentGroupID usingDelegate:(id<PCCandyStorePurchaseControllerDelegate>)delegate;

- (void)retrievePicoCandyUser;
- (void)refreshPicoCandyUser;

- (NSDictionary *)fetchAllCandyBoxContents;
- (BOOL)candyBoxContainsContentForContentID:(NSString *)contentID;
- (BOOL)candyBoxContainsContentGroupForContentGroupID:(NSString *)contentGroupID;
- (PicoSticker *)stickerFromCandyBoxWithContentID:(NSString *)contentID;

- (NSDictionary *)fetchCoverStickerForContentGroupID:(NSString *)contentGroupID;
- (NSArray *)fetchStickersForGroupIndex:(int)stickerGroupIndex;
- (NSArray *)fetchStickersForPakType:(HONStickerPakType)stickerPakType;
- (void)retrieveContentsForContentGroupID:(NSString *)contentGroupID ignoringCache:(BOOL)ignoreCache completion:(void (^)(NSArray *contents))completion;

- (void)purchaseStickerPakWithContentGroupID:(NSString *)contentGroupID;
- (BOOL)isStickerPakPurchasedWithContentGroupID:(NSString *)contentGroupID;
@end
