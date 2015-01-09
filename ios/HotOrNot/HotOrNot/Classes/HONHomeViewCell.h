//
//  HONHomeViewCell.h
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONStatusUpdateVO.h"

@class HONHomeViewCell;
@protocol HONHomeViewCellDelegate <HONTableViewCellDelegate>
@optional
- (void)homeViewCell:(HONHomeViewCell *)viewCell didSelectStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO;
@end

@interface HONHomeViewCell : HONTableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)toggleImageLoading:(BOOL)isLoading;

@property (nonatomic, retain) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, assign) id <HONHomeViewCellDelegate> delegate;
@end
