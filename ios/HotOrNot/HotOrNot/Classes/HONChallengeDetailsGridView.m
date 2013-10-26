//
//  HONChallengeDetailsGridView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 8:48 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONChallengeDetailsGridView.h"


@interface HONChallengeDetailsGridView ()
//- (void)layoutGrid;
@end

@implementation HONChallengeDetailsGridView

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initAtPos:yPos forChallenge:challengeVO asPrimaryOpponent:opponentVO])) {
		NSLog(@"[%@]", [[self class] description]);
		[self layoutGrid];
	}
	
	return (self);
}


- (void)layoutGrid {
	self.gridOpponents = [NSMutableArray array];
	
	// go thru each challenge participant, add if user is one of them
	for (HONOpponentVO *challenger in self.challengeVO.challengers) {
		if (![self.primaryOpponentVO.imagePrefix isEqualToString:challenger.imagePrefix]) {
//			NSMutableArray *dataArray = [NSMutableArray new];
//			[dataArray addObject:challenger];
//			[dataArray addObject:vo];
			[self.gridOpponents addObject:challenger];
		}
	}
	
	NSLog(@"layoutGrid (SUB) [%d]-> [%d]", [self.challenges count], [self.gridOpponents count]);
	[super layoutGrid];
}

- (void)createItemForParticipant:(HONOpponentVO *)opponentVO {
	[super createItemForParticipant:opponentVO];
	
	_profileButton.hidden = NO;
	[_profileButton addTarget:self action:@selector(_goProfile:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Navigation
- (void)_goProfile:(id)sender {
	self.selectedOpponentVO = nil;
	for (HONOpponentVO *vo in self.gridOpponents) {
		if (vo.userID == [sender tag]) {
			self.selectedOpponentVO = vo;
			break;
		}
	}
	
	if (self.selectedOpponentVO != nil)
		[self.delegate participantGridView:self showProfile:self.selectedOpponentVO forChallenge:self.challengeVO];
}
@end
