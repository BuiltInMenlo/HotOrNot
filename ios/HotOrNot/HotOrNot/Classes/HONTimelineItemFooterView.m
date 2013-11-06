//
//  HONTimelineItemFooterView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 5:36 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemFooterView.h"
#import "HONEmotionVO.h"


@interface HONTimelineItemFooterView ()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UIButton *likesButton;
@property (nonatomic, strong) UILabel *likesLabel;
@end

@implementation HONTimelineItemFooterView
@synthesize delegate = _delegate;

- (id)initAtPosY:(CGFloat)yPos withChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, 84.0)])) {
		_challengeVO = challengeVO;
		
		_likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likesButton.frame = CGRectMake(6.0, 5.0 - ((int)([self _calcScore] == 0)), 24.0, 24.0);
		[_likesButton setBackgroundImage:[UIImage imageNamed:([self _calcScore] > 0) ? @"heartLike_Icon" : @"heartDefault_Icon"] forState:UIControlStateNormal];
		[_likesButton setBackgroundImage:[UIImage imageNamed:([self _calcScore] > 0) ? @"heartLike_Icon" : @"heartDefault_Icon"] forState:UIControlStateHighlighted];
		[self addSubview:_likesButton];
		
		_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 10.0, 270.0, 14.0)];
		_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:11];
		_likesLabel.textColor = ([self _calcScore] == 0) ? [HONAppDelegate honGreyTextColor] : [HONAppDelegate honDarkGreyTextColor];
		_likesLabel.backgroundColor = [UIColor clearColor];
		_likesLabel.text = _challengeVO.recentLikes;
		[self addSubview:_likesLabel];
		
		
		CGFloat offset;
		NSArray *participants;
		UIView *participantsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 33.0, 320.0, 53.0)];
		[self addSubview:participantsView];
		
		if ([_challengeVO.challengers count] >= 2) {
			participants = [NSArray arrayWithObjects:(HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0], (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:1], nil];
			offset = 64.0;
		
		} else if ([_challengeVO.challengers count] == 1) {
			participants = [NSArray arrayWithObjects:(HONOpponentVO *)[_challengeVO.challengers firstObject], nil];
			offset = 40.0;
		
		} else {
			participants = [NSArray array];
			offset = 44.0;
		}
		
		if ([_challengeVO.challengers count] > 0) {
			UIView *avatarsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 51.0)];
			avatarsHolderView.clipsToBounds = YES;
			[participantsView addSubview:avatarsHolderView];
			
			int idx = 0;
			for (HONOpponentVO *vo in participants) {
				UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0 + (idx * 35.0), 10.0, 30.0, 30.0)];
				[avatarImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", vo.imagePrefix, kSnapThumbSuffix]] placeholderImage:nil];
				avatarImageView.userInteractionEnabled = YES;
				[avatarsHolderView addSubview:avatarImageView];
				
//				UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//				avatarButton.frame = CGRectMake(0.0, 0.0, avatarImageView.frame.size.width, avatarImageView.frame.size.height);
//				[avatarButton addTarget:self action:@selector(_goProfileForParticipant:) forControlEvents:UIControlEventTouchUpInside];
//				[avatarsHolderView addSubview:avatarButton];
//				[avatarButton setTag:idx];
				
				idx++;
			}
		
		} else {
			UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
			avatarImageView.image = [UIImage imageNamed:@"noReply"];
			[participantsView addSubview:avatarImageView];
		}
		
		UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + offset, 7.0 + (((int)([_challengeVO.challengers count] == 0)) * 10), 257.0 - offset, 15.0)];
		participantsLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:11];
		participantsLabel.textColor = [UIColor colorWithWhite:0.710 alpha:1.0];
		participantsLabel.backgroundColor = [UIColor clearColor];
		participantsLabel.text = [self _captionForParticipants];
		[participantsView addSubview:participantsLabel];
		
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + offset, 24.0, 257.0 - offset, 18.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
		subjectLabel.text = ((HONOpponentVO *)[_challengeVO.challengers firstObject]).subjectName;
		[participantsView addSubview:subjectLabel];
		
		CGSize size = [subjectLabel.text boundingRectWithSize:CGSizeMake(257.0 - offset, 18.0)
												   options:NSStringDrawingTruncatesLastVisibleLine
												attributes:@{NSFontAttributeName:subjectLabel.font}
												   context:nil].size;
		subjectLabel.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y, size.width, size.height);
		
		HONEmotionVO *emotionVO = [self _participantEmotionVO];
		if (emotionVO != nil) {
			offset += 6.0;
			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0 + offset + size.width, 23.0, 18.0, 18.0)];
//			emoticonImageView.image = [UIImage imageNamed:@"emoticon_blue"];
			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.urlSmallBlue] placeholderImage:nil];
			[participantsView addSubview:emoticonImageView];
		}

		
		UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		detailsButton.frame = CGRectMake(0.0, 0.0, participantsView.frame.size.width, participantsView.frame.size.height);
		[detailsButton addTarget:self action:([_challengeVO.challengers count] == 0) ? @selector(_goJoinChallenge) : @selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
		[participantsView addSubview:detailsButton];

		
		UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
		joinButton.frame = CGRectMake(257.0, 5.0, 64.0, 44.0);
		[joinButton setBackgroundImage:[UIImage imageNamed:@"replyButton_nonActive"] forState:UIControlStateNormal];
		[joinButton setBackgroundImage:[UIImage imageNamed:@"replyButton_Active"] forState:UIControlStateHighlighted];
		[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
		[participantsView addSubview:joinButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)upvoteUser:(int)userID onChallenge:(HONChallengeVO *)challengeVO; {
	_challengeVO = challengeVO;
	
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
	
	_likesLabel.text = _challengeVO.recentLikes;
	[_likesButton setBackgroundImage:[UIImage imageNamed:([self _calcScore] > 0) ? @"heartLike_Icon" : @"heartDefault_Icon"] forState:UIControlStateNormal];
	[_likesButton setBackgroundImage:[UIImage imageNamed:([self _calcScore] > 0) ? @"heartLike_Icon" : @"heartDefault_Icon"] forState:UIControlStateHighlighted];
}


#pragma mark - Navigation
- (void)_goDetails {
	[self.delegate footerView:self showDetailsForChallenge:_challengeVO];
}

- (void)_goJoinChallenge {
	[self.delegate footerView:self joinChallenge:_challengeVO];
}

- (void)_goProfileForParticipant:(id)sender {
	int index = [sender tag];
	
	HONOpponentVO *vo = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index];
	[self.delegate footerView:self showProfileForParticipant:vo forChallenge:_challengeVO];
}


#pragma mark - Data Tally
- (int)_calcScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	return (score);
}

- (HONEmotionVO *)_participantEmotionVO {
	HONEmotionVO *emotionVO;
	
	if ([_challengeVO.challengers count] > 0) {
		for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
			if ([vo.hastagName isEqualToString:((HONOpponentVO *)[_challengeVO.challengers firstObject]).subjectName]) {
				emotionVO = vo;
				break;
			}
		}
		
		return (emotionVO);
	}
	
	return (nil);
}

- (NSString *)_captionForParticipants {
	if ([_challengeVO.challengers count] == 0)
		return (@"Be the first to reply");
	
	
	NSString *caption = @"";
	HONOpponentVO *vo = (HONOpponentVO *)[_challengeVO.challengers firstObject];
	if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
		caption = @"You";
	
	else
		caption = vo.username;
	
	
	return ([NSString stringWithFormat:@"%@ replied… %d total", caption, [_challengeVO.challengers count]]);
}

@end
