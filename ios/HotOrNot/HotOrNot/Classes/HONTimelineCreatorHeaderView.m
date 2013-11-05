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
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)])) {
		//self.backgroundColor = [UIColor whiteColor];
		_challengeVO = vo;
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:[_challengeVO.creatorVO.avatarURL stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
		[self addSubview:avatarImageView];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = avatarImageView.frame;
		[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 10.0, 110.0, 18.0)];
		nameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:14];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.text = [NSString stringWithFormat:@"%@…", _challengeVO.creatorVO.username];
		[self addSubview:nameLabel];
		
		CGSize nameSize = [nameLabel.text boundingRectWithSize:CGSizeMake(150.0, 22.0)
												   options:NSStringDrawingTruncatesLastVisibleLine
												attributes:@{NSFontAttributeName:nameLabel.font}
												   context:nil].size;
		nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, nameSize.width, nameSize.height);
		
		UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = nameLabel.frame;
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:profileButton];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + (nameSize.width + 3.0), 10.0, 125.0, 18.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _challengeVO.subjectName;
		[self addSubview:subjectLabel];
		
		CGSize subjectSize = [subjectLabel.text boundingRectWithSize:CGSizeMake(125.0, 18.0)
											options:NSStringDrawingTruncatesLastVisibleLine
										 attributes:@{NSFontAttributeName:subjectLabel.font}
											context:nil].size;
		subjectLabel.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y, subjectSize.width, subjectSize.height);
		
		HONEmotionVO *emotionVO = [self _creatorEmotionVO];
		if (emotionVO != nil) {
			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(subjectLabel.frame.origin.x + subjectSize.width + 6.0, 9.0, 18.0, 18.0)];
//			emoticonImageView.image = [UIImage imageNamed:@"emoticon_white"];
			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.urlSmallWhite] placeholderImage:nil];
			[self addSubview:emoticonImageView];
		}
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
