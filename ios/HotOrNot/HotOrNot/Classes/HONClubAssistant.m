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

- (NSString *)userSignupClubCoverImageURL {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"user_club"]);
}

- (NSString *)defaultCoverImageURL {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"club_cover"]);
}

- (NSString *)defaultClubPhotoURL {
	return ([[HONClubAssistant sharedInstance] defaultCoverImageURL]);
}

- (NSArray *)clubCoverPhotoAlbumPrefixes {
	return (@[[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-001"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-002"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-003"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-004"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-005"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-006"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-007"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-008"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-009"],
			  [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], @"pc-010"]]);
}

- (NSString *)rndCoverImageURL {
	NSArray *rndCovers = [[HONClubAssistant sharedInstance] clubCoverPhotoAlbumPrefixes];
	return ([rndCovers objectAtIndex:(arc4random() % ([rndCovers count] - 1))]);
}


- (NSDictionary *)createClubDictionary {
	NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{@"id"			: @"2394",
																								  @"username"	: @"Selfieclub",
																								  @"avatar"		: @""}];
	[dict setValue:NSLocalizedString(@"create_club", @"Add Club") forKey:@"name"];
	[dict setValue:@"CREATE" forKey:@"club_type"];
	[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
//	[dict setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[[HONDateTimeAlloter sharedInstance] utcNowDate]] forKey:@"added"];
//	[dict setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[[HONDateTimeAlloter sharedInstance] utcNowDate]] forKey:@"updated"];
	
	return ([dict copy]);
}

- (NSMutableDictionary *)emptyClubDictionaryWithOwner:(NSDictionary *)owner {
	return ([@{@"id"			: @"",
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
			} mutableCopy]);
}

- (NSDictionary *)orthodoxThresholdClubDictionary {
	NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{@"id"			: @"2394",
																								  @"username"	: @"Selfieclub",
																								  @"avatar"		: @""}];
	[dict setValue:@"100" forKey:@"id"];
	[dict setValue:@"Locked Club" forKey:@"name"];
	[dict setValue:@"LOCKED" forKey:@"club_type"];
	[dict setValue:@"0000-00-00 00:00:00" forKey:@"added"];
	[dict setValue:@"9999-99-99 99:99:99" forKey:@"updated"];
//	[dict setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[[HONDateTimeAlloter sharedInstance] utcNowDate]] forKey:@"added"];
//	[dict setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[[HONDateTimeAlloter sharedInstance] utcNowDate]] forKey:@"updated"];
	[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"locked"] forKey:@"img"];
	[dict setValue:@"https://hotornot-challenges.s3.amazonaws.com/26mgmt" forKey:@"img"];
	
	return ([dict copy]);
}

- (NSDictionary *)emptyClubPhotoDictionary {
	return (@{@"challenge_id"	: @"0",
			  @"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
			  @"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],
			  @"avatar"			: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
			  @"img"			: [[HONClubAssistant sharedInstance] defaultClubPhotoURL],
			  @"score"			: @"0",
			  @"subjects"		: @[],
			  @"added"			: [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[[HONDateTimeAlloter sharedInstance] utcNowDate]]});
}

- (NSArray *)emotionsForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSMutableArray *emotions = [NSMutableArray array];
	for (NSString *subject in clubPhotoVO.subjectNames) {
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeAll]) {
//			NSLog(@"SUBJECT:[%@] STICKER:[%@]", subject, dict);
			HONEmotionVO *vo = [HONEmotionVO emotionWithDictionary:dict];
			if ([[vo.emotionName lowercaseString] isEqualToString:[subject lowercaseString]]) {
				[emotions addObject:vo];
				break;
			}
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

- (BOOL)isClubNameMatchedForUserClubs:(NSString *)clubName considerWhitespace:(BOOL)isWhitespace {
	return ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:[clubName stringByReplacingOccurrencesOfString:@" " withString:@""]]);
}


- (int)labelIDForAreaCode:(NSString *)areaCode {
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"schools"]) {
		if ([[dict objectForKey:@"area_code"] isEqualToString:areaCode])
			return ([[dict objectForKey:@"label"] intValue]);
	}
	
	return (0);
}

