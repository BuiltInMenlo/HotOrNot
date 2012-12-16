//
//  HONVoterVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoterVO.h"

@implementation HONVoterVO
@synthesize dictionary;
@synthesize userID, fbID, username, points, challenges, imageURL;

+ (HONVoterVO *)voterWithDictionary:(NSDictionary *)dictionary {
	HONVoterVO *vo = [[HONVoterVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.fbID = [dictionary objectForKey:@"fb_id"];
	vo.points = [[dictionary objectForKey:@"points"] intValue];
	vo.challenges = [[dictionary objectForKey:@"challenges"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.imageURL = [dictionary objectForKey:@"img_url"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.fbID = nil;
	self.username = nil;
	self.imageURL = nil;
}
@end
