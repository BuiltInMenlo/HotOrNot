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

- (void)retrieveStickersWithContentGroupIDs:(NSArray *)contentGroupIDs completion:(void (^)(id))completion {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"picocandy"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"picocandy"];
	
//	NSLog(@"PICOCANDY:[%@]", [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:@"free"]);
	
	NSMutableArray *stickers = [NSMutableArray array];
	PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
	for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:@"free"]) {
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
//			NSLog(@"///// fetchStickerPackInfo:[%d][%@] /////", success, contentGroup);
			
			[contentGroup.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				PCContent *content = (PCContent *)obj;
//				NSLog(@"content.image:[%@][%@][%@] (%@)", content.medium_image, content.medium_image, content.large_image, content.name);
				
				[stickers addObject:@{@"id"		: content.content_id,
									  @"name"	: content.name,
									  @"price"	: @"0",
									  @"img"	: content.large_image}];
				
				[[NSUserDefaults standardUserDefaults] setObject:[stickers copy] forKey:@"picocandy"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}];
			
			if (completion)
				completion([[NSUserDefaults standardUserDefaults] objectForKey:@"picocandy"]);
		}];
	}
}

@end
