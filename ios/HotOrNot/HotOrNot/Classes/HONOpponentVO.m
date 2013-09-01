//
//  HONOpponentVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONOpponentVO.h"

@implementation HONOpponentVO

@synthesize dictionary;
@synthesize userID, fbID, username, avatarURL, imagePrefix, joinedDate, score, birthday;

+ (HONOpponentVO *)opponentWithDictionary:(NSDictionary *)dictionary {
	HONOpponentVO *vo = [[HONOpponentVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.fbID = [dictionary objectForKey:@"fb_id"];
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarURL = [dictionary objectForKey:@"avatar"];
	vo.imagePrefix = ([dictionary objectForKey:@"img"] != [NSNull null]) ? [dictionary objectForKey:@"img"] : @"";
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	vo.joinedDate = [dateFormat dateFromString:[dictionary objectForKey:@"joined"]];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.birthday = ([dictionary objectForKey:@"age"] != [NSNull null]) ? [dateFormat dateFromString:[dictionary objectForKey:@"age"]] : [dateFormat dateFromString:@"1970-01-01 00:00:00"];
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.fbID = nil;
	self.username = nil;
	self.avatarURL = nil;
	self.imagePrefix = nil;
	self.joinedDate = nil;
}

@end
