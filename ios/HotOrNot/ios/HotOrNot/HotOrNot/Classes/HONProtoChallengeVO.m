//
//  HONProtoChallengeVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:14 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONProtoChallengeVO.h"

@implementation HONProtoChallengeVO
@synthesize dictionary;
@synthesize userID, challengeID, clubID, imgPrefix, emotionNames, recipients;

+ (HONProtoChallengeVO *)protoChallengeWithDictionary:(NSDictionary *)dictionary {
	HONProtoChallengeVO *vo = [[HONProtoChallengeVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.userID = [[dictionary objectForKey:@"user_id"] intValue];
	vo.challengeID = [[dictionary objectForKey:@"challenge_id"] intValue];
	vo.clubID = [[dictionary objectForKey:@"club_id"] intValue];
	
	vo.imgPrefix = [dictionary objectForKey:@"img_url"];
	vo.emotionNames = [dictionary objectForKey:@"emotions"];
	vo.recipients = [dictionary objectForKey:@"recipients"];
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.imgPrefix = nil;
	self.emotionNames = nil;
	self.recipients = nil;
}


@end
