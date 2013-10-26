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


@protocol HONBasicParticipantGridViewDelegate;
@interface HONBasicParticipantGridView : UIView {
//	NSMutableArray *challenges;
//	
//	HONChallengeVO *challengeVO;
//	HONOpponentVO *primaryOpponentVO;
//	HONOpponentVO *selectedOpponentVO;
	
	UIButton *_profileButton;
	
}



- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO;
- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO;

- (void)layoutGrid;
- (void)createItemForParticipant:(HONOpponentVO *)opponentVO;

@property (nonatomic, assign) id <HONBasicParticipantGridViewDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *challenges;
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@property (nonatomic, retain) HONOpponentVO *primaryOpponentVO;
@property (nonatomic, retain) HONOpponentVO *selectedOpponentVO;
@property (nonatomic, retain) NSMutableArray *gridOpponents;
@end

@protocol HONBasicParticipantGridViewDelegate
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)participantGridViewPreviewShowControls:(HONBasicParticipantGridView *)participantGridView;
@optional
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@end
