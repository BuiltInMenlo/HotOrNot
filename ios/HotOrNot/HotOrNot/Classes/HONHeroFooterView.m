//
//  HONHeroFooterView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 7:29 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONHeroFooterView.h"
#import "HONEmotionVO.h"


@interface HONHeroFooterView ()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) UILabel *likesLabel;
@end

@implementation HONHeroFooterView
@synthesize delegate = _delegate;

- (id)initAtYPos:(int)yPos withChallenge:(HONChallengeVO *)challengeVO andHeroOpponent:(HONOpponentVO *)heroOpponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, 94.0)])) {
		_challengeVO = challengeVO;
		_opponentVO = heroOpponentVO;
		
		float offset = 0.0;
		NSString *concatSubjects = @"";
		
		for (HONEmotionVO *emotionVO in [self _challengeEmotions]) {
			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0 + offset, 0.0, 43.0, 43.0)];
			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
			[self addSubview:emoticonImageView];
			
			concatSubjects = [NSString stringWithFormat:@"%@ : %@", concatSubjects, emotionVO.hastagName];
			offset += 35.0;
		}
		
		if ([concatSubjects length] == 1 + [_challengeVO.challengers count])
			concatSubjects = [NSString stringWithFormat:@"%@ : %@", _challengeVO.subjectName, _opponentVO.subjectName];
		
		
		UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 39.0, 250.0, 22.0)];
		participantsLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:18];
		participantsLabel.textColor = [UIColor whiteColor];
		participantsLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		participantsLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		participantsLabel.backgroundColor = [UIColor clearColor];
		participantsLabel.text = [self _participantCaption];
		[self addSubview:participantsLabel];
		
		CGSize participantsSize = [participantsLabel.text boundingRectWithSize:CGSizeMake(250.0, 44.0)
																	   options:NSStringDrawingTruncatesLastVisibleLine
																	attributes:@{NSFontAttributeName:participantsLabel.font}
																	   context:nil].size;
		
		participantsLabel.frame = CGRectMake(participantsLabel.frame.origin.x, participantsLabel.frame.origin.y, participantsSize.width, participantsSize.height);
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 61.0, 250.0, 24.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		subjectLabel.shadowOffset =  CGSizeMake(1.0, 1.0);
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = ([concatSubjects length] >= 3) ? [concatSubjects substringFromIndex:3] : concatSubjects;
		[self addSubview:subjectLabel];
		
		CGSize subjectSize = [subjectLabel.text boundingRectWithSize:CGSizeMake(250.0, 44.0)
															 options:NSStringDrawingTruncatesLastVisibleLine
														  attributes:@{NSFontAttributeName:subjectLabel.font}
															 context:nil].size;
		
		subjectLabel.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y, subjectSize.width, subjectSize.height);
		
		UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = CGRectMake(9.0, 36.0, MAX(participantsSize.width, subjectSize.width), self.frame.size.height);
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:profileButton];
		
		UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likesButton.frame = CGRectMake(290.0, 60.0, 24.0, 24.0);
		[likesButton setBackgroundImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateNormal];
		[likesButton setBackgroundImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateHighlighted];
		[self addSubview:likesButton];
		
		_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(245.0, 64.0, 40.0, 16.0)];
		_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_likesLabel.textColor = [UIColor whiteColor];
		_likesLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		_likesLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_likesLabel.backgroundColor = [UIColor clearColor];
		_likesLabel.textAlignment = NSTextAlignmentRight;
		_likesLabel.text = ([self _calcScore] > 99) ? @"99+" : [NSString stringWithFormat:@"%d", [self _calcScore]];
		[self addSubview:_likesLabel];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)updateLikesCaption:(NSString *)caption {
	_likesLabel.text = caption;
}

#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate heroFooterView:self showProfile:_opponentVO];
}


#pragma mark - Data Tally
- (NSString *)_participantCaption {
	NSMutableArray *opponentIDs = [NSMutableArray array];
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([vo.imagePrefix length] > 0) {
			BOOL isFound = NO;
			for (NSNumber *userID in opponentIDs) {
				if ([userID intValue] == vo.userID) {
					isFound = YES;
					break;
				}
			}
			
			if (!isFound)
				[opponentIDs addObject:[NSNumber numberWithInt:vo.userID]];
		}
	}
	
	BOOL _isChallengeOpponent = NO;
	BOOL _isChallengeCreator = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorVO.userID);
	
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.userID) {
			_isChallengeOpponent = YES;
			break;
		}
	}
	
	NSString *participants = _challengeVO.creatorVO.username;
	int uniqueOpponents = ([opponentIDs count] - (int)_isChallengeOpponent) - 1;
	if ((_isChallengeCreator && _isChallengeOpponent) || (!_isChallengeCreator && !_isChallengeOpponent)) {
		if (_challengeVO.creatorVO.userID == _opponentVO.userID)
			participants = (uniqueOpponents > 0) ? [NSString stringWithFormat:@"%@ and %d other%@", _opponentVO.username, uniqueOpponents, (uniqueOpponents == 1) ? @"" : @"s"] : _challengeVO.creatorVO.username;
		
		else
			participants = (uniqueOpponents > 1) ? [NSString stringWithFormat:@"%@, %@ and %d other%@", _opponentVO.username, _challengeVO.creatorVO.username, uniqueOpponents, (uniqueOpponents == 1) ? @"" : @"s"] : _challengeVO.creatorVO.username;
	}
	
	if (!_isChallengeCreator && _isChallengeOpponent)
		participants = (uniqueOpponents > 0) ? [NSString stringWithFormat:@"%@, you and %d other%@", _opponentVO.username, uniqueOpponents, (uniqueOpponents == 1) ? @"" : @"s"] : [NSString stringWithFormat:@"%@ and %@", _opponentVO.username, _challengeVO.creatorVO.username];
	
	if ([_challengeVO.challengers count] == 0)
		participants = _challengeVO.creatorVO.username;
	
	return (participants);
}

- (NSArray *)_challengeEmotions {
	NSMutableArray *foundEmotions = [NSMutableArray array];
	
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
//		NSLog(@"COMPOSE EMOTION:[%@]>—<[%@]", vo.hastagName, _opponentVO.subjectName);
		if ([vo.hastagName isEqualToString:_challengeVO.creatorVO.subjectName]) {
			[foundEmotions addObject:vo];
			break;
		}
	}
	
	NSLog(@"FOUND CREATOR EMOTION:[%@]", ([foundEmotions count] > 0) ? ((HONEmotionVO *)[foundEmotions objectAtIndex:0]).hastagName : @"");
	
//	BOOL isHeroCreator = ([_challengeVO.challengers count] == 0);
	
	if ([_challengeVO.challengers count] > 0) {
//		HONOpponentVO *participantVO = ((HONOpponentVO *)[_challengeVO.challengers lastObject]);//([((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:1]).imagePrefix isEqualToString:_opponentVO.imagePrefix]) ? _challengeVO.creatorVO : _opponentVO;
		//NSLog(@"TEST:[%@]", participantVO.dictionary);
		
		for (HONEmotionVO *vo in [HONAppDelegate replyEmotions]) {
//			NSLog(@"REPLY EMOTION:[%@]>—<[%@]", vo.hastagName, ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).subjectName);
			if ([vo.hastagName isEqualToString:_opponentVO.subjectName])
				[foundEmotions addObject:vo];
			
			if ([foundEmotions count] > 2)
				break;
		}
	}
	
	return([foundEmotions copy]);
}

- (int)_calcScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	return (score);
}


@end