- (HONUserClubVO *)userSignupClub {
	__block HONUserClubVO *vo = nil;
	[[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSLog(@"MATCHING SIGNUP CLUB:[%@]<=|%d|-=>[%@]", [[[HONAppDelegate infoForUser] objectForKey:@"username"] lowercaseString], ([[[[HONAppDelegate infoForUser] objectForKey:@"username"] lowercaseString] isEqualToString:[[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]]), [[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]);
		if ([[[[HONAppDelegate infoForUser] objectForKey:@"username"] lowercaseString] isEqualToString:[[(NSDictionary *)obj objectForKey:@"name"] lowercaseString]]) {
			vo = [HONUserClubVO clubWithDictionary:(NSDictionary *)obj];
			*stop = YES;
		}
	}];
	
	return ((vo != nil) ? vo : [HONUserClubVO clubWithDictionary:[[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"] firstObject]]);
}

- (void)copyUserSignupClubToClipboardWithAlert:(BOOL)showsAlert {
	[[HONClubAssistant sharedInstance] copyClubToClipBoard:[[HONClubAssistant sharedInstance] userSignupClub] withAlert:showsAlert];
}

- (void)copyClubToClipBoard:(HONUserClubVO *)clubVO withAlert:(BOOL)showsAlert {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = NSLocalizedString(@"tap_join", @"Join my private club in @Selfieclub");
	
	if (showsAlert) {
		[[[UIAlertView alloc] initWithTitle:@"Copied to your clipboard!"
									message:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_msg", nil)]
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
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
	
	// school
	HONUserClubVO *schoolClubVO = [[HONClubAssistant sharedInstance] suggestedSchoolClubVO];
	if (schoolClubVO != nil)
		[clubs addObject:schoolClubVO];
	
	// bae
	HONUserClubVO *baeClubVO = [[HONClubAssistant sharedInstance] suggestedBAEClubVO];
	if (baeClubVO != nil)
		[clubs addObject:baeClubVO];
	
	// bff
	HONUserClubVO *bffsClubVO = [[HONClubAssistant sharedInstance] suggestedBFFsClubVO];
	if (bffsClubVO != nil)
		[clubs addObject:bffsClubVO];
	
	
	
	// email domain
	HONUserClubVO *workplaceClubVO = [[HONClubAssistant sharedInstance] suggestedWorkplaceClubVO];
	if (workplaceClubVO != nil)
		[clubs addObject:workplaceClubVO];
	
	// sand hill
//	HONUserClubVO *sandHillClubVO = [[HONClubAssistant sharedInstance] suggestedEmailClubVO:[[NSUserDefaults standardUserDefaults] objectForKey:@"sandhill_domains"]];
//	if (sandHillClubVO != nil)
//		[clubs addObject:sandHillClubVO];
	
	return ([clubs copy]);
}

- (HONUserClubVO *)suggestedAreaCodeClubVO {
	HONUserClubVO *vo;
	
	NSString *clubName = @"";
	if ([[[HONDeviceIntrinsics sharedInstance] phoneNumber] length] > 0) {
		clubName = [NSString stringWithFormat:NSLocalizedString(@"areacode_club", @"%@Club"), [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringWithRange:NSMakeRange(2, 3)]];
		clubName = ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) ? @"" : clubName;
		
		if ([clubName length] > 0) {
			NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
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
		
//		for (NSString *domain in domains) {
//			if ([[vo.email lowercaseString] rangeOfString:domain].location != NSNotFound) {
//				clubName = @"Sand Hill Bros";
//				break;
//			}
//		}
	}
	
	clubName = ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) ? @"" : clubName;
	if ([clubName length] > 0) {
		NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
		[dict setValue:@"-3" forKey:@"id"];
		[dict setValue:clubName forKey:@"name"];
		[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"email"] forKey:@"img"];
		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
		
		vo = [HONUserClubVO clubWithDictionary:[dict copy]];
	}
	
	return (vo);
}

- (HONUserClubVO *)suggestedFamilyClubVO {
	HONUserClubVO *vo;
	
//	if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:@"My BAE"]) {
//		NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
//		[dict setValue:@"-2" forKey:@"id"];
//		[dict setValue:@"MyFamily" forKey:@"name"];
//		[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"family"] forKey:@"img"];
//		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
//		vo = [HONUserClubVO clubWithDictionary:dict];
//	}
//	
//	return (vo);
	
	NSString *clubName = @"";
	NSMutableArray *segmentedKeys = [[NSMutableArray alloc] init];
	NSMutableDictionary *segmentedDict = [[NSMutableDictionary alloc] init];
	
	NSArray *deviceName = [[[HONDeviceIntrinsics sharedInstance] deviceName] componentsSeparatedByString:@" "];
	if ([deviceName count] == 3 && ([[deviceName lastObject] isEqualToString:@"iPhone"] || [[deviceName lastObject] isEqualToString:@"iPod"])) {
		NSString *familyName = [deviceName objectAtIndex:1];
		
		if ([familyName rangeOfString:@"'s"].location != NSNotFound) {
			familyName = [familyName substringToIndex:[familyName length] - 2];
			clubName = [NSString stringWithFormat:NSLocalizedString(@"family_club", @"My%@Club"), [[[familyName substringToIndex:1] uppercaseString] stringByAppendingString:[familyName substringFromIndex:1]]];
		}
		
	} else {
		for (HONContactUserVO *vo in [[HONContactsAssistant sharedInstance] deviceContactsSortedByName:NO]) {
			NSString *name = ([vo.lastName length] > 0) ? vo.lastName : vo.firstName;
			
			if (![segmentedKeys containsObject:name]) {
				[segmentedKeys addObject:name];
				
				NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
				[segmentedDict setValue:newSegment forKey:name];
				
			} else {
				NSMutableArray *prevSegment = (NSMutableArray *)[segmentedDict valueForKey:name];
				[prevSegment addObject:vo];
				[segmentedDict setValue:prevSegment forKey:name];
			}
		}
		
		for (NSString *key in segmentedDict) {
			NSLog(@"KEY:[%@]-=-(%d)", key, [[segmentedDict objectForKey:key] count]);
			if ([key length] > 0 && [[segmentedDict objectForKey:key] count] >= 3) {
				clubName = [NSString stringWithFormat:NSLocalizedString(@"family_club", @"My%@Club"), key];
				break;
			}
		}
	}
	
	clubName = ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) ? @"" : clubName;
	if ([clubName length] > 1) {
		NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
		[dict setValue:@"-2" forKey:@"id"];
		[dict setValue:clubName forKey:@"name"];
		[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"family"] forKey:@"img"];
		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
		
		vo = [HONUserClubVO clubWithDictionary:[dict copy]];
		
		[[NSUserDefaults standardUserDefaults] setObject:vo.dictionary forKey:@"family_club"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	return (vo);
}

- (HONUserClubVO *)suggestedBAEClubVO {
	HONUserClubVO *vo = nil;
	
	if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:NSLocalizedString(@"bae_club", @"MyBAE")]) {
		NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
		[dict setValue:@"-5" forKey:@"id"];
		[dict setValue:NSLocalizedString(@"bae_club", @"MyBAE") forKey:@"name"];
		[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
		vo = [HONUserClubVO clubWithDictionary:dict];
	}
	
	return (vo);
}

- (HONUserClubVO *)suggestedBFFsClubVO {
	HONUserClubVO *vo = nil;
	
	if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:NSLocalizedString(@"bff_club", @"MyBFFs")]) {
		NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
		[dict setValue:@"-5" forKey:@"id"];
		[dict setValue:NSLocalizedString(@"bff_club", @"MyBFFs") forKey:@"name"];
		[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
		vo = [HONUserClubVO clubWithDictionary:dict];
	}
	
	return (vo);
}

- (HONUserClubVO *)suggestedSchoolClubVO {
	HONUserClubVO *vo = nil;
	
	if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:NSLocalizedString(@"school_club", @"MySchool")]) {
		NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
		[dict setValue:@"-4" forKey:@"id"];
		[dict setValue:NSLocalizedString(@"school_club", @"MySchool") forKey:@"name"];
		[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
		[dict setValue:@"HIGH_SCHOOL" forKey:@"club_type"];
		vo = [HONUserClubVO clubWithDictionary:dict];
	}
	
	return (vo);
	
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"high_schools"] != nil)
//		vo = [HONUserClubVO clubWithDictionary:[[[NSUserDefaults standardUserDefaults] objectForKey:@"high_schools"] firstObject]];
//	
//	return (vo);
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
		if ([[segmentedDict objectForKey:key] count] >= 5) {
			clubName = [key stringByAppendingString:@" Club"];
			break;
		}
	}
	
	clubName = ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) ? @"" : clubName;
	
	if ([clubName length] > 0) {
		NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
		[dict setValue:@"-3" forKey:@"id"];
		[dict setValue:clubName forKey:@"name"];
		[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"suggested_covers"] objectForKey:@"email"] forKey:@"img"];
		[dict setValue:@"SUGGESTED" forKey:@"club_type"];
		
		vo = [HONUserClubVO clubWithDictionary:[dict copy]];
	}
	
	return (vo);
}

