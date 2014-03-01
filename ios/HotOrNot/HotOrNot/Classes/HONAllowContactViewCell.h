//
//  HONAllowContactViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/28/2014 @ 17:26 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONTrivialUserVO.h"

@protocol HONAllowContactViewCellDelegate;
@interface HONAllowContactViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONTrivialUserVO *userVO;
@property (nonatomic, assign) id <HONAllowContactViewCellDelegate> delegate;
@end


@protocol HONAllowContactViewCellDelegate <NSObject>
- (void)contactViewCell:(HONAllowContactViewCell *)cell user:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

