//
//  HONInviteCelebViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.27.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONCelebVO.h"

@protocol HONInviteCelebViewCellDelegate;
@interface HONInviteCelebViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
@property (nonatomic, retain) HONCelebVO *celebVO;
@property (nonatomic, assign) id <HONInviteCelebViewCellDelegate> delegate;
@end

@protocol HONInviteCelebViewCellDelegate
- (void)inviteCelebViewCell:(HONInviteCelebViewCell *)cell celeb:(HONCelebVO *)celebVO toggleSelected:(BOOL)isSelected;
@end
