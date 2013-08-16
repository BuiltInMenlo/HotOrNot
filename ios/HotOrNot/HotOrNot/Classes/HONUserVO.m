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
@synthesize userID, fbID, username, points, votes, pokes, score, pics, imageURL, birthday, friends;

+ (HONUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONUserVO *vo = [[HONUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.points = [[dictionary objectForKey:@"points"] intValue];
	vo.votes = [[dictionary objectForKey:@"votes"] intValue];
	vo.pokes = [[dictionary objectForKey:@"pokes"] intValue];
	vo.pics = [[dictionary objectForKey:@"pics"] intValue];
	vo.score = (vo.points * [HONAppDelegate createPointMultiplier]) + (vo.votes * [HONAppDelegate votePointMultiplier]) + (vo.pokes * [HONAppDelegate pokePointMultiplier]);
	vo.username = [dictionary objectForKey:@"username"];
	vo.fbID = [dictionary objectForKey:@"fb_id"];
	vo.imageURL = [dictionary objectForKey:@"avatar_url"];
	
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
	self.imageURL = nil;
	self.fbID = nil;
	self.friends = nil;
	self.birthday = nil;
}

@end
