//
//  HONParticipantGridView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 8:40 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


typedef enum {
	HONParticipantGridViewTypeDetails = 0,
	HONParticipantGridViewTypeProfile,
	HONParticipantGridViewTypeUsersProfile
} HONParticipantGridViewType;


@class HONBasicParticipantGridView;
@protocol HONParticipantGridViewDelegate <NSObject>
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;

@optional
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView removeParticipantItem:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showDetailsForChallenge:(HONChallengeVO *)challengeVO;
@end

@interface HONBasicParticipantGridView : UIView {
	HONParticipantGridViewType _participantGridViewType;
	HONOpponentVO *_heroOpponentVO;
	NSMutableArray *_challenges;
	NSMutableArray *_gridItems;
	NSMutableArray *_gridViews;
	
	HONOpponentVO *_selectedOpponentVO;
	HONChallengeVO *_selectedChallengeVO;
	
	UIView *_holderView;
	UIButton *_previewButton;
	
	UILongPressGestureRecognizer *_lpGestureRecognizer;
}

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO;
- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO;

- (void)layoutGrid;
- (void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer;
- (UIView *)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO;

@property (nonatomic, assign) id <HONParticipantGridViewDelegate> delegate;
@end
