//
//  HONVerifyViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONVerifyViewCellDelegate;
@interface HONVerifyViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;


- (id)initAsInviteCell:(BOOL)isInviteCell;
- (void)showTapOverlay;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) BOOL isInviteCell;
@property (nonatomic, assign) id <HONVerifyViewCellDelegate> delegate;
@end

@protocol HONVerifyViewCellDelegate <NSObject>
- (void)verifyViewCell:(HONVerifyViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell approveChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell disapproveChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell skipChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell shoutoutChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell moreActionsForChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell fullSizeDisplayForChallenge:(HONChallengeVO *)challengeVO;
@optional
- (void)verifyViewCell:(HONVerifyViewCell *)cell bannerTappedForChallenge:(HONChallengeVO *)challengeVO;
@end
