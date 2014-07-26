//
//  HONClubAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 05/04/2014 @ 00:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONClubAssistant.h"

@implementation HONClubAssistant
static HONClubAssistant *sharedInstance = nil;

+ (HONClubAssistant *)sharedInstance {
	static HONClubAssistant *s_sharedInstance = nil;
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

- (NSArray *)clubTypeKeys {
	return (@[@"owned",
			  @"member",
			  @"pending",
			  @"other"]);
}

- (NSDictionary *)emptyClubDictionaryWithOwner:(NSDictionary *)owner {
	return (@{@"id"				: @"",
			  @"name"			: @"",
			  
			  @"description"	: @"",
			  @"img"			: @"",
			  @"club_type"		: @"",
			  @"added"			: @"0000-00-00 00:00:00",
			  @"updated"		: @"0000-00-00 00:00:00",
			  
			  @"total_members"		: @"1",
			  @"total_score"		: @"0",
			  @"total_submissions"	: @"0",
			  
			  @"owner"			: ([owner count] == 0) ? @{@"id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
														   @"username"	: [[HONAppDelegate infoForUser] objectForKey:@"username"],
														   @"avatar"	: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]} : owner,
			   
			  @"members"		: @[],
			  @"pending"		: @[],
			  @"blocked"		: @[],
			  
			  @"submissions"	: @[]
			});
}

- (NSArray *)emotionsForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSMutableArray *emotions = [NSMutableArray array];
	for (NSString *subject in clubPhotoVO.subjectNames) {
//		for (HONEmotionVO *vo in [HONAppDelegate orthodoxEmojis]) {
		for (HONEmotionVO *vo in [HONAppDelegate picoCandyStickers]) {
			if ([[vo.emotionName lowercaseString] isEqualToString:[subject lowercaseString]])
				[emotions addObject:[HONEmotionVO emotionWithDictionary:vo.dictionary]];
		}
	}
	
	return ([emotions copy]);
}

- (NSString *)defaultCoverImagePrefix {
	return ([[[HONClubAssistant sharedInstance] defaultCoverImagePrefixes] objectAtIndex:arc4random() % [[[HONClubAssistant sharedInstance] defaultCoverImagePrefixes] count]]);
}

- (NSArray *)defaultCoverImagePrefixes {
	return (@[[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-001"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-002"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-003"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-004"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-005"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-006"]]);
}


- (void)wipeUserClubs {
	[[HONClubAssistant sharedInstance] writeUserClubs:@{}];
}

- (void)writeUserClubs:(NSDictionary *)clubs {
	[[NSUserDefaults standardUserDefaults] setObject:clubs forKey:@"clubs"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)fetchUserClubs {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"clubs"] == nil) {
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			[[HONClubAssistant sharedInstance] writeUserClubs:result];
		}];
	}
	
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"clubs"]);
}

@end
