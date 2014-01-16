//
//  HONVerifyShoutoutViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONVerifyShoutoutViewCellDelegate;
@interface HONVerifyShoutoutViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;


- (id)initAsInviteCell:(BOOL)isInviteCell;
- (void)showTapOverlay;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) BOOL isInviteCell;
@property (nonatomic, assign) id <HONVerifyShoutoutViewCellDelegate> delegate;
@end

@protocol HONVerifyShoutoutViewCellDelegate <NSObject>
- (void)verifyShoutoutViewCell:(HONVerifyShoutoutViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellApprove:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellSkip:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellShoutout:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellMore:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellBanner:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellShowPreview:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
@optional
@end
