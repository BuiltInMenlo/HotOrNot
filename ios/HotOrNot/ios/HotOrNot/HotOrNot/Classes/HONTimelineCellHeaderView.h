//
//  HONTimelineCellHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

const CGSize kFeedItemAvatarSize;

@class HONTimelineCellHeaderView;
@protocol HONTimelineCellHeaderViewDelegate <NSObject>
- (void)timelineCellHeaderView:(HONTimelineCellHeaderView *)cell showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@optional
- (void)timelineCellHeaderView:(HONTimelineCellHeaderView *)cell showDetails:(HONChallengeVO *)challengeVO;
@end

@interface HONTimelineCellHeaderView : UIView
- (id)initWithChallenge:(HONChallengeVO *)vo;

@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, weak) id <HONTimelineCellHeaderViewDelegate> delegate;
@end
