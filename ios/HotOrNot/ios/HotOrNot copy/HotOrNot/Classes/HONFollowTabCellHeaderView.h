//
//  HONFollowTabCellHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/1/13 @ 1:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONOpponentVO.h"


@protocol HONFollowTabCellHeaderDelegate;
@interface HONFollowTabCellHeaderView : UIView
- (id)initWithOpponent:(HONOpponentVO *)opponentVO;

@property (nonatomic, assign) id <HONFollowTabCellHeaderDelegate> delegate;
@end

@protocol HONFollowTabCellHeaderDelegate
- (void)cellHeaderView:(HONFollowTabCellHeaderView *)cell showProfileForUser:(HONOpponentVO *)opponentVO;
@end