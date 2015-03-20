//
//  HONUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "RegExCategories.h"

#import "HONUserVO.h"


@implementation HONUserVO
@synthesize dictionary;
@synthesize userID, username, avatarPrefix, altID, phoneNumber, isVerified, voteScore, invitedDate, joinedDate;

+ (HONUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONUserVO *vo = [[HONUserVO alloc] init];
	vo.dictionary = dictionary;
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [[HONUserAssistant sharedInstance] usernameWithDigitsStripped:[dictionary objectForKey:@"username"]];
	vo.avatarPrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[dictionary objectForKey:@"img_url"]];
	vo.avatarPrefix = ([vo.avatarPrefix rangeOfString:@"default"].location != NSNotFound) ? @"" : vo.avatarPrefix;
	vo.altID = ([dictionary objectForKey:@"alt_id"] != nil) ? [dictionary objectForKey:@"alt_id"] : @"";
	vo.isVerified = ((BOOL)[[dictionary objectForKey:@"is_verified"] intValue]);
	vo.voteScore = [[dictionary objectForKey:@"total_votes"] intValue];
	vo.invitedDate = ([dictionary objectForKey:@"invited"] != nil) ? [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"invited"]] : [NSDate blankTimestamp];
	vo.joinedDate =([dictionary objectForKey:@"joined"] != nil) ? [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"joined"]] : [NSDate blankTimestamp];
	
	return (vo);
}

+ (HONUserVO *)userFromActivityItemVO:(HONActivityItemVO *)activityItemVO {
	return ([HONUserVO userWithDictionary:@{@"id"		: [[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"id"],
												   @"username"	: [[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"username"],
												   @"img_url"	: [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"avatar_url"]],
												   @"alt_id"	: [activityItemVO.dictionary objectForKey:@"id"]}]);
}

+ (HONUserVO *)userFromContactUserVO:(HONContactUserVO *)contactVO {
	return ([HONUserVO userWithDictionary:@{@"id"		: (contactVO.isSMSAvailable) ? contactVO.mobileNumber : contactVO.email,
												   @"username"	: contactVO.fullName,
												   @"img_url"	: contactVO.avatarPrefix,
												   @"alt_id"	: (contactVO.isSMSAvailable) ? contactVO.mobileNumber : contactVO.email}]);
}

+ (HONUserVO *)userFromOpponentVO:(HONOpponentVO *)opponentVO {
	return ([HONUserVO userWithDictionary:@{@"id"		: [opponentVO.dictionary objectForKey:@"id"],
												  @"username"	: [opponentVO.dictionary objectForKey:@"username"],
												  @"img_url"	: [opponentVO.dictionary objectForKey:@"avatar"],
												  @"alt_id"		: [[[[HONAPICaller sharedInstance] normalizePrefixForImageURL:[opponentVO.dictionary objectForKey:@"avatar"]] componentsSeparatedByString:@"/"] lastObject]}]);
}


- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.altID = nil;
	self.phoneNumber = nil;
	self.invitedDate = nil;
	self.joinedDate = nil;
}
@end
