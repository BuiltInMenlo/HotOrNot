//
//  HONBasicSelfieGridViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/27/2014 @ 07:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONChallengeVO.h"
#import "HONOpponentVO.h"
#import "HONSnapPreviewViewController.h"

typedef enum {
	HONSelfieGridTypeDetails = 0,
	HONSelfieGridTypeOwnProfile,
	HONSelfieGridTypeCohortProfile
} HONSelfieGridType;

@class HONBasicSelfieGridViewController;
@protocol HONSelfieGridViewControllerDelegate <NSObject>
- (void)selfieGridViewController:(HONBasicSelfieGridViewController *)viewController showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)selfieGridViewController:(HONBasicSelfieGridViewController *)viewController showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@optional
- (void)selfieGridViewController:(HONBasicSelfieGridViewController *)viewController removeParticipantSelfie:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)selfieGridViewController:(HONBasicSelfieGridViewController *)viewController showDetailsForChallenge:(HONChallengeVO *)challengeVO;
@end


@interface HONBasicSelfieGridViewController : UIViewController <UIAlertViewDelegate> {
	HONSelfieGridType _selfieGridType;
	HONOpponentVO *_heroOpponentVO;
	HONSnapPreviewViewController *_snapPreviewViewController;
	
	UIScrollView *_scrollView;
	NSMutableArray *_challenges;
	NSMutableArray *_gridItems;
	NSMutableArray *_gridViews;
	int _itemCounter;
	CGFloat _yPos;
	
	HONOpponentVO *_selectedOpponentVO;
	HONChallengeVO *_selectedChallengeVO;
	
	UIView *_holderView;
	UIButton *_previewButton;
	
	UILongPressGestureRecognizer *_lpGestureRecognizer;
}

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO;
- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO;

- (void)buildGrid;
- (void)refreshGrid;
- (void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer;
- (UIView *)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO;

@property (nonatomic, assign) id<HONSelfieGridViewControllerDelegate> delegate;

@end
