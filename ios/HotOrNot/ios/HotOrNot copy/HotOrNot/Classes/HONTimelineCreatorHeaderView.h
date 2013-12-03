//
//  HONTimelineCreatorHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@protocol HONTimelineHeaderCreatorViewDelegate;
@interface HONTimelineCreatorHeaderView : UIView
- (id)initWithChallenge:(HONChallengeVO *)vo;

@property (nonatomic, assign) id <HONTimelineHeaderCreatorViewDelegate> delegate;
@end

@protocol HONTimelineHeaderCreatorViewDelegate
- (void)timelineHeaderView:(HONTimelineCreatorHeaderView *)cell showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@optional
- (void)timelineHeaderView:(HONTimelineCreatorHeaderView *)cell showDetails:(HONChallengeVO *)challengeVO;
@end
