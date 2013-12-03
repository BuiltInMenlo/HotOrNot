//
//  HONChallengeViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONGenericRowViewCell.h"
#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONChallengeViewCellDelegate;
@interface HONChallengeViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (id)initAsEvenRow:(BOOL)isEven;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, assign) id <HONChallengeViewCellDelegate> delegate;
@end

@protocol HONChallengeViewCellDelegate
- (void)challengeViewCellShowPreview:(HONChallengeViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)challengeViewCellHidePreview:(HONChallengeViewCell *)cell;
- (void)challengeViewCell:(HONChallengeViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO;
- (void)challengeViewCell:(HONChallengeViewCell *)cell approveUser:(BOOL)isApproved forChallenge:(HONChallengeVO *)challengeVO;
@end
