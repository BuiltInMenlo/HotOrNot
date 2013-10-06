//
//  HONSnapPreviewViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@protocol HONSnapPreviewViewControllerDelegate;
@interface HONSnapPreviewViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>
- (id)initWithChallenge:(HONChallengeVO *)vo asRoot:(BOOL)isFirst;
- (id)initWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO asRoot:(BOOL)isFirst;
- (void)showControls;

@property (nonatomic, assign) id <HONSnapPreviewViewControllerDelegate> delegate;
@end

@protocol HONSnapPreviewViewControllerDelegate
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController;
- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)snapPreviewViewControllerFlag:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@end
