//
//  HONClubAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 05/04/2014 @ 00:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

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
	return (@[@"pending",
			  @"owned",
			  @"member",
			  @"other"]);
}

- (NSString *)defaultCoverImageURL {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"club_cover"]);
//	return ([[[HONClubAssistant sharedInstance] defaultCoverImagePrefixes] objectAtIndex:arc4random() % [[[HONClubAssistant sharedInstance] defaultCoverImagePrefixes] count]]);
}

- (NSString *)defaultClubPhotoURL {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"club_photo"]);
}

- (NSArray *)defaultCoverImagePrefixes {
	return (@[[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-001"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-002"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-003"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-004"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-005"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-006"]]);
}

- (NSArray *)clubCoverPhotoAlbumPrefixes {
	return ([[HONClubAssistant sharedInstance] defaultCoverImagePrefixes]);
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

- (NSDictionary *)orthodoxThresholdClubDictionary {
	NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{@"id"		: @"2394",
																								  @"username"	: @"Selfieclub",
																								   @"avatar"	: @""}] mutableCopy];
	
	[dict setValue:@"100" forKey:@"id"];
	[dict setValue:@"Locked Club" forKey:@"name"];
	[dict setValue:@"LOCKED" forKey:@"club_type"];
	[dict setValue:@"0000-00-00 00:00:00" forKey:@"added"];
	[dict setValue:@"9999-99-99 99:99:99" forKey:@"updated"];
	[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"locked"] forKey:@"img"];
	
	return ([dict copy]);
}

- (NSArray *)emotionsForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSMutableArray *emotions = [NSMutableArray array];
	for (NSString *subject in clubPhotoVO.subjectNames) {
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
//			NSLog(@"SUBJECT:[%@] STICKER:[%@]", subject, dict);
			HONEmotionVO *vo = [HONEmotionVO emotionWithDictionary:dict];
			if ([[vo.emotionName lowercaseString] isEqualToString:[subject lowercaseString]])
				[emotions addObject:vo];
		}		
	}
	
	return ([emotions copy]);
}

- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName {
	__block NSMutableArray *tot = [NSMutableArray array];
	[[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		NSLog(@"MATCHING:[%@]<=|%d|-=>[%@]", [clubName lowercaseString], ([[clubName lowercaseString] isEqualToString:[[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]]), [[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]);
		if ([[clubName lowercaseString] isEqualToString:[[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]]) {
			[tot addObject:@(idx)];
			*stop = YES;
		}
	}];
	
	if ([tot count] == 0) {
		[[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"member"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//			NSLog(@"MATCHING:[%@]<=|%d|-=>[%@]", [clubName lowercaseString], ([[clubName lowercaseString] isEqualToString:[[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]]), [[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]);
			if ([[clubName lowercaseString] isEqualToString:[[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]]) {
				[tot addObject:@(idx)];
				*stop = YES;
			}
		}];
	}
	
	return ([tot count] > 0);
}


- (NSArray *)suggestedClubs {
	NSMutableArray *clubs = [NSMutableArray array];

	// family
	HONUserClubVO *familyClubVO = [[HONClubAssistant sharedInstance] suggestedFamilyClubVO];
	if (familyClubVO != nil)
		[clubs addObject:familyClubVO];
	
	// area code
	HONUserClubVO *areaCodeClubVO = [[HONClubAssistant sharedInstance] suggestedAreaCodeClubVO];
	if (areaCodeClubVO != nil)
		[clubs addObject:areaCodeClubVO];
	
	// email domain
	HONUserClubVO *workplaceClubVO = [[HONClubAssistant sharedInstance] suggestedWorkplaceClubVO];
	if (workplaceClubVO != nil)
		[clubs addObject:workplaceClubVO];
	
	// sand hill
	HONUserClubVO *sandHillClubVO = [[HONClubAssistant sharedInstance] suggestedEmailClubVO:[[NSUserDefaults standardUserDefaults] objectForKey:@"sandhill_domains"]];
	if (sandHillClubVO != nil)
		[clubs addObject:sandHillClubVO];
	
	return ([clubs copy]);
}

- (HONUserClubVO *)suggestedAreaCodeClubVO {
	HONUserClubVO *vo;
	
	NSString *clubName = @"";
	if ([[[HONDeviceIntrinsics sharedInstance] phoneNumber] length] > 0) {
		clubName = [[[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringWithRange:NSMakeRange(2, 3)] stringByAppendingString:@" club"];
		clubName = ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) ? @"" : clubName;
		
		if ([clubName length] > 0) {
			NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}] mutableCopy];
			[dict setValue:@"-1" forKey:@"id"];
			[dict setValue:clubName forKey:@"name"];
			[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"location"] forKey:@"img"];
			[dict setValue:@"SUGGESTED" forKey:@"club_type"];
			
			vo = [HONUserClubVO clubWithDictionary:[dict copy]];
		}
	}
	
	return (vo);
}

