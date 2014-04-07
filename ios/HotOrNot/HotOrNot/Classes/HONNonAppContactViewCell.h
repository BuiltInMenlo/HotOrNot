//
//  HONNonAppContactViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"
#import "HONContactUserVO.h"

@class HONNonAppContactViewCell;
@protocol HONNonAppContactViewCellDelegate <NSObject>
- (void)nonAppContactViewCell:(HONNonAppContactViewCell *)viewCell contactUser:(HONContactUserVO *)userVO toggleSelected:(BOOL)isSelected;
@end

@interface HONNonAppContactViewCell : HONBaseRowViewCell
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, retain) HONContactUserVO *userVO;
@property (nonatomic, assign) id <HONNonAppContactViewCellDelegate> delegate;
@end
