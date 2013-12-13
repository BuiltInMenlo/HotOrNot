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
- (void)showTapOverlay;
- (void)tintMe;;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) id <HONVerifyShoutoutViewCellDelegate> delegate;
@end

@protocol HONVerifyShoutoutViewCellDelegate <NSObject>
- (void)verifyShoutoutViewCellShowPreview:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCell:(HONVerifyShoutoutViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellApprove:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellSkip:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellShoutout:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyShoutoutViewCellMore:(HONVerifyShoutoutViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
@end
