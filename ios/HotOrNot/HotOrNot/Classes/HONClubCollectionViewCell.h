//
//  HONClubCollectionViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/09/2014 @ 20:10 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONUserClubVO.h"

@class HONClubCollectionViewCell;
@protocol HONClubCollectionViewCellDelegate <NSObject>
@end

@interface HONClubCollectionViewCell : UICollectionViewCell
+ (NSString *)cellReuseIdentifier;
- (void)resetSubviews;
-(void)applyTouchOverlayAndReset:(BOOL)reset;
-(void)removeTouchOverlay;


@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, assign) id <HONClubCollectionViewCellDelegate> delegate;
@end
