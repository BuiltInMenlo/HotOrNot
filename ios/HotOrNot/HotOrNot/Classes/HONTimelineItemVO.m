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
@synthesize timelineItemType, challengeVO, emotionVO, userClubVO, timestamp;

+ (HONTimelineItemVO *)timelineItemWithDictionary:(NSDictionary *)dictionary {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	HONTimelineItemVO *vo = [[HONTimelineItemVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.timelineItemType = ([dictionary objectForKey:@"creator"]) ? HONTimelineItemTypeSelfie : HONTimelineItemTypeInviteRequest;
	vo.timestamp = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	switch (vo.timelineItemType) {
		case HONTimelineItemTypeSelfie:
			vo.challengeVO = [HONChallengeVO challengeWithDictionary:dictionary];
			vo.emotionVO = [[HONChallengeAssistant sharedInstance] emotionForOpponent:vo.challengeVO.creatorVO];
			break;
			
		case HONTimelineItemTypeInviteRequest:
			vo.userClubVO = [HONUserClubVO clubWithDictionary:dictionary];
			break;
			
		case HONTimelineItemTypeCTA:
			break;
			
		default:
			break;
	}
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.challengeVO = nil;
	self.userClubVO = nil;
	self.timestamp = nil;
}

@end
