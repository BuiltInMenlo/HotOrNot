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
@synthesize challengeID, statusID, status, subjectName, challengers, commentTotal, hasViewed, isCelebCreated, isExploreChallenge, addedDate, startedDate, updatedDate, expireSeconds;

+ (HONChallengeVO *)challengeWithDictionary:(NSDictionary *)dictionary {
	HONChallengeVO *vo = [[HONChallengeVO alloc] init];
	vo.dictionary = dictionary;
	
	//NSDictionary *challenger = [dictionary objectForKey:@"challenger"];
	//NSLog(@"CREATOR[%d]:\n%@\nCHALLENGER[%d]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", [[dictionary objectForKey:@"id"] intValue], creator, [[dictionary objectForKey:@"id"] intValue], challenger);
	
	vo.challengeID = [[dictionary objectForKey:@"id"] intValue];
	vo.statusID = [[dictionary objectForKey:@"status"] intValue];
	vo.subjectName = ([dictionary objectForKey:@"subject"] != [NSNull null]) ? [dictionary objectForKey:@"subject"] : @"#N/A";
	vo.commentTotal = [[dictionary objectForKey:@"comments"] intValue];
	vo.hasViewed = [[dictionary objectForKey:@"has_viewed"] isEqualToString:@"Y"];
	vo.isCelebCreated = [[dictionary objectForKey:@"is_celeb"] intValue];
	vo.isExploreChallenge = [[dictionary objectForKey:@"is_explore"] intValue];
	vo.expireSeconds = [[dictionary objectForKey:@"expires"] intValue];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.addedDate = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	vo.startedDate = [dateFormat dateFromString:[dictionary objectForKey:@"started"]];
	vo.updatedDate = [dateFormat dateFromString:[dictionary objectForKey:@"updated"]];
	
	switch (vo.statusID) {
		case 1:
			vo.status = @"Created";
			break;
			
		case 2:
			vo.status = @"Waiting";
			break;
			
		case 3:
			vo.status = @"Canceled";
			break;
			
		case 4:
			vo.status = @"Started";
			break;
		
		case 5:
			vo.status = @"Completed";
			break;
			
		case 6:
			vo.status = @"Flagged";
			break;
		
		case 7:
			vo.status = @"Waiting";
			break;
			
		default:
			vo.status = @"Accept";
			break;
	}
	
	vo.creatorVO = [HONOpponentVO opponentWithDictionary:[dictionary objectForKey:@"creator"]];
	
	vo.challengers = [NSMutableArray array];
	for (NSDictionary *challenger in [[[dictionary objectForKey:@"challengers"] reverseObjectEnumerator] allObjects]) {
		[vo.challengers addObject:[HONOpponentVO opponentWithDictionary:challenger]];
	}
	
//	NSLog(@"CREATOR[%@]:\nCHALLENGER[%@]", vo.creatorVO.dictionary, ([vo.challengers count] > 0) ? ((HONOpponentVO *)[vo.challengers objectAtIndex:0]).dictionary : @"");
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.status = nil;
	self.subjectName = nil;
	self.startedDate = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
	self.creatorVO = nil;
	self.challengers = nil;
}

@end
