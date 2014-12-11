//
//  HONVoterVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "HONVoterVO.h"

@implementation HONVoterVO
@synthesize dictionary;
@synthesize userID, fbID, username, points, votes, pokes, score, challenges, imageURL, challengerName, addedDate;

+ (HONVoterVO *)voterWithDictionary:(NSDictionary *)dictionary {
	HONVoterVO *vo = [[HONVoterVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.fbID = [dictionary objectForKey:@"fb_id"];
	vo.points = [[dictionary objectForKey:@"points"] intValue];
	vo.votes = [[dictionary objectForKey:@"votes"] intValue];
	vo.pokes = [[dictionary objectForKey:@"pokes"] intValue];
	vo.score = vo.points + vo.votes + vo.pokes;
	vo.challenges = [[dictionary objectForKey:@"challenges"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
//	vo.imageURL = ([dictionary objectForKey:@"fb_id"] == [NSNull null]) ? @"http://s3.amazonaws.com/picchallenge/default_user.jpg" : [dictionary objectForKey:@"img_url"];
	vo.imageURL = [dictionary objectForKey:@"img_url"];
	vo.challengerName = [dictionary objectForKey:@"challenger_name"];
	
	vo.addedDate = [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.fbID = nil;
	self.username = nil;
	self.imageURL = nil;
	self.addedDate = nil;
}
@end
