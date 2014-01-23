//
//  HONPopularUserViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:03 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONTrivialUserVO.h"

@protocol HONPopularUserViewCellDelegate;
@interface HONPopularUserViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, retain) HONTrivialUserVO *trivialUserVO;
@property (nonatomic) BOOL isSelected;

@property (nonatomic, assign) id <HONPopularUserViewCellDelegate> delegate;
@end


@protocol HONPopularUserViewCellDelegate <NSObject>
- (void)popularUserViewCell:(HONPopularUserViewCell *)cell user:(HONTrivialUserVO *)trivialUserVO toggleSelected:(BOOL)isSelected;
@end