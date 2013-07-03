//
//  HONRecentOpponentViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"


@protocol HONRecentOpponentViewCellDelegate;
@interface HONRecentOpponentViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONUserVO *userVO;
@property (nonatomic, assign) id <HONRecentOpponentViewCellDelegate> delegate;
@end

@protocol HONRecentOpponentViewCellDelegate
- (void)recentOpponentViewCell:(HONRecentOpponentViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end
