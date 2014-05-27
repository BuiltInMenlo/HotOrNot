//
//  HONClubTimelineViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONTimelineItemVO.h"
#import "HONChallengeVO.h"

@class HONClubTimelineViewCell;
@protocol HONClubTimelineViewCellDelegate <NSObject>
@optional
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell acceptInviteForClub:(HONUserClubVO *)userClubVO;
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell denyInviteForClub:(HONUserClubVO *)userClubVO;
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell selectedClubRow:(HONUserClubVO *)userClubVO;
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell selectedCTARow:(HONUserClubVO *)userClubVO;
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell likeClubChallenge:(HONChallengeVO *)challengeVO;
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell replyClubChallenge:(HONChallengeVO *)challengeVO;
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell moreClubChallenge:(HONChallengeVO *)challengeVO;
@end

@interface HONClubTimelineViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONTimelineItemVO *timelineItemVO;
@property (nonatomic, assign) id <HONClubTimelineViewCellDelegate> delegate;
@end
