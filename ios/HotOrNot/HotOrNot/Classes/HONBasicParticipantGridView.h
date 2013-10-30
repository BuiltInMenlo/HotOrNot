//
//  HONParticipantGridView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 8:40 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"


@protocol HONParticipantGridViewDelegate;
@interface HONBasicParticipantGridView : UIView {
	HONOpponentVO *_heroOpponentVO;
	NSMutableArray *_challenges;
	NSMutableArray *_gridItems;
	
	HONOpponentVO *_selectedOpponentVO;
	HONChallengeVO *_selectedChallengeVO;
	
	UIButton *_previewButton;
}

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO;
- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO;

- (void)layoutGrid;
- (void)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO;

@property (nonatomic, assign) id <HONParticipantGridViewDelegate> delegate;
@end


@protocol HONParticipantGridViewDelegate
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@optional
@end
