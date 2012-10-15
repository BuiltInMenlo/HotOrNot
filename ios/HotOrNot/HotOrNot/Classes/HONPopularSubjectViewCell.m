//
//  HONPopularSubjectViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularSubjectViewCell.h"

@interface HONPopularSubjectViewCell()
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@end

@implementation HONPopularSubjectViewCell

@synthesize subjectLabel = _subjectLabel;
@synthesize scoreLabel = _scoreLabel;

- (id)initAsMidCell:(int)index {
	if ((self = [super initAsMidCell:index])) {
		self.subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 10.0, 200.0, 16.0)];
		//subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//subjectLabel = [SNAppDelegate snLinkColor];
		self.subjectLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:self.subjectLabel];
		
		self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 200.0, 16.0)];
		//scoreLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//scoreLabel = [SNAppDelegate snLinkColor];
		self.scoreLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:self.scoreLabel];
		
		UIButton *challengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengeButton.frame = CGRectMake(220.0, 10.0, 84.0, 44.0);
		[challengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[challengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[challengeButton addTarget:self action:@selector(_goChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:challengeButton];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setSubjectVO:(HONPopularSubjectVO *)subjectVO {
	_subjectVO = subjectVO;
	
	self.subjectLabel.text = [NSString stringWithFormat:@"#%@", _subjectVO.subjectName];
	
	if (_subjectVO.score == 1)
		self.scoreLabel.text = @"1 challenge";
	
	else
		self.scoreLabel.text = [NSString stringWithFormat:@"%d challenges", _subjectVO.score];
}

- (void)_goChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"POPULAR_SUBJECT_CHALLENGE" object:_subjectVO];
}

@end
