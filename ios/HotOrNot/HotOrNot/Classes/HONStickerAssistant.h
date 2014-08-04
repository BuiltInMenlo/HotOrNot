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
extern NSString * const kClubCoverStickerPak;
extern NSString * const kPaidStickerPak;

typedef NS_ENUM(NSInteger, HONStickerPakType) {
	HONStickerPakTypeAll = 0,
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
- (NSArray *)retrieveStickerStoreProducts;
- (void)retrieveStickersWithPakType:(HONStickerPakType)stickerPakType completion:(void (^)(id result))completion;
- (void)purchaseStickerWithContentID:(NSString *)contentID usingDelegate:(id<PCCandyStorePurchaseControllerDelegate>)delegate;
- (void)purchaseStickerPakWithContentGroupID:(NSString *)contentGroupID usingDelegate:(id<PCCandyStorePurchaseControllerDelegate>)delegate;

- (void)retrievePicoCandyUser;
- (void)refreshPicoCandyUser;

- (NSDictionary *)fetchAllCandyBoxContents;
- (BOOL)candyBoxContainsContentForContentID:(NSString *)contentID;
- (BOOL)candyBoxContainsContentGroupForContentGroupID:(NSString *)contentGroupID;
- (PicoSticker *)stickerFromCandyBoxWithContentID:(NSString *)contentID;


- (NSArray *)fetchStickersForPakType:(HONStickerPakType)stickerPakType;
- (void)retrieveContentsForContentGroup:(NSString *)contentGroupID completion:(void (^)(NSArray *contents))completion;
@end
