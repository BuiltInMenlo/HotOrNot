//
//  HONUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "NSDictionary+NullReplacement.h"
#import "NSString+DataTypes.h"

#import "HONUserVO.h"

@implementation HONUserVO

@synthesize dictionary;
@synthesize userID, username, points, votes, abuseCount, totalVolleys, isVerified, isSuspended, score, avatarPrefix, birthday, friends;

+ (HONUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONUserVO *vo = [[HONUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.points = [[dictionary objectForKey:@"points"] intValue];
	vo.votes = [[dictionary objectForKey:@"total_votes"] intValue];
	vo.totalVolleys = [[dictionary objectForKey:@"total_challenges"] intValue];
	vo.abuseCount = [[dictionary objectForKey:@"abuse_ct"] intValue];
	vo.isVerified = ((BOOL)[[dictionary objectForKey:@"is_verified"] intValue]);
	vo.isSuspended = ((BOOL)[[dictionary objectForKey:@"is_suspended"] intValue]);
	vo.score = vo.points + vo.votes;
	vo.avatarPrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:[dictionary objectForKey:@"avatar_url"]];
	vo.avatarPrefix = ([vo.avatarPrefix rangeOfString:@"default"].location != NSNotFound) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"default_imgs"] objectForKey:@"avatar"] : vo.avatarPrefix;
	vo.birthday = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"age"]];
	
	vo.friends = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"friends"]) {
		NSDictionary *friend = [dict dictionaryByReplacingNullsWithBlanks];
		[vo.friends addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															 [@"" stringFromInt:[[[friend objectForKey:@"user"] objectForKey:@"id"] intValue]], @"id",
															 [@"" stringFromInt:0], @"points",
															 [@"" stringFromInt:0], @"total_votes",
															 [@"" stringFromInt:0], @"pics",
															 [[friend objectForKey:@"user"] objectForKey:@"username"], @"username",
															 [[friend objectForKey:@"user"] objectForKey:@"avatar_url"], @"avatar_url", nil]]];
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
