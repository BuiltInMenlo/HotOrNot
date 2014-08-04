//
//  HONTrivialUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONTrivialUserVO.h"

@implementation HONTrivialUserVO
@synthesize dictionary;
@synthesize userID, username, avatarPrefix, altID, phoneNumber, isVerified, abuseCount;

+ (HONTrivialUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONTrivialUserVO *vo = [[HONTrivialUserVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarPrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[dictionary objectForKey:@"img_url"]];
	vo.avatarPrefix = ([vo.avatarPrefix rangeOfString:@"default"].location != NSNotFound) ? @"" : vo.avatarPrefix;
	vo.altID = ([dictionary objectForKey:@"alt_id"] != [NSNull null]) ? [dictionary objectForKey:@"alt_id"] : @"";
	vo.isVerified = ((BOOL)[[dictionary objectForKey:@"is_verified"] intValue]);
	vo.abuseCount = [[dictionary objectForKey:@"abuse_ct"] intValue];
	
	return (vo);
}

+ (HONTrivialUserVO *)userFromActivityItemVO:(HONActivityItemVO *)activityItemVO {
	return ([HONTrivialUserVO userWithDictionary:@{@"id"		: [[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"id"],
												   @"username"	: [[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"username"],
												   @"img_url"	: [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[[activityItemVO.dictionary objectForKey:@"user"] objectForKey:@"avatar_url"]],
												   @"alt_id"	: [activityItemVO.dictionary objectForKey:@"id"]}]);
}

+ (HONTrivialUserVO *)userFromContactVO:(HONContactUserVO *)contactVO {
	return ([HONTrivialUserVO userWithDictionary:@{@"id"		: [@"" stringFromInt:contactVO.userID],
												   @"username"	: contactVO.username,
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
												  @"abuse_ct"		: [@"" stringFromInt:userVO.abuseCount],
												  @"is_verified"	: [@"" stringFromBOOL:userVO.isVerified]}]);
}


- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.altID = nil;
}
@end
