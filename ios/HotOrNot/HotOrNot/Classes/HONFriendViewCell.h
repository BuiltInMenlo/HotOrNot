//
//  HONFriendViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/2/13 @ 2:35 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"


@protocol HONFriendViewCellDelegate;
@interface HONFriendViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONUserVO *userVO;
@property (nonatomic, assign) id <HONFriendViewCellDelegate> delegate;
@end


@protocol HONFriendViewCellDelegate
- (void)friendViewCell:(HONFriendViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end