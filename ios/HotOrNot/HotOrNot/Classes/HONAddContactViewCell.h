//
//  HONAddContactViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONContactUserVO.h"


@protocol HONAddContactViewCellDelegate;
@interface HONAddContactViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleSelected:(BOOL)isSelected;
@property (nonatomic, retain) HONContactUserVO *userVO;
@property (nonatomic, assign) id <HONAddContactViewCellDelegate> delegate;
@end

@protocol HONAddContactViewCellDelegate
- (void)addContactViewCell:(HONAddContactViewCell *)cell user:(HONContactUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end