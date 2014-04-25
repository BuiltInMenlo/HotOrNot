//
//  HONSnapPreviewViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

typedef enum {
	HONSnapPreviewTypeChallenge	= 1,
	HONSnapPreviewTypeVerify,
	HONSnapPreviewTypeProfile
} HONSnapPreviewType;

typedef enum {
	HONSnapPreviewActionSheetTypeFlag = 0,
	HONSnapPreviewActionSheetTypeMore
} HONSnapPreviewActionSheetType;

typedef enum {
	HONSnapPreviewAlertTypeFlag = 0,
	HONSnapPreviewAlertTypeDisprove,
	HONSnapPreviewAlertTypeShare
} HONSnapPreviewAlertType;


@class HONSnapPreviewViewController;
@protocol HONSnapPreviewViewControllerDelegate <NSObject>
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController;
@optional
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController flagOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController upvoteOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController joinChallenge:(HONChallengeVO *)challengeVO;
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController removeVerifyChallenge:(HONChallengeVO *)challengeVO;
@end

@interface HONSnapPreviewViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate>
- (id)initWithVerifyChallenge:(HONChallengeVO *)vo;
- (id)initWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (id)initFromProfileWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;

@property (nonatomic, assign) id <HONSnapPreviewViewControllerDelegate> delegate;
@end
