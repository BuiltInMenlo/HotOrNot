//
//  HONSearchUserViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:03 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserVO.h"

@class HONSearchUserViewCell;
@protocol HONSearchUserViewCellDelegate <NSObject>
- (void)searchUserViewCell:(HONSearchUserViewCell *)viewCell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

@interface HONSearchUserViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, retain) HONUserVO *userVO;
@property (nonatomic) BOOL isSelected;

@property (nonatomic, assign) id <HONSearchUserViewCellDelegate> delegate;
@end
