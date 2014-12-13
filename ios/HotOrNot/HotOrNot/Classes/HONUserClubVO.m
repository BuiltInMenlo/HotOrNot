//
//  HONUserClubVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"

@implementation HONUserClubVO
@synthesize dictionary;
@synthesize clubID, clubName, coverImagePrefix, blurb, ownerID, ownerName, ownerImagePrefix, pendingMembers, activeMembers, bannedMembers, location, postRadius, distance, addedDate, updatedDate, totalScore, submissions, clubEnrollmentType;
@synthesize visibleMembers, totalMembers;

+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary {
	HONUserClubVO *vo = [[HONUserClubVO alloc] init];
	vo.dictionary = dictionary;
	
//	for (NSString *param in dictionary)
//		NSLog(@"NAME:[%@]", param);
	
//	NSLog(@"NAME:[%@]", [dictionary objectForKey:@"name"]);
//	NSLog(@"DICTIONARY:[%@]\nOWNER:[%@]\nMEMBERS:[%@]:\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary, [dictionary objectForKey:@"owner"], [dictionary objectForKey:@"members"], [dictionary objectForKey:@"added"]);
//	NSLog(@"NAME:[%@]\nSUBMISSIONS:[%@]:\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", [dictionary objectForKey:@"name"], [dictionary objectForKey:@"submissions"]);
	
	vo.clubID = [[dictionary objectForKey:@"id"] intValue];
	vo.clubName = [dictionary objectForKey:@"name"];
	vo.blurb = ([dictionary objectForKey:@"description"] != nil) ? [dictionary objectForKey:@"description"] : @"";
	
	vo.coverImagePrefix = ([dictionary objectForKey:@"img"] != nil && [[dictionary objectForKey:@"img"] length] > 0) ? [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[dictionary objectForKey:@"img"]] : [[HONClubAssistant sharedInstance] defaultCoverImageURL];
	vo.coverImagePrefix = ([vo.coverImagePrefix rangeOfString:@"defaultClubCover"].location != NSNotFound) ? [[HONClubAssistant sharedInstance] defaultCoverImageURL] : vo.coverImagePrefix;
	
	NSMutableString *imgURL = [vo.coverImagePrefix mutableCopy];
	[imgURL replaceOccurrencesOfString:@"http://d1fqnfrnudpaz6.cloudfront.net" withString:@"http://hotornot-challenges.s3.amazonaws.com" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imgURL length])];
	vo.coverImagePrefix = [imgURL copy];
	
	vo.location = ([dictionary objectForKey:@"coords"] != nil) ? [[CLLocation alloc] initWithLatitude:[[[dictionary objectForKey:@"coords"] objectForKey:@"lat"] doubleValue] longitude:[[[dictionary objectForKey:@"coords"] objectForKey:@"lon"] doubleValue]] : [[CLLocation alloc] initWithLatitude:0.00 longitude:0.00];
	vo.postRadius = ([dictionary objectForKey:@"radius"] != nil) ? [[dictionary objectForKey:@"radius"] floatValue] : CGFLOAT_MIN;
	vo.distance = ([dictionary objectForKey:@"distance"] != nil) ? [[dictionary objectForKey:@"distance"] floatValue] : 0.0;
	
	vo.addedDate = [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	vo.updatedDate = [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"updated"]];
	
	vo.ownerID = ([[dictionary objectForKey:@"owner"] objectForKey:@"id"] != nil) ? [[[dictionary objectForKey:@"owner"] objectForKey:@"id"] intValue] : 0;
	vo.ownerName = ([[dictionary objectForKey:@"owner"] objectForKey:@"username"]) ? [[dictionary objectForKey:@"owner"] objectForKey:@"username"] : @"";
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
		[mDict setValue:@(vo.clubID) forKey:@"club_id"];
		[submissions addObject:[HONClubPhotoVO clubPhotoWithDictionary:[mDict copy]]];
	}
	
	vo.submissions = [submissions copy];// [[[submissions copy] reverseObjectEnumerator] allObjects];
	vo.totalScore = [[dictionary objectForKey:@"total_score"] intValue];
	
	vo.clubEnrollmentType = (vo.ownerID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? HONClubEnrollmentTypeOwner : HONClubEnrollmentTypeUndetermined;
	
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
	self.location = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
	self.ownerName = nil;
	self.ownerImagePrefix = nil;
	self.submissions = nil;
}

@end
