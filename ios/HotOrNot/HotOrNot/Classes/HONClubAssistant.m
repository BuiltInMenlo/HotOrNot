//
//  HONClubAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 05/04/2014 @ 00:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>

#import "NSDate+Operations.h"
#import "NSString+Formatting.h"
#import "NSUserDefaults+Replacements.h"

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

- (void)generateSelfieclubOwnedClubWithName:(NSString *)clubName andBlurb:(NSString *)blurb {
	[[HONAPICaller sharedInstance] createClubWithTitle:([clubName length] == 0) ? [NSString stringWithFormat:@"%d_%d", 2394, [NSDate elapsedUTCSecondsSinceUnixEpoch]] : clubName withDescription:([blurb length] > 0) ? blurb : @"STAFF_CLUB" withImagePrefix:[[HONClubAssistant sharedInstance] defaultClubPhotoURL] completion:^(NSDictionary *result) {
		HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:result];
		NSLog(@"CLUB:[%@]", NSStringFromNSDictionary(vo.dictionary));
	}];
}




- (NSArray *)clubTypeKeys {
	return (@[@"pending",
			  @"owned",
			  @"member"]);
}

- (NSString *)userSignupClubCoverImageURL {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"user_club"]);
}

- (NSString *)defaultCoverImageURL {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"club_cover"]);
}

- (NSString *)defaultClubPhotoURL {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"club_photo"]);
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
	return ([NSString stringWithFormat:@"defaultClubPhoto-%02d", (arc4random_uniform(5) + 1)]);
//	NSArray *rndCovers = [[HONClubAssistant sharedInstance] clubCoverPhotoAlbumPrefixes];
//	return ([rndCovers objectAtIndex:(arc4random() % ([rndCovers count] - 1))]);
}

- (NSMutableDictionary *)emptyClubDictionaryWithOwner:(NSDictionary *)owner {
	return ([@{@"id"			: @"",
			   @"name"			: @"",
			  
			   @"description"	: @"",
			   @"img"			: @"",
			   @"club_type"		: @"",
			   @"coords"		: @{@"lat"	: @(0.00),
									@"lon"	: @(0.00)},
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

- (NSMutableDictionary *)clubDictionaryWithOwner:(NSDictionary *)owner activeMembers:(NSArray *)actives pendingMembers:(NSArray *)invites {
	NSMutableArray *members = [NSMutableArray array];
	[actives enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		[members addObject:@{@"id"			: @(vo.userID),
							 @"username"	: vo.username,
							 @"avatar"		: vo.avatarPrefix,
							 @"invited"		: [vo.invitedDate formattedISO8601StringUTC],
							 @"joined"		: [vo.joinedDate formattedISO8601StringUTC]}];
	}];
	
	NSMutableArray *pending = [NSMutableArray array];
	[invites enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		[pending addObject:@{@"id"			: @(vo.userID),
							 @"username"	: vo.username,
							 @"avatar"		: vo.avatarPrefix,
							 @"extern_name"	: ([vo.altID length] > 0) ? vo.username : @"",
							 @"phone"		: vo.altID,
							 @"email"		: vo.altID,
							 @"invited"		: [vo.invitedDate formattedISO8601StringUTC]}];
	}];
	
	NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{@"id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																							 @"username"	: [[HONAppDelegate infoForUser] objectForKey:@"username"],
																							 @"avatar"		: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]}];
	[dict replaceObject:@(1 + ((int)[members count] + (int)[pending count])) forKey:@"total_members"];
	[dict replaceObject:[members copy] forKey:@"members"];
	[dict replaceObject:[pending copy] forKey:@"pending"];
	
	return (dict);
}

