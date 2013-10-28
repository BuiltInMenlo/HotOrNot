//
//  HONUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserVO.h"


@implementation HONUserVO

@synthesize dictionary;
@synthesize userID, fbID, username, points, votes, abuseCount, totalVolleys, isVerified, isSuspended, score, avatarURL, birthday, friends;

+ (HONUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONUserVO *vo = [[HONUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.points = [[dictionary objectForKey:@"points"] intValue];
	vo.votes = [[dictionary objectForKey:@"total_votes"] intValue];
	vo.totalVolleys = [[dictionary objectForKey:@"total_challenges"] intValue];
	vo.abuseCount = [[dictionary objectForKey:@"abuse_ct"] intValue];
	vo.isVerified = ((BOOL)[[dictionary objectForKey:@"is_verified"] intValue]);
	vo.isSuspended = ((BOOL)[[dictionary objectForKey:@"is_suspended"] intValue]);
	vo.score = vo.points + vo.votes;
	vo.username = [dictionary objectForKey:@"username"];
	vo.fbID = [dictionary objectForKey:@"fb_id"];
	
	NSMutableString *imageURL = [[dictionary objectForKey:@"avatar_url"] mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	[imageURL replaceOccurrencesOfString:@"Large_640x1136Large_640x1136.jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	vo.avatarURL = [imageURL copy];
	imageURL = nil;
	
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.birthday = [dateFormat dateFromString:[dictionary objectForKey:@"age"]];
	
	vo.friends = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"friends"]) {
		[vo.friends addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%d", [[[dict objectForKey:@"user"] objectForKey:@"id"] intValue]], @"id",
															 [NSString stringWithFormat:@"%d", 0], @"points",
															 [NSString stringWithFormat:@"%d", 0], @"votes",
															 [NSString stringWithFormat:@"%d", 0], @"pokes",
															 [NSString stringWithFormat:@"%d", 0], @"pics",
															 @"", @"fb_id",
															 [[dict objectForKey:@"user"] objectForKey:@"username"], @"username",
															 [[dict objectForKey:@"user"] objectForKey:@"avatar_url"], @"avatar_url", nil]]];
	}
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarURL = nil;
	self.fbID = nil;
	self.friends = nil;
	self.birthday = nil;
}

@end
