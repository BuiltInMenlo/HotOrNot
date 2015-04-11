//
//  HONUserAssistant.m
//  HotOrNot
//
//  Created by BIM  on 1/5/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "RegExCategories.h"

#import "NSArray+BuiltinMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"

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

- (UIImage *)activeUserAvatar {
	return (([[[HONUserAssistant sharedInstance] activeUserInfo] hasObjectForKey:@"avatar"]) ? [UIImage imageWithData:[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"avatar"]] : [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"default_avatar"]]);
}

- (NSString *)activeUserAvatarURL {
	return ([[HONUserAssistant sharedInstance] avatarURLForUserID:[[HONUserAssistant sharedInstance] activeUserID]]);
}

- (int)activeUserID {
	return (([[[HONUserAssistant sharedInstance] activeUserInfo] hasObjectForKey:@"id"]) ? [[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"id"] intValue] : -1);
}

- (NSString *)activeUsername {
	return (([[[HONUserAssistant sharedInstance] activeUserInfo] hasObjectForKey:@"username"]) ? [[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"username"] : nil);
}

- (NSDate *)activeUserLoginDate {
	return (([[[HONUserAssistant sharedInstance] activeUserInfo] hasObjectForKey:@"last_login"]) ? [NSDate dateFromISO9601FormattedString:[[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"last_login"] normalizedISO8601Timestamp]] : [NSDate utcNowDate]);
}

- (BOOL)activeUserNotificationsEnabled {
	return (([[[HONUserAssistant sharedInstance] activeUserInfo] hasObjectForKey:@"notifications"]) ? [[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"notifications"] isEqualToString:@"Y"] : NO);
}

- (NSDate *)activeUserSignupDate {
	return (([[[HONUserAssistant sharedInstance] activeUserInfo] hasObjectForKey:@"added"]) ? [NSDate dateFromISO9601FormattedString:[[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"added"] normalizedISO8601Timestamp]] : [NSDate utcNowDate]);
}

- (NSDictionary *)activeUserInfo {
	return (([[NSUserDefaults standardUserDefaults] hasObjectForKey:@"user_info"]) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] : nil);
}

- (void)writeActiveUserAvatarFromURL:(NSString *)url {
	[[HONImageBroker sharedInstance] writeImageFromWeb:url withUserDefaultsKey:@"avatar_image"];
}

- (void)writeActiveUserInfo:(NSDictionary *)userInfo {
	NSDate *signupDate = [NSDate dateFromISO9601FormattedString:[[userInfo objectForKey:@"added"] normalizedISO8601Timestamp]];
	
	
	if (![[[NSRegularExpression alloc] initWithPattern:@"\\d+{10}"] isMatch:[userInfo objectForKey:@"username"]]) {
		
	}
	
	
	NSString *username = [[[NSRegularExpression alloc] initWithPattern:@"\\d{10}\\.[a-f0-9]{14}$"] replace:[userInfo objectForKey:@"username"]
																									  with:NSStringFromInt([signupDate unixEpochTimestamp])];
	
	if (![[HONUserAssistant sharedInstance] activeUserAvatar] || ![[userInfo objectForKey:@"avatar_url"] isEqualToString:[[HONUserAssistant sharedInstance] activeUserAvatarURL]])
		[[HONUserAssistant sharedInstance] writeActiveUserAvatarFromURL:[userInfo objectForKey:@"avatar_url"]];
	
	NSMutableDictionary *dict = [userInfo mutableCopy];
	[dict replaceObject:username forKey:@"username"];
	if ([[userInfo objectForKey:@"email"] length] == 0 || [[[HONDeviceIntrinsics sharedInstance] phoneNumber] length] == 0)
		[dict replaceObject:[NSString stringWithFormat:@"+1%d", [signupDate unixEpochTimestamp]] forKey:@"email"];
	
	[[NSUserDefaults standardUserDefaults] replaceObject:[dict copy] forKey:@"user_info"];
	
//	NSLog(@"WROTE USER-INFO:[%@]", [[HONUserAssistant sharedInstance] activeUserInfo]);
}


- (NSString *)rndAvatarURL {
	NSArray *avatars = @[@"bird",
						 @"football",
						 @"pizza",
						 @"rocket",
						 @"tree",
						 @"watermelon"];
	
	return ([NSString stringWithFormat:@"%@/%@.png", [HONAPICaller s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront], [avatars randomElement]]);
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
		[activityItems addObjectsFromArray:[result objectForKey:@"results"]];
		
		NSLog(@"TOTAL:[%d] RETRIEVED:[%lu]", [[result objectForKey:@"count"] intValue], (unsigned long)[activityItems count]);
		while (0==0){//[activityItems count] < [[result objectForKey:@"count"] intValue]) {
			//dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.333 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
				[[HONAPICaller sharedInstance] retrieveActivityForUserByUserID:userID fromPage:++page completion:^(NSDictionary *result) {;
					[activityItems addObjectsFromArray:[result objectForKey:@"results"]];
					NSLog(@"TOTAL:[%d] RETRIEVED:[%lu]", [[result objectForKey:@"count"] intValue], (unsigned long)[activityItems count]);
				}];
			//});
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
		HONUserVO *vo = [[HONClubAssistant sharedInstance] clubMemberWithUserID:userID];
		
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
		HONUserVO *vo = [[HONClubAssistant sharedInstance] clubMemberWithUserID:userID];
		
		if (vo != nil) {
			[dict setObject:@{@"id"			: @(vo.userID),
							  @"username"	: vo.username,
							  @"avatar"		: [[HONUserAssistant sharedInstance] rndAvatarURL]} forKey:key];
			
		} else {
			[dict setObject:@{@"id"			: @(userID),
							  @"username"	: [NSString stringWithFormat:@"Anonymous_%d", [NSDate elapsedUTCSecondsSinceUnixEpoch]],
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
