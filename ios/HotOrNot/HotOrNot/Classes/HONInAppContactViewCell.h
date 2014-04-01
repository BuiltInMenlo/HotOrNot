//
//  HONInAppContactViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:20 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONFollowContactViewCell.h"


@class HONInAppContactViewCell;
@protocol HONInAppContactViewCellDelegate <HONFollowContactViewCellDelegate>
- (void)inAppContactViewCell:(HONFollowContactViewCell *)viewCell inviteUser:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

@interface HONInAppContactViewCell : HONFollowContactViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, assign) id<HONInAppContactViewCellDelegate> delegate;
@end
