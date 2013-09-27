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
@interface HONExploreViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, retain) HONChallengeVO *lChallengeVO;
@property (nonatomic, retain) HONChallengeVO *rChallengeVO;

@property (nonatomic, assign) id <HONExploreViewCellDelegate> delegate;
@end

@protocol HONExploreViewCellDelegate
- (void)exploreViewCellShowPreview:(HONExploreViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)exploreViewCellHidePreview:(HONExploreViewCell *)cell;
- (void)exploreViewCell:(HONExploreViewCell *)cell selectLeftChallenge:(HONChallengeVO *)challengeVO;
- (void)exploreViewCell:(HONExploreViewCell *)cell selectRightChallenge:(HONChallengeVO *)challengeVO;
@end