//
//  HONChallengeVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"

@implementation HONChallengeVO

@synthesize dictionary;
@synthesize challengeID, creatorID, imageURL, image2URL, status, subjectName, creatorName, startedDate;

+ (HONChallengeVO *)challengeWithDictionary:(NSDictionary *)dictionary {
	HONChallengeVO *vo = [[HONChallengeVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.challengeID = [[dictionary objectForKey:@"challenge_id"] intValue];
	vo.creatorID = [[dictionary objectForKey:@"creator_id"] intValue];
	vo.status = [dictionary objectForKey:@"status"];
	vo.imageURL = [dictionary objectForKey:@"img_url"];
	vo.image2URL = [dictionary objectForKey:@"img2_url"];
	vo.subjectName = [dictionary objectForKey:@"subject"];
	vo.creatorName = [dictionary objectForKey:@"creator"];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.startedDate = [dateFormat dateFromString:[dictionary objectForKey:@"started"]];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.status = nil;
	self.imageURL = nil;
	self.image2URL = nil;
	self.subjectName = nil;
	self.creatorName = nil;
	self.startedDate = nil;
}

@end
