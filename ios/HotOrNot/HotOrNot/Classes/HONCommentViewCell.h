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
@protocol HONCommentViewCellDelegate <NSObject>
- (void)commentViewCell:(HONCommentViewCell *)cell didUpVoteComment:(HONCommentVO *)commentVO;
- (void)commentViewCell:(HONCommentViewCell *)cell didDownVoteComment:(HONCommentVO *)commentVO;
@end

@interface HONCommentViewCell : HONTableViewCell
- (void)refreshScore;

@property (nonatomic, strong) HONCommentVO *commentVO;
@property (nonatomic, assign) id <HONCommentViewCellDelegate> delegate;
@end
