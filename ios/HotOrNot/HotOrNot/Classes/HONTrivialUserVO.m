//
//  HONTrivialUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "NSString+DataTypes.h"

#import "HONTrivialUserVO.h"

@implementation HONTrivialUserVO
@synthesize dictionary;
@synthesize userID, username, avatarPrefix, altID, phoneNumber, isVerified, voteScore, invitedDate, joinedDate;

+ (HONTrivialUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONTrivialUserVO *vo = [[HONTrivialUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarPrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[dictionary objectForKey:@"img_url"]];
	vo.avatarPrefix = ([vo.avatarPrefix rangeOfString:@"default"].location != NSNotFound) ? @"" : vo.avatarPrefix;
	vo.altID = ([dictionary objectForKey:@"alt_id"] != nil) ? [dictionary objectForKey:@"alt_id"] : @"";
	vo.isVerified = ((BOOL)[[dictionary objectForKey:@"is_verified"] intValue]);
	vo.voteScore = [[dictionary objectForKey:@"total_votes"] intValue];
	vo.invitedDate = ([dictionary objectForKey:@"invited"] != nil) ? [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"invited"]] : [NSDate blankTimestamp];
	vo.joinedDate =([dictionary objectForKey:@"joined"] != nil) ? [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"joined"]] : [NSDate blankTimestamp];
	
	return (vo);
}

+ (HONTrivialUserVO *)userFromActivityItemVO:(HONActivityItemVO *)activityItemVO {
	return ([HONTrivialUserVO userWithDictionary:@{@"id"		: [[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"id"],
												   @"username"	: [[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"username"],
												   @"img_url"	: [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"avatar_url"]],
												   @"alt_id"	: [activityItemVO.dictionary objectForKey:@"id"]}]);
}

+ (HONTrivialUserVO *)userFromContactUserVO:(HONContactUserVO *)contactVO {
	return ([HONTrivialUserVO userWithDictionary:@{@"id"		: (contactVO.isSMSAvailable) ? contactVO.mobileNumber : contactVO.email,
												   @"username"	: contactVO.fullName,
												   @"img_url"	: contactVO.avatarPrefix,
												   @"alt_id"	: (contactVO.isSMSAvailable) ? contactVO.mobileNumber : contactVO.email}]);
}

+ (HONTrivialUserVO *)userFromOpponentVO:(HONOpponentVO *)opponentVO {
	return ([HONTrivialUserVO userWithDictionary:@{@"id"		: [opponentVO.dictionary objectForKey:@"id"],
												  @"username"	: [opponentVO.dictionary objectForKey:@"username"],
												  @"img_url"	: [opponentVO.dictionary objectForKey:@"avatar"],
												  @"alt_id"		: [[[[HONAPICaller sharedInstance] normalizePrefixForImageURL:[opponentVO.dictionary objectForKey:@"avatar"]] componentsSeparatedByString:@"/"] lastObject]}]);
}

+ (HONTrivialUserVO *)userFromUserVO:(HONUserVO *)userVO {
	return ([HONTrivialUserVO userWithDictionary:@{@"id"			: [userVO.dictionary objectForKey:@"id"],
												  @"username"		: [userVO.dictionary objectForKey:@"username"],
												  @"img_url"		: [userVO.dictionary objectForKey:@"avatar_url"],
												  @"alt_id"			: [userVO.dictionary objectForKey:@"device_token"],
												  @"total_votes"	: [@"" stringFromInt:userVO.voteScore],
												  @"is_verified"	: [@"" stringFromBOOL:userVO.isVerified]}]);
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
