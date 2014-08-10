//
//  HONStickerAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 13:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONStickerAssistant.h"


NSString * const kPicoCandyAppID	= @"1df5644d9e94";
NSString * const kPicoCandyAPIKey	= @"8Xzg4rCwWpwHfNCPLBvV";

NSString * const kFreeStickerPak		= @"free";
NSString * const kInviteStickerPak		= @"invite";
NSString * const kAvatarStickerPak		= @"avatar";
NSString * const kClubCoverStickerPak	= @"club";
NSString * const kPaidStickerPak		= @"paid";

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

- (void)retrieveStickersWithPakType:(HONStickerPakType)stickerPakType completion:(void (^)(id result))completion {
	NSString *key = (stickerPakType == HONStickerPakTypeAvatars) ? kAvatarStickerPak : (stickerPakType == HONStickerPakTypeClubCovers) ? kClubCoverStickerPak : (stickerPakType == HONStickerPakTypeFree) ? kFreeStickerPak : (stickerPakType == HONStickerPakTypeInviteBonus) ? kInviteStickerPak : (stickerPakType == HONStickerPakTypePaid) ? kPaidStickerPak : @"all";
	
	NSMutableDictionary *allStickers = ([[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] mutableCopy] : [NSMutableDictionary dictionary];
	
//	if ([allStickers objectForKey:key] != nil)
//		return;
	
	NSArray *contentGroupIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:key];
	
	NSMutableArray *stickers = [NSMutableArray array];
	PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
	for (NSString *contentGroupID in contentGroupIDs) {
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
		NSLog(@"///// fetchStickerPackInfo:[%@]%@}--(%d) /////", contentGroupID, contentGroup, success);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[contentGroup.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					PCContent *content = (PCContent *)obj;
					NSLog(@"PCContent:\n[%@]/[%@] -=- (%@)", content.content_id, contentGroupID, content.name);
					
					[stickers addObject:@{@"id"		: content.content_id,
										  @"cg_id"	: contentGroupID,
										  @"name"	: content.name,
										  @"price"	: content.price,
										  @"img"	: [content.large_image stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]}];
				}];
				
				[allStickers setObject:[stickers copy] forKey:key];
				[[NSUserDefaults standardUserDefaults] setObject:[allStickers copy] forKey:@"sticker_paks"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			});
		}];
	}
}


- (NSArray *)fetchStickersForPakType:(HONStickerPakType)stickerPakType {
	if (stickerPakType == HONStickerPakTypeAvatars) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kAvatarStickerPak]);
		
	} else if (stickerPakType == HONStickerPakTypeClubCovers) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kClubCoverStickerPak]);
	
	} else if (stickerPakType == HONStickerPakTypeFree) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kFreeStickerPak]);
		
	} else if (stickerPakType == HONStickerPakTypeInviteBonus) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kInviteStickerPak]);
		
	} else if (stickerPakType == HONStickerPakTypePaid) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kPaidStickerPak]);
	}
	
	
	NSMutableArray *stickers = [NSMutableArray array];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAvatars]];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeClubCovers]];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeFree]];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeInviteBonus]];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypePaid]];
	
	return ([stickers copy]);
}

- (void)retrieveContentsForContentGroup:(NSString *)contentGroupID completion:(void (^)(NSArray *contents))completion {
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
	
//	[[[HONStickerAssistant sharedInstance] fetchAllCandyBoxContents] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		PicoSticker *sticker = (PicoSticker *)obj;
//		NSLog(@"[%@]<%@>[%@]", contentID, ([contentID isEqualToString:sticker.candyBoxContent.contentId]) ? @"¡" : @"-", sticker.candyBoxContent.contentId);
//		isFound = ([contentID isEqualToString:sticker.candyBoxContent.contentId]);
//		*stop = isFound;
//	}];
//	
//	return (isFound);
}

- (BOOL)candyBoxContainsContentGroupForContentGroupID:(NSString *)contentGroupID {
//	__block BOOL isFound = NO;
	
	CandyBox *candyBox = [PicoManager sharedManager].candyBox;
//	NSDictionary *cbContentGroups = candyBox.contentGroups;
	
	return ([candyBox.contentGroups count] > 0);
//	[cbContentGroups enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		NSLog(@"contentGroupID:[%@](%@)", obj);
//		CandyBoxContent *cbContent = (CandyBoxContent *)obj;
//		isFound = ([contentGroupID isEqualToString:cbContent.contentGroupId]);
//		*stop = isFound;
//	}];
//
//	return (isFound);
	
//	[[[HONStickerAssistant sharedInstance] fetchAllCandyBoxContents] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		PicoSticker *sticker = (PicoSticker *)obj;
//		NSLog(@"[%@]<%@>[%@]", contentGroupID, ([contentGroupID isEqualToString:sticker.candyBoxContent.contentGroupId]) ? @"¡" : @"-", sticker.candyBoxContent.contentGroupId);
//		isFound = ([contentGroupID isEqualToString:sticker.candyBoxContent.contentGroupId]);
//		*stop = isFound;
//	}];
//	
//	return (isFound);
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
