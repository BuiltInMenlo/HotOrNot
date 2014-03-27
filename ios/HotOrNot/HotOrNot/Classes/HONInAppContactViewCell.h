//
//  HONInAppContactViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:20 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONInviteUserViewCell.h"

@protocol HONInAppContactViewCellDelegate;
@interface HONInAppContactViewCell : HONInviteUserViewCell
+ (NSString *)cellReuseIdentifier;

//@property (nonatomic, assign) id <HONInAppContactViewCellDelegate> delegate;
@end

