//
//  HONPopularUserVO.m
//  HotOrNot
//
//  Created by Sparkle Mountain iMac on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularUserVO.h"
#import "HONAppDelegate.h"

@implementation HONPopularUserVO

@synthesize dictionary;
@synthesize userID, username, points, votes, pokes, score, imageURL;

+ (HONPopularUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONPopularUserVO *vo = [[HONPopularUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.points = [[dictionary objectForKey:@"points"] intValue];
	vo.votes = [[dictionary objectForKey:@"votes"] intValue];
	vo.pokes = [[dictionary objectForKey:@"pokes"] intValue];
	vo.score = (vo.points * [HONAppDelegate createPointMultiplier]) + (vo.votes * [HONAppDelegate votePointMultiplier]) + (vo.pokes * [HONAppDelegate pokePointMultiplier]);
	vo.username = [dictionary objectForKey:@"username"];
	vo.imageURL = [dictionary objectForKey:@"img_url"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.imageURL = nil;
}

@end
