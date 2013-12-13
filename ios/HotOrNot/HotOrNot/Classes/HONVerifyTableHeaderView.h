//
//  HONVerifyTableHeaderView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 10:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONOpponentVO.h"


@protocol HONVerifyTableHeaderViewDelegate;
@interface HONVerifyTableHeaderView : UIView
- (id)initWithOpponent:(HONOpponentVO *)opponentVO;

@property (nonatomic, assign) id <HONVerifyTableHeaderViewDelegate> delegate;
@end


@protocol HONVerifyTableHeaderViewDelegate <NSObject>
- (void)tableHeaderView:(HONVerifyTableHeaderView *)cell showProfileForUser:(HONOpponentVO *)opponentVO;
@end