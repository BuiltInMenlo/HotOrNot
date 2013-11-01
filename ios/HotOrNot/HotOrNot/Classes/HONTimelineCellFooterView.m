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
@end

@implementation HONTimelineCellFooterView
@synthesize delegate = _delegate;

- (id)initAtPosY:(CGFloat)yPos withChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, 55.0)])) {
		_challengeVO = challengeVO;
		
		CGFloat offset;
		NSArray *participants;
		
		if ([_challengeVO.challengers count] >= 2) {
			participants = [NSArray arrayWithObjects:(HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0], (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:1], nil];
			offset = 80.0;
		
		} else {
			participants = [NSArray arrayWithObjects:(HONOpponentVO *)[_challengeVO.challengers firstObject], nil];
			offset = 40.0;
		
		}
		
		if ([_challengeVO.challengers count] > 0) {
			int idx = 0;
			for (HONOpponentVO *vo in participants) {
				UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0 + (idx * 35.0), 1.0, 30.0, 30.0)];
				[avatarImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Small_160x160.jpg", vo.imagePrefix]] placeholderImage:nil];
				avatarImageView.userInteractionEnabled = YES;
				[self addSubview:avatarImageView];
				
				UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				avatarButton.frame = CGRectMake(0.0, 0.0, avatarImageView.frame.size.width, avatarImageView.frame.size.height);
				[avatarButton addTarget:self action:@selector(_goProfileForParticipant:) forControlEvents:UIControlEventTouchUpInside];
				[avatarImageView addSubview:avatarButton];
				[avatarButton setTag:idx];
				
				idx++;
			}
		
		} else {
			UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 1.0, 30.0, 30.0)];
			avatarImageView.image = [UIImage imageNamed:@"noReply"];
			[self addSubview:avatarImageView];
		}
		
		UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + offset, 5.0, 257.0 - offset, 16.0)];
		participantsLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:12];
		participantsLabel.textColor = [UIColor colorWithWhite:0.710 alpha:1.0];
		participantsLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		participantsLabel.shadowOffset =  CGSizeMake(1.0, 1.0);
		participantsLabel.backgroundColor = [UIColor clearColor];
		participantsLabel.text = [self _captionForParticipants];
		[self addSubview:participantsLabel];
		
		HONEmotionVO *emotionVO = [self _participantEmotionVO];
		if (emotionVO != nil && [_challengeVO.challengers count] > 0) {
			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0 + (offset - 4.0), 18.0, 30.0, 30.0)];
			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
			[self addSubview:emoticonImageView];
		}
		
		offset += ((int)(emotionVO != nil) * 27.0);
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + offset, 22.0, 257.0 - offset, 22.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		subjectLabel.text = ((HONOpponentVO *)[_challengeVO.challengers lastObject]).subjectName; //firstObject
		[self addSubview:subjectLabel];
		
		UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
		joinButton.frame = CGRectMake(255.0, 0.0, 64.0, 44.0);
		[joinButton setBackgroundImage:[UIImage imageNamed:@"replyHomeButton_nonActive"] forState:UIControlStateNormal];
		[joinButton setBackgroundImage:[UIImage imageNamed:@"replyHomeButton_Active"] forState:UIControlStateHighlighted];
		[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:joinButton];
	}
	
	return (self);
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
	
	
	return ([NSString stringWithFormat:@"%@ replied… (%d other%@)", caption, [_challengeVO.challengers count], ([_challengeVO.challengers count] != 1) ? @"s" : @""]);
}

@end
