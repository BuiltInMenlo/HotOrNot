//
//  HONFollowFriendViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"


@protocol HONFollowFriendViewCellDelegate;
@interface HONFollowFriendViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONUserVO *userVO;
@property (nonatomic, assign) id <HONFollowFriendViewCellDelegate> delegate;
@end

@protocol HONFollowFriendViewCellDelegate
- (void)followFriendViewCell:(HONFollowFriendViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end
