//
//  HONTimelineHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

@protocol HONTimelineHeaderViewDelegate;
@interface HONTimelineHeaderView : UIView
- (id)initWithChallenge:(HONChallengeVO *)vo;
@property (nonatomic, assign) id <HONTimelineHeaderViewDelegate> delegate;
@end

@protocol HONTimelineHeaderViewDelegate
- (void)timelineHeaderView:(HONTimelineHeaderView *)cell showDetails:(HONChallengeVO *)challengeVO;
- (void)timelineHeaderView:(HONTimelineHeaderView *)cell showCreatorTimeline:(HONChallengeVO *)challengeVO;
@end
