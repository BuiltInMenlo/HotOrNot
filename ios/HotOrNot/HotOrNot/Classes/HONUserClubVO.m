//
//  HONUserClubVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"

@implementation HONUserClubVO
@synthesize dictionary;
@synthesize clubID, clubName, coverImagePrefix, blurb, ownerID, ownerName, ownerImagePrefix, pendingMembers, activeMembers, bannedMembers, addedDate, updatedDate, totalScore, submissions, clubEnrollmentType;

+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary {
	HONUserClubVO *vo = [[HONUserClubVO alloc] init];
	vo.dictionary = dictionary;
	
//	for (NSString *param in dictionary)
//		NSLog(@"NAME:[%@]", param);
	
//	NSLog(@"NAME:[%@]", [dictionary objectForKey:@"name"]);
//	NSLog(@"DICTIONARY[%@]\nOWNER:[%@]\nMEMBERS:[%@]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary, [dictionary objectForKey:@"owner"], [dictionary objectForKey:@"members"], [dictionary objectForKey:@"added"]);
	
	vo.clubID = [[dictionary objectForKey:@"id"] intValue];
	vo.clubName = [dictionary objectForKey:@"name"];
	vo.blurb = [dictionary objectForKey:@"description"];
	
	vo.coverImagePrefix = ([dictionary objectForKey:@"img"] != nil && [[dictionary objectForKey:@"img"] length] > 0) ? [HONAppDelegate cleanImagePrefixURL:[dictionary objectForKey:@"img"]] : [[HONClubAssistant sharedInstance] defaultCoverImagePrefix];
	vo.coverImagePrefix = ([vo.coverImagePrefix rangeOfString:@"defaultClubCover"].location != NSNotFound) ? [[HONClubAssistant sharedInstance] defaultCoverImagePrefix] : vo.coverImagePrefix;
	vo.addedDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	vo.updatedDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"updated"]];
	
	vo.ownerID = [[[dictionary objectForKey:@"owner"] objectForKey:@"id"] intValue];
	vo.ownerName = [[dictionary objectForKey:@"owner"] objectForKey:@"username"];
	vo.ownerImagePrefix = [HONAppDelegate cleanImagePrefixURL:([[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] != nil) ? [[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] : [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront] stringByAppendingString:@"/defaultAvatar"]];
	
	
//	vo.pendingMembers = [dictionary objectForKey:@"pending"];
//	vo.activeMembers = [dictionary objectForKey:@"members"];
//	vo.bannedMembers = [dictionary objectForKey:@"blocked"];
	
	NSMutableArray *pending = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"pending"])
		[pending addObject:[HONTrivialUserVO userWithDictionary:dict]];
	vo.pendingMembers = pending;
	
	NSMutableArray *members = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"members"])
		[members addObject:[HONTrivialUserVO userWithDictionary:dict]];
	vo.activeMembers = members;
	
	NSMutableArray *banned = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"blocked"])
		[banned addObject:[HONTrivialUserVO userWithDictionary:dict]];
	vo.bannedMembers = banned;
	
	NSMutableArray *submissions = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"submissions"])
		[submissions addObject:[HONClubPhotoVO clubPhotoWithDictionary:dict]];
	
	vo.submissions = [[[submissions copy] reverseObjectEnumerator] allObjects];
	vo.totalScore = [[dictionary objectForKey:@"total_score"] intValue];
	
	vo.clubEnrollmentType = (vo.ownerID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? HONClubEnrollmentTypeOwner : HONClubEnrollmentTypeUndetermined;
	vo.clubEnrollmentType = ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"AUTO_GEN"]) ? HONClubEnrollmentTypeAutoGen : vo.clubEnrollmentType;
	vo.clubEnrollmentType = ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"HIGH_SCHOOL"]) ? HONClubEnrollmentTypeHighSchool : vo.clubEnrollmentType;
	
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
		for (HONTrivialUserVO *trivialUserVO in vo.pendingMembers) {
			NSLog(@"PENDING:(%d) - [%d - %@]", vo.clubID, trivialUserVO.userID, trivialUserVO.username);
			if (trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				vo.clubEnrollmentType = HONClubEnrollmentTypePending;
				break;
			}
		}
	}
		
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
		for (HONTrivialUserVO *trivialUserVO in vo.activeMembers) {
			NSLog(@"ACTIVE:(%d) - [%d - %@]", vo.clubID, trivialUserVO.userID, trivialUserVO.username);
			if (trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				vo.clubEnrollmentType = HONClubEnrollmentTypeMember;
				break;
			}
		}
	}
	
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
		for (HONTrivialUserVO *trivialUserVO in vo.bannedMembers) {
			NSLog(@"BANNED:(%d) - [%d - %@]", vo.clubID, trivialUserVO.userID, trivialUserVO.username);
			if (trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				vo.clubEnrollmentType = HONClubEnrollmentTypeBanned;
				break;
			}
		}
	}
	
	vo.clubEnrollmentType = (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) ? HONClubEnrollmentTypeUnknown : vo.clubEnrollmentType;
	
//	NSLog(@"/-/-/--/--(%@) [%d - %@]--/-/-/-/", (vo.clubEnrollmentType == HONClubEnrollmentTypeUnknown) ? @"Unknown" : (vo.clubEnrollmentType == HONClubEnrollmentTypeAutoGen) ? @"AutoGen" : (vo.clubEnrollmentType == HONClubEnrollmentTypeOwner) ? @"Owner" : (vo.clubEnrollmentType == HONClubEnrollmentTypePending) ? @"Pending" : (vo.clubEnrollmentType == HONClubEnrollmentTypeMember) ? @"Member" : (vo.clubEnrollmentType == HONClubEnrollmentTypeBanned) ? @"Banned" : @"Unknown", vo.clubID, vo.clubName);
//	NSLog(@"DICTIONARY:[%@]\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary);
	return (vo);
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
