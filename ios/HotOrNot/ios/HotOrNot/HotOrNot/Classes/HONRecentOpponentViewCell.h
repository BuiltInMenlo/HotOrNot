//
//  HONRecentOpponentViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"


@protocol HONInviteUserViewCellDelegate;
@interface HONRecentOpponentViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsInviteUser:(BOOL)isInvite;
- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONUserVO *userVO;
@property (nonatomic, assign) id <HONInviteUserViewCellDelegate> delegate;
@end

@protocol HONInviteUserViewCellDelegate
- (void)recentOpponentViewCell:(HONRecentOpponentViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end
