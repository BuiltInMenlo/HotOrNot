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
@property (nonatomic, strong) UILabel *likesLabel;
@end

@implementation HONTimelineItemFooterView
@synthesize delegate = _delegate;

- (id)initAtPosY:(CGFloat)yPos withChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, 40.0)])) {
		_challengeVO = challengeVO;
//		self.backgroundColor = [HONAppDelegate honDebugColorByName:@"fuschia" atOpacity:0.5];
		
		CGFloat offset;
		NSArray *participants;
		
		if ([_challengeVO.challengers count] >= 2) {
			participants = [NSArray arrayWithObjects:(HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0], (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:1], nil];
			offset = 60.0;
		
		} else if ([_challengeVO.challengers count] == 1) {
			participants = [NSArray arrayWithObjects:(HONOpponentVO *)[_challengeVO.challengers firstObject], nil];
			offset = 40.0;
		
		} else {
			participants = [NSArray array];
			offset = 40.0;
		}
		
		UIView *avatarsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 5.0, 55.0, 51.0)];
		avatarsHolderView.clipsToBounds = YES;
		[self addSubview:avatarsHolderView];
		
		if ([_challengeVO.challengers count] > 0) {
			int idx = 0;
			for (HONOpponentVO *vo in participants) {
				UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0 + (idx * 35.0), 0.0, 30.0, 30.0)];
				[avatarImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", vo.imagePrefix, kSnapThumbSuffix]] placeholderImage:nil];
				avatarImageView.userInteractionEnabled = YES;
				[avatarsHolderView addSubview:avatarImageView];
				
				UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				avatarButton.frame = avatarImageView.frame;
				[avatarButton addTarget:self action:@selector(_goProfileForParticipant:) forControlEvents:UIControlEventTouchUpInside];
				[avatarsHolderView addSubview:avatarButton];
				[avatarButton setTag:idx];
				
				idx++;
			}
		
		} else {
			UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 0.0, 30.0, 30.0)];
			avatarImageView.image = [UIImage imageNamed:@"noReply"];
			[avatarsHolderView addSubview:avatarImageView];
		}
		
		UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + offset, 3.0, 257.0 - offset, 19.0)];
		participantsLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		participantsLabel.textColor = [UIColor whiteColor];
		participantsLabel.backgroundColor = [UIColor clearColor];
		participantsLabel.text = [self _captionForParticipants];
		[self addSubview:participantsLabel];
		
		_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + offset, 19.0, 270.0, 19.0)];
		_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		_likesLabel.textColor = [UIColor whiteColor];//([self _calcScore] == 0) ? [HONAppDelegate honLightGreyTextColor] : [UIColor whiteColor];
		_likesLabel.backgroundColor = [UIColor clearColor];
		_likesLabel.text = [self _captionForScore];
		[self addSubview:_likesLabel];
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
	
	_challengeVO.likesTotal++;
	_likesLabel.text = [self _captionForScore];
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
	
	HONOpponentVO *vo;
	NSString *caption = @"";
	
	vo = (HONOpponentVO *)[_challengeVO.challengers firstObject];
	caption = (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"You" : vo.username;
	
	return ([NSString stringWithFormat:@"%@ replied… %d total", caption, [_challengeVO.challengers count]]);
}

- (NSString *)_captionForScore {
	int score = [self _calcScore];
		
	if (score == 0)
		return (@"Be the first to like");
	
	else if (score > 99)
		return (@"99+ Likes");
	
	else
		return ([NSString stringWithFormat:@"%d Like%@", score, (score != 1) ? @"s" : @""]);
}

@end
