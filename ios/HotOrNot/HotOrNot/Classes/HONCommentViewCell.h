//
//  HONCommentViewCell.h
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONCommentVO.h"

@class HONCommentViewCell;
@protocol HONCommentViewCellDelegate <HONTableViewCellDelegate>
- (void)commentViewCell:(HONCommentViewCell *)cell didSelectComment:(HONCommentVO *)commentVO;
@end

@interface HONCommentViewCell : HONTableViewCell
@property (nonatomic, strong) HONCommentVO *commentVO;
@property (nonatomic, assign) id <HONCommentViewCellDelegate> delegate;
@end
