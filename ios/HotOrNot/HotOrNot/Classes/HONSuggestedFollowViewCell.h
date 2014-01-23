//
//  HONSuggestedFollowViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/25/2013 @ 13:37 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONGenericAvatarViewCell.h"
#import "HONTrivialUserVO.h"


@protocol HONSuggestedFollowViewCellDelegate;
@interface HONSuggestedFollowViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONTrivialUserVO *trivialUserVO;
@property (nonatomic, assign) id <HONSuggestedFollowViewCellDelegate> delegate;
@end


@protocol HONSuggestedFollowViewCellDelegate <NSObject>
- (void)followViewCell:(HONSuggestedFollowViewCell *)cell user:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

