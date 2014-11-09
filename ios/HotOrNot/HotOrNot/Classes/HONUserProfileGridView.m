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
		_participantGridViewType = (opponentVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? HONParticipantGridViewTypeUsersProfile : HONParticipantGridViewTypeProfile;
		
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
	
	NSLog(@"%@.layoutGrid withTotal[%ld]", [[self class] description], (unsigned long)[_gridItems count]);
	[super layoutGrid];
	
//	[_lpGestureRecognizer removeTarget:self action:@selector(goLongPress:)];
//	[self removeGestureRecognizer:_lpGestureRecognizer];
}

- (void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_holderView];
		NSLog(@"TOUCHPT:[%@]", NSStringFromCGPoint(touchPoint));
		
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
			[self.delegate participantGridView:self showPreview:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
			//[self.delegate participantGridView:self removeParticipantItem:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}

@end
