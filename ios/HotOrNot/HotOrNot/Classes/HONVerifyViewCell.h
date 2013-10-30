//
//  HONVerifyViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONGenericRowViewCell.h"
#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONVerifyViewCellDelegate;
@interface HONVerifyViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (id)initAsEvenRow:(BOOL)isEven;
- (void)showTapOverlay;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, assign) id <HONVerifyViewCellDelegate> delegate;
@end

@protocol HONVerifyViewCellDelegate
- (void)verifyViewCellShowPreview:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
//- (void)verifyViewCellShowPreviewControls:(HONVerifyViewCell *)cell;
- (void)verifyViewCell:(HONVerifyViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO;
- (void)verifyViewCellApprove:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyViewCellDisprove:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
@end
