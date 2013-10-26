//
//  HONProfileGridView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 8:49 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONUserProfileGridView.h"


@interface HONUserProfileGridView ()
//- (void)layoutGrid;
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
	self.gridOpponents = [NSMutableArray array];
	
	// go thru all challenges if user is creator, add
	for (HONChallengeVO *vo in self.challenges) {
		if (self.primaryOpponentVO.userID == vo.creatorVO.userID) {
			[self.gridOpponents addObject:vo.creatorVO];
//			NSMutableArray *dataArray = [NSMutableArray array];
//			[dataArray addObject:vo.creatorVO];
//			[dataArray addObject:vo];
//			[_gridOpponents addObject:dataArray];
		}
		
		// go thru each challenge participant, add if user is one of them
		for (HONOpponentVO *challenger in vo.challengers) {
			if (self.primaryOpponentVO.userID == challenger.userID) {
				[self.gridOpponents addObject:challenger];
//				NSMutableArray *dataArray = [NSMutableArray new];
//				[dataArray addObject:challenger];
//				[dataArray addObject:vo];
//				[_gridOpponents addObject:dataArray];
			}
		}
	}
	
	NSLog(@"layoutGrid (SUB) [%d]-> [%d]", [self.challenges count], [self.gridOpponents count]);
	[super layoutGrid];
}


#pragma mark - Navigation

@end
