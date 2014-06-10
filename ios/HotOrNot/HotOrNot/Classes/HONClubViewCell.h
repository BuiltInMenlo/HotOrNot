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
@end

@interface HONClubViewCell : UICollectionViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, assign) id <HONClubViewCellDelegate> delegate;
@end
