//
//  HONHomeViewCell.h
//  HotOrNot
//
//  Created by BIM  on 7/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"

@class HONHomeViewCell;
@protocol HONHomeViewCellDelegate <HONTableViewCellDelegate>
@optional
- (void)homeViewCell:(HONHomeViewCell *)cell didSelectChannel:(HONClubPhotoVO *)clubPhotoVO;
@end

@interface HONHomeViewCell : HONTableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)populateFields:(NSDictionary *)dictionary;

@property (nonatomic, assign) id <HONHomeViewCellDelegate> delegate;

@end
