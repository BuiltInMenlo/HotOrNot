//
//  HONMessageVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 20:40 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONMessageVO.h"

@implementation HONMessageVO

@synthesize dictionary;
@synthesize messageID, statusID, status, subjectName, hashtagName, challengers, hasViewed, addedDate, startedDate, updatedDate;


+ (HONMessageVO *)messageWithDictionary:(NSDictionary *)dictionary {
	HONMessageVO *vo = [[HONMessageVO alloc] init];
	vo.dictionary = dictionary;
	
	//NSDictionary *challenger = [dictionary objectForKey:@"challenger"];
	//NSLog(@"CREATOR[%d]:\n%@\nCHALLENGER[%d]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", [[dictionary objectForKey:@"id"] intValue], creator, [[dictionary objectForKey:@"id"] intValue], challenger);
	
	vo.messageID = [[dictionary objectForKey:@"id"] intValue];
	vo.statusID = [[dictionary objectForKey:@"status"] intValue];
	vo.subjectName = [([dictionary objectForKey:@"subject"] != [NSNull null]) ? [dictionary objectForKey:@"subject"] : @"N/A" stringByReplacingOccurrencesOfString:@"#" withString:@""];
	vo.hashtagName = [@"#" stringByAppendingString:vo.subjectName];
	vo.hasViewed = [[dictionary objectForKey:@"has_viewed"] isEqualToString:@"Y"];
	
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
	
	//	NSLog(@"CHALLENGE:(%d)[%@]\n]=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-[\n%@", vo.challengeID, vo.dictionary, [dictionary objectForKey:@"creator"]);
	
	
	
	NSMutableDictionary *creator = [NSMutableDictionary dictionaryWithDictionary:[dictionary objectForKey:@"creator"]];
	[creator setValue:[dictionary objectForKey:@"added"] forKey:@"joined"];
	vo.creatorVO = [HONOpponentVO opponentWithDictionary:creator];
	
	vo.challengers = [NSMutableArray array];
	for (NSDictionary *challenger in [[[dictionary objectForKey:@"challengers"] reverseObjectEnumerator] allObjects]) {
		HONOpponentVO *opponentVO = [HONOpponentVO opponentWithDictionary:challenger];
		[vo.challengers addObject:opponentVO];
	}
	
	//NSLog(@"CREATOR[%@]:\nCHALLENGER[%@]", vo.creatorVO.dictionary, ([vo.challengers count] > 0) ? ((HONOpponentVO *)[vo.challengers objectAtIndex:0]).dictionary : @"");
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.status = nil;
	self.challengers = nil;
	self.subjectName = nil;
	self.hashtagName = nil;
	self.startedDate = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
	self.creatorVO = nil;
}


@end
