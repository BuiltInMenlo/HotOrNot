//
//  HONStickerAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 13:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONStickerAssistant.h"


NSString * const kPicoCandyAppID	= @"1df5644d9e94";
NSString * const kPicoCandyAPIKey	= @"8Xzg4rCwWpwHfNCPLBvV";

NSString * const kFreePak		= @"free";
NSString * const kInvitePak		= @"invite";
NSString * const kAvatarPak		= @"avatar";
NSString * const kClubCoverPak	= @"club";
NSString * const kPaidPak		= @"paid";

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

- (void)registerStickerStore {
	PicoManager *picoManager = [PicoManager sharedManager];
	[picoManager registerStoreWithAppId:kPicoCandyAppID
								 apiKey:kPicoCandyAPIKey];
}


- (void)retrieveStickersWithPakType:(HONStickerPakType)stickerPakType completion:(void (^)(id result))completion {
	NSString *key = (stickerPakType == HONStickerPakTypeAvatars) ? kAvatarPak : (stickerPakType == HONStickerPakTypeClubCovers) ? kClubCoverPak : (stickerPakType == HONStickerPakTypeFree) ? kFreePak : (stickerPakType == HONStickerPakTypeInviteBonus) ? kInvitePak : (stickerPakType == HONStickerPakTypePaid) ? kPaidPak : @"all";
	
	NSMutableDictionary *allStickers = ([[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] mutableCopy] : [NSMutableDictionary dictionary];
	
	if ([allStickers objectForKey:key] != nil)
		[allStickers removeObjectForKey:key];
	[allStickers setObject:@[] forKey:key];

	NSArray *contentGroupIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:key];
	
	NSMutableArray *stickers = [NSMutableArray array];
	PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
	for (NSString *contentGroupID in contentGroupIDs) {
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
		NSLog(@"///// fetchStickerPackInfo:[%d][%@] /////", success, contentGroup);
			
			[contentGroup.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				PCContent *content = (PCContent *)obj;
				NSLog(@"content.image:[%@][%@][%@] (%@)", content.medium_image, content.medium_image, content.large_image, content.name);
				
				[stickers addObject:@{@"id"		: content.content_id,
									  @"name"	: content.name,
									  @"price"	: @"0",
									  @"img"	: [content.large_image stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"]}];
			}];
			
			[allStickers setObject:[stickers copy] forKey:key];
			[[NSUserDefaults standardUserDefaults] setObject:[allStickers copy] forKey:@"sticker_paks"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}];
	}
}


- (NSArray *)fetchStickersForPakType:(HONStickerPakType)stickerPakType {
	if (stickerPakType == HONStickerPakTypeAvatars) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kAvatarPak]);
		
	} else if (stickerPakType == HONStickerPakTypeClubCovers) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kClubCoverPak]);
	
	} else if (stickerPakType == HONStickerPakTypeFree) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kFreePak]);
		
	} else if (stickerPakType == HONStickerPakTypeInviteBonus) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kInvitePak]);
		
	} else if (stickerPakType == HONStickerPakTypePaid) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kPaidPak]);
	}
	
	
	NSMutableArray *stickers = [NSMutableArray array];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAvatars]];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeClubCovers]];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeFree]];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeInviteBonus]];
	[stickers addObjectsFromArray:[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypePaid]];
	
	return ([stickers copy]);
}

@end
