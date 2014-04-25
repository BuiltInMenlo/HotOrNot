//
//  HONTimelineItemFooterView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 5:36 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@class HONTimelineItemFooterView;
@protocol HONTimelineItemFooterViewDelegate <NSObject>
- (void)footerView:(HONTimelineItemFooterView *)cell joinChallenge:(HONChallengeVO *)challengeVO;
- (void)footerView:(HONTimelineItemFooterView *)cell likeChallenge:(HONChallengeVO *)challengeVO;
- (void)footerView:(HONTimelineItemFooterView *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@optional
- (void)footerView:(HONTimelineItemFooterView *)cell showDetailsForChallenge:(HONChallengeVO *)challengeVO;
@end

@interface HONTimelineItemFooterView : UIView
- (id)initAtPosY:(CGFloat)yPos withChallenge:(HONChallengeVO *)challengeVO;
- (void)updateChallenge:(HONChallengeVO *)challengeVO;

@property (nonatomic, assign) id <HONTimelineItemFooterViewDelegate> delegate;
@end