- (void)writePreClubWithTitle:(NSString *)title andBlurb:(NSString *)blurb andCoverPrefixURL:(NSString *)coverPrefix {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"proto_club"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"proto_club"];
	
	[[NSUserDefaults standardUserDefaults] setObject:@{@"name"			: title,
													   @"description"	: blurb,
													   @"img"			: coverPrefix} forKey:@"proto_club"];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)fetchPreClub {
//	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"proto_club"];
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"proto_club"]);
}

- (void)wipeUserClubs {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clubs"];
}

- (void)addClub:(NSDictionary *)club forKey:(NSString *)key {
	NSMutableDictionary *allclubs = [[[HONClubAssistant sharedInstance] fetchUserClubs] mutableCopy];
	NSMutableArray *clubs = [[allclubs objectForKey:key] mutableCopy];
	
	BOOL isFound = NO;
	for (NSDictionary *dict in clubs) {
		if ([[dict objectForKey:@"id"] isEqualToString:[club objectForKey:@"id"]]) {
			isFound = YES;
			break;
		}
	}
	
	if (!isFound) {
		[clubs addObject:club];
		[allclubs setObject:[clubs copy] forKey:key];
		
		[[HONClubAssistant sharedInstance] writeUserClubs:[allclubs copy]];
	}
}

