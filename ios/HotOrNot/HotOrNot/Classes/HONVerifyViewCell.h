//
//  HONVerifyViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@class HONVerifyViewCell;
@protocol HONVerifyViewCellDelegate <NSObject>
- (void)verifyViewCell:(HONVerifyViewCell *)cell showCreatorProfile:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell approveChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell unapproveChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell skipChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell inviteChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell moreActionsForChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell fullSizeDisplayForChallenge:(HONChallengeVO *)challengeVO;
@optional
- (void)verifyViewCell:(HONVerifyViewCell *)cell bannerTappedForChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell shoutoutChallenge:(HONChallengeVO *)challengeVO;
@end


@interface HONVerifyViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsBannerCell:(BOOL)isBannerCell;
- (void)showTapOverlay;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) id <HONVerifyViewCellDelegate> delegate;
@end
