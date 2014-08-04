//
//  HONActivityItemVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:41 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONActivityItemVO.m"

@implementation HONActivityItemVO
@synthesize dictionary;
@synthesize activityID, activityType, userID, username, avatarPrefix, message, challengeID, clubID, clubName, sentDate;

+ (HONActivityItemVO *)activityWithDictionary:(NSDictionary *)dictionary {
	HONActivityItemVO *vo = [[HONActivityItemVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.activityID = [dictionary objectForKey:@"id"];
	vo.activityType = [[dictionary objectForKey:@"activity_type"] intValue];
	vo.challengeID = ([dictionary objectForKey:@"challengeID"] != [NSNull null]) ? [[dictionary objectForKey:@"challengeID"] intValue] : -1;
	vo.clubID = ([dictionary objectForKey:@"club_id"] != [NSNull null]) ? [[dictionary objectForKey:@"club_id"] intValue] : -1;
	vo.clubName = [dictionary objectForKey:@"club_name"];
	vo.sentDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"time"]];
	
	vo.userID = [[[dictionary objectForKey:@"user"] objectForKey:@"id"] intValue];
	vo.username = (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"You" : [[dictionary objectForKey:@"user"] objectForKey:@"username"];
	vo.avatarPrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[[dictionary objectForKey:@"user"] objectForKey:@"avatar_url"]];
	
	
	if (vo.activityType == HONActivityItemTypeVerify) {
		vo.message = [vo.username stringByAppendingString:@" verified your selfie"];
	
	} else if (vo.activityType == HONActivityItemTypeInviteRequest) {
		vo.message = [vo.username stringByAppendingString:[NSString stringWithFormat:@" sent you an invite to %@", vo.clubName]];
	
	} else if (vo.activityType == HONActivityItemTypeInviteAccepted) {
		vo.message = [vo.username stringByAppendingString:[NSString stringWithFormat:@" accepted your invite to %@", vo.clubName]];
	
	} else if (vo.activityType == HONActivityItemTypeLike) {
		vo.message = [vo.username stringByAppendingString:[NSString stringWithFormat:@" liked your selfie in %@", vo.clubName]];
	
	} else if (vo.activityType == HONActivityItemTypeClubSubmission) {
		vo.message = [vo.username stringByAppendingString:[NSString stringWithFormat:@" submitted a photo into %@", vo.clubName]];
	
	} else {
		vo.message = vo.username;
	}
	
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.clubName = nil;
	self.message = nil;
	self.sentDate = nil;
}


@end
