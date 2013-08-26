//
//  HONTimelineHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONTimelineHeaderView.h"

@interface HONTimelineHeaderView()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@end

@implementation HONTimelineHeaderView

@synthesize delegate = _delegate;

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 61.0)])) {
		_challengeVO = vo;
		
		self.backgroundColor = [UIColor whiteColor];
		
		UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 9.0, 38.0, 38.0)];
		[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL] placeholderImage:nil];
		creatorAvatarImageView.userInteractionEnabled = YES;
		[self addSubview:creatorAvatarImageView];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 10.0, 180.0, 20.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
		subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _challengeVO.subjectName;
		[self addSubview:subjectLabel];
		
		UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 28.0, 150.0, 19.0)];
		creatorNameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
		creatorNameLabel.textColor = [HONAppDelegate honGrey518Color];
		creatorNameLabel.backgroundColor = [UIColor clearColor];
		creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorVO.username];
		[self addSubview:creatorNameLabel];
		
		if ([_challengeVO.challengers count] > 0 && [((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).imagePrefix length] > 0) {
			UILabel *lastJoinedLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 5.0, 160.0, 19.0)];
			lastJoinedLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
			lastJoinedLabel.textColor = [HONAppDelegate honOrthodoxGreenColor];
			lastJoinedLabel.backgroundColor = [UIColor clearColor];
			lastJoinedLabel.textAlignment = NSTextAlignmentRight;
			lastJoinedLabel.text = [NSString stringWithFormat:@"@%@", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).username];
			[self addSubview:lastJoinedLabel];
		}
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 24.0, 160.0, 16.0)];
		timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
		timeLabel.textColor = [HONAppDelegate honGreyTimeColor];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textAlignment = NSTextAlignmentRight;
		timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
		[self addSubview:timeLabel];
		
		UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		detailsButton.frame = self.frame;
		[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:detailsButton];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = creatorAvatarImageView.frame;
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[avatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goDetails {
	[self.delegate timelineHeaderView:self showDetails:_challengeVO];
}

- (void)_goCreatorTimeline {
	[self.delegate timelineHeaderView:self showCreatorTimeline:_challengeVO];
}

@end
