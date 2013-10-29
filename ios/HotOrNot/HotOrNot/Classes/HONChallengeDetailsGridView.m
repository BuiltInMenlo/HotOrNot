//
//  HONChallengeDetailsGridView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 8:48 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONChallengeDetailsGridView.h"


@interface HONChallengeDetailsGridView ()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@property (nonatomic, retain) HONOpponentVO *selectedOpponentVO;
@end

@implementation HONChallengeDetailsGridView

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initAtPos:yPos forChallenge:challengeVO asPrimaryOpponent:opponentVO])) {
		_challengeVO = challengeVO;
		
		[self layoutGrid];
	}
	
	return (self);
}


- (void)layoutGrid {
	_gridItems = [NSMutableArray array];
	
	// go thru each challenge participant, add if user is one of them
	for (HONOpponentVO *challenger in _challengeVO.challengers) {
		if (![challenger.imagePrefix isEqualToString:_heroOpponentVO.imagePrefix]) {
			[_gridItems addObject:@{@"challenge"	: _challengeVO,
									@"participant"	: challenger}];
		}
	}
	
	if (![_heroOpponentVO.imagePrefix isEqualToString:_challengeVO.creatorVO.imagePrefix]) {
		[_gridItems addObject:@{@"challenge"	: _challengeVO,
								@"participant"	: _challengeVO.creatorVO}];
	}
	
	NSLog(@"%@.layoutGrid withTotal[%d]", [[self class] description], [_gridItems count]);
	[super layoutGrid];
}

- (void)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO {
	[super createItemForParticipant:opponentVO fromChallenge:challengeVO];
	
	_profileButton.hidden = NO;
	[_profileButton addTarget:self action:@selector(_goProfile:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Navigation
- (void)_goProfile:(id)sender {
	_selectedOpponentVO = nil;
	for (NSDictionary *dict in _gridItems) {
		HONOpponentVO *vo = (HONOpponentVO *)[dict objectForKey:@"participant"];
		if (vo.userID == [sender tag]) {
			_selectedOpponentVO = vo;
			break;
		}
	}
	
	if (_selectedOpponentVO != nil)
		[self.delegate participantGridView:self showProfile:_selectedOpponentVO forChallenge:_challengeVO];
}
@end
