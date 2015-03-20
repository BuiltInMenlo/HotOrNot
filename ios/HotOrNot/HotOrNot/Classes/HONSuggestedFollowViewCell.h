//
//  HONSuggestedFollowViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/25/2013 @ 13:37 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserVO.h"


@class HONSuggestedFollowViewCell;
@protocol HONSuggestedFollowViewCellDelegate <NSObject>
- (void)followViewCell:(HONSuggestedFollowViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

@interface HONSuggestedFollowViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONUserVO *userVO;
@property (nonatomic, assign) id <HONSuggestedFollowViewCellDelegate> delegate;
@end