- (void)writeUserClubs:(NSDictionary *)clubs {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"clubs"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clubs"];
	
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

- (HONUserClubVO *)clubWithParticipants:(NSArray *)participants {
	HONUserClubVO *clubVO = nil;
	
	NSMutableArray *ownedClubs = [NSMutableArray array];
	for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"])
		[ownedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
	
	
	for (HONUserClubVO *ownedClubVO in ownedClubs) {
		int avail = [participants count];
		
		for (HONTrivialUserVO *participantVO in participants) {
			for (HONTrivialUserVO *vo in ownedClubVO.activeMembers) {
				NSLog(@"OWNED MATCHING ACTIVE(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, (participantVO.userID == vo.userID), vo.username);
				avail -= (int)(participantVO.userID == vo.userID);
			}
			
			if (avail > 0) {
				for (HONTrivialUserVO *vo in ownedClubVO.pendingMembers) {
					NSLog(@"OWNED MATCHING PENDING(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, (participantVO.userID == vo.userID || [participantVO.altID isEqualToString:vo.altID]), vo.username);
					avail -= (int)(participantVO.userID == vo.userID || [participantVO.altID isEqualToString:vo.altID]);
				}
			}
		}
		
		if (avail == 0) {
			clubVO = ownedClubVO;
			break;
		}
	}
		
	if (clubVO == nil) {
		NSMutableArray *memberClubs = [NSMutableArray array];
		for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"member"])
			[memberClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		
		for (HONUserClubVO *memberClubVO in memberClubs) {
			int avail = [participants count];
			
			for (HONTrivialUserVO *participantVO in participants) {
				avail -= (int)(memberClubVO.ownerID == participantVO.userID);
				
				for (HONTrivialUserVO *vo in memberClubVO.activeMembers) {
					NSLog(@"MEMBER MATCHING ACTIVE(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, (participantVO.userID == vo.userID), vo.username);
					avail -= (int)(participantVO.userID == vo.userID);
				}
				
				if (avail > 0) {
					for (HONTrivialUserVO *vo in memberClubVO.pendingMembers) {
						NSLog(@"MEMBER MATCHING PENDING(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, ((participantVO.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID])), vo.username);
						avail -= (int)((participantVO.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID]));
					}
				}
			}
			
			if (avail == 0) {
				clubVO = memberClubVO;
				break;
			}
		}
		
		if (clubVO == nil) {
			NSMutableArray *pendingClubs = [NSMutableArray array];
			for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"pending"])
				[pendingClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
			
			for (HONUserClubVO *pendingClubVO in pendingClubs) {
				int avail = [participants count];
				
				for (HONTrivialUserVO *participantVO in participants) {
					avail -= (int)(pendingClubVO.ownerID == participantVO.userID);
					
					for (HONTrivialUserVO *vo in pendingClubVO.activeMembers) {
						NSLog(@"PENDING MATCHING ACTIVE (%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, (participantVO.userID == vo.userID), vo.username);
						avail -= (int)(participantVO.userID == vo.userID);
					}
					
					if (avail > 0) {
						for (HONTrivialUserVO *vo in pendingClubVO.pendingMembers) {
							NSLog(@"PENDING MATCHING PENDING(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, ((participantVO.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID])), vo.username);
							avail -= (int)((participantVO.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID]));
						}
					}
				}
				
				if (avail == 0) {
					clubVO = pendingClubVO;
					break;
				}
			}
		}
	}
	
	
	return (clubVO);
}

@end
