//
//  HONClubViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/09/2014 @ 20:10 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONUserClubVO.h"

@class HONClubViewCell;
@protocol HONClubViewCellDelegate <NSObject>
- (void)clubViewCell:(HONClubViewCell *)cell deleteClub:(HONUserClubVO *)userClubVO;
- (void)clubViewCell:(HONClubViewCell *)cell editClub:(HONUserClubVO *)userClubVO;
- (void)clubViewCell:(HONClubViewCell *)cell joinClub:(HONUserClubVO *)userClubVO;
- (void)clubViewCell:(HONClubViewCell *)cell quitClub:(HONUserClubVO *)userClubVO;
- (void)clubViewCellCreateClub:(HONClubViewCell *)cell;
@end

@interface HONClubViewCell : UICollectionViewCell
+ (NSString *)cellReuseIdentifier;
- (void)resetSubviews;

@property (nonatomic, assign) HONClubType clubType;
@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, assign) id <HONClubViewCellDelegate> delegate;
@end
