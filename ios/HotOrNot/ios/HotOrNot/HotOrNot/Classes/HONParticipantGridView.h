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
@interface HONParticipantGridView : UIView
- (id)initWithFrame:(CGRect)frame forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO;
- (id)initWithFrame:(CGRect)frame forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO;

@property (nonatomic, assign) id <HONParticipantGridViewDelegate> delegate;
@end

@protocol HONParticipantGridViewDelegate
- (void)participantGridView:(HONParticipantGridView *)participantGridView showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
- (void)participantGridView:(HONParticipantGridView *)participantGridView showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO;
@end
