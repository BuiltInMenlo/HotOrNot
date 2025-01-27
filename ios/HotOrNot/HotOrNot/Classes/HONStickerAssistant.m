//
//  HONStickerAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 13:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "NSUserDefaults+Replacements.h"
#import "UIImageView+AFNetworking.h"

#import "NHThreadThis.h"

#import "HONStickerAssistant.h"


NSString * const kPicoCandyAppID	= @"1df5644d9e94";
NSString * const kPicoCandyAPIKey	= @"8Xzg4rCwWpwHfNCPLBvV";

NSString * const kFreeStickerPak		= @"free";
NSString * const kInviteStickerPak		= @"invite";
NSString * const kAvatarStickerPak		= @"avatar";
NSString * const kSelfieclubStickerPak	= @"selfieclub";
NSString * const kClubCoverStickerPak	= @"club";
NSString * const kPaidStickerPak		= @"paid";

NSString * const kStickersGroup		= @"stickers";
NSString * const kFacesGroup		= @"faces";
NSString * const kAnimalsGroup		= @"animals";
NSString * const kObjectsGroup		= @"objects";
NSString * const kOtherGroup		= @"other";


@implementation HONStickerAssistant
static HONStickerAssistant *sharedInstance = nil;

+ (HONStickerAssistant *)sharedInstance {
	static HONStickerAssistant *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (NSDictionary *)fetchStickerStoreInfo {
	PCStore *storeInfo = [PicoManager sharedManager].candyStore.storeInfo;
	
	return (@{@"name"			: storeInfo.name,
			  @"created"		: storeInfo.created_at,
			  @"updated"		: storeInfo.updated_at,
			  @"description"	: storeInfo.description,
			  @"currency"		: storeInfo.currency.name,
			  @"products_tot"	: [@"" stringFromInt:[storeInfo.availableProducts count]],
			  @"vendor_tot"		: [@"" stringFromInt:[storeInfo.availableVendorIds count]]});
	
}

- (void)registerStickerStore {
	PicoManager *picoManager = [PicoManager sharedManager];
	[picoManager registerStoreWithAppId:kPicoCandyAppID
								 apiKey:kPicoCandyAPIKey];
	
	PCStore *storeInfo = picoManager.candyStore.storeInfo;
	
	NSLog(@"PCStore.name:[%@]", storeInfo.name);
	NSLog(@"PCStore.created_at:[%@]", storeInfo.created_at);
	NSLog(@"PCStore.updated_at:[%@]", storeInfo.updated_at);
	NSLog(@"PCStore.description:[%@]", storeInfo.description);
}

- (NSArray *)retrieveStickerStoreProducts {
	NSMutableArray *products = [[PicoManager sharedManager].candyStore.storeInfo.availableProducts mutableCopy];
	[products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSLog(@"CandyStore.availableProduct[%d] : %@", idx, obj);
		[products addObject:obj];
	}];
	
	return ([products copy]);
}

- (void)retrievePicoCandyUser {
	PicoUser *picoUser = [PicoUser currentUser];
	NSLog(@"PicoUser.storeUserId:[%@]", picoUser.storeUserId);
	NSLog(@"PicoUser.accessToken:[%@]", picoUser.accessToken);
	NSLog(@"PicoUser.busy:[%d]", picoUser.busy);
	NSLog(@"PicoUser.requireAccountCreation:[%d]", picoUser.requireAccountCreation);
	NSLog(@"PicoUser.connected:[%d]", picoUser.connected);
	NSLog(@"PicoUser.newAccount:[%d]", picoUser.newAccount);
	NSLog(@"PicoUser.accountBalance:[%@]", picoUser.accountBalance);
	
	if (picoUser.requireAccountCreation || !picoUser.connected)
		[[PicoManager sharedManager] linkCurrentStoreUserWithClientAppId:[[HONAppDelegate infoForUser] objectForKey:@"id"]];
	
	[[HONStickerAssistant sharedInstance] fetchAllCandyBoxContents];
}