- (void)locationClubWithCompletion:(void (^)(id result))completion {
	__block HONUserClubVO *clubVO = nil;
	
	CGFloat radius = [[[NSUserDefaults standardUserDefaults] objectForKey:@"join_radius"] floatValue];
	[[HONAPICaller sharedInstance] retrieveNearbyClubFromLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] withinRadius:radius completion:^(NSMutableDictionary *result) {
		if ([result count] == 0) {
			[[HONClubAssistant sharedInstance] createLocationClubWithCompletion:^(HONUserClubVO *clubVO) {
				[[HONClubAssistant sharedInstance] writeClub:result];
				
				if (completion)
					completion(clubVO);
			}];
			
		} else {
			CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[result objectForKey:@"coords"] objectForKey:@"lat"] doubleValue] longitude:[[[result objectForKey:@"coords"] objectForKey:@"lon"] doubleValue]];
			CGFloat distance = [[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:location];
			
			[result setValue:@(distance) forKey:@"distance"];
			[result setValue:@(radius) forKey:@"radius"];
			[result setValue:([result objectForKey:@"coords"] != nil) ? [result objectForKey:@"coords"] : @{@"lat"	: [result objectForKey:@"lat"],
																											@"lon"	: [result objectForKey:@"lon"]} forKey:@"coords"];
			[result setValue:@{@"id"		: [result objectForKey:@"owner"],
							   @"username"	: @"",
							   @"avatar"	: [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront] stringByAppendingString:@"/defaultAvatar"]} forKey:@"owner"];
			
			
			if ([[HONClubAssistant sharedInstance] currentLocationClub].clubID != [[result objectForKey:@"id"] intValue]) {
				NSLog(@"CLOSEST CLUB:[%@] IN RANGE:%@ -= %.04f @ (%@)", result, NSStringFromBOOL([[result objectForKey:@"distance"] floatValue] <= [[result objectForKey:@"radius"] floatValue]), [[result objectForKey:@"distance"] floatValue], NSStringFromCLLocation([[HONDeviceIntrinsics sharedInstance] deviceLocation]));
				if ([[result objectForKey:@"distance"] floatValue] <= [[result objectForKey:@"radius"] floatValue]) {
					if ([[HONClubAssistant sharedInstance] isMemberOfClubWithClubID:[[result objectForKey:@"id"] intValue] includePending:NO]) {
						[[HONAPICaller sharedInstance] retrieveClubByClubID:[[result objectForKey:@"id"] intValue] withOwnerID:[[[result objectForKey:@"owner"] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
							NSMutableDictionary *dict = [result mutableCopy];
							[dict setValue:[result objectForKey:@"coords"] forKey:@"coords"];
							[dict setValue:[result objectForKey:@"radius"] forKey:@"radius"];
							[dict setValue:[result objectForKey:@"distance"] forKey:@"distance"];
							clubVO = [HONUserClubVO clubWithDictionary:dict];
							
							if (completion)
								completion(clubVO);
						}];
						
					} else {
						NSMutableDictionary *dict = [result mutableCopy];
						[dict setValue:[result objectForKey:@"coords"] forKey:@"coords"];
						[dict setValue:[result objectForKey:@"radius"] forKey:@"radius"];
						[dict setValue:[result objectForKey:@"distance"] forKey:@"distance"];
						clubVO = [HONUserClubVO clubWithDictionary:dict];
						
						[[HONAPICaller sharedInstance] joinClub:clubVO completion:^(NSDictionary *result) {
							[[HONAPICaller sharedInstance] retrieveClubByClubID:clubVO.clubID withOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
								[[HONClubAssistant sharedInstance] writeClub:result];
								
								if (completion)
									completion(clubVO);
							}];
						}];
					}
				
				} else {
					[[HONClubAssistant sharedInstance] createLocationClubWithCompletion:^(HONUserClubVO *clubVO) {
						if (completion)
							completion(clubVO);
					}];
				}
			
			} else {
				if (completion)
					completion([[HONClubAssistant sharedInstance] currentLocationClub]);
			}
		}
	}];
	
	
	
	/*
	NSMutableArray *locationClubs = [NSMutableArray array];
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"location_clubs"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dict = [(NSDictionary *)obj mutableCopy];
		CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[dict objectForKey:@"coords"] objectForKey:@"lat"] doubleValue] longitude:[[[dict objectForKey:@"coords"] objectForKey:@"lon"] doubleValue]];
		CGFloat dist = [[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:location];
		
		[dict setValue:@(dist) forKey:@"distance"];
		[locationClubs addObject:dict];
	}];
	
	NSDictionary *locationClub = [[locationClubs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSDictionary *dict1 = (NSDictionary *)obj1;
		NSDictionary *dict2 = (NSDictionary *)obj2;
		
		if ([[dict1 objectForKey:@"distance"] floatValue] > [[dict2 objectForKey:@"distance"] floatValue])
			return ((NSComparisonResult)NSOrderedDescending);
		
		if ([[dict1 objectForKey:@"distance"] floatValue] < [[dict2 objectForKey:@"distance"] floatValue])
			return ((NSComparisonResult)NSOrderedAscending);
		
		return ((NSComparisonResult)NSOrderedSame);
	}] firstObject];
	
	NSLog(@"CLOSEST CLUB:[%@] CAN POST:%@", locationClub, NSStringFromBOOL([[locationClub objectForKey:@"dist"] floatValue]));
	NSLog(@"MEMBER OF:[%d] =-= (%@)", [[locationClub objectForKey:@"club_id"] intValue], NSStringFromBOOL([[HONClubAssistant sharedInstance] isMemberOfClubWithClubID:[[locationClub objectForKey:@"club_id"] intValue] includePending:NO]));
	if ([[HONClubAssistant sharedInstance] isMemberOfClubWithClubID:[[locationClub objectForKey:@"club_id"] intValue] includePending:NO]) {
		[[HONAPICaller sharedInstance] retrieveClubByClubID:[[locationClub objectForKey:@"club_id"] intValue] withOwnerID:[[locationClub objectForKey:@"owner_id"] intValue] completion:^(NSDictionary *result) {
			NSMutableDictionary *dict = [result mutableCopy];
			[dict setValue:[locationClub objectForKey:@"coords"] forKey:@"coords"];
			[dict setValue:[locationClub objectForKey:@"radius"] forKey:@"radius"];
			[dict setValue:[locationClub objectForKey:@"distance"] forKey:@"distance"];
			clubVO = [HONUserClubVO clubWithDictionary:dict];
			
			[[NSUserDefaults standardUserDefaults] setObject:clubVO.dictionary forKey:@"location_club"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			if (completion)
				completion(clubVO);
		}];
		
	} else {
		[[HONAPICaller sharedInstance] retrieveClubByClubID:[[locationClub objectForKey:@"club_id"] intValue] withOwnerID:[[locationClub objectForKey:@"owner_id"] intValue] completion:^(NSDictionary *result) {
			NSMutableDictionary *dict = [result mutableCopy];
			[dict setValue:[locationClub objectForKey:@"coords"] forKey:@"coords"];
			[dict setValue:[locationClub objectForKey:@"radius"] forKey:@"radius"];
			[dict setValue:[locationClub objectForKey:@"distance"] forKey:@"distance"];
			clubVO = [HONUserClubVO clubWithDictionary:dict];
			
			[[NSUserDefaults standardUserDefaults] setObject:clubVO.dictionary forKey:@"location_club"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[HONAPICaller sharedInstance] joinClub:clubVO completion:^(NSDictionary *result) {
				if (completion)
					completion(clubVO);
			}];
		}];
	}
	*/
}



