//
//  HONFollowTabViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 11/1/13 @ 12:52 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONFollowTabViewCellDelegate;
@interface HONFollowTabViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)showTapOverlay;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, assign) id <HONFollowTabViewCellDelegate> delegate;
@end

@protocol HONFollowTabViewCellDelegate
- (void)followViewCellShowPreview:(HONFollowTabViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)followViewCell:(HONFollowTabViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO;
- (void)followViewCellApprove:(HONFollowTabViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
- (void)followViewCellDisprove:(HONFollowTabViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO;
@end
