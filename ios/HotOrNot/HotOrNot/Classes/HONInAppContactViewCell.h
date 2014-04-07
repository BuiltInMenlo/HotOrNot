//
//  HONInAppContactViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:20 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONBaseAvatarViewCell.h"


@class HONInAppContactViewCell;
@protocol HONInAppContactViewCellDelegate <HONBaseAvatarViewCellDelegate>
- (void)inAppContactViewCell:(HONInAppContactViewCell *)viewCell addUser:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

@interface HONInAppContactViewCell : HONBaseAvatarViewCell
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, assign) id<HONInAppContactViewCellDelegate> delegate;
@end
