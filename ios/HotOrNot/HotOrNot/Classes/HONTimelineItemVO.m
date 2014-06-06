//
//  HONTimelineItemVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/26/2014 @ 13:47 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTimelineItemVO.h"

@implementation HONTimelineItemVO
@synthesize dictionary;
@synthesize timelineItemType, emotionVO, opponentVO, userClubVO, timestamp;

+ (HONTimelineItemVO *)timelineItemWithDictionary:(NSDictionary *)dictionary {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	//NSLog(@"DICTIONARY:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary);
	//dictionary = [((NSArray *)dictionary) objectAtIndex:0];
	
	HONTimelineItemVO *vo = [[HONTimelineItemVO alloc] init];
	vo.dictionary = dictionary;
	
	if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"FEATURED"])
		vo.timelineItemType = HONTimelineItemTypeFeatured;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"NEARBY"])
		vo.timelineItemType = HONTimelineItemTypeNearby;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"SCHOOL"])
		vo.timelineItemType = HONTimelineItemTypeSchool;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"STAFF"])
		vo.timelineItemType = HONTimelineItemTypeSelfieclubTeam;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"SPONSORED"])
		vo.timelineItemType = HONTimelineItemTypeSponsored;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"SUGGESTED"])
		vo.timelineItemType = HONTimelineItemTypeSuggested;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"USER_GENERATED"])
		vo.timelineItemType = HONTimelineItemTypeUserCreated;
	
	else
		vo.timelineItemType = HONTimelineItemTypeUnknown;
	
	vo.timestamp = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	switch (vo.timelineItemType) {
		case HONTimelineItemTypeUserCreated:
			vo.opponentVO = ([[dictionary objectForKey:@"submissions"] count] > 0) ? [HONOpponentVO opponentWithDictionary:[[dictionary objectForKey:@"submissions"] lastObject]] : nil;
			
			if (vo.opponentVO == nil) {
				vo.opponentVO = [HONOpponentVO opponentWithDictionary:@{@"user_id"	: @"592",
																		@"username"	: @"markus18",
																		@"avatar"	: @"https://d3j8du2hyvd35p.cloudfront.net/defaultAvatar",
																		@"img"		: @"https://d1fqnfrnudpaz6.cloudfront.net/a616f063d7b1477f95bca5098e15ef36_1396173765",
																		@"subjects"	: @[@"happy",
																						@"excited",
																						@"stoked"],
																		@"score"	: @"76",
																		@"added"	: @"2014-05-01 14:23:10"}];
			}
			
			vo.emotionVO = [[HONChallengeAssistant sharedInstance] emotionForOpponent:vo.opponentVO];
			break;
			
		case HONTimelineItemTypeNearby:
			vo.userClubVO = [HONUserClubVO clubWithDictionary:dictionary];
			break;
			
		default:
			break;
	}
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.opponentVO = nil;
	self.userClubVO = nil;
	self.timestamp = nil;
}

@end
