//
//  HONStickerAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 13:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

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


- (void)nameForContentGroupID:(NSString *)contentGroupID completion:(void (^)(id result))completion {
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

- (void)retrieveStickersWithPakType:(HONStickerPakType)stickerPakType ignoringCache:(BOOL)ignoreCache completion:(void (^)(id result))completion {
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
//					NSLog(@"PCContent:\n%@\t%@\t%@\t%@", contentGroupID, content.content_id, content.name, [content.large_image stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]);
					[stickers addObject:@{@"id"		: content.content_id,
										  @"cg_id"	: contentGroupID,
										  @"name"	: content.name,
										  @"price"	: content.price,
										  @"img"	: [content.large_image stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]}];
					
				}
				
				[contentGroups setValue:[stickers copy] forKey:contentGroupID];
				[[NSUserDefaults standardUserDefaults] setValue:[contentGroups copy] forKey:@"content_groups"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
//				[contentGroup.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//					PCContent *content = (PCContent *)obj;
//					NSLog(@"PCContent:\n%@\t%@\t%@\t%@", contentGroupID, content.content_id, content.name, [content.large_image stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]);
//					[stickers addObject:@{@"id"		: content.content_id,
//										  @"cg_id"	: contentGroupID,
//										  @"name"	: content.name,
//										  @"price"	: content.price,
//										  @"img"	: [content.large_image stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]}];
//				}];
			}];
			
		}];
	}
	
	
	
	
	/*
	NSMutableDictionary *stickerPak = ([[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] mutableCopy] : [NSMutableDictionary dictionary];
	
	NSArray *contentGroupIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:key];
	PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
	for (NSString *contentGroupID in contentGroupIDs) {
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
		NSLog(@"///// fetchStickerPackInfo:[%@]%@}--(%d) /////", contentGroupID, contentGroup, success);
			
			[[NHThreadThis backgroundThis] doThis:^{
				NSMutableArray *stickers = ([stickerPak objectForKey:key] != nil) ? [[stickerPak objectForKey:key] mutableCopy] : [NSMutableArray array];
//				NSMutableArray *stickers = [NSMutableArray array];
				
				[contentGroup.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					PCContent *content = (PCContent *)obj;
					NSLog(@"PCContent:\n%@\t%@\t%@\t%@", contentGroupID, content.content_id, content.name, [content.large_image stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]);
					[stickers addObject:@{@"id"		: content.content_id,
										  @"cg_id"	: contentGroupID,
										  @"name"	: content.name,
										  @"price"	: content.price,
										  @"img"	: [content.large_image stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]}];
				}];
				
				[stickerPak setObject:[stickers copy] forKey:key];
				[[NSUserDefaults standardUserDefaults] setValue:[stickerPak copy] forKey:@"sticker_paks"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}];
			
//			dispatch_async(dispatch_get_main_queue(), ^{
//			});
		}];
	}
	 */
}


- (NSDictionary *)fetchCoverStickerForContentGroup:(NSString *)contentGroupID {
	for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
		if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
			return (dict);
		}
	}
	return (nil);
}


- (NSArray *)fetchStickersForGroupType:(HONStickerGroupType)stickerGroupType {
	NSMutableDictionary *contentGroups = ([[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] mutableCopy] : [NSMutableDictionary dictionary];
	NSMutableArray *stickers = [NSMutableArray array];
	NSString *contentGroupID = @"0";
	
	if (stickerGroupType == HONStickerGroupTypeStickers) {
		contentGroupID = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"emotion_groups"] objectForKey:kStickersGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
			NSLog(@"CONTENT GROUP:[%@]-=-[%@]", contentGroupID, [dict objectForKey:@"cg_id"]);
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
		
	} else if (stickerGroupType == HONStickerGroupTypeFaces) {
		contentGroupID = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"emotion_groups"] objectForKey:kFacesGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
		
	} else if (stickerGroupType == HONStickerGroupTypeAnimals) {
		contentGroupID = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"emotion_groups"] objectForKey:kAnimalsGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
		
	} else if (stickerGroupType == HONStickerGroupTypeObjects) {
		contentGroupID = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"emotion_groups"] objectForKey:kObjectsGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
		
	} else if (stickerGroupType == HONStickerGroupTypeOther) {
		contentGroupID = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"emotion_groups"] objectForKey:kOtherGroup] objectForKey:@"content_group"];
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
			if ([[dict objectForKey:@"cg_id"] isEqualToString:contentGroupID]) {
				[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
				break;
			}
		}
	}
	
	return ([stickers copy]);
}

- (NSArray *)fetchStickersForPakType:(HONStickerPakType)stickerPakType {
	NSMutableDictionary *contentGroups = ([[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"content_groups"] mutableCopy] : [NSMutableDictionary dictionary];
	
	NSMutableArray *stickers = [NSMutableArray array];
	if (stickerPakType == HONStickerPakTypeAvatars) {
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kAvatarStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	
	} else if (stickerPakType == HONStickerPakTypeSelfieclub) {
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kSelfieclubStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	
	} else if (stickerPakType == HONStickerPakTypeClubCovers) {
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kClubCoverStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	
	} else if (stickerPakType == HONStickerPakTypeFree) {
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kFreeStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
	} else if (stickerPakType == HONStickerPakTypeInviteBonus) {
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kInviteStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
	} else if (stickerPakType == HONStickerPakTypePaid) {
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kPaidStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	
	} else {
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kAvatarStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kSelfieclubStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kClubCoverStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kFreeStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kInviteStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
		
		for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:kPaidStickerPak])
			[stickers addObjectsFromArray:[contentGroups objectForKey:contentGroupID]];
	}
	
	return ([stickers copy]);
}

- (void)retrieveContentsForContentGroup:(NSString *)contentGroupID ignoringCache:(BOOL)ignoreCache completion:(void (^)(NSArray *contents))completion {
	[[[NHThreadThis backgroundThis] groupThese] doThisAndWait:^{
		PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
			NSMutableArray *stickers = [NSMutableArray array];
			NSLog(@"///// fetchStickerPackInfo:[%d][%@] /////", success, contentGroup);
			[contentGroup.contents enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSLog(@"PCContent(%d):[%@]", idx, obj);
				
				if (![(PCContent *)obj isEqual:[NSNull null]])
					[stickers addObject:(PCContent *)obj];
			}];
			
			if (completion)
				completion(stickers);
		}];
	}];
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

@end
