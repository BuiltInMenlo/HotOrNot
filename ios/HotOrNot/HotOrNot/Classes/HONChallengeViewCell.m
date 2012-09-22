//
//  HONChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeViewCell.h"
#import "UIImageView+WebCache.h"

@interface HONChallengeViewCell()

@property (nonatomic, strong) UIImageView *creatorImageView;
@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UIButton *ctaButton;
@end

@implementation HONChallengeViewCell
@synthesize challengeVO = _challengeVO;

@synthesize creatorImageView = _creatorImageView;
@synthesize creatorLabel = _creatorLabel;
@synthesize subjectLabel = _subjectLabel;
@synthesize ctaButton = _ctaButton;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
		
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 56.0, self.frame.size.width, 1.0)];
		lineView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
		[self addSubview:lineView];
		
		self.creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 40.0, 40.0)];
		self.creatorImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:self.creatorImageView];
		
		self.creatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 10.0, 200.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		self.creatorLabel.backgroundColor = [UIColor clearColor];
		self.creatorLabel.text = @"Username";
		[self addSubview:self.creatorLabel];
		
		self.subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 200.0, 16.0)];
		//self.subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.subjectLabel = [SNAppDelegate snLinkColor];
		self.subjectLabel.backgroundColor = [UIColor clearColor];
		self.subjectLabel.text = @"#hashtag";
		[self addSubview:self.subjectLabel];
		
		self.ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.ctaButton.frame = CGRectMake(200.0, 5.0, 100.0, 43.0);
		[self.ctaButton setBackgroundColor:[UIColor whiteColor]];
		[self.ctaButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[self.ctaButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[self.ctaButton addTarget:self action:@selector(_goCTA) forControlEvents:UIControlEventTouchUpInside];
		//self.ctaButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[self.ctaButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[self.ctaButton setTitle:@"Accept" forState:UIControlStateNormal];
		[self addSubview:self.ctaButton];
	}
	
	return (self);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[self.creatorImageView setImageWithURL:[NSURL URLWithString:self.challengeVO.imageURL] placeholderImage:nil];
	self.creatorLabel.text = self.challengeVO.creatorName;
	self.subjectLabel.text = [NSString stringWithFormat:@"#%@", self.challengeVO.subjectName];
	[self.ctaButton setTitle:self.challengeVO.status forState:UIControlStateNormal];
}


#pragma mark - Navigation
- (void)_goCTA {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ACCEPT_CHALLENGE" object:self.challengeVO];
}

@end