- (void)refreshPicoCandyUser {
	NSLog(@"refreshing PicoUser:");
	PicoUser *picoUser = [PicoUser currentUser];
	[picoUser fetchInfoFromServer:^(id user) {
		PicoUser *userInfo = (PicoUser *)user;
		NSLog(@"PicoUser.busy:[%d] {()}", userInfo.busy);
		NSLog(@"PicoUser.requireAccountCreation:[%d]", userInfo.requireAccountCreation);
		NSLog(@"PicoUser.connected:[%d]", userInfo.connected);
		NSLog(@"PicoUser.newAccount:[%d]", userInfo.newAccount);
		NSLog(@"PicoUser.accountBalance:[%@]", userInfo.accountBalance);
		
		[[HONStickerAssistant sharedInstance] fetchAllCandyBoxContents];
		
	} fail:^(void) {
		NSLog(@"PicoUser.fetchInfoFromServer FAILED");
	}];
}


- (void)nameForContentGroupID:(NSString *)contentGroupID completion:(void (^)(NSString *result))completion {
//	NSLog(@"--- nameForContentGroupID:[%@] ---", contentGroupID);
	PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
	[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
//		NSLog(@"///// nameForContentGroupID:[%@]%@}--(%@) /////", contentGroupID, contentGroup, contentGroup.name);
		if (completion)
			completion(contentGroup.name);
	}];
}

- (void)retrieveAllStickerPakTypesWithDelay:(CGFloat)delay ignoringCache:(BOOL)ignoreCache {
	[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeSelfieclub ignoringCache:ignoreCache completion:nil];
	
	double delayInSeconds = (double)delay;
	dispatch_time_t popTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime1, dispatch_get_main_queue(), ^(void) {
		[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeFree ignoringCache:ignoreCache completion:nil];
		
		dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime2, dispatch_get_main_queue(), ^(void) {
			[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeInviteBonus ignoringCache:ignoreCache completion:nil];
			
			dispatch_time_t popTime3 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime3, dispatch_get_main_queue(), ^(void) {
				[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypePaid ignoringCache:ignoreCache completion:nil];
				
//				dispatch_time_t popTime4 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//				dispatch_after(popTime4, dispatch_get_main_queue(), ^(void) {
//				});
			});
		});
	});
}

- (void)retrieveStickersWithPakType:(HONStickerPakType)stickerPakType ignoringCache:(BOOL)ignoreCache completion:(void (^)(BOOL success))completion {
	NSString *key = (stickerPakType == HONStickerPakTypeSelfieclub) ? kSelfieclubStickerPak : (stickerPakType == HONStickerPakTypeAvatars) ? kAvatarStickerPak : (stickerPakType == HONStickerPakTypeClubCovers) ? kClubCoverStickerPak : (stickerPakType == HONStickerPakTypeFree) ? kFreeStickerPak : (stickerPakType == HONStickerPakTypeInviteBonus) ? kInviteStickerPak : (stickerPakType == HONStickerPakTypePaid) ? kPaidStickerPak : @"all";
	NSLog(@"retrieveStickersWithPakType:[%@] ignoringCache:[%@]", key, [@"" stringFromBOOL:ignoreCache]);
	
	
	NSMutableDictionary *contentGroups = ([[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] mutableCopy] : [NSMutableDictionary dictionary];
	
	
	NSArray *contentGroupIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:key];
	PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
	for (NSString *contentGroupID in contentGroupIDs) {
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
			NSLog(@"///// fetchStickerPackInfo:[%@] {%@}--(%d) /////", contentGroupID, key, success);
			[[NHThreadThis backgroundThis] doThis:^{
				NSMutableArray *stickers = [NSMutableArray array];
				for (PCContent *content in contentGroup.contents) {
//					NSLog(@"PCContent:\n%@\t%@\t%@\t%@\t%@", contentGroupID, content.content_id, content.name, content.large_image, [[content.large_image stringByReplacingOccurrencesOfString:@"/large.gif" withString:@"/"] stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]);
					[stickers addObject:@{@"id"		: content.content_id,
										  @"cg_id"	: contentGroupID,
										  @"name"	: content.name,
										  @"price"	: content.price,
										  @"img"	: content.large_image}];
					
//					[[NHThreadThis backgroundThis] doThis:^{
//					dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((double)1.875f * NSEC_PER_SEC));
//					dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
//						UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//						[imageView setImageWithURL:[NSURL URLWithString:content.large_image]];
//					});
//					}];
				}
				
				[contentGroups setValue:[stickers copy] forKey:contentGroupID];
				[[NSUserDefaults standardUserDefaults] setValue:[contentGroups copy] forKey:@"content_groups"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}];
		}];
	}
	
	if (completion)
		completion(YES);
}


