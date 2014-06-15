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
@synthesize messageID, statusID, status, subjectName, hashtagName, participants, participantNames, replies, hasViewed, addedDate, startedDate, updatedDate;


+ (HONMessageVO *)messageWithDictionary:(NSDictionary *)dictionary {
	HONMessageVO *vo = [[HONMessageVO alloc] init];
	vo.dictionary = dictionary;
	
	//NSDictionary *challenger = [dictionary objectForKey:@"challenger"];
	//NSLog(@"CREATOR[%d]:\n%@\nCHALLENGER[%d]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", [[dictionary objectForKey:@"id"] intValue], creator, [[dictionary objectForKey:@"id"] intValue], challenger);
	
	vo.messageID = [[dictionary objectForKey:@"id"] intValue];
	vo.statusID = [[dictionary objectForKey:@"status"] intValue];
	vo.subjectName = [([dictionary objectForKey:@"subject"] != [NSNull null]) ? [dictionary objectForKey:@"subject"] : @"N/A" stringByReplacingOccurrencesOfString:@"#" withString:@""];
	vo.hashtagName = [@"#" stringByAppendingString:vo.subjectName];
	vo.hasViewed = ([[[dictionary objectForKey:@"viewed"] objectForKey:[[HONAppDelegate infoForUser] objectForKey:@"id"]] intValue]);
	
	vo.addedDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	vo.startedDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"started"]];
	vo.updatedDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"updated"]];
	
	
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
	
	BOOL isFound = NO;
	vo.participantNames = [NSMutableArray array];
	vo.participants = [NSMutableArray array];
	vo.replies = [NSMutableArray array];
	for (NSDictionary *challenger in [dictionary objectForKey:@"challengers"]) {
		HONOpponentVO *opponentVO = [HONOpponentVO opponentWithDictionary:challenger];
		
		if ([opponentVO.imagePrefix length] > 0)
			[vo.replies addObject:opponentVO];
		
		[vo.participants addObject:opponentVO];
		
		isFound = NO;
		for (NSString *username in vo.participantNames) {
			if ([username isEqualToString:opponentVO.username]) {
				isFound = YES;
				break;
			}
		}
		
		if (!isFound && opponentVO.userID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
			[vo.participantNames addObject:opponentVO.username];
	}
	
	isFound = NO;
	for (NSString *username in vo.participantNames) {
		if ([username isEqualToString:[[HONAppDelegate infoForUser] objectForKey:@"username"]]) {
			isFound = YES;
			break;
		}
	}
	
	if (!isFound && vo.creatorVO.userID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
		[vo.participantNames insertObject:vo.creatorVO.username atIndex:0];
	
	//NSLog(@"CREATOR[%@]:\nCHALLENGER[%@]", vo.creatorVO.dictionary, ([vo.challengers count] > 0) ? ((HONOpponentVO *)[vo.challengers objectAtIndex:0]).dictionary : @"");
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.status = nil;
	self.participants = nil;
	self.participantNames = nil;
	self.replies = nil;
	self.subjectName = nil;
	self.hashtagName = nil;
	self.startedDate = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
	self.creatorVO = nil;
}


@end
