//
//  HONVoterVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoterVO.h"
#import "HONAppDelegate.h"

@implementation HONVoterVO
@synthesize dictionary;
@synthesize userID, fbID, username, points, votes, pokes, score, challenges, imageURL;

+ (HONVoterVO *)voterWithDictionary:(NSDictionary *)dictionary {
	HONVoterVO *vo = [[HONVoterVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.fbID = [dictionary objectForKey:@"fb_id"];
	vo.points = [[dictionary objectForKey:@"points"] intValue];
	vo.votes = [[dictionary objectForKey:@"votes"] intValue];
	vo.pokes = [[dictionary objectForKey:@"pokes"] intValue];
	vo.score = (vo.points * [HONAppDelegate createPointMultiplier]) + (vo.votes * [HONAppDelegate votePointMultiplier]) + (vo.pokes * [HONAppDelegate pokePointMultiplier]);
	vo.challenges = [[dictionary objectForKey:@"challenges"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.imageURL = ([dictionary objectForKey:@"fb_id"] == [NSNull null]) ? @"https://s3.amazonaws.com/picchallenge/default_user.png" : [dictionary objectForKey:@"img_url"];
		
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.fbID = nil;
	self.username = nil;
	self.imageURL = nil;
}
@end
