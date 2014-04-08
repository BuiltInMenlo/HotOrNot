//
//  HONFollowUserViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/4/13 @ 6:55 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONTrivialUserVO.h"

@class HONFollowUserViewCell;
@protocol HONFollowUserViewCellDelegate <NSObject>
- (void)followViewCell:(HONFollowUserViewCell *)cell user:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

@interface HONFollowUserViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONTrivialUserVO *userVO;
@property (nonatomic, assign) id <HONFollowUserViewCellDelegate> delegate;
@end
