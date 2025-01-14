//
//  HONSearchUserViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:03 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONTrivialUserVO.h"

@class HONSearchUserViewCell;
@protocol HONSearchUserViewCellDelegate <NSObject>
- (void)searchUserViewCell:(HONSearchUserViewCell *)viewCell user:(HONTrivialUserVO *)trivialUserVO toggleSelected:(BOOL)isSelected;
@end

@interface HONSearchUserViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, retain) HONTrivialUserVO *trivialUserVO;
@property (nonatomic) BOOL isSelected;

@property (nonatomic, assign) id <HONSearchUserViewCellDelegate> delegate;
@end
