//
//  HONCommentItemView.h
//  HotOrNot
//
//  Created by BIM  on 12/31/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentVO.h"

@class HONCommentItemView;
@protocol HONCommentItemViewDelegate <NSObject>
@optional
- (void)commentItemView:(HONCommentItemView *)commentItemView hidePhotoForComment:(HONCommentVO *)commentVO;
- (void)commentItemView:(HONCommentItemView *)commentItemView showPhotoForComment:(HONCommentVO *)commentVO;
@end

@interface HONCommentItemView : UIView
- (void)updateStatus:(HONCommentStatusType)statusType;

@property (nonatomic, retain) HONCommentVO *commentVO;
@property (nonatomic, assign) id<HONCommentItemViewDelegate> delegate;
@end
