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
- (void)cellHeaderView:(HONVerifyCellHeaderView *)cell showProfileForCreator:(HONOpponentVO *)creatorVO;
@end

@interface HONVerifyCellHeaderView : UIView
- (id)initWithCreator:(HONOpponentVO *)creatorVO;

@property (nonatomic, assign) id <HONVerifyCellHeaderViewDelegate> delegate;
@end
