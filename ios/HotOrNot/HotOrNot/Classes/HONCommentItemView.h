//
//  HONCommentItemView.h
//  HotOrNot
//
//  Created by BIM  on 12/31/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentVO.h"

typedef NS_ENUM(NSUInteger, HONCommentViewType) {
	HONCommentViewTypeUnknown = 0,
	HONCommentViewTypeLocalBot,
	HONCommentViewTypeRemoteBot,
	HONCommentViewTypeText,
	HONCommentViewTypeImage
};

@interface HONCommentItemView : UIView
- (id)initWithFrame:(CGRect)frame asType:(HONCommentViewType)viewType;
- (void)updateStatus:(HONCommentStatusType)statusType;

@property (nonatomic, retain) HONCommentVO *commentVO;
@end
