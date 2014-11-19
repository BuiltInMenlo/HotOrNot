//
//  HONActivityItemVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:41 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "HONActivityItemVO.m"

@implementation HONActivityItemVO
@synthesize dictionary;
@synthesize activityID, activityType, originUserID, originUsername, originAvatarPrefix, message, challengeID, clubID, clubName, sentDate, recipientUserID, recipientUsername;

+ (HONActivityItemVO *)activityWithDictionary:(NSDictionary *)dictionary {
	HONActivityItemVO *vo = [[HONActivityItemVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.activityID = [dictionary objectForKey:@"id"];
	vo.activityType = HONActivityItemTypeLike;//[[dictionary objectForKey:@"activity_type"] intValue];
	vo.challengeID = ([dictionary objectForKey:@"status_update_id"] != [NSNull null]) ? [[dictionary objectForKey:@"status_update_id"] intValue] : -1;
	vo.clubID = ([dictionary objectForKey:@"club_id"] != [NSNull null]) ? [[dictionary objectForKey:@"club_id"] intValue] : -1;
	vo.clubName = @"";//[dictionary objectForKey:@"club_name"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
	
	vo.sentDate = [dateFormatter dateFromString:[dictionary objectForKey:@"time"]];//[NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"time"]];
	
	vo.originUserID = ([dictionary objectForKey:@"subject_member"] != [NSNull null]) ? [[[dictionary objectForKey:@"subject_member"] objectForKey:@"id"] intValue] : 0;//[[[dictionary objectForKey:@"user"] objectForKey:@"id"] intValue];
	vo.originUsername = ([dictionary objectForKey:@"subject_member"] != [NSNull null]) ? (vo.originUserID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? NSLocalizedString(@"activity_you", @"You") : [[dictionary objectForKey:@"subject_member"] objectForKey:@"name"] : @"";
	vo.originAvatarPrefix = ([dictionary objectForKey:@"subject_member"] != [NSNull null]) ? [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[[dictionary objectForKey:@"subject_member"] objectForKey:@"avatar_url"]] : @"";
	
	vo.recipientUserID = [[[dictionary objectForKey:@"member"] objectForKey:@"id"] intValue];//([dictionary objectForKey:@"recip"]) ? ([[[dictionary objectForKey:@"recip"] objectForKey:@"id"] intValue] == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] : [[[dictionary objectForKey:@"recip"] objectForKey:@"id"] intValue] : 0;
	vo.recipientUsername = [[dictionary objectForKey:@"member"] objectForKey:@"name"];//([dictionary objectForKey:@"recip"]) ? ([[[dictionary objectForKey:@"recip"] objectForKey:@"username"] isEqualToString:[[HONAppDelegate infoForUser] objectForKey:@"username"]]) ? [[HONAppDelegate infoForUser] objectForKey:@"username"] : [[dictionary objectForKey:@"recip"] objectForKey:@"username"] : @"";
	
	if (vo.activityType == HONActivityItemTypeSignup) {
		vo.message = NSLocalizedString(@"activity_signup", @"You have just joined Selfieclub!");;
	
	} else if (vo.activityType == HONActivityItemTypeInviteRequest) {
		vo.message = [vo.originUsername stringByAppendingString:[NSString stringWithFormat: NSLocalizedString(@"sent_invite", @" sent %@ an invite to %@"), vo.recipientUsername, vo.clubName]];
	
	} else if (vo.activityType == HONActivityItemTypeInviteAccepted) {
		vo.message = [vo.originUsername stringByAppendingString:[NSString stringWithFormat: NSLocalizedString(@"accept_invite", @" accepted %@ invite to %@"), vo.recipientUsername, vo.clubName]];
	
	} else if (vo.activityType == HONActivityItemTypeLike) {
//		NSLog(@"CLUB NAME(%lu):[%@]", vo.activityType, vo.clubName);
		vo.message = [vo.originUsername stringByAppendingString:[NSString stringWithFormat: NSLocalizedString(@"liked_selfie", @" liked %@ selfie in %@"), vo.recipientUsername, vo.clubName]];
	
	} else if (vo.activityType == HONActivityItemTypeClubSubmission) {
		vo.message = [vo.originUsername stringByAppendingString:[NSString stringWithFormat: NSLocalizedString(@"submit_photo", @" submitted a photo into %@") ]];
	
	} else {
		vo.message = vo.originUsername;
	}
	
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.originUsername = nil;
	self.originAvatarPrefix = nil;
	self.recipientUsername = nil;
	self.clubName = nil;
	self.message = nil;
	self.sentDate = nil;
}


@end
