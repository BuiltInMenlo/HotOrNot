//
//  HONParticipantGridView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 8:40 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONParticipantGridView.h"


@interface HONParticipantGridView (Protected)
- (void)goPreview;
- (void)goProfile;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) NSMutableArray *opponents;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) HONOpponentVO *primaryOpponentVO;
@property (nonatomic, strong) HONOpponentVO *selectedOpponentVO;
@end

@implementation HONParticipantGridView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:frame])) {
		self.primaryOpponentVO = opponentVO;
		
		self.challenges = [NSMutableArray arrayWithCapacity:0];
		self.challengeVO = challengeVO;
		
		self.opponents = [NSMutableArray arrayWithObject:self.challengeVO.creatorVO];
		for (HONOpponentVO *vo in self.challengeVO.challengers)
			[self.opponents addObject:vo];
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:frame])) {
		self.primaryOpponentVO = opponentVO;
		self.challenges = [challenges mutableCopy];
		self.challengeVO = nil;
		
		self.opponents = [NSMutableArray arrayWithCapacity:[self.challenges count]];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goPreview {
	[self.delegate participantGridView:self showPreview:self.selectedOpponentVO forChallenge:self.challengeVO];
}

- (void)_goProfile {
	[self.delegate participantGridView:self showProfile:self.selectedOpponentVO forChallenge:self.challengeVO];
}


#pragma mark - UI Presentation
- (void)layoutGrid {
	
}

- (void)createGridItemForParticipant:(HONOpponentVO *)opponentVO {
	
}


#pragma mark - Data Tally



@end