- (HONUserClubVO *)suggestedEmailClubVO:(NSArray *)domains {
	HONUserClubVO *vo;
	
	NSString *clubName = @"";
	for (HONContactUserVO *vo in [[HONContactsAssistant sharedInstance] deviceContactsSortedByName:NO]) {
		if ([vo.email length] == 0)
			continue;
		
		for (NSString *domain in domains) {
			if ([[vo.email lowercaseString] rangeOfString:domain].location != NSNotFound) {
				clubName = @"Sand Hill Bros";
				break;
			}
		}
	}
	
	clubName = ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) ? @"" : clubName;
	if ([clubName length] > 0) {
		NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}] mutableCopy];
		[dict setValue:@"-1" forKey:@"id"];
		[dict setValue:clubName forKey:@"name"];
		[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"email"] forKey:@"img"];
		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
		
		vo = [HONUserClubVO clubWithDictionary:[dict copy]];
	}
	
	return (vo);
}

- (HONUserClubVO *)suggestedFamilyClubVO {
	HONUserClubVO *vo;
	
	NSString *clubName = @"";
	NSMutableArray *segmentedKeys = [[NSMutableArray alloc] init];
	NSMutableDictionary *segmentedDict = [[NSMutableDictionary alloc] init];
	
	NSArray *deviceName = [[[HONDeviceIntrinsics sharedInstance] deviceName] componentsSeparatedByString:@" "];
	if ([[deviceName lastObject] isEqualToString:@"iPhone"] || [[deviceName lastObject] isEqualToString:@"iPod"]) {
		NSString *familyName = [deviceName objectAtIndex:1];
		familyName = [familyName substringToIndex:[familyName length] - 2];
		clubName = [NSString stringWithFormat:@"%@ Family", [[[familyName substringToIndex:1] uppercaseString] stringByAppendingString:[familyName substringFromIndex:1]]];
		
	} else {
		for (HONContactUserVO *vo in [[HONContactsAssistant sharedInstance] deviceContactsSortedByName:NO]) {
			if (![segmentedKeys containsObject:vo.lastName]) {
				[segmentedKeys addObject:vo.lastName];
				
				NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
				[segmentedDict setValue:newSegment forKey:vo.lastName];
				
			} else {
				NSMutableArray *prevSegment = (NSMutableArray *)[segmentedDict valueForKey:vo.lastName];
				[prevSegment addObject:vo];
				[segmentedDict setValue:prevSegment forKey:vo.lastName];
			}
		}
		
		for (NSString *key in segmentedDict) {
			if ([[segmentedDict objectForKey:key] count] >= 2) {
				clubName = [NSString stringWithFormat:@"%@ Family", key];
				break;
			}
		}
	}
	
	clubName = ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) ? @"" : clubName;
	
	if ([clubName length] > 0) {
		NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}] mutableCopy];
		[dict setValue:@"-1" forKey:@"id"];
		[dict setValue:clubName forKey:@"name"];
		[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"family"] forKey:@"img"];
		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
		
		vo = [HONUserClubVO clubWithDictionary:[dict copy]];
	}
	
	return (vo);
}

- (HONUserClubVO *)suggestedWorkplaceClubVO {
	HONUserClubVO *vo;
	
	NSString *clubName = @"";
	NSMutableArray *segmentedKeys = [[NSMutableArray alloc] init];
	NSMutableDictionary *segmentedDict = [[NSMutableDictionary alloc] init];
	
	for (HONContactUserVO *vo in [[HONContactsAssistant sharedInstance] deviceContactsSortedByName:NO]) {
		if ([vo.email length] > 0) {
			NSString *emailDomain = [[vo.email componentsSeparatedByString:@"@"] lastObject];
			
			BOOL isValid = YES;
			for (NSString *domain in [[HONClubAssistant sharedInstance] excludedClubDomains]) {
				if ([emailDomain isEqualToString:domain]) {
					isValid = NO;
					break;
				}
			}
			
			if (isValid) {
				if (![segmentedKeys containsObject:emailDomain]) {
					[segmentedKeys addObject:emailDomain];
					
					NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
					[segmentedDict setValue:newSegment forKey:emailDomain];
					
				} else {
					NSMutableArray *prevSegment = (NSMutableArray *)[segmentedDict valueForKey:emailDomain];
					[prevSegment addObject:vo];
					[segmentedDict setValue:prevSegment forKey:emailDomain];
				}
			}
		}
	}
	
	for (NSString *key in segmentedDict) {
		if ([[segmentedDict objectForKey:key] count] >= 2) {
			clubName = [key stringByAppendingString:@" Club"];
			break;
		}
	}
	
	clubName = ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) ? @"" : clubName;
	
	if ([clubName length] > 0) {
		NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}] mutableCopy];
		[dict setValue:@"-1" forKey:@"id"];
		[dict setValue:clubName forKey:@"name"];
		[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"email"] forKey:@"img"];
		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
		
		vo = [HONUserClubVO clubWithDictionary:[dict copy]];
	}
	
	return (vo);
}


- (void)wipeUserClubs {
	[[HONClubAssistant sharedInstance] writeUserClubs:@{}];
}

- (void)addClub:(NSDictionary *)club forKey:(NSString *)key {
	NSMutableDictionary *allclubs = [[[HONClubAssistant sharedInstance] fetchUserClubs] mutableCopy];
	
	NSMutableArray *clubs = [[allclubs objectForKey:key] mutableCopy];
	[clubs addObject:club];
	[allclubs setObject:[clubs copy] forKey:key];
	
	[[HONClubAssistant sharedInstance] writeUserClubs:[allclubs copy]];
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


- (NSArray *)excludedClubDomains {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"excluded_domains"]);
}

@end
