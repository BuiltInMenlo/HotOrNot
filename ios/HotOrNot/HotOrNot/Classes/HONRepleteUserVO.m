//
//  HONRepleteUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "NSDate+BuiltinMenlo.h"
#import "HONRepleteUserVO.h"

@implementation HONRepleteUserVO

@synthesize dictionary;
@synthesize userID, username, voteScore, totalVolleys, isVerified, isSuspended, avatarPrefix, birthday, friends;

+ (HONRepleteUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONRepleteUserVO *vo = [[HONRepleteUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.voteScore = [[dictionary objectForKey:@"total_votes"] intValue];
	vo.totalVolleys = [[dictionary objectForKey:@"total_challenges"] intValue];
	vo.isVerified = ((BOOL)[[dictionary objectForKey:@"is_verified"] intValue]);
	vo.isSuspended = ((BOOL)[[dictionary objectForKey:@"is_suspended"] intValue]);
	vo.avatarPrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[dictionary objectForKey:@"avatar_url"]];
	vo.avatarPrefix = ([vo.avatarPrefix rangeOfString:@"default"].location != NSNotFound) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"avatar"] : vo.avatarPrefix;
	vo.birthday = [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"age"]];
	
	vo.friends = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"friends"]) {
		[vo.friends addObject:[HONRepleteUserVO userWithDictionary:@{@"id"				: @([[[dict objectForKey:@"user"] objectForKey:@"id"] intValue]),
															   @"points"		: @(0),
															   @"total_votes"	: @(0),
															   @"pics"			: @(0),
															   @"username"		: [[dict objectForKey:@"user"] objectForKey:@"username"],
															   @"avatar_url"	: [[dict objectForKey:@"user"] objectForKey:@"avatar_url"]}]];
	}
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.friends = nil;
	self.birthday = nil;
}

@end