- (NSArray *)staffDesignatedClubsWithThreshold:(int)threshold {
	NSMutableArray *staffClubs = [NSMutableArray arrayWithArray:@[]];
//	__block BOOL isInRange = NO;
//	__block NSDictionary *foundDict;
//	__block HONUserClubVO *vo = nil;
	
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"staff_clubs"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSMutableDictionary *dict = (NSMutableDictionary *)[obj mutableCopy];
		
		CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[dict objectForKey:@"coords"] objectForKey:@"lat"] doubleValue] longitude:[[[dict objectForKey:@"coords"] objectForKey:@"lon"] doubleValue]];
		CGFloat distance = [[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:location];
		NSLog(@"LOCATION_CLUB:[%d - %@] -=- (%.03f)", [[dict objectForKey:@"club_id"] intValue], [dict objectForKey:@"name"], [[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:location]);
		
		[dict setValue:[dict objectForKey:@"club_id"] forKey:@"id"];
		[dict setObject:@{@"id"			: [dict objectForKey:@"owner_id"],
						  @"username"	: @"",
						  @"avatar"		: [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront] stringByAppendingString:@"/defaultAvatar"]} forKey:@"owner"];
		[dict setValue:@(distance) forKey:@"distance"];
		
//		if (distance <= [[dict objectForKey:@"radius"] floatValue]) {
//			foundDict = dict;
//			isInRange = YES;
//			*stop = YES;
//		}
		
		[staffClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
	}];
	
	
	staffClubs = [[staffClubs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		HONUserClubVO *vo1 = (HONUserClubVO *)obj1;
		HONUserClubVO *vo2 = (HONUserClubVO *)obj2;
		
		if (vo1.distance < vo2.distance)
			return ((NSComparisonResult)NSOrderedAscending);
		
		if (vo2.distance < vo1.distance)
			return ((NSComparisonResult)NSOrderedDescending);
		
		return ((NSComparisonResult)NSOrderedSame);
	}] mutableCopy];
	
	
	// inside the radius, join if needed
