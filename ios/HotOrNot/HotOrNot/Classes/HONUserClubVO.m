//
//  HONUserClubVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "NSString+DataTypes.h"

#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"

@implementation HONUserClubVO
@synthesize dictionary;
@synthesize clubID, clubName, coverImagePrefix, blurb, ownerID, ownerName, ownerImagePrefix, pendingMembers, activeMembers, bannedMembers, addedDate, updatedDate, totalScore, submissions, clubEnrollmentType;
@synthesize visibleMembers, totalMembers;

+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary {
	HONUserClubVO *vo = [[HONUserClubVO alloc] init];
	vo.dictionary = dictionary;
	
//	for (NSString *param in dictionary)
//		NSLog(@"NAME:[%@]", param);
	
//	NSLog(@"NAME:[%@]", [dictionary objectForKey:@"name"]);
//	NSLog(@"DICTIONARY[%@]\nOWNER:[%@]\nMEMBERS:[%@]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary, [dictionary objectForKey:@"owner"], [dictionary objectForKey:@"members"], [dictionary objectForKey:@"added"]);
	
	vo.clubID = [[dictionary objectForKey:@"id"] intValue];
	vo.clubName = [dictionary objectForKey:@"name"];
	vo.blurb = ([dictionary objectForKey:@"description"] != nil) ? [dictionary objectForKey:@"description"] : @"";
	
	vo.coverImagePrefix = ([dictionary objectForKey:@"img"] != nil && [[dictionary objectForKey:@"img"] length] > 0) ? [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[dictionary objectForKey:@"img"]] : [[HONClubAssistant sharedInstance] defaultCoverImageURL];
	vo.coverImagePrefix = ([vo.coverImagePrefix rangeOfString:@"defaultClubCover"].location != NSNotFound) ? [[HONClubAssistant sharedInstance] defaultCoverImageURL] : vo.coverImagePrefix;
	
	NSMutableString *imgURL = [vo.coverImagePrefix mutableCopy];
	[imgURL replaceOccurrencesOfString:@"http://d1fqnfrnudpaz6.cloudfront.net" withString:@"https://hotornot-challenges.s3.amazonaws.com" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imgURL length])];
	vo.coverImagePrefix = [imgURL copy];
	
	vo.addedDate = [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	vo.updatedDate = [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"updated"]];
	
	vo.ownerID = [[[dictionary objectForKey:@"owner"] objectForKey:@"id"] intValue];
	vo.ownerName = [[dictionary objectForKey:@"owner"] objectForKey:@"username"];
	vo.ownerImagePrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:([[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] != nil) ? [[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] : [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront] stringByAppendingString:@"/defaultAvatar"]];
	
	vo.visibleMembers = 1;
	vo.totalMembers = 1;
	
	NSMutableArray *pending = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"pending"])
		[pending addObject:([[dict objectForKey:@"extern_name"] length] > 0) ? [HONTrivialUserVO userFromContactUserVO:[HONContactUserVO contactWithDictionary:dict]] : [HONTrivialUserVO userWithDictionary:dict]];
	vo.pendingMembers = pending;
	vo.totalMembers += (int)[vo.pendingMembers count];
	
	NSMutableArray *members = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"members"])
		[members addObject:[HONTrivialUserVO userWithDictionary:dict]];
	vo.activeMembers = members;
	vo.totalMembers += (int)[vo.activeMembers count];
	vo.visibleMembers += (int)[vo.activeMembers count];
	
	NSMutableArray *banned = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"blocked"])
		[banned addObject:[HONTrivialUserVO userWithDictionary:dict]];
	vo.bannedMembers = banned;
	
	NSMutableArray *submissions = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"submissions"]) {
		NSMutableDictionary *mDict = [dict mutableCopy];
		[mDict setValue:[@"" stringFromInt:vo.clubID] forKey:@"club_id"];
		[submissions addObject:[HONClubPhotoVO clubPhotoWithDictionary:[mDict copy]]];
	}
	
	vo.submissions = [[[submissions copy] reverseObjectEnumerator] allObjects];
	vo.totalScore = [[dictionary objectForKey:@"total_score"] intValue];
	
	vo.clubEnrollmentType = (vo.ownerID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? HONClubEnrollmentTypeOwner : HONClubEnrollmentTypeUndetermined;
	vo.clubEnrollmentType = (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined && [[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"LOCKED"]) ? HONClubEnrollmentTypeThreshold : vo.clubEnrollmentType;
	vo.clubEnrollmentType = (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined && [[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"CREATE"]) ? HONClubEnrollmentTypeCreate : vo.clubEnrollmentType;
	vo.clubEnrollmentType = (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined && [[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"SUGGESTED"]) ? HONClubEnrollmentTypeSuggested : vo.clubEnrollmentType;
	vo.clubEnrollmentType = (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined && [[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"HIGH_SCHOOL"]) ? HONClubEnrollmentTypeHighSchool : vo.clubEnrollmentType;
	
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
		for (HONTrivialUserVO *trivialUserVO in vo.pendingMembers) {
//			NSLog(@"PENDING:(%d) - [%d - %@]", vo.clubID, trivialUserVO.userID, trivialUserVO.username);
			if (trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				vo.clubEnrollmentType = HONClubEnrollmentTypePending;
				break;
			}
		}
	}
		
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
		for (HONTrivialUserVO *trivialUserVO in vo.activeMembers) {
//			NSLog(@"ACTIVE:(%d) - [%d - %@]", vo.clubID, trivialUserVO.userID, trivialUserVO.username);
			if (trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				vo.clubEnrollmentType = HONClubEnrollmentTypeMember;
				break;
			}
		}
	}
	
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
		for (HONTrivialUserVO *trivialUserVO in vo.bannedMembers) {
//			NSLog(@"BANNED:(%d) - [%d - %@]", vo.clubID, trivialUserVO.userID, trivialUserVO.username);
			if (trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				vo.clubEnrollmentType = HONClubEnrollmentTypeBanned;
				break;
			}
		}
	}
	
	vo.clubEnrollmentType = (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) ? HONClubEnrollmentTypeUnknown : vo.clubEnrollmentType;
	
	NSLog(@"//-/--/--/ {%@} -(%@)- [%d | %@] /--/--/-//", [vo.updatedDate formattedISO8601String], (vo.clubEnrollmentType == HONClubEnrollmentTypeBanned) ? @"Banned" : (vo.clubEnrollmentType == HONClubEnrollmentTypeCreate) ? @"Create" : (vo.clubEnrollmentType == HONClubEnrollmentTypeHighSchool) ? @"HighSchool" : (vo.clubEnrollmentType == HONClubEnrollmentTypeMember) ? @"Member" : (vo.clubEnrollmentType == HONClubEnrollmentTypeOwner) ? @"Owner" : (vo.clubEnrollmentType == HONClubEnrollmentTypePending) ? @"Pending" : (vo.clubEnrollmentType == HONClubEnrollmentTypeSuggested) ? @"Suggested" : (vo.clubEnrollmentType == HONClubEnrollmentTypeThreshold) ? @"Threshold" : (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) ? @"Undetermined" : @"Unknown", vo.clubID, vo.clubName);
//	NSLog(@"DICTIONARY:[%@]\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary);
	return (vo);
}


- (int)visibleMembers {
	return ((int)[self.activeMembers count] + 1);
}


- (void)dealloc {
	self.dictionary = nil;
	self.clubName = nil;
	self.blurb = nil;
	self.coverImagePrefix = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
	self.ownerName = nil;
	self.ownerImagePrefix = nil;
	self.submissions = nil;
}

@end
