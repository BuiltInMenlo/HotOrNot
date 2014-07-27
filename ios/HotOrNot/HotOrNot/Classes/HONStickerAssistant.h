//
//  HONStickerAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 13:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "PicoManager.h"
#import "PCCandyStoreSearchController.h"

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
- (void)retrieveStickersWithPakType:(HONStickerPakType)stickerPakType completion:(void (^)(id result))completion;
- (NSArray *)fetchStickersForPakType:(HONStickerPakType)stickerPakType;
@end