//	if (isInRange) {
//		[[HONAPICaller sharedInstance] retrieveClubByClubID:[[foundDict objectForKey:@"club_id"] intValue] withOwnerID:[[foundDict objectForKey:@"owner_id"] intValue] completion:^(NSDictionary *result) {
//			vo = [HONUserClubVO clubWithDictionary:result];
//			
//			if (![[HONClubAssistant sharedInstance] isMemberOfClub:vo includePending:YES]) {
//				[[HONAPICaller sharedInstance] joinClub:vo completion:^(NSDictionary *result) {
//					[[HONAPICaller sharedInstance] retrieveClubByClubID:vo.clubID withOwnerID:vo.ownerID completion:^(NSDictionary *result) {
//						[[HONClubAssistant sharedInstance] writeClub:result];
//						
//						[[NSUserDefaults standardUserDefaults] setObject:vo.dictionary forKey:@"location_club"];
//						[[NSUserDefaults standardUserDefaults] synchronize];
//					}];
//				}];
//			
//			} else {
//				[[NSUserDefaults standardUserDefaults] setObject:vo.dictionary forKey:@"location_club"];
//				[[NSUserDefaults standardUserDefaults] synchronize];
//			}
//		}];
	
	// leave that club alone, he's just a boigh!
//	} else {
//	}
	
	
	return ([staffClubs subarrayWithRange:NSMakeRange(0, MIN(MAX(0, threshold), [staffClubs count] - 1))]);
}


- (HONUserClubVO *)currentLocationClub {
	return ([HONUserClubVO clubWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"location_club"]]);
}

- (void)createLocationClubWithCompletion:(void (^)(id result))completion {
	__block HONUserClubVO *clubVO = nil;
	
	[[HONAPICaller sharedInstance] createClubWithTitle:[NSString stringWithFormat:@"My Location|%.03f_%.03f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude]
									   withDescription:@""
									   withImagePrefix:[[HONClubAssistant sharedInstance] defaultCoverImageURL]
											atLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation]
											completion:^(NSDictionary *result) {
		NSDictionary *dict = [result mutableCopy];
		
		[dict setValue:@(0.0) forKey:@"distance"];
		[dict setValue:@([[[NSUserDefaults standardUserDefaults] objectForKey:@"join_radius"] floatValue]) forKey:@"radius"];
		[dict setValue:@{@"lat"	: @([[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude),
						 @"lon"	: @([[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude)} forKey:@"coords"];
		
		clubVO = [HONUserClubVO clubWithDictionary:dict];
		NSLog(@"CREATED CLUB:[%@]", NSStringFromNSDictionary(clubVO.dictionary));
		
		if (completion)
			completion(clubVO);
	}];
}

- (NSMutableDictionary *)emptyClubPhotoDictionary {
	return ([@{@"challenge_id"	: @"0",
			  @"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
			  @"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],
			  @"avatar"			: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
			  @"img"			: [[HONClubAssistant sharedInstance] defaultClubPhotoURL],
			  @"score"			: @"0",
			  @"subjects"		: @[],
			  @"added"			: [NSDate utcStringFormattedISO8601]} mutableCopy]);
}

- (NSArray *)emotionsForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	return (@[]);
}

- (BOOL)isStaffClub:(HONUserClubVO *)clubVO {
	__block BOOL isFound = NO;
	
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"staff_clubs"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSMutableDictionary *dict = (NSMutableDictionary *)[obj mutableCopy];
		
		if ([[dict objectForKey:@"club_id"] intValue] == clubVO.clubID) {
			isFound = YES;
			*stop = YES;
		}
	}];
	
	
	return (isFound);
}

- (BOOL)isMemberOfClub:(HONUserClubVO *)clubVO includePending:(BOOL)isPending {
	__block BOOL isFound = NO;
	
	
	if (clubVO.clubID == [[HONClubAssistant sharedInstance] currentLocationClub].clubID)
		return (YES);
	
	if (clubVO.ownerID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
		return (YES);
	
	[clubVO.activeMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		
		if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
			isFound = YES;
			*stop = YES;
		}
	}];
	
	if (isPending && !isFound) {
		[clubVO.pendingMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
			
			if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				isFound = YES;
				*stop = YES;
			}
		}];
	}
	
	return (isFound);
}

