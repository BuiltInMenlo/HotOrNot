//
//  HONVerifyViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/1/13 @ 12:52 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONVerifyViewCellDelegate;
@interface HONVerifyViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)showTapOverlay;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, assign) id <HONVerifyViewCellDelegate> delegate;
@end

@protocol HONVerifyViewCellDelegate <NSObject>
- (void)verifyViewCellShowPreview:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCell:(HONVerifyViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO;
- (void)verifyViewCellApprove:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCellDisprove:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
@end
