//
//  HONClubCollectionViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/09/2014 @ 20:10 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONUserClubVO.h"

@class HONClubCollectionViewCell;
@protocol HONClubViewCellDelegate <NSObject>
- (void)clubViewCell:(HONClubCollectionViewCell *)cell deleteClub:(HONUserClubVO *)userClubVO;
- (void)clubViewCell:(HONClubCollectionViewCell *)cell editClub:(HONUserClubVO *)userClubVO;
- (void)clubViewCell:(HONClubCollectionViewCell *)cell joinClub:(HONUserClubVO *)userClubVO;
- (void)clubViewCell:(HONClubCollectionViewCell *)cell quitClub:(HONUserClubVO *)userClubVO;
- (void)clubViewCellCreateClub:(HONClubCollectionViewCell *)cell;
@end

@interface HONClubCollectionViewCell : UICollectionViewCell
+ (NSString *)cellReuseIdentifier;
- (void)resetSubviews;

@property (nonatomic, assign) HONClubType clubType;
@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, assign) id <HONClubViewCellDelegate> delegate;
@end
