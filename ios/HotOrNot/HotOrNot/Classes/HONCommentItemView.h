//
//  HONCommentItemView.h
//  HotOrNot
//
//  Created by BIM  on 12/31/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentVO.h"

@interface HONCommentItemView : UIView

- (void)updateStatus:(HONCommentStatusType)statusType;

@property (nonatomic, retain) HONCommentVO *commentVO;
@end
