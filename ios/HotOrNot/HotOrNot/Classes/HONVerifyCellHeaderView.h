//
//  HONFollowTabCellHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/1/13 @ 1:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONOpponentVO.h"


@protocol HONVerifyCellHeaderViewDelegate;
@interface HONVerifyCellHeaderView : UIView
- (id)initWithOpponent:(HONOpponentVO *)opponentVO;

@property (nonatomic, assign) id <HONVerifyCellHeaderViewDelegate> delegate;
@end

@protocol HONVerifyCellHeaderViewDelegate
- (void)cellHeaderView:(HONVerifyCellHeaderView *)cell showProfileForUser:(HONOpponentVO *)opponentVO;
@end