- (NSDictionary *)fetchCoverStickerForContentGroupID:(NSString *)contentGroupID {
	for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
		if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
			return (dict);
		}
	}
	
	return (nil);
}

- (NSString *)fetchContentGroupIDForGroupIndex:(int)stickerGroupIndex {
	NSDictionary *pakTypeStickers = [[NSUserDefaults standardUserDefaults] objectForKey:@"emotion_groups"];
	
	if (stickerGroupIndex == 0) {
		return ([[pakTypeStickers objectForKey:kStickersGroup] objectForKey:@"content_group"]);
		
	} else if (stickerGroupIndex == 1) {
		return ([[pakTypeStickers objectForKey:kFacesGroup] objectForKey:@"content_group"]);
		
	} else if (stickerGroupIndex == 2) {
		return ([[pakTypeStickers objectForKey:kAnimalsGroup] objectForKey:@"content_group"]);
		
	} else if (stickerGroupIndex == 3) {
		return ([[pakTypeStickers objectForKey:kObjectsGroup] objectForKey:@"content_group"]);
		
	} else if (stickerGroupIndex == 4) {
		return ([[pakTypeStickers objectForKey:kOtherGroup] objectForKey:@"content_group"]);
	}
	
	return (@"0");
}

- (NSArray *)fetchStickersForGroupIndex:(int)stickerGroupIndex {
	NSMutableDictionary *contentGroups = ([[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] mutableCopy] : [NSMutableDictionary dictionary];
	NSArray *allPakTypeStickers = [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll];
	
	NSDictionary *pakTypeStickers = [[NSUserDefaults standardUserDefaults] objectForKey:@"emotion_groups"];
	NSMutableArray *stickers = [NSMutableArray array];
	NSString *contentGroupID = @"0";
	
	if (stickerGroupIndex == 0) {
		contentGroupID = [[pakTypeStickers objectForKey:kStickersGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
//			NSLog(@"CONTENT GROUP:[%@]-=-[%@]", contentGroupID, [dict objectForKey:@"cg_id"]);
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
		
	} else if (stickerGroupIndex == 1) {
		contentGroupID = [[pakTypeStickers objectForKey:kFacesGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
//			NSLog(@"CONTENT GROUP:[%@]-=-[%@]", contentGroupID, [dict objectForKey:@"cg_id"]);
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
		
	} else if (stickerGroupIndex == 2) {
		contentGroupID = [[pakTypeStickers objectForKey:kAnimalsGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in allPakTypeStickers) {
//			NSLog(@"CONTENT GROUP:[%@]-=-[%@]", contentGroupID, [dict objectForKey:@"cg_id"]);
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
		
	} else if (stickerGroupIndex == 3) {
		contentGroupID = [[pakTypeStickers objectForKey:kObjectsGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in allPakTypeStickers) {
//			NSLog(@"CONTENT GROUP:[%@]-=-[%@]", contentGroupID, [dict objectForKey:@"cg_id"]);
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
	
	} else if (stickerGroupIndex == 4) {
		contentGroupID = [[pakTypeStickers objectForKey:kOtherGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in allPakTypeStickers) {
//			NSLog(@"CONTENT GROUP:[%@]-=-[%@]", contentGroupID, [dict objectForKey:@"cg_id"]);
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
	}
	
	return ([stickers copy]);
}

- (NSArray *)fetchStickersForPakType:(HONStickerPakType)stickerPakType {
	NSMutableArray *stickers = [NSMutableArray array];
	NSMutableDictionary *contentGroups = ([[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] mutableCopy] : [NSMutableDictionary dictionary];
	NSDictionary *contentGroupIDs = [[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"];
	
	if (stickerPakType == HONStickerPakTypeAvatars) {
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kAvatarStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	
	} else if (stickerPakType == HONStickerPakTypeSelfieclub) {
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kSelfieclubStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	
	} else if (stickerPakType == HONStickerPakTypeClubCovers) {
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kClubCoverStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	
	} else if (stickerPakType == HONStickerPakTypeFree) {
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kFreeStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
	} else if (stickerPakType == HONStickerPakTypeInviteBonus) {
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kInviteStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
	} else if (stickerPakType == HONStickerPakTypePaid) {
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kPaidStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	
	} else {
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kAvatarStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kSelfieclubStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kClubCoverStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kFreeStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kInviteStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [contentGroupIDs objectForKey:kPaidStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	}
	
	return ([stickers copy]);
}

- (void)retrieveContentsForContentGroupID:(NSString *)contentGroupID ignoringCache:(BOOL)ignoreCache completion:(void (^)(NSArray *contents))completion {
	[[[NHThreadThis backgroundThis] groupThese] doThisAndWait:^{
		PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
			NSMutableArray *stickers = [NSMutableArray array];
			NSLog(@"///// fetchStickerPackInfo:[%d][%@] /////", success, contentGroup);
			[contentGroup.contents enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				PCContent *content = (PCContent *)obj;
//				NSLog(@"PCContent:\n%@\t%@\t%@\t%@\t%@", contentGroupID, content.content_id, content.name, content.large_image, [[content.large_image stringByReplacingOccurrencesOfString:@"/large.gif" withString:@"/"] stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]);
				
				if (![(PCContent *)obj isEqual:[NSNull null]]) {
					[stickers addObject:@{@"id"		: content.content_id,
										  @"cg_id"	: contentGroupID,
										  @"name"	: content.name,
										  @"price"	: content.price,
										  @"img"	: content.large_image}];
				}
			}];
			
			if (completion)
				completion(stickers);
		}];
	}];
}

- (NSArray *)fetchAllContentGroupIDs {
	NSMutableArray *cgIDs = [NSMutableArray array];
	NSDictionary *contentGroups = [[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"];
	for (NSString *key in [contentGroups keyEnumerator]) {
		[cgIDs addObject:key];
	}
	
	
//	
//	
//	
//	[[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		NSDictionary *dict = (NSDictionary *)obj;
//		
//		__block BOOL isFound = NO;
//		[cgIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//			isFound = ([(NSString *)obj isEqualToString:[dict objectForKey:@"cg_id"]]);
//			*stop = isFound;
//		}];
//		
//		if (!isFound)
//			[cgIDs addObject:[dict objectForKey:@"cg_id"]];
//	}];
	
	return ([cgIDs copy]);
}

- (BOOL)candyBoxContainsContentForContentID:(NSString *)contentID {
	__block BOOL isFound = NO;
	CandyBox *candyBox = [PicoManager sharedManager].candyBox;
	NSArray *cbContents = candyBox.contents;
	[cbContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CandyBoxContent *cbContent = (CandyBoxContent *)obj;
//		NSLog(@"[%@]<%@>[%@]", contentID, ([contentID isEqualToString:cbContent.contentId]) ? @"¡" : @"-", cbContent.contentId);
		isFound = ([contentID isEqualToString:cbContent.contentId]);
		*stop = isFound;
	}];
		
	return (isFound);
}

- (BOOL)candyBoxContainsContentGroupForContentGroupID:(NSString *)contentGroupID {
	CandyBox *candyBox = [PicoManager sharedManager].candyBox;
	return ([candyBox.contentGroups count] > 0);
}

- (void)purchaseStickerWithContentID:(NSString *)contentID usingDelegate:(id<PCCandyStorePurchaseControllerDelegate>)delegate {
	if (![[HONStickerAssistant sharedInstance] candyBoxContainsContentForContentID:contentID]) {
		PCCandyStorePurchaseController *candyStorePurchaseController = [[PCCandyStorePurchaseController alloc] init];
		candyStorePurchaseController.delegate = delegate;
		[candyStorePurchaseController purchaseStickerWithId:contentID];
	}
}


- (void)purchaseStickerPakWithContentGroupID:(NSString *)contentGroupID usingDelegate:(id<PCCandyStorePurchaseControllerDelegate>)delegate {
	PCCandyStorePurchaseController *candyStorePurchaseController = [[PCCandyStorePurchaseController alloc] init];
	candyStorePurchaseController.delegate = delegate;
	[candyStorePurchaseController purchaseStickerPackWithId:contentGroupID];
}

- (void)purchaseStickerPakWithContentGroupID:(NSString *)contentGroupID {
	NSMutableArray *contentGroupIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"purchases"] mutableCopy];
	if (![contentGroupIDs containsObject:contentGroupID])
		[contentGroupIDs addObject:contentGroupID];
	
	[[NSUserDefaults standardUserDefaults] replaceObject:[contentGroupIDs copy] forExistingKey:@"purchases"];
}

- (BOOL)isStickerPakPurchasedWithContentGroupID:(NSString *)contentGroupID {
	__block BOOL isPurchased = NO;
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"purchases"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *cgID = (NSString *)obj;
		isPurchased = ([cgID isEqualToString:contentGroupID]);
		*stop = isPurchased;
	}];
	
	return (isPurchased);
}

- (NSDictionary *)fetchAllCandyBoxContents {
	CandyBox *candyBox = [PicoManager sharedManager].candyBox;
	NSArray *cbContents = candyBox.contents;
	
	NSMutableDictionary *contents = [NSMutableDictionary dictionary];
	[cbContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CandyBoxContent *cbContent = (CandyBoxContent *)obj;
//		NSLog(@"contentInfo(%@):[%@]", cbContent.contentId, cbContent.contentInfo);
		[contents setObject:[[PicoSticker alloc] initWithContent:cbContent]
					 forKey:[[cbContent.contentInfo objectForKey:@"file_name"] stringByReplacingOccurrencesOfString:@".png" withString:@""]];
	}];
	
	return ([contents copy]);
}

- (PicoSticker *)stickerFromCandyBoxWithContentID:(NSString *)contentID {
	__block PicoSticker *sticker = nil;
	
	CandyBox *candyBox = [PicoManager sharedManager].candyBox;
	[candyBox.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CandyBoxContent *content = (CandyBoxContent *)obj;
//		NSLog(@"CandyBoxContent:[%d][%d]", [contentID intValue], [content.contentId intValue]);
		if ([contentID intValue] == [content.contentId intValue]) {
			sticker = [[PicoSticker alloc] initWithContent:content];
			*stop = YES;
		}
	}];
	
	return (sticker);
}


- (void)writeContentGroupCachedWithContentGroupID:(NSString *)contentGroupID {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cached_cg"] == nil) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[[[HONStickerAssistant sharedInstance] fetchAllContentGroupIDs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *cgID = (NSString *)obj;
			[dict setValue:[@"" stringFromBOOL:NO] forKey:cgID];
		}];
		
		[[NSUserDefaults standardUserDefaults] setValue:[dict copy] forKey:@"cached_cg"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cached_cg"] mutableCopy];
	[dict setValue:[@"" stringFromBOOL:YES] forKey:contentGroupID];
	
	[[NSUserDefaults standardUserDefaults] setValue:[dict copy] forKey:@"cached_cg"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isContentGroupCachedForContentGroupID:(NSString *)contentGroupID {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cached_cg"] == nil) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[[[HONStickerAssistant sharedInstance] fetchAllContentGroupIDs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *cgID = (NSString *)obj;
			[dict setValue:[@"" stringFromBOOL:NO] forKey:cgID];
		}];
		
		[[NSUserDefaults standardUserDefaults] setValue:[dict copy] forKey:@"cached_cg"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"cached_cg"] objectForKey:contentGroupID] isEqualToString:@"YES"]);
}

@end
