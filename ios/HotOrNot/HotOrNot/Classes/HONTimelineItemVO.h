//
//  HONTimelineItemVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/26/2014 @ 13:47 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONChallengeVO.h"
#import "HONOpponentVO.h"
#import "HONClubPhotoVO.h"
#import "HONUserClubVO.h"

typedef NS_ENUM(NSInteger, HONTimelineItemType) {
	HONTimelineItemTypeFeatured = 0,
	HONTimelineItemTypeNearby,
	HONTimelineItemTypeSchool,
	HONTimelineItemTypeSelfieclub,
	HONTimelineItemTypeSponsored,
	HONTimelineItemTypeSuggested,
	HONTimelineItemTypeUserCreated,
	HONTimelineItemTypeUserCreatedEmpty,
	HONTimelineItemTypeUnknown,
	HONTimelineItemType__TOTAL
};


@interface HONTimelineItemVO : NSObject
+ (HONTimelineItemVO *)timelineItemWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, assign) HONTimelineItemType timelineItemType;
//@property (nonatomic, retain) HONOpponentVO *opponentVO;
@property (nonatomic, retain) HONClubPhotoVO *clubPhotoVO;
@property (nonatomic, retain) HONUserClubVO *userClubVO;
@property (nonatomic, retain) NSDate *timestamp;

@end
