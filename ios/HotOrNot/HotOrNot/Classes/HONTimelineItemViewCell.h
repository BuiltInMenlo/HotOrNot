//
//  HONTimelineItemViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@protocol HONTimelineItemViewCellDelegate;
@interface HONTimelineItemViewCell : UITableViewCell

+ (NSString *)cellReuseIdentifier;
- (id)init;
- (void)upvoteUser:(int)userID;
- (void)showTapOverlay;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, assign) id <HONTimelineItemViewCellDelegate> delegate;
@end


@protocol HONTimelineItemViewCellDelegate
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showProfileForUserID:(int)userID forChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showVoters:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCellHidePreview:(HONTimelineItemViewCell *)cell;
@end