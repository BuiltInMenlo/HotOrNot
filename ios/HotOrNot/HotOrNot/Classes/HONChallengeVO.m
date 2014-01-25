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
@synthesize challengeID, statusID, status, subjectName, hashtagName, recentLikes, challengers, likedByTotal, totalLikes, hasViewed, addedDate, startedDate, updatedDate;

+ (HONChallengeVO *)challengeWithDictionary:(NSDictionary *)dictionary {
	HONChallengeVO *vo = [[HONChallengeVO alloc] init];
	vo.dictionary = dictionary;
	
	//NSDictionary *challenger = [dictionary objectForKey:@"challenger"];
	//NSLog(@"CREATOR[%d]:\n%@\nCHALLENGER[%d]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", [[dictionary objectForKey:@"id"] intValue], creator, [[dictionary objectForKey:@"id"] intValue], challenger);
	
	vo.challengeID = [[dictionary objectForKey:@"id"] intValue];
	vo.statusID = [[dictionary objectForKey:@"status"] intValue];
	vo.subjectName = [([dictionary objectForKey:@"subject"] != [NSNull null]) ? [dictionary objectForKey:@"subject"] : @"N/A" stringByReplacingOccurrencesOfString:@"#" withString:@""];
	vo.hashtagName = [@"#" stringByAppendingString:vo.subjectName];
	vo.likedByTotal = [[dictionary objectForKey:@"total_likers"] intValue];
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
//	[creator setObject:[dateFormat stringFromDate:vo.addedDate] forKey:@"joined"];
	vo.creatorVO = [HONOpponentVO opponentWithDictionary:creator];
	vo.totalLikes = vo.creatorVO.score;
	
	vo.challengers = [NSMutableArray array];
	for (NSDictionary *challenger in [[[dictionary objectForKey:@"challengers"] reverseObjectEnumerator] allObjects]) {
		HONOpponentVO *opponentVO = [HONOpponentVO opponentWithDictionary:challenger];
		[vo.challengers addObject:opponentVO];
		vo.totalLikes += opponentVO.score;
	}
	
	vo.recentLikes = @"Be the first to like";
	
	NSArray *userLikes = [dictionary objectForKey:@"recent_likes"];
	
	BOOL isTurdInPunchBowl = NO;
	for (id element in userLikes) {
		if (![element isKindOfClass:[NSDictionary class]]) {
			isTurdInPunchBowl = YES;
			break;
		}
	}
		
	if ([userLikes count] > 0 && [dictionary objectForKey:@"recent_likes"] != [NSNull null] && !isTurdInPunchBowl) {
		int remaining = vo.likedByTotal - [userLikes count];
		if ([userLikes count] == 3) {
				vo.recentLikes = (remaining > 0) ? [NSString stringWithFormat:@"%@, %@, %@, and %d other%@", [[userLikes objectAtIndex:0] objectForKey:@"username"], [[userLikes objectAtIndex:1] objectForKey:@"username"], [[userLikes objectAtIndex:2] objectForKey:@"username"], remaining, (remaining != 1) ? @"s" : @""] : [NSString stringWithFormat:@"%@, %@, and %@", [[userLikes objectAtIndex:0] objectForKey:@"username"], [[userLikes objectAtIndex:1] objectForKey:@"username"], [[userLikes objectAtIndex:2] objectForKey:@"username"]];
			
		} else if ([userLikes count] == 2) {
				vo.recentLikes = (remaining > 0) ? [NSString stringWithFormat:@"%@, %@, and %d other%@", [[userLikes objectAtIndex:0] objectForKey:@"username"], [[userLikes objectAtIndex:1] objectForKey:@"username"], remaining, (remaining != 1) ? @"s" : @""] : [NSString stringWithFormat:@"%@ and %@", [[userLikes objectAtIndex:0] objectForKey:@"username"], [[userLikes objectAtIndex:1] objectForKey:@"username"]];
			
		} else if ([userLikes count] == 1) {
				vo.recentLikes = (remaining > 0) ? [NSString stringWithFormat:@"%@, and %d other%@", [[userLikes objectAtIndex:0] objectForKey:@"username"], remaining, (remaining != 1) ? @"s" : @""] : [[userLikes objectAtIndex:0] objectForKey:@"username"];
			
		} else
			vo.recentLikes = @"Be the first to like";
	} else
		vo.recentLikes = @"Be the first to like";
	
	
	vo.recentLikes = (vo.totalLikes == 0) ? @"Be the first to like" : [NSString stringWithFormat:@"%d like%@", vo.totalLikes, (vo.totalLikes != 1) ? @"s" : @""];
	
	
	//NSLog(@"CREATOR[%@]:\nCHALLENGER[%@]", vo.creatorVO.dictionary, ([vo.challengers count] > 0) ? ((HONOpponentVO *)[vo.challengers objectAtIndex:0]).dictionary : @"");
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.status = nil;
	self.recentLikes = nil;
	self.challengers = nil;
	self.subjectName = nil;
	self.hashtagName = nil;
	self.startedDate = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
	self.creatorVO = nil;
}

@end
