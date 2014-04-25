//
//  HONInviteContactViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONContactUserVO.h"

@class HONInviteContactViewCell;
@protocol HONInviteContactViewCellDelegate <NSObject>
- (void)inviteContactViewCell:(HONInviteContactViewCell *)viewCell inviteUser:(HONContactUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

@interface HONInviteContactViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, retain) HONContactUserVO *userVO;
@property (nonatomic, assign) id <HONInviteContactViewCellDelegate> delegate;
@end
