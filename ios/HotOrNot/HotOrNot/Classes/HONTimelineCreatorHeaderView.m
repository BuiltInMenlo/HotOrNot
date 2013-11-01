//
//  HONTimelineCreatorHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONTimelineCreatorHeaderView.h"
#import "HONEmotionVO.h"

@interface HONTimelineCreatorHeaderView()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@end

@implementation HONTimelineCreatorHeaderView
@synthesize delegate = _delegate;

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)])) {
//		self.backgroundColor = [HONAppDelegate honDebugColorByName:@"fuschia" atOpacity:0.33];
		_challengeVO = vo;
		
		HONEmotionVO *emotionVO = [self _creatorEmotionVO];
		
		if (emotionVO != nil) {
			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-2.0, 1.0, 42.0, 42.0)];
			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
			[self addSubview:emoticonImageView];
		}
		
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + ((int)(emotionVO != nil) * 34.0), 10.0, 150.0, 22.0)];
		nameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		nameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		nameLabel.text = _challengeVO.creatorVO.username;
		[self addSubview:nameLabel];
		
		CGSize size = [nameLabel.text boundingRectWithSize:CGSizeMake(150.0, 22)
												   options:NSStringDrawingTruncatesLastVisibleLine
												attributes:@{NSFontAttributeName:nameLabel.font}
												   context:nil].size;
		nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, size.width, size.height);
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + (size.width + 5.0) + ((int)(emotionVO != nil) * 34.0), 9.0, 240.0, 22.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		subjectLabel.shadowOffset =  CGSizeMake(1.0, 1.0);
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _challengeVO.subjectName;
		[self addSubview:subjectLabel];
		
		UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = nameLabel.frame;
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:profileButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate timelineHeaderView:self showProfile:_challengeVO.creatorVO forChallenge:_challengeVO];
}


#pragma mark - Data Tally
- (HONEmotionVO *)_creatorEmotionVO {
	HONEmotionVO *emotionVO;
	
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
		if ([vo.hastagName isEqualToString:_challengeVO.subjectName]) {
			emotionVO = vo;
			break;
		}
	}
	
	return (emotionVO);
}

@end
