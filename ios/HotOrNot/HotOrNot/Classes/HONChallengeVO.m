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
@synthesize challengeID, creatorID, subjectName, creatorName;

+ (HONChallengeVO *)challengeWithDictionary:(NSDictionary *)dictionary {
	HONChallengeVO *vo = [[HONChallengeVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.challengeID = [[dictionary objectForKey:@"challenge_id"] intValue];
	vo.creatorID = [[dictionary objectForKey:@"creator_id"] intValue];
	vo.subjectName = [dictionary objectForKey:@"subject"];
	vo.creatorName = [dictionary objectForKey:@"creator"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.subjectName = nil;
	self.creatorName = nil;
}

@end
