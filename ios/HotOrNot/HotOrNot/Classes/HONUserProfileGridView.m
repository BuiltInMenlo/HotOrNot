//
//  HONProfileGridView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 8:49 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONUserProfileGridView.h"


@interface HONUserProfileGridView ()
@end

@implementation HONUserProfileGridView

- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initAtPos:yPos forChallenges:challenges asPrimaryOpponent:opponentVO])) {
		NSLog(@"[%@]", [[self class] description]);
		[self layoutGrid];
	}
	
	return (self);
}


- (void)layoutGrid {
	_gridItems = [NSMutableArray array];
	
	for (HONChallengeVO *vo in _challenges) {
		if (_heroOpponentVO.userID == vo.creatorVO.userID) {
			[_gridItems addObject:@{@"challenge"	: vo,
									@"participant"	: vo.creatorVO}];
		}
		
		for (HONOpponentVO *challenger in vo.challengers)
			if (_heroOpponentVO.userID == challenger.userID) {
				[_gridItems addObject:@{@"challenge"	: vo,
										@"participant"	: challenger}];
		}
	}
	
	NSLog(@"%@.layoutGrid withTotal[%d]", [[self class] description], [_gridItems count]);
	[super layoutGrid];
}

- (void)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO {
	[super createItemForParticipant:opponentVO fromChallenge:challengeVO];
}


@end
