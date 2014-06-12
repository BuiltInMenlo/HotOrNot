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
		vo.timelineItemType = HONTimelineItemTypeSelfieclub;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"SPONSORED"])
		vo.timelineItemType = HONTimelineItemTypeSponsored;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"SUGGESTED"])
		vo.timelineItemType = HONTimelineItemTypeSuggested;
	
	else if ([[dictionary objectForKey:@"club_type"] isEqualToString:@"USER_GENERATED"])
		vo.timelineItemType = HONTimelineItemTypeUserCreated;
	
	else
		vo.timelineItemType = HONTimelineItemTypeUnknown;
	
	vo.timestamp = [[HONDateTimeStipulator sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	
	
	switch (vo.timelineItemType) {
		case HONTimelineItemTypeUserCreated:
			vo.opponentVO = ([[dictionary objectForKey:@"submissions"] count] > 0) ? [HONOpponentVO opponentWithDictionary:[[dictionary objectForKey:@"submissions"] firstObject]] : nil;
			
//			if (vo.opponentVO == nil)
//				vo.opponentVO = [[HONChallengeAssistant sharedInstance] fpoOpponent];
			
			vo.emotionVO = (vo.opponentVO != nil) ? [[HONChallengeAssistant sharedInstance] emotionForOpponent:vo.opponentVO] : nil;
			break;
			
		case HONTimelineItemTypeNearby:
			vo.userClubVO = [HONUserClubVO clubWithDictionary:dictionary];
			break;
			
		case HONTimelineItemTypeSuggested:
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
