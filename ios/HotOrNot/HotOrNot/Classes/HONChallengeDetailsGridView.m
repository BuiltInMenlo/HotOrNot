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
@end

@implementation HONChallengeDetailsGridView

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initAtPos:yPos forChallenge:challengeVO asPrimaryOpponent:opponentVO])) {
		_participantGridViewType = HONParticipantGridViewTypeDetails;
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
	
	NSLog(@"%@.layoutGrid withTotal[%ld]", [[self class] description], (unsigned long)[_gridItems count]);
	[super layoutGrid];
}

- (void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_holderView];
//		NSLog(@"TOUCHPT:[%@]", NSStringFromCGPoint(touchPoint));
		
		NSDictionary *dict = [NSDictionary dictionary];
		if (CGRectContainsPoint(_holderView.frame, touchPoint)) {
			int row = ((int)(touchPoint.y - _holderView.frame.origin.y) / (kSnapThumbSize.height + 1.0));
			int col = ((int)touchPoint.x / (kSnapThumbSize.width + 1.0));
			int idx = (row * 4) + col;
			
			NSLog(@"COORDS FOR CELL:[%d] -> (%d, %d)", idx, col, row);
			dict = (idx < [_gridItems count]) ? [_gridItems objectAtIndex:idx] : nil;
			
			_selectedChallengeVO = [dict objectForKey:@"challenge"];
			_selectedOpponentVO = [dict objectForKey:@"participant"];
		}
		
		if (dict != nil)
			[self.delegate participantGridView:self showProfile:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}

@end
