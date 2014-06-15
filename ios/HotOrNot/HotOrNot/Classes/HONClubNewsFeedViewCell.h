//
//  HONClubTimelineViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONTimelineItemVO.h"
#import "HONChallengeVO.h"

typedef NS_ENUM(NSInteger, HONClubNewsFeedCellType) {
	HONClubNewsFeedCellTypeClub = 0,
	HONClubNewsFeedCellTypeCreateClub,
	HONClubNewsFeedCellTypeConfirmClubs
};

@class HONClubNewsFeedViewCell;
@protocol HONClubNewsFeedViewCellDelegate <NSObject>
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell createClubWithProtoVO:(HONUserClubVO *)userClubVO;
@optional
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell joinClub:(HONUserClubVO *)userClubVO;
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell upvoteClubPhoto:(HONUserClubVO *)userClubVO;
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell replyToClubPhoto:(HONUserClubVO *)userClubVO;
@end

@interface HONClubNewsFeedViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONTimelineItemVO *timelineItemVO;
@property (nonatomic, assign) HONClubNewsFeedCellType cellType;
@property (nonatomic, assign) id <HONClubNewsFeedViewCellDelegate> delegate;
@end
