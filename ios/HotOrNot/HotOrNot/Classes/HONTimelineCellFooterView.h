//
//  HONTimelineCellFooterView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 5:36 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONTimelineCellFooterViewDelegate;
@interface HONTimelineCellFooterView : UIView
- (id)initAtPosY:(CGFloat)yPos withChallenge:(HONChallengeVO *)challengeVO;

@property (nonatomic, assign) id <HONTimelineCellFooterViewDelegate> delegate;
@end


@protocol HONTimelineCellFooterViewDelegate
- (void)cellFooterView:(HONTimelineCellFooterView *)cell showDetailsForChallenge:(HONChallengeVO *)challengeVO;
- (void)cellFooterView:(HONTimelineCellFooterView *)cell joinChallenge:(HONChallengeVO *)challengeVO;
- (void)cellFooterView:(HONTimelineCellFooterView *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@end