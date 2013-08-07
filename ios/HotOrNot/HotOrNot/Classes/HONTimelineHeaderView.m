//
//  HONTimelineHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONTimelineHeaderView.h"

@interface HONTimelineHeaderView()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@end

@implementation HONTimelineHeaderView

@synthesize delegate = _delegate;

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)])) {
		_challengeVO = vo;
		
		self.backgroundColor = [UIColor whiteColor];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 18.0, 200.0, 28.0)];
		subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:24];
		subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _challengeVO.subjectName;
		[self addSubview:subjectLabel];
		
		UIButton *subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		subjectButton.frame = subjectLabel.frame;
		[subjectButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[subjectButton addTarget:self action:@selector(_goSubjectTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:subjectButton];
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 20.0, 160.0, 16.0)];
		timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
		timeLabel.textColor = [HONAppDelegate honGreyTimeColor];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textAlignment = NSTextAlignmentRight;
		timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
		[self addSubview:timeLabel];
	
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
	}
	
	return (self);
}


#pragma mark - public APIs
- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
}


#pragma mark - Navigation
- (void)_goSubjectTimeline {
	[self.delegate timelineHeaderView:self showSubjectChallenges:_challengeVO.subjectName];
}

@end
