//
//  HONUserAssistant.m
//  HotOrNot
//
//  Created by BIM  on 1/5/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSArray+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"

#import "HONUserAssistant.h"

@implementation HONUserAssistant
static HONUserAssistant *sharedInstance = nil;

+ (HONUserAssistant *)sharedInstance {
	static HONUserAssistant *s_sharedInstance = nil;
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

- (int)activeUserID {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] objectForKey:@"id"] intValue]);
}

- (NSString *)activeUsername {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] objectForKey:@"username"]);
}


- (NSString *)rndAvatarURL {
	NSArray *avatars = @[@"bird",
						 @"football",
						 @"pizza",
						 @"rocket",
						 @"tree",
						 @"watermelon"];
	
	return ([NSString stringWithFormat:@"%@/%@.png", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront], [avatars randomElement]]);
}


- (void)retrieveActivityByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] retrieveActivityForUserByUserID:userID fromPage:page completion:^(NSDictionary *result) {
		
		NSLog(@"ON PAGE:[%d]", page);
		NSLog(@"RETRIEVED:[%d]", (int)[[result objectForKey:@"results"] count]);
		
		if (completion)
			completion([result objectForKey:@"results"]);
	}];
}

- (NSString *)usernameWithDigitsStripped:(NSString *)username {
//	NSError *error = NULL;
//	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[_\\.A-Za-z]*"
//																		   options:NSRegularExpressionCaseInsensitive
//																			 error:&error];
//	
//	NSArray *matches = [regex matchesInString:username options:0 range:NSMakeRange(0, [username length])];
//	
//	if ([matches count] > 0) {
//		for (NSTextCheckingResult *match in matches) {
//			return ([username substringWithRange:[match rangeAtIndex:HONRegexMatchWordGroup]]);
//		}
//	}
	
	
	return (username);	
}

- (void)retrieveActivityScoreByUserID:(int)userID completion:(void (^)(id result))completion {
	__block int page = 1;
	__block NSMutableArray *activityItems = [NSMutableArray array];
	
	[[HONAPICaller sharedInstance] retrieveActivityForUserByUserID:userID fromPage:1 completion:^(NSDictionary *result) {
		NSLog(@"TOTAL:[%d]", [[result objectForKey:@"count"] intValue]);
		
		[activityItems addObjectsFromArray:[result objectForKey:@"results"]];
		while ([activityItems count] < [[result objectForKey:@"count"] intValue]) {
			[[HONAPICaller sharedInstance] retrieveActivityForUserByUserID:userID fromPage:++page completion:^(NSDictionary *result) {;
				[activityItems addObjectsFromArray:[result objectForKey:@"results"]];
			}];
		}
		
		NSLog(@"FINISHED RETRIEVED:[%d]", (int)[activityItems count]);
		
		__block int score = 0;
		[activityItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *dict = (NSDictionary *)obj;
			
			//NSLog(@"VOTE:[%d / %d]~(%@) -=- \"%@\"", [[dict objectForKey:@"status_update_id"] intValue], [[[dict objectForKey:@"subject_member"] objectForKey:@"id"] intValue], NSStringFromBOOL(([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_UPVOTED"])), [dict objectForKey:@"event_type"]);
			if ([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_UPVOTED"])
				score++;
			
			else if ([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_DOWNVOTED"])
				score--;
		}];
		
		if (completion)
			completion(@(score));
	}];
}

- (NSString *)avatarURLForUserID:(int)userID {
	NSString *key = [NSString stringWithFormat:@"member_%d", userID];
	NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_lookup"] mutableCopy];
	
	if (![dict hasObjectForKey:key]) {
		HONTrivialUserVO *vo = [[HONClubAssistant sharedInstance] clubMemberWithUserID:userID];
		
		if (vo != nil) {
			[dict setObject:@{@"id"			: @(vo.userID),
							  @"username"	: vo.username,
							  @"avatar"		: [[HONUserAssistant sharedInstance] rndAvatarURL]} forKey:key];
			
		} else {
			[dict setObject:@{@"id"			: @(userID),
							  @"username"	: @"",
							  @"avatar"		: [[HONUserAssistant sharedInstance] rndAvatarURL]} forKey:key];
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:[dict copy] forKey:@"user_lookup"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	return ([[dict objectForKey:key] objectForKey:@"avatar"]);
}

- (NSString *)usernameForUserID:(int)userID {
	NSString *key = [NSString stringWithFormat:@"member_%d", userID];
	NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_lookup"] mutableCopy];
	
	if (![dict hasObjectForKey:key]) {
		HONTrivialUserVO *vo = [[HONClubAssistant sharedInstance] clubMemberWithUserID:userID];
		
		if (vo != nil) {
			[dict setObject:@{@"id"			: @(vo.userID),
							  @"username"	: vo.username,
							  @"avatar"		: [[HONUserAssistant sharedInstance] rndAvatarURL]} forKey:key];
			
		} else {
			[dict setObject:@{@"id"			: @(userID),
							  @"username"	: @"",
							  @"avatar"		: [[HONUserAssistant sharedInstance] rndAvatarURL]} forKey:key];
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:[dict copy] forKey:@"user_lookup"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	return ([[dict objectForKey:key] objectForKey:@"username"]);
}


- (void)writeClubMemberToUserLookup:(NSDictionary *)userInfo {
	NSString *key = [NSString stringWithFormat:@"member_%@", [userInfo objectForKey:@"id"]];
	NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_lookup"] mutableCopy];
	
	if (![dict hasObjectForKey:key]) {
		[dict setObject:@{@"id"			: [userInfo objectForKey:@"id"],
						  @"username"	: [userInfo objectForKey:@"username"],
						  @"avatar"		: [userInfo objectForKey:@"avatar"]} forKey:key];
		
		[[NSUserDefaults standardUserDefaults] setObject:[dict copy] forKey:@"user_lookup"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

@end
