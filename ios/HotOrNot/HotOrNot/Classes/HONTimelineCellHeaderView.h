//
//  HONTimelineCellHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@protocol HONTimelineCellHeaderViewDelegate;
@interface HONTimelineCellHeaderView : UIView
- (id)initWithChallenge:(HONChallengeVO *)vo;

@property (nonatomic, assign) id <HONTimelineCellHeaderViewDelegate> delegate;
@end

@protocol HONTimelineCellHeaderViewDelegate <NSObject>
- (void)timelineCellHeaderView:(HONTimelineCellHeaderView *)cell showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@optional
- (void)timelineCellHeaderView:(HONTimelineCellHeaderView *)cell showDetails:(HONChallengeVO *)challengeVO;
@end