- (BOOL)isMemberOfClubWithClubID:(int)clubID includePending:(BOOL)isPending {
	__block BOOL isFound = NO;
	
	[[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[(NSDictionary *)obj objectForKey:@"id"] intValue] == clubID) {
			isFound = YES;
			*stop = YES;
		}
	}];
	
	if (!isFound) {
		[[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"member"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([[(NSDictionary *)obj objectForKey:@"id"] intValue] == clubID) {
				isFound = YES;
				*stop = YES;
			}
		}];
	}
	
	if (isPending && !isFound) {
		[[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"pending"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([[(NSDictionary *)obj objectForKey:@"id"] intValue] == clubID) {
				isFound = YES;
				*stop = YES;
			}
		}];
	}
	
	return (isFound);
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

- (void)isStatusUpdateSeenWithID:(int)statusUpdateID completion:(void (^)(BOOL isSeen))completion {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"seen_updates"] == nil) {
		[[NSUserDefaults standardUserDefaults] setValue:@{} forKey:@"seen_updates"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	NSLog(@"!!!!! LOCAL SEEN:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"seen_updates"]);
	
	__block BOOL isFound = NO;
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"seen_updates"] objectForKey:NSStringFromInt(statusUpdateID)] != nil) {
		if (completion)
			completion(YES);
	
	} else {
		[[HONAPICaller sharedInstance] retrieveSeenMembersChallengeWithChallengeID:statusUpdateID completion:^(NSDictionary *result) {
			[[result objectForKey:@"results"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSDictionary *dict = (NSDictionary *)obj;
				isFound = ([[dict objectForKey:@"member_id"] intValue] == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
//				NSLog(@"--- dict:[%@]", dict);
//				NSLog(@"--- isFound:[%@]", NSStringFromBOOL(isFound));
				
				if (isFound) {
					NSMutableDictionary *seenClubs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"seen_updates"] mutableCopy];
					[seenClubs setValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:NSStringFromInt(statusUpdateID)];
					
					[[NSUserDefaults standardUserDefaults] setValue:[seenClubs copy] forKey:@"seen_updates"];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
				
				*stop = isFound;
			}];
			
			if (completion)
				completion(isFound);
		}];
	}
}

- (BOOL)hasVotedForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	__block BOOL isFound = NO;
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"votes"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		NSLog(@"VOTES:[%d]=-(%@)-=[%d]", [key intValue], NSStringFromBOOL(([(NSString *)key isEqualToString:NSStringFromInt(clubPhotoVO.challengeID)])), clubPhotoVO.challengeID);
		if ([(NSString *)key isEqualToString:NSStringFromInt(clubPhotoVO.challengeID)])
			isFound = YES;
		
		*stop = isFound;
	}];
	
	return (isFound);
}

- (BOOL)hasVotedForComment:(HONCommentVO *)commentVO {
	__block BOOL isFound = NO;
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"votes"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		NSLog(@"VOTES:[%d]=-(%@)-=[%d]", [key intValue], NSStringFromBOOL(([(NSString *)key isEqualToString:NSStringFromInt(clubPhotoVO.challengeID)])), clubPhotoVO.challengeID);
		if ([(NSString *)key isEqualToString:NSStringFromInt(commentVO.commentID)])
			isFound = YES;
		
		*stop = isFound;
	}];
	
	return (isFound);
}

