//
//  HONFollowTabCellHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/1/13 @ 1:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONOpponentVO.h"


const CGSize kVerifyAvatarSize;

@class HONVerifyCellHeaderView;
@protocol HONVerifyCellHeaderViewDelegate <NSObject>
- (void)cellHeaderView:(HONVerifyCellHeaderView *)cell showProfileForUser:(HONOpponentVO *)opponentVO;
@end

@interface HONVerifyCellHeaderView : UIView
- (id)initWithOpponent:(HONOpponentVO *)opponentVO;

@property (nonatomic, assign) id <HONVerifyCellHeaderViewDelegate> delegate;
@end
