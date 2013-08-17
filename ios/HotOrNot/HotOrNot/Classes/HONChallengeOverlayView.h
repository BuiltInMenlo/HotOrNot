//
//  HONChallengeOverlayView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/16/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@protocol HONChallengeOverlayViewDelegate;
@interface HONChallengeOverlayView : UIView
- (id)initWithChallenge:(HONChallengeVO *)challengeVO forOpponent:(HONOpponentVO *)opponentVO;

@property (nonatomic, assign) id <HONChallengeOverlayViewDelegate> delegate;
@end


@protocol HONChallengeOverlayViewDelegate
- (void)challengeOverlayViewClose:(HONChallengeOverlayView *)challengeOverlayView;
- (void)challengeOverlayViewUpvote:(HONChallengeOverlayView *)challengeOverlayView opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)challengeOverlayViewShowMore:(HONChallengeOverlayView *)challengeOverlayView opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@end
