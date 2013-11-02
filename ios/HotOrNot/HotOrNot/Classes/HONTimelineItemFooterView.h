//
//  HONTimelineItemFooterView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 5:36 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONTimelineItemFooterViewDelegate;
@interface HONTimelineItemFooterView : UIView
- (id)initAtPosY:(CGFloat)yPos withChallenge:(HONChallengeVO *)challengeVO;
- (void)upvoteUser:(int)userID;

@property (nonatomic, assign) id <HONTimelineItemFooterViewDelegate> delegate;
@end


@protocol HONTimelineItemFooterViewDelegate
- (void)footerView:(HONTimelineItemFooterView *)cell joinChallenge:(HONChallengeVO *)challengeVO;
- (void)footerView:(HONTimelineItemFooterView *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@optional
- (void)footerView:(HONTimelineItemFooterView *)cell showDetailsForChallenge:(HONChallengeVO *)challengeVO;
@end