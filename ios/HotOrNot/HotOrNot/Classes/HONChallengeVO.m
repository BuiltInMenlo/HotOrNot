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
@synthesize challengeID, statusID, status, subjectName, challengers, commentTotal, hasViewed, isCelebCreated, addedDate, startedDate, updatedDate, expireSeconds;

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
	
	vo.creatorVO = [HONOpponentVO opponentWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
														  vo.subjectName, @"subject",
														  [[dictionary objectForKey:@"creator"] objectForKey:@"id"], @"id",
														  [[dictionary objectForKey:@"creator"] objectForKey:@"fb_id"], @"fb_id",
														  [[dictionary objectForKey:@"creator"] objectForKey:@"username"], @"username",
														  [[dictionary objectForKey:@"creator"] objectForKey:@"avatar"], @"avatar",
														  [[dictionary objectForKey:@"creator"] objectForKey:@"img"], @"img",
														  [[dictionary objectForKey:@"creator"] objectForKey:@"score"], @"score",
														  [[dictionary objectForKey:@"creator"] objectForKey:@"age"], @"age",
														  [dictionary objectForKey:@"added"], @"joined", nil]];
	
	vo.challengers = [NSMutableArray array];
	for (NSDictionary *challenger in [[[dictionary objectForKey:@"challengers"] reverseObjectEnumerator] allObjects]) {
		NSMutableDictionary *dictMod = [NSMutableDictionary dictionaryWithDictionary:challenger];
		[dictMod setObject:vo.subjectName forKey:@"subject"];
		[vo.challengers addObject:[HONOpponentVO opponentWithDictionary:dictMod]];
	}
	
	//NSLog(@"CREATOR[%@]:\nCHALLENGER[%@]", vo.creatorAvatar, vo.challengerAvatar);
	
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
