//
//  HONTimelineItemFooterView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 5:36 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemFooterView.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONEmotionVO.h"


@interface HONTimelineItemFooterView ()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UILabel *participantsLabel;
@property (nonatomic, strong) UIButton *likeButton;
@end

@implementation HONTimelineItemFooterView
@synthesize delegate = _delegate;

- (id)initAtPosY:(CGFloat)yPos withChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, 56.0)])) {
		_challengeVO = challengeVO;
//		self.backgroundColor = [HONAppDelegate honDebugColorByName:@"fuschia" atOpacity:0.5];
		
		_participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 26.0, 200.0, 19.0)];
		_participantsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14];
		_participantsLabel.textColor = [UIColor whiteColor];
		_participantsLabel.backgroundColor = [UIColor clearColor];
		_participantsLabel.text = [self _captionForParticipants];
		[self addSubview:_participantsLabel];
		
		CGSize size;
		if ([[HONDeviceTraits sharedInstance] isIOS7]) {
			size = [_participantsLabel.text boundingRectWithSize:CGSizeMake(200.0, 19.0)
														 options:NSStringDrawingTruncatesLastVisibleLine
													  attributes:@{NSFontAttributeName:_participantsLabel.font}
														 context:nil].size;
			
		} //else
//			size = [_participantsLabel.text sizeWithFont:nameLabel.font constrainedToSize:CGSizeMake(200.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];

		_participantsLabel.frame = CGRectMake(_participantsLabel.frame.origin.x, _participantsLabel.frame.origin.y, MIN(200.0, size.width), _participantsLabel.frame.size.height);
		UIButton *participantsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		participantsButton.frame = _participantsLabel.frame;
		[participantsButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:participantsButton];
		
		
		UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
		joinButton.frame = CGRectMake(214.0, 0.0, 44.0, 44.0);
		[joinButton setBackgroundImage:[UIImage imageNamed:@"replyButton_nonActive"] forState:UIControlStateNormal];
		[joinButton setBackgroundImage:[UIImage imageNamed:@"replyButton_Active"] forState:UIControlStateHighlighted];
		[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:joinButton];
		
		_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButton.frame = CGRectMake(266.0, 0.0, 44.0, 44.0);
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"timelineLikeButton_nonActive"] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"timelineLikeButton_Active"] forState:UIControlStateHighlighted];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"timelineLikeButton_Tapped"] forState:UIControlStateSelected];
		[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_likeButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)updateChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_participantsLabel.text = [self _captionForParticipants];
}


#pragma mark - Navigation
- (void)_goDetails {
	[self.delegate footerView:self showDetailsForChallenge:_challengeVO];
}

- (void)_goJoinChallenge {
	[self.delegate footerView:self joinChallenge:_challengeVO];
}

- (void)_goLike {
	[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton setSelected:YES];
	
	[self.delegate footerView:self likeChallenge:_challengeVO];
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
	int score = [self _calcScore];
	int challengers = [_challengeVO.challengers count];
	
	if (challengers == 0 && score == 0)
		return (@"Be the first to like & reply");
	
	
	NSString *caption = @"";
	if (challengers > 0) {
		caption = [NSString stringWithFormat:@"%d repl%@", challengers, (challengers == 1) ? @"y" : @"ies"];
		caption = (score > 0) ? [caption stringByAppendingString:@" & "] : [caption stringByAppendingString:@"… "];
		
	} else
		caption = @"Be the first to reply… ";
	
	caption = (score > 0) ? [caption stringByAppendingString:[NSString stringWithFormat:@"%d like%@", score, (score == 1) ? @"" : @"s"]] : [caption stringByAppendingString:@"Be the first to like"];
	
	return (caption);
}


@end
