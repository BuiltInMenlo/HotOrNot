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
@synthesize challengeID, statusID, status, subjectName, commentTotal, hasViewed, rechallengedUsers, addedDate, startedDate, updatedDate, expireSeconds;
@synthesize creatorID, creatorFB, creatorName, creatorAvatar, creatorImgPrefix, creatorScore;
@synthesize challengerID, challengerFB, challengerName, challengerAvatar, challengerImgPrefix, challengerScore;

+ (HONChallengeVO *)challengeWithDictionary:(NSDictionary *)dictionary {
	HONChallengeVO *vo = [[HONChallengeVO alloc] init];
	vo.dictionary = dictionary;
	
	NSDictionary *creator = [dictionary objectForKey:@"creator"];
	NSDictionary *challenger = [dictionary objectForKey:@"challenger"];
	//NSLog(@"CREATOR[%d]:\n%@\nCHALLENGER[%d]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", [[dictionary objectForKey:@"id"] intValue], creator, [[dictionary objectForKey:@"id"] intValue], challenger);
	
	vo.challengeID = [[dictionary objectForKey:@"id"] intValue];
	vo.statusID = [[dictionary objectForKey:@"status"] intValue];
	vo.subjectName = ([dictionary objectForKey:@"subject"] != [NSNull null]) ? [dictionary objectForKey:@"subject"] : @"#N/A";
	vo.commentTotal = [[dictionary objectForKey:@"comments"] intValue];
	vo.hasViewed = [[dictionary objectForKey:@"has_viewed"] isEqualToString:@"Y"];	
	vo.rechallengedUsers = @"";
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
	
	vo.creatorID = [[creator objectForKey:@"id"] intValue];
	vo.creatorFB = [creator objectForKey:@"fb_id"];
	vo.creatorName = [creator objectForKey:@"username"];
	vo.creatorAvatar = [creator objectForKey:@"avatar"];
	vo.creatorImgPrefix = [creator objectForKey:@"img"];
	vo.creatorScore = [[creator objectForKey:@"score"] intValue];
	
	vo.challengerID = [[challenger objectForKey:@"id"] intValue];
	vo.challengerFB = [challenger objectForKey:@"fb_id"];
	vo.challengerName = [challenger objectForKey:@"username"];
	vo.challengerAvatar = [challenger objectForKey:@"avatar"];
	vo.challengerImgPrefix = [challenger objectForKey:@"img"];
	vo.challengerScore = [[challenger objectForKey:@"score"] intValue];
	
	//NSLog(@"CREATOR[%@]:\nCHALLENGER[%@]", vo.creatorAvatar, vo.challengerAvatar);
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.status = nil;
	self.creatorImgPrefix = nil;
	self.challengerImgPrefix = nil;
	self.subjectName = nil;
	self.creatorName = nil;
	self.creatorFB = nil;
	self.challengerFB = nil;
	self.challengerName = nil;
	self.startedDate = nil;
	self.addedDate = nil;
}

@end