- (int)labelIDForAreaCode:(NSString *)areaCode {
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
		[[[UIAlertView alloc] initWithTitle:@"Paste anywhere to share!"
									message:@""
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
}

- (NSArray *)repliesForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSMutableArray *replies = [NSMutableArray array];
	
	[[[HONClubAssistant sharedInstance] fetchClubWithClubID:clubPhotoVO.clubID].submissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoVO *vo = (HONClubPhotoVO *)obj;
//		NSLog(@"REPLY FOR:[%d] -=- ID:[%d] PARENT:[%d]", clubPhotoVO.challengeID, vo.challengeID, vo.parentID);
		if (vo.parentID == clubPhotoVO.challengeID && [vo.comment length] > 0) {
			[replies addObject:[HONCommentVO commentWithClubPhoto:vo]];
		}
	}];
	
	return ([replies copy]);
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
			[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
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
		[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
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
			NSLog(@"KEY:[%@]-=-(%ld)", key, (unsigned long)[[segmentedDict objectForKey:key] count]);
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
		[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
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
		[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
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

- (void)writeStatusUpdateAsVotedWithID:(int)statusUpdateID asUpVote:(BOOL)isUpVote {
	NSMutableDictionary *votes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"votes"] mutableCopy];
	[votes setValue:(isUpVote) ? @(1) : @(-1) forKey:NSStringFromInt(statusUpdateID)];
	
	[[NSUserDefaults standardUserDefaults] setObject:[votes copy] forKey:@"votes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)writeCommentAsVotedWithID:(int)commentID asUpVote:(BOOL)isUpVote {
	NSMutableDictionary *votes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"votes"] mutableCopy];
	[votes setValue:(isUpVote) ? @(1) : @(-1) forKey:NSStringFromInt(commentID)];
	
	[[NSUserDefaults standardUserDefaults] setObject:[votes copy] forKey:@"votes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)fetchPreClub {
//	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"proto_club"];
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"proto_club"]);
}

- (void)wipeUserClubs {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clubs"];
}

- (void)writeClub:(NSDictionary *)clubDictionary {
	NSMutableDictionary *allclubs = [[[HONClubAssistant sharedInstance] fetchUserClubs] mutableCopy];
	
	__block int ind = -1;
	__block BOOL isFound = NO;
	__block NSString *key = [[[HONClubAssistant sharedInstance] clubTypeKeys] firstObject];
	__block NSMutableArray *clubs = [[allclubs objectForKey:key] mutableCopy];
	[[[HONClubAssistant sharedInstance] clubTypeKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		key = (NSString *)obj;
		
		clubs = [[allclubs objectForKey:key] mutableCopy];
		[clubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *dict = (NSDictionary *)obj;
			if ([[dict objectForKey:@"id"] isEqualToString:[clubDictionary objectForKey:@"id"]]) {
				ind = idx;
				isFound = YES;
			}
			
			*stop = isFound;
		}];
		
		
		if (isFound && ind > -1) {
			[clubs removeObjectAtIndex:ind];
			*stop = YES;
		}
	}];
	
	[clubs addObject:clubDictionary];
	[allclubs setObject:[clubs copy] forKey:key];
	[[HONClubAssistant sharedInstance] writeUserClubs:[allclubs copy]];
}

- (void)writeStatusUpdateAsSeenWithID:(int)statusUpdateID completion:(void (^)(id result))completion {
	[[NSUserDefaults standardUserDefaults] setObject:@{} forKey:@"seen_updates"];
	
	NSMutableDictionary *seenClubs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"seen_updates"] mutableCopy];
	[seenClubs setValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:NSStringFromInt(statusUpdateID)];
	
	[[NSUserDefaults standardUserDefaults] setValue:[seenClubs copy] forKey:@"seen_updates"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[HONAPICaller sharedInstance] markChallengeAsSeenWithChallengeID:statusUpdateID completion:^(NSDictionary *result) {
		if (completion)
			completion(result);
	}];
}

- (void)writeUserClubs:(NSDictionary *)clubs {
	[[NSUserDefaults standardUserDefaults] replaceObject:clubs forKey:@"clubs"];
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


- (HONUserClubVO *)fetchClubWithClubID:(int)clubID {
	HONUserClubVO *clubVO = nil;
	
	for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"]) {
		HONUserClubVO *ownedClubVO = [HONUserClubVO clubWithDictionary:dict];
		if (ownedClubVO.clubID == clubID) {
			clubVO = ownedClubVO;
			break;
		}
	}
	
	for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"member"]) {
		HONUserClubVO *memberClubVO = [HONUserClubVO clubWithDictionary:dict];
		if (memberClubVO.clubID == clubID) {
			clubVO = memberClubVO;
			break;
		}
	}
	
	for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"pending"]) {
		HONUserClubVO *pendingClubVO = [HONUserClubVO clubWithDictionary:dict];
		if (pendingClubVO.clubID == clubID) {
			clubVO = pendingClubVO;
			break;
		}
	}
	
	return (clubVO);
}

- (HONClubPhotoVO *)fetchClubPhotoWithClubPhotoID:(int)challengeID {
	
	__block HONClubPhotoVO *clubPhotoVO = nil;
	[[[HONClubAssistant sharedInstance] clubTypeKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:(NSString *)obj]) {
			[[HONUserClubVO clubWithDictionary:dict].submissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONClubPhotoVO *vo = (HONClubPhotoVO *)obj;
				if (vo.challengeID == challengeID) {
					clubPhotoVO = [HONClubPhotoVO clubPhotoWithDictionary:vo.dictionary];
					*stop = YES;
				}
			}];
		}
	}];
	
	return (clubPhotoVO);
		
}

