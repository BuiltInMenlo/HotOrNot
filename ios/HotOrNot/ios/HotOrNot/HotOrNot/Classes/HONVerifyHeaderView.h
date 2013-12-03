//
//  HONVerifyHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/21/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

@protocol HONVerifyHeaderViewDelegate;
@interface HONVerifyHeaderView : UIView
- (id)initWithChallenge:(HONChallengeVO *)vo;
@property (nonatomic, assign) id <HONVerifyHeaderViewDelegate> delegate;
@end

@protocol HONVerifyHeaderViewDelegate
- (void)verifyHeaderView:(HONVerifyHeaderView *)cell showCreatorTimeline:(HONChallengeVO *)challengeVO;
@end