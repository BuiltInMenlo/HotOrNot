//
//  HONHomeViewCell.h
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCollectionViewCell.h"
#import "HONClubPhotoVO.h"

@class HONHomeViewCell;
@protocol HONHomeViewCellDelegate <HONCollectionViewCellDelegate>
@optional
- (void)homeViewCell:(HONHomeViewCell *)viewCell didSelectClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
@end

@interface HONHomeViewCell : HONCollectionViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleImageLoading:(BOOL)isLoading;
@property (nonatomic, retain) HONClubPhotoVO *clubPhotoVO;
@property (nonatomic, assign) id <HONHomeViewCellDelegate> delegate;
@end
