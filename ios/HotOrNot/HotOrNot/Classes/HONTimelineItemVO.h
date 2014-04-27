//
//  HONTimelineItemVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/26/2014 @ 13:47 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONChallengeVO.h"
#import "HONEmotionVO.h"
#import "HONUserClubVO.h"

typedef enum {
	HONTimelineItemTypeSelfie = 0,
	HONTimelineItemTypeInviteRequest,
	HONTimelineItemTypeCTA,
	HONTimelineItemType__TOTAL
} HONTimelineItemType;


@interface HONTimelineItemVO : NSObject
+ (HONTimelineItemVO *)timelineItemWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, assign) HONTimelineItemType timelineItemType;
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@property (nonatomic, retain) HONEmotionVO *emotionVO;
@property (nonatomic, retain) HONUserClubVO *userClubVO;
@property (nonatomic, retain) NSDate *timestamp;

@end
