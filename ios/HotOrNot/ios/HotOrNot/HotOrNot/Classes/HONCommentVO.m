//
//  HONCommentVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentVO.h"


@implementation HONCommentVO

@synthesize dictionary;
@synthesize commentID, challengeID, userID, fbID, username, avatarURL, userScore, content, addedDate;

+ (HONCommentVO *)commentWithDictionary:(NSDictionary *)dictionary {
	HONCommentVO *vo = [[HONCommentVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.commentID = [[dictionary objectForKey:@"id"] intValue];
	vo.challengeID = [[dictionary objectForKey:@"challenge_id"] intValue];
	vo.userID = [[dictionary objectForKey:@"user_id"] intValue];
	vo.fbID = [dictionary objectForKey:@"fb_id"];
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarURL = [dictionary objectForKey:@"img_url"];
	vo.userScore = [[dictionary objectForKey:@"score"] intValue];
	vo.content = [dictionary objectForKey:@"text"];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.addedDate = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.fbID = nil;
	self.username = nil;
	self.avatarURL = nil;
	self.content = nil;
	self.addedDate = nil;
}

@end
