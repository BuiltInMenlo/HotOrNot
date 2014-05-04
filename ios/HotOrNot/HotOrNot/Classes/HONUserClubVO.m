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
@synthesize clubID, userClubStatusType, userClubExpoType, userClubConentType, actionsPerMinute, totalPendingMembers, totalActiveMembers, totalBannedMembers, totalHistoricMembers, totalAllMembers, totalEntries, coverImagePrefix, ownerID, ownerName, ownerImagePrefix, ownerBirthdate, addedDate, updatedDate;

+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	HONUserClubVO *vo = [[HONUserClubVO alloc] init];
	vo.dictionary = dictionary;
	
	
	//NSLog(@"DICTIONARY[%@]\nOWNER:[%@]\nMEMBERS:[%@]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary, [dictionary objectForKey:@"owner"], [dictionary objectForKey:@"members"], [dictionary objectForKey:@"added"]);
	
	vo.clubID = [[dictionary objectForKey:@"id"] intValue];
	vo.clubName = [dictionary objectForKey:@"name"];
	vo.blurb = [dictionary objectForKey:@"description"];
	vo.coverImagePrefix = [HONAppDelegate cleanImagePrefixURL:([dictionary objectForKey:@"img"] != [NSNull null]) ? [dictionary objectForKey:@"img"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront]] stringByAppendingString:kSnapLargeSuffix]];
	
	vo.totalPendingMembers = [[dictionary objectForKey:@"pending"] count];
	vo.totalBannedMembers = [[dictionary objectForKey:@"blocked"] count];
	vo.totalActiveMembers = [[dictionary objectForKey:@"members"] count];
	
	vo.addedDate = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	vo.updatedDate = (vo.totalActiveMembers == 0) ? vo.addedDate : [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	vo.ownerID = [[[dictionary objectForKey:@"owner"] objectForKey:@"id"] intValue];
	vo.ownerName = [[dictionary objectForKey:@"owner"] objectForKey:@"username"];
	vo.ownerImagePrefix = [HONAppDelegate cleanImagePrefixURL:([[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] != [NSNull null]) ? [[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront]] stringByAppendingString:kSnapLargeSuffix]];
	vo.ownerBirthdate = [dateFormat dateFromString:[[dictionary objectForKey:@"owner"] objectForKey:@"age"]];
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.clubName = nil;
	self.blurb = nil;
	self.coverImagePrefix = nil;
	self.ownerName = nil;
	self.ownerImagePrefix = nil;
	self.ownerBirthdate = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
}



@end
