//
//  HONTimelineCellFooterView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 5:36 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONTimelineCellFooterView.h"
#import "HONEmotionVO.h"


@interface HONTimelineCellFooterView ()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UIButton *likesButton;
@property (nonatomic, strong) UILabel *likesLabel;
@end

@implementation HONTimelineCellFooterView
@synthesize delegate = _delegate;

- (id)initAtPosY:(CGFloat)yPos withChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, 84.0)])) {
		_challengeVO = challengeVO;
		
		_likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likesButton.frame = CGRectMake(7.0, 0.0, 24.0, 24.0);
		[_likesButton setBackgroundImage:[UIImage imageNamed:([self _calcScore] > 0) ? @"heartLike_Icon" : @"heartDefault_Icon"] forState:UIControlStateNormal];
		[_likesButton setBackgroundImage:[UIImage imageNamed:([self _calcScore] > 0) ? @"heartLike_Icon" : @"heartDefault_Icon"] forState:UIControlStateHighlighted];
		[self addSubview:_likesButton];
		
		_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0, 4.0, 250.0, 16.0)];
		_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		_likesLabel.textColor = ([self _calcScore] == 0) ? [HONAppDelegate honGreyTextColor] : [HONAppDelegate honDarkGreyTextColor];
		_likesLabel.backgroundColor = [UIColor whiteColor];
		_likesLabel.text = [self _captionForScore];
		[self addSubview:_likesLabel];
		
		
		UIView *participantsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 33.0, 320.0, 53.0)];
		[self addSubview:participantsView];
		
		CGFloat offset;
		NSArray *participants;
		
		if ([_challengeVO.challengers count] >= 2) {
			participants = [NSArray arrayWithObjects:(HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0], (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:1], nil];
			offset = 64.0;
		
		} else {
			participants = [NSArray arrayWithObjects:(HONOpponentVO *)[_challengeVO.challengers firstObject], nil];
			offset = 40.0;
		}
		
		if ([_challengeVO.challengers count] > 0) {
			UIView *avatarsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 51.0)];
			avatarsHolderView.clipsToBounds = YES;
			[participantsView addSubview:avatarsHolderView];
			
			int idx = 0;
			for (HONOpponentVO *vo in participants) {
				UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0 + (idx * 35.0), 10.0, 30.0, 30.0)];
				[avatarImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Small_160x160.jpg", vo.imagePrefix]] placeholderImage:nil];
				avatarImageView.userInteractionEnabled = YES;
				[avatarsHolderView addSubview:avatarImageView];
				
				UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				avatarButton.frame = CGRectMake(0.0, 0.0, avatarImageView.frame.size.width, avatarImageView.frame.size.height);
				[avatarButton addTarget:self action:@selector(_goProfileForParticipant:) forControlEvents:UIControlEventTouchUpInside];
				[avatarsHolderView addSubview:avatarButton];
				[avatarButton setTag:idx];
				
				idx++;
			}
		
		} else {
			UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
			avatarImageView.image = [UIImage imageNamed:@"noReply"];
			[participantsView addSubview:avatarImageView];
		}
		
		UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + offset, 5.0, 257.0 - offset, 16.0)];
		participantsLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:12];
		participantsLabel.textColor = [UIColor colorWithWhite:0.710 alpha:1.0];
		participantsLabel.backgroundColor = [UIColor clearColor];
		participantsLabel.text = [self _captionForParticipants];
		[participantsView addSubview:participantsLabel];
		
		HONEmotionVO *emotionVO = [self _participantEmotionVO];
		if (emotionVO != nil && [_challengeVO.challengers count] > 0) {
			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0 + (offset - 4.0), 18.0, 30.0, 30.0)];
			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
			[participantsView addSubview:emoticonImageView];
		}
		
		offset += ((int)(emotionVO != nil) * 27.0);
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + offset, 22.0, 257.0 - offset, 22.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
		subjectLabel.text = ((HONOpponentVO *)[_challengeVO.challengers lastObject]).subjectName; //firstObject
		[participantsView addSubview:subjectLabel];
		
		UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
		joinButton.frame = CGRectMake(255.0, 0.0, 64.0, 44.0);
		[joinButton setBackgroundImage:[UIImage imageNamed:@"replyButton_nonActive"] forState:UIControlStateNormal];
		[joinButton setBackgroundImage:[UIImage imageNamed:@"replyButton_Active"] forState:UIControlStateHighlighted];
		[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
		[participantsView addSubview:joinButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)upvoteUser:(int)userID {
	if (_challengeVO.creatorVO.userID == userID)
		_challengeVO.creatorVO.score++;
	
	else {
		int index = -1;
		int counter = 0;
		for (HONOpponentVO *vo in _challengeVO.challengers) {
			if (vo.userID == userID) {
				index = counter;
				break;
			}
			
			counter++;
		}
		
		if (index > -1)
			((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index]).score++;
	}
	
	_likesLabel.text = [self _captionForScore];
	[_likesButton setBackgroundImage:[UIImage imageNamed:([self _calcScore] > 0) ? @"heartLike_Icon" : @"heartDefault_Icon"] forState:UIControlStateNormal];
	[_likesButton setBackgroundImage:[UIImage imageNamed:([self _calcScore] > 0) ? @"heartLike_Icon" : @"heartDefault_Icon"] forState:UIControlStateHighlighted];
}


#pragma mark - Navigation
- (void)_goDetails {
	[self.delegate cellFooterView:self showDetailsForChallenge:_challengeVO];
}

- (void)_goJoinChallenge {
	[self.delegate cellFooterView:self joinChallenge:_challengeVO];
}

- (void)_goProfileForParticipant:(id)sender {
	int index = [sender tag];
	
	HONOpponentVO *vo = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index];
	[self.delegate cellFooterView:self showProfileForParticipant:vo forChallenge:_challengeVO];
}


#pragma mark - Data Tally
- (int)_calcScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	return (score);
}

- (NSString *)_captionForScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	
	if (score == 0)
		return (@"Be the first to like");
	
	else
		return ([NSString stringWithFormat:@"%d", score]);
}

- (HONEmotionVO *)_participantEmotionVO {
	HONEmotionVO *emotionVO;
	
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
		if ([vo.hastagName isEqualToString:_challengeVO.subjectName]) {
			emotionVO = vo;
			break;
		}
	}
	
	return (emotionVO);
}

- (NSString *)_captionForParticipants {
	NSString *caption = @"";
	
	if ([_challengeVO.challengers count] == 0)
		return (@"Be the first to reply.");
	
	HONOpponentVO *vo = ([_challengeVO.challengers count] == 1) ? (HONOpponentVO *)[_challengeVO.challengers firstObject] : (HONOpponentVO *)[_challengeVO.challengers lastObject];
	if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
		caption = @"You";
	
	else
		caption = vo.username;
	
	
	return ([NSString stringWithFormat:@"%@ replied… %d total", caption, [_challengeVO.challengers count]]);
}

@end