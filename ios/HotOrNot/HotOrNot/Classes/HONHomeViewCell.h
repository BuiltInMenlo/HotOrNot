//
//  HONHomeViewCell.h
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCollectionViewCell.h"
#import "HONStatusUpdateVO.h"

@class HONHomeViewCell;
@protocol HONHomeViewCellDelegate <HONCollectionViewCellDelegate>
@optional
- (void)homeViewCell:(HONHomeViewCell *)viewCell didSelectStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO;
@end

@interface HONHomeViewCell : HONCollectionViewCell
+ (NSString *)cellReuseIdentifier;
//- (void)toggleImageLoading:(BOOL)isLoading;
- (void)refeshScore;
@property (nonatomic, retain) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, assign) id <HONHomeViewCellDelegate> delegate;
@end
