//
//  HONExploreViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"


@protocol HONExploreViewCellDelegate;
@interface HONExploreViewCell : UICollectionViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONChallengeVO *lChallengeVO;
@property (nonatomic, retain) HONChallengeVO *rChallengeVO;

@property (nonatomic, assign) id <HONExploreViewCellDelegate> delegate;
@end

@protocol HONExploreViewCellDelegate
- (void)discoveryViewCell:(HONExploreViewCell *)cell selectLeftChallenge:(HONChallengeVO *)challengeVO;
- (void)discoveryViewCell:(HONExploreViewCell *)cell selectRightChallenge:(HONChallengeVO *)challengeVO;
@end