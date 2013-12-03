//
//  HONHeroFooterView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 7:29 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@protocol HONHeroFooterViewDelegate;
@interface HONHeroFooterView : UIView
- (id)initAtYPos:(int)yPos withChallenge:(HONChallengeVO *)challengeVO andHeroOpponent:(HONOpponentVO *)heroOpponentVO;
- (void)updateLikesCaption:(NSString *)caption;
@property (nonatomic, assign) id <HONHeroFooterViewDelegate> delegate;
@end

@protocol HONHeroFooterViewDelegate
- (void)heroFooterView:(HONHeroFooterView *)heroFooterView showProfile:(HONOpponentVO *)heroOpponentVO;
@end
