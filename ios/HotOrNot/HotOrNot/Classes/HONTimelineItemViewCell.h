//
//  HONTimelineItemViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@class HONTimelineItemViewCell;
@protocol HONTimelineItemViewCellDelegate <NSObject>
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell upvoteCreatorForChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell shareChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showVoters:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreviewForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showBannerForChallenge:(HONChallengeVO *)challengeVO;
@end

@interface HONTimelineItemViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsBannerCell:(BOOL)isBanner;
- (void)updateChallenge:(HONChallengeVO *)challengeVO;
- (void)showTapOverlay;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, assign) id <HONTimelineItemViewCellDelegate> delegate;
@end
