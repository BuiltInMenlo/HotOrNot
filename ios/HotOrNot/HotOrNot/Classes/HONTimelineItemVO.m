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
@synthesize timelineItemType, clubPhotoVO, userClubVO, timestamp;

+ (HONTimelineItemVO *)timelineItemWithDictionary:(NSDictionary *)dictionary {
	//NSLog(@"DICTIONARY:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary);
	//dictionary = [((NSArray *)dictionary) objectAtIndex:0];
	
	HONTimelineItemVO *vo = [[HONTimelineItemVO alloc] init];
	vo.dictionary = dictionary;
	
	if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"FEATURED"])
		vo.timelineItemType = HONTimelineItemTypeFeatured;
	
	else if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"NEARBY"])
		vo.timelineItemType = HONTimelineItemTypeNearby;
	
	else if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"SCHOOL"])
		vo.timelineItemType = HONTimelineItemTypeSchool;
	
	else if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"STAFF"])
		vo.timelineItemType = HONTimelineItemTypeSelfieclub;
	
	else if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"SPONSORED"])
		vo.timelineItemType = HONTimelineItemTypeSponsored;
	
	else if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"SUGGESTED"])
		vo.timelineItemType = HONTimelineItemTypeSuggested;
	
	else if ([[[dictionary objectForKey:@"club_type"] uppercaseString] isEqualToString:@"USER_GENERATED"]) {
		vo.timelineItemType = ([[dictionary objectForKey:@"submissions"] count] > 0) ? HONTimelineItemTypeUserCreated : HONTimelineItemTypeUserCreatedEmpty;
	}
	
	else
		vo.timelineItemType = HONTimelineItemTypeUnknown;
	
	vo.timestamp = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	
	
	switch (vo.timelineItemType) {
		case HONTimelineItemTypeUserCreated:
			vo.userClubVO = [HONUserClubVO clubWithDictionary:dictionary];
			vo.clubPhotoVO = [HONClubPhotoVO clubPhotoWithDictionary:[[dictionary objectForKey:@"submissions"] lastObject]];
//			vo.opponentVO = [HONOpponentVO opponentWithDictionary:[[dictionary objectForKey:@"submissions"] lastObject]];
			break;
			
		case HONTimelineItemTypeUserCreatedEmpty:
			vo.userClubVO = [HONUserClubVO clubWithDictionary:dictionary];
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
	self.clubPhotoVO = nil;
	self.userClubVO = nil;
	self.timestamp = nil;
}

@end
