//
//  HONChallengeOverlayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/16/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeOverlayView.h"

@interface HONChallengeOverlayView()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@end

@implementation HONChallengeOverlayView

- (id)initWithChallenge:(HONChallengeVO *)challengeVO forOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		_challengeVO = challengeVO;
		_opponentVO = opponentVO;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = self.frame;
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
		[self addSubview:closeButton];
		
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 176.0) * 0.5, 320.0, 64.0)];
		[self addSubview:holderView];
		
		UIButton *upvoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		upvoteButton.frame = CGRectMake(0.0, 0.0, 159.0, 64.0);
		[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButtonOverlay_nonActive"] forState:UIControlStateNormal];
		[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButtonOverlay_Active"] forState:UIControlStateHighlighted];
		[upvoteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:upvoteButton];
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(161.0, 0.0, 159.0, 64.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButtonOverlay_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButtonOverlay_Active"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:moreButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goClose {
	[self.delegate challengeOverlayViewClose:self];
}

- (void)_goUpvote {
	[self.delegate challengeOverlayViewUpvote:self opponent:_opponentVO forChallenge:_challengeVO];
}

- (void)_goMore {
	[self.delegate challengeOverlayViewShowMore:self opponent:_opponentVO forChallenge:_challengeVO];
}

@end
