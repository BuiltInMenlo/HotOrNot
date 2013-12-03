//
//  HONVerifyCellHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 10:01 PM.
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