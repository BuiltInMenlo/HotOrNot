//
//  HONSuggestedFollowViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/25/2013 @ 13:37 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONPopularUserVO.h"

#define kStatsPosY	170.0

@protocol HONSuggestedFollowViewCellDelegate;
@interface HONSuggestedFollowViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONPopularUserVO *popularUserVO;
@property (nonatomic, assign) id <HONSuggestedFollowViewCellDelegate> delegate;
@end


@protocol HONSuggestedFollowViewCellDelegate
- (void)followViewCell:(HONSuggestedFollowViewCell *)cell user:(HONPopularUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

