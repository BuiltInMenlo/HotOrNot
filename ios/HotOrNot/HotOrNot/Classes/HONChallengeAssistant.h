//
//  HONChallengeAssistant.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:27.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HONChallengeVO.h"
#import "HONEmotionVO.h"
#import "HONOpponentVO.h"

@interface HONChallengeAssistant : NSObject
+ (HONChallengeAssistant *)sharedInstance;


- (BOOL)isChallengeParticipant:(HONChallengeVO *)challengeVO;
- (HONOpponentVO *)mostRecentOpponentInChallenge:(HONChallengeVO *)challengeVO byUserID:(int)userID;
- (HONEmotionVO *)mostRecentEmotionForOpponent:(HONOpponentVO *)opponentVO;

- (int)hasVoted:(int)challengeID;
- (void)setVoteForChallenge:(HONChallengeVO *)challengeVO forParticipant:(HONOpponentVO *)opponentVO;

- (NSDictionary *)emptyChallengeDictionaryWithID:(int)challengeID;
@end