- (HONUserClubVO *)createClubWithSameParticipants:(NSArray *)participants {
	__block HONUserClubVO *clubVO = [[HONClubAssistant sharedInstance] clubWithParticipants:participants];
	
	if (clubVO != nil) {
		[[HONAPICaller sharedInstance] createClubWithTitle:clubVO.clubName withDescription:clubVO.blurb withImagePrefix:clubVO.coverImagePrefix completion:^(NSDictionary *result) {
			clubVO = [HONUserClubVO clubWithDictionary:result];
		}];
	
	} else {
		NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubPhotoDictionary] mutableCopy];
		[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], [NSDate elapsedUTCSecondsSinceUnixEpoch]] forKey:@"name"];
		[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
		clubVO = [HONUserClubVO clubWithDictionary:dict];
		
		[[HONAPICaller sharedInstance] createClubWithTitle:clubVO.clubName withDescription:clubVO.blurb withImagePrefix:clubVO.coverImagePrefix completion:^(NSDictionary *result) {
			clubVO = [HONUserClubVO clubWithDictionary:result];
			
			__block NSString *names = @"";
//			__block HONClubPhotoVO *clubPhotoVO = nil;
			
			NSMutableArray *selectedUsers = [NSMutableArray array];
			NSMutableArray *selectedContacts = [NSMutableArray array];
			
			NSMutableArray *participants = [NSMutableArray array];
			[clubVO.activeMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
				[selectedUsers addObject:vo];
				[participants addObject:vo.username];
				names = [names stringByAppendingFormat:@"%@, ", vo.username];
			}];
			
			[clubVO.pendingMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *trivialUserVO = (HONTrivialUserVO *)obj;
				if ([trivialUserVO.altID length] > 0) {
					HONContactUserVO *contactUserVO = [HONContactUserVO contactFromTrivialUserVO:trivialUserVO];
					[selectedContacts addObject:contactUserVO];
					
					[participants addObject:trivialUserVO.username];
					names = [names stringByAppendingFormat:@"%@, ", trivialUserVO.username];
				}
			}];

			names = [names stringByTrimmingFinalSubstring:@", "];
		}];
	}
	
	return (clubVO);
}

- (HONClubPhotoVO *)submitClubPhotoIntoClub:(HONUserClubVO *)clubVO {
	__block HONClubPhotoVO *clubPhotoVO = nil;
	return (clubPhotoVO);
}


- (void)sendClubInvites:(HONUserClubVO *)clubVO toInAppUsers:(NSArray *)inAppUsers toNonAppContacts:(NSArray *)nonAppContacts completion:(void (^)(BOOL success))completion {
	if ([inAppUsers count] == 0 && [nonAppContacts count] == 0) {
		if (completion)
			completion(YES);
	}
	
	if ([inAppUsers count] > 0 && [nonAppContacts count] > 0) {
		[[HONAPICaller sharedInstance] inviteInAppUsers:inAppUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID inviteNonAppContacts:nonAppContacts completion:^(NSDictionary *result) {
			if (completion)
				completion(YES);
		}];
		
	} else {
		if ([inAppUsers count] > 0) {
			[[HONAPICaller sharedInstance] inviteInAppUsers:inAppUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
				if (completion)
					completion(YES);
			}];
		}
		
		if ([nonAppContacts count] > 0) {
			[[HONAPICaller sharedInstance] inviteNonAppUsers:nonAppContacts toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
				if (completion)
					completion(YES);
			}];
		}
	}
}

