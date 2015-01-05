//
//  HONComposeViewCell.h
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONTopicVO.h"

@class HONTopicViewCell;
@protocol HONTopicViewCellDelegate <HONTableViewCellDelegate>
@optional
- (void)topicViewCell:(HONTopicViewCell *)viewCell didSelectTopic:(HONTopicVO *)topicVO;
@end

@interface HONTopicViewCell : HONTableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleImageLoading:(BOOL)isLoading;

@property (nonatomic, retain) HONTopicVO *topicVO;
@property (nonatomic, assign) id <HONTopicViewCellDelegate> delegate;
@end
