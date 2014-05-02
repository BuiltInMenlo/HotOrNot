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
@synthesize userID, username, avatarPrefix, altID, isVerified, abuseCount;

+ (HONTrivialUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONTrivialUserVO *vo = [[HONTrivialUserVO alloc] init];
		
	vo.dictionary = dictionary;
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarPrefix = [HONAppDelegate cleanImagePrefixURL:[dictionary objectForKey:@"img_url"]];
	vo.altID = ([dictionary objectForKey:@"alt_id"] != [NSNull null]) ? [dictionary objectForKey:@"alt_id"] : @"";
	vo.isVerified = ((BOOL)[[dictionary objectForKey:@"is_verified"] intValue]);
	vo.abuseCount = [[dictionary objectForKey:@"abuse_ct"] intValue];
	
	return (vo);
}

+ (HONTrivialUserVO *)userFromOpponentVO:(HONOpponentVO *)opponentVO {
	return([HONTrivialUserVO userWithDictionary:@{@"id"			: [opponentVO.dictionary objectForKey:@"id"],
												  @"username"	: [opponentVO.dictionary objectForKey:@"username"],
												  @"img_url"	: [opponentVO.dictionary objectForKey:@"avatar"],
												  @"alt_id"		: [[[HONAppDelegate cleanImagePrefixURL:[opponentVO.dictionary objectForKey:@"avatar"]] componentsSeparatedByString:@"/"] lastObject]}]);
}

+ (HONTrivialUserVO *)userFromUserVO:(HONUserVO *)userVO {
	return([HONTrivialUserVO userWithDictionary:@{@"id"				: [userVO.dictionary objectForKey:@"id"],
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
