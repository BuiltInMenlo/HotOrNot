//
//  HONUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "NSDate+Operations.h"
#import "NSDictionary+NullReplacement.h"
#import "NSString+DataTypes.h"

#import "HONUserVO.h"

@implementation HONUserVO

@synthesize dictionary;
@synthesize userID, username, voteScore, totalVolleys, isVerified, isSuspended, avatarPrefix, birthday, friends;

+ (HONUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONUserVO *vo = [[HONUserVO alloc] init];
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
