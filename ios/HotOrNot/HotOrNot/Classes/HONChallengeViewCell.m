//
//  HONChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeViewCell.h"
#import "UIImageView+WebCache.h"
#import "HONAppDelegate.h"

@interface HONChallengeViewCell()

@property (nonatomic, strong) UIImageView *creatorImageView;
@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) UILabel *challengerLabel;
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIButton *loadMoreButton;
@end

@implementation HONChallengeViewCell
@synthesize challengeVO = _challengeVO;

@synthesize creatorImageView = _creatorImageView;
@synthesize creatorLabel = _creatorLabel;
@synthesize challengerLabel = _challengerLabel;
@synthesize subjectLabel = _subjectLabel;
@synthesize pointsLabel = _pointsLabel;
@synthesize ctaButton = _ctaButton;
@synthesize loadMoreButton = _loadMoreButton;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 56.0, self.frame.size.width, 1.0)];
		lineView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
		[self addSubview:lineView];
	}
	
	return (self);
}

- (id)initAsTopCell:(int)points withSubject:(NSString *)subject {
	if ((self = [self init])) {
		self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
		self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 20.0, 50.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		self.pointsLabel.backgroundColor = [UIColor clearColor];
		self.pointsLabel.text = [NSString stringWithFormat:@"%d", points];
		[self addSubview:self.pointsLabel];
		
		
		self.subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 20.0, 150.0, 16.0)];
		//self.subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.subjectLabel = [SNAppDelegate snLinkColor];
		self.subjectLabel.backgroundColor = [UIColor clearColor];
		self.subjectLabel.textAlignment = NSTextAlignmentCenter;
		self.subjectLabel.text = [NSString stringWithFormat:@"#%@", subject];
		[self addSubview:self.subjectLabel];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		
	}
	
	return (self);
}

- (id)initAsChallengeCell {
	if ((self = [self init])) {
		self.creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 40.0, 40.0)];
		self.creatorImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:self.creatorImageView];
		
		self.creatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 10.0, 100.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		self.creatorLabel.backgroundColor = [UIColor clearColor];
		self.creatorLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:self.creatorLabel];
		
		self.subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 100.0, 16.0)];
		//self.subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.subjectLabel = [SNAppDelegate snLinkColor];
		self.subjectLabel.backgroundColor = [UIColor clearColor];
		self.subjectLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:self.subjectLabel];
		
		self.ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.ctaButton.frame = CGRectMake(200.0, 5.0, 100.0, 43.0);
		[self.ctaButton setBackgroundImage:[UIImage imageNamed:@"genericButton_nonActive.png"] forState:UIControlStateNormal];
		[self.ctaButton setBackgroundImage:[UIImage imageNamed:@"genericButton_Active.png"] forState:UIControlStateHighlighted];
		[self.ctaButton addTarget:self action:@selector(_goCTA) forControlEvents:UIControlEventTouchUpInside];
		//self.ctaButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[self.ctaButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
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
	
	if ([self.challengeVO.status isEqualToString:@"Started"]) {
		[self.ctaButton removeFromSuperview];
		[self.subjectLabel removeFromSuperview];
		self.creatorLabel.frame = CGRectMake(40.0, 5.0, 100.0, 16.0);
		
		UILabel *challengerLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 5.0, 100.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		challengerLabel.backgroundColor = [UIColor clearColor];
		challengerLabel.textAlignment = NSTextAlignmentCenter;
		challengerLabel.text = @"Challenger";
		[self addSubview:challengerLabel];
		
		UILabel *creatorScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 25.0, 100.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		creatorScoreLabel.backgroundColor = [UIColor clearColor];
		creatorScoreLabel.textAlignment = NSTextAlignmentCenter;
		creatorScoreLabel.text = [NSString stringWithFormat:@"%d", self.challengeVO.scoreCreator];
		[self addSubview:creatorScoreLabel];
		
		UILabel *challengerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 25.0, 100.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		challengerScoreLabel.backgroundColor = [UIColor clearColor];
		challengerScoreLabel.textAlignment = NSTextAlignmentCenter;
		challengerScoreLabel.text = [NSString stringWithFormat:@"%d", self.challengeVO.scoreChallenger];
		[self addSubview:challengerScoreLabel];
		
		self.creatorImageView.frame = CGRectMake(5.0, 5.0, 20.0, 40.0);
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25.0, 5.0, 20.0, 40.0)];
		challengerImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[challengerImageView setImageWithURL:[NSURL URLWithString:self.challengeVO.image2URL] placeholderImage:nil];
		[self addSubview:challengerImageView];
		
		int hours = [HONAppDelegate hoursBeforeDate:self.challengeVO.endDate];
		int mins = [HONAppDelegate minutesBeforeDate:self.challengeVO.endDate];
		int secs = [HONAppDelegate secondsBeforeDate:self.challengeVO.endDate];
		
		NSString *timeUntil;
		if (hours > 0)
			timeUntil = [NSString stringWithFormat:@"%d hours", hours];
		
		else {
			if (mins > 0)
				timeUntil = [NSString stringWithFormat:@"%d minutes", mins];
				
			else
				timeUntil = [NSString stringWithFormat:@"%d seconds", secs];
		}
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 15.0, 90.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textAlignment = NSTextAlignmentCenter;
		timeLabel.text = timeUntil;
		[self addSubview:timeLabel];
		
		NSLog(@"FINISHES IN [%d] HOURS", [HONAppDelegate hoursBeforeDate:self.challengeVO.endDate]);
		NSLog(@"FINISHES IN [%d] MINUTES", [HONAppDelegate minutesBeforeDate:self.challengeVO.endDate]);
		NSLog(@"FINISHES IN [%d] SECONDS", [HONAppDelegate secondsBeforeDate:self.challengeVO.endDate]);
		NSLog(@"FINISHED [%@]", timeUntil);
	}
}


#pragma mark - Navigation
- (void)_goCTA {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ACCEPT_CHALLENGE" object:self.challengeVO];
}

@end
