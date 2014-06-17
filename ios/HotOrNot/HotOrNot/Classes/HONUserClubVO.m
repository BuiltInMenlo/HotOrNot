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
@synthesize clubID, clubType, clubName, coverImagePrefix, blurb, ownerID, ownerName, ownerImagePrefix, pendingMembers, activeMembers, bannedMembers, addedDate, updatedDate, totalScore, submissions, clubEnrollmentType;

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
	
	vo.coverImagePrefix = ([dictionary objectForKey:@"img"] != nil && [[dictionary objectForKey:@"img"] length] > 0) ? [HONAppDelegate cleanImagePrefixURL:[dictionary objectForKey:@"img"]] : [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsCloudFront] stringByAppendingString:@"/defaultClubCover"];
	vo.addedDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	vo.updatedDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"updated"]];
	
	vo.ownerID = [[[dictionary objectForKey:@"owner"] objectForKey:@"id"] intValue];
	vo.ownerName = [[dictionary objectForKey:@"owner"] objectForKey:@"username"];
	vo.ownerImagePrefix = [HONAppDelegate cleanImagePrefixURL:([[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] != nil) ? [[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] : [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront] stringByAppendingString:@"/defaultAvatar"]];
	
	vo.pendingMembers = [dictionary objectForKey:@"pending"];
	vo.activeMembers = [dictionary objectForKey:@"members"];
	vo.bannedMembers = [dictionary objectForKey:@"blocked"];
	
	NSMutableArray *submissions = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"submissions"])
		[submissions addObject:[HONClubPhotoVO clubPhotoWithDictionary:dict]];
	
	vo.submissions = [submissions copy];
	vo.totalScore = [[dictionary objectForKey:@"total_score"] intValue];
	
	
	
	if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"USER_GENERATED"])
		vo.clubType = ([vo.submissions count]) ? HONClubTypeUserCreatedEmpty : HONClubTypeUserCreated;
	
	else if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"SUGGESTED"])
		vo.clubType = HONClubTypeSuggested;
	
	else if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"PRE_BUILT"])
		vo.clubType = HONClubTypeAutoPrepped;
	
	
	vo.clubEnrollmentType = (vo.ownerID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? HONClubEnrollmentTypeOwner : HONClubEnrollmentTypeUndetermined;
	vo.clubEnrollmentType = (vo.clubType == HONClubTypeAutoPrepped) ? HONClubEnrollmentTypeAutoPrepped : vo.clubEnrollmentType;
	
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
			for (NSDictionary *dict in vo.pendingMembers) {
				NSLog(@"PENDING:[%d - %@]", [[dict objectForKey:@"id"] intValue], [dict objectForKey:@"username"]);
				if ([[dict objectForKey:@"id"] intValue] == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
					vo.clubEnrollmentType = HONClubEnrollmentTypePending;
					break;
				}
			}
		}
		
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
		for (NSDictionary *dict in vo.activeMembers) {
			NSLog(@"ACTIVE:[%d - %@]", [[dict objectForKey:@"id"] intValue], [dict objectForKey:@"username"]);
			if ([[dict objectForKey:@"id"] intValue] == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				vo.clubEnrollmentType = HONClubEnrollmentTypeMember;
				break;
			}
		}
	}
	
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) {
		for (NSDictionary *dict in vo.bannedMembers) {
			NSLog(@"BANNED:[%d - %@]", [[dict objectForKey:@"id"] intValue], [dict objectForKey:@"username"]);
			if ([[dict objectForKey:@"id"] intValue] == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				vo.clubEnrollmentType = HONClubEnrollmentTypeBanned;
				break;
			}
		}
	}
	
	vo.clubEnrollmentType = (vo.clubEnrollmentType == HONClubEnrollmentTypeUndetermined) ? HONClubEnrollmentTypeUnknown : vo.clubEnrollmentType;
	
	NSLog(@"/-/-/--/--(%@) [%d - %@] {%d}--/-/-/-/", (vo.clubEnrollmentType == HONClubEnrollmentTypeUnknown) ? @"Unknown" : (vo.clubEnrollmentType == HONClubEnrollmentTypeAutoPrepped) ? @"AutoPrepped" : (vo.clubEnrollmentType == HONClubEnrollmentTypeOwner) ? @"Owner" : (vo.clubEnrollmentType == HONClubEnrollmentTypePending) ? @"Pending" : (vo.clubEnrollmentType == HONClubEnrollmentTypeMember) ? @"Member" : (vo.clubEnrollmentType == HONClubEnrollmentTypeBanned) ? @"Banned" : @"Unknown", vo.clubID, vo.clubName, vo.clubType);
	NSLog(@"DICTIONARY:[%@]\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary);
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
