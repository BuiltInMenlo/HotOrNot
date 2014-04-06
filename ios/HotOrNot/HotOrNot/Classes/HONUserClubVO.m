//
//  HONUserClubVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"

@implementation HONUserClubVO
@synthesize dictionary;
@synthesize clubID, userClubStatusType, userClubExpoType, userClubConentType, actionsPerMinute, totalPendingMembers, totalActiveMembers, totalBannedMembers, totalHistoricMembers, totalAllMembers, totalEntries, coverImagePrefix, ownerID, ownerName, ownerImagePrefix, ownerBirthdate, addedDate, startedDate, updatedDate;

+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary {
	HONUserClubVO *vo = [[HONUserClubVO alloc] init];
	vo.dictionary = dictionary;
	
//	vo.clubID = [[dictionary objectForKey:@"id"] intValue];
//	vo.userClubStatusType = [[dictionary objectForKey:@"status_id"] intValue];
//	vo.userClubExpoType = [[dictionary objectForKey:@"expo_id"] intValue];
//	vo.userClubConentType = [[dictionary objectForKey:@"content_id"] intValue];
	
	vo.clubName = [dictionary objectForKey:@"name"];
//	vo.emotionName = [dictionary objectForKey:@"suject"];
//	vo.creatorName = [dictionary objectForKey:@"creator"];
	
//	vo.totalPendingMembers = [[dictionary objectForKey:@"pending"] intValue];
//	vo.totalActiveMembers = [[dictionary objectForKey:@"following"] intValue];
	
	vo.coverImagePrefix = [HONAppDelegate cleanImagePrefixURL:([dictionary objectForKey:@"img"] != [NSNull null]) ? [dictionary objectForKey:@"img"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:@"avatars"]] stringByAppendingString:kSnapLargeSuffix]];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
//	vo.addedDate = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
//	vo.startedDate = [dateFormat dateFromString:[dictionary objectForKey:@"started"]];
//	vo.updatedDate = [dateFormat dateFromString:[dictionary objectForKey:@"updated"]];
	
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.clubName = nil;
	self.coverImagePrefix = nil;
	self.emotionName = nil;
	self.hastagName = nil;
	self.ownerName = nil;
	self.ownerImagePrefix = nil;
	self.ownerBirthdate = nil;
	self.addedDate = nil;
	self.startedDate = nil;
	self.updatedDate = nil;
}



@end
