//
//  HONClubViewCell.h
//  HotOrNot
//
//  Created by BIM  on 8/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONUserClubVO.h"

@class HONClubViewCell;
@protocol HONClubViewCellDelegate <NSObject>
- (void)clubViewCell:(HONClubViewCell *)viewCell selectedClub:(HONUserClubVO *)clubVO;
@end

@interface HONClubViewCell : HONTableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleImageLoading:(BOOL)isLoading;

@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, assign) id <HONClubViewCellDelegate> delegate;
@end
