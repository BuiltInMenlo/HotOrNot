//
//  HONSubscribeViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/4/13 @ 6:55 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@protocol HONSubscribeViewCellDelegate;
@interface HONSubscribeViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONUserVO *userVO;
@property (nonatomic, assign) id <HONSubscribeViewCellDelegate> delegate;
@end

@protocol HONSubscribeViewCellDelegate
- (void)subscribeViewCell:(HONSubscribeViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end
