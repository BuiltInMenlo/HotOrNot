//
//  HONUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserVO.h"
#import "HONAppDelegate.h"

@implementation HONUserVO

@synthesize dictionary;
@synthesize userID, fbID, username, points, votes, pokes, score, pics, imageURL;

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
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.imageURL = nil;
	self.fbID = nil;
}

@end