- (HONUserClubVO *)clubWithParticipants:(NSArray *)participants {
	HONUserClubVO *clubVO = nil;
	
	NSMutableArray *ownedClubs = [NSMutableArray array];
	for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"])
		[ownedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
	
	
	for (HONUserClubVO *ownedClubVO in ownedClubs) {
		int avail = (int)[participants count];
		
		if (avail != [ownedClubVO.activeMembers count] + [ownedClubVO.pendingMembers count])
			continue;
		
		else {
			for (HONTrivialUserVO *participantVO in participants) {
				for (HONTrivialUserVO *vo in ownedClubVO.activeMembers) {
					NSLog(@"OWNED MATCHING ACTIVE(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, (participantVO.userID == vo.userID), vo.username);
					avail -= (int)(participantVO.userID == vo.userID);
				}
				
				if (avail > 0) {
					for (HONTrivialUserVO *vo in ownedClubVO.pendingMembers) {
						NSLog(@"OWNED(%d) MATCHING PENDING(%d):[%@]<=|%d|-=>[%@]", ownedClubVO.clubID, avail, participantVO.username, ((participantVO.userID != 0 && vo.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [vo.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID])), vo.username);
						NSLog(@"PARTICIPANT:(%d)[%@]", participantVO.userID, participantVO.altID);
						NSLog(@"PENDING:(%d)[%@]", vo.userID, vo.altID);
						
						avail -= (int)((participantVO.userID != 0 && vo.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [vo.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID]));
					}
				}
			}
			
			if (avail == 0) {
				clubVO = ownedClubVO;
				break;
			}
		}
	}
	
	if (clubVO == nil) {
		NSMutableArray *memberClubs = [NSMutableArray array];
		for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"member"])
			[memberClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		
		for (HONUserClubVO *memberClubVO in memberClubs) {
			int avail = (int)[participants count];
			
			if (avail != 1 + ([memberClubVO.activeMembers count] - 1) + [memberClubVO.pendingMembers count])
				continue;
			
			else {
				for (HONTrivialUserVO *participantVO in participants) {
					avail -= (int)(memberClubVO.ownerID == participantVO.userID);
					
					for (HONTrivialUserVO *vo in memberClubVO.activeMembers) {
						if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
							continue;
						
						NSLog(@"MEMBER MATCHING ACTIVE(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, (participantVO.userID == vo.userID), vo.username);
						avail -= (int)(participantVO.userID == vo.userID);
					}
					
					if (avail > 0) {
						for (HONTrivialUserVO *vo in memberClubVO.pendingMembers) {
							NSLog(@"MEMBER MATCHING PENDING(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, ((participantVO.userID != 0 && vo.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [vo.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID])), vo.username);
							avail -= (int)((participantVO.userID != 0 && vo.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [vo.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID]));
						}
					}
				}
				
				if (avail == 0) {
					clubVO = memberClubVO;
					break;
				}
			}
		}
		
		if (clubVO == nil) {
			NSMutableArray *pendingClubs = [NSMutableArray array];
			for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"pending"])
				[pendingClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
			
			for (HONUserClubVO *pendingClubVO in pendingClubs) {
				int avail = (int)[participants count];
				
				if (avail != 1 + [pendingClubVO.activeMembers count] + ([pendingClubVO.pendingMembers count] - 1))
					continue;
				
				else {
					for (HONTrivialUserVO *participantVO in participants) {
						avail -= (int)(pendingClubVO.ownerID == participantVO.userID);
						
						for (HONTrivialUserVO *vo in pendingClubVO.activeMembers) {
							NSLog(@"PENDING MATCHING ACTIVE (%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, (participantVO.userID == vo.userID), vo.username);
							avail -= (int)(participantVO.userID == vo.userID);
						}
						
						if (avail > 0) {
							for (HONTrivialUserVO *vo in pendingClubVO.pendingMembers) {
								if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
									continue;
								
								NSLog(@"PENDING MATCHING PENDING(%d):[%@]<=|%d|-=>[%@]", avail, participantVO.username, ((participantVO.userID != 0 && vo.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [vo.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID])), vo.username);
								avail -= (int)((participantVO.userID != 0 && vo.userID != 0 && participantVO.userID == vo.userID) || ([participantVO.altID length] > 0 && [vo.altID length] > 0 && [participantVO.altID isEqualToString:vo.altID]));
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
	}
	
	
	return (clubVO);
}

- (HONUserClubVO *)clubWithClubID:(int)clubID {
	__block HONUserClubVO *vo = nil;
	
	[[[HONClubAssistant sharedInstance] fetchUserClubs] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		NSArray *dict = (NSArray *)obj;
		[dict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([[(NSDictionary *)obj objectForKey:@"id"] intValue] == clubID) {
				vo = [HONUserClubVO clubWithDictionary:(NSDictionary *)obj];
				*stop = YES;
			}
		}];
	}];
	
	return (vo);
}

- (HONUserClubVO *)clubWithName:(NSString *)clubName {
	__block HONUserClubVO *vo = nil;
	
	[[[HONClubAssistant sharedInstance] fetchUserClubs] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		NSArray *dict = (NSArray *)obj;
		[dict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([[(NSDictionary *)obj objectForKey:@"name"] isEqualToString:clubName]) {
				vo = [HONUserClubVO clubWithDictionary:(NSDictionary *)obj];
				*stop = YES;
			}
		}];
	}];
	
	return (vo);
}

@end
