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
@property (nonatomic, strong) UIImageView *bgImgView;
@end

@implementation HONChallengeViewCell
@synthesize challengeVO = _challengeVO;
@synthesize bgImgView = _bgImgView;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self addSubview:_bgImgView];
	}
	
	return (self);
}

- (id)initAsTopCell:(int)points withSubject:(NSString *)subject {
	if ((self = [self init])) {
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 55.0);
		_bgImgView.image = [UIImage imageNamed:@"headerBackground.png"];
		
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 20.0, 50.0, 16.0)];
		//ptsLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//ptsLabel = [SNAppDelegate snLinkColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
		ptsLabel.text = [NSString stringWithFormat:@"%d", points];
		[self addSubview:ptsLabel];
		
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 20.0, 150.0, 16.0)];
		//subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//subjectLabel = [SNAppDelegate snLinkColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.text = [NSString stringWithFormat:@"#%@", subject];
		[self addSubview:subjectLabel];
		
		UIButton *dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		dailyButton.frame = CGRectMake(108.0, 5.0, 195.0, 50.0);
		[dailyButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:dailyButton];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerRowBackground.png"];
	}
	
	return (self);
}

- (id)initAsChallengeCell {
	if ((self = [self init])) {
		
	}
	
	return (self);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	UIImageView *creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 10.0, 50.0, 50.0)];
	creatorImageView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
	[creatorImageView setImageWithURL:[NSURL URLWithString:self.challengeVO.imageURL] placeholderImage:nil];
	[self addSubview:creatorImageView];
	
	UILabel *creatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 10.0, 100.0, 16.0)];
	//creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	//creatorLabel = [SNAppDelegate snLinkColor];
	creatorLabel.backgroundColor = [UIColor clearColor];
	creatorLabel.textAlignment = NSTextAlignmentCenter;
	creatorLabel.text = self.challengeVO.creatorName;
	[self addSubview:creatorLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 100.0, 16.0)];
	//subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	//subjectLabel = [SNAppDelegate snLinkColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.textAlignment = NSTextAlignmentCenter;
	subjectLabel.text = [NSString stringWithFormat:@"#%@", self.challengeVO.subjectName];
	[self addSubview:subjectLabel];
	
	UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
	ctaButton.frame = CGRectMake(200.0, 10.0, 100.0, 44.0);
	[ctaButton setBackgroundImage:[[UIImage imageNamed:@"genericButton_nonActive.png"] stretchableImageWithLeftCapWidth:16.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[ctaButton setBackgroundImage:[[UIImage imageNamed:@"genericButton_Active.png"] stretchableImageWithLeftCapWidth:16.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	[ctaButton addTarget:self action:@selector(_goCTA) forControlEvents:UIControlEventTouchUpInside];
	//ctaButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	[ctaButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
	[ctaButton setTitle:self.challengeVO.status forState:UIControlStateNormal];
	[self addSubview:ctaButton];
	
	if ([self.challengeVO.status isEqualToString:@"Waiting"]) {
		_bgImgView.image = [UIImage imageNamed:@"genericRowBackground.png"];
		
		[ctaButton setBackgroundImage:[[UIImage imageNamed:@"genericGrayButton_nonActive.png"] stretchableImageWithLeftCapWidth:16.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[ctaButton setBackgroundImage:[[UIImage imageNamed:@"genericGrayButton_Active.png"] stretchableImageWithLeftCapWidth:16.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	
	} else if ([self.challengeVO.status isEqualToString:@"Accept"]) {
		_bgImgView.image = [UIImage imageNamed:@"genericRowBackground.png"];
		
	} else if ([self.challengeVO.status isEqualToString:@"Started"]) {
		_bgImgView.image = [UIImage imageNamed:@"activeRowBackground.png"];
		
		[ctaButton removeFromSuperview];
		[subjectLabel removeFromSuperview];
				
		creatorImageView.frame = CGRectMake(20.0, 10.0, 22.0, 50.0);
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(47.0, 10.0, 22.0, 50.0)];
		challengerImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[challengerImageView setImageWithURL:[NSURL URLWithString:self.challengeVO.image2URL] placeholderImage:nil];
		[self addSubview:challengerImageView];

		
		creatorLabel.frame = CGRectMake(60.0, 5.0, 100.0, 16.0);
		
		UILabel *creatorScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 35.0, 100.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		creatorScoreLabel.backgroundColor = [UIColor clearColor];
		creatorScoreLabel.textAlignment = NSTextAlignmentCenter;
		creatorScoreLabel.text = [NSString stringWithFormat:@"%d", self.challengeVO.scoreCreator];
		[self addSubview:creatorScoreLabel];
		
		
		UILabel *challengerLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0, 5.0, 100.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		challengerLabel.backgroundColor = [UIColor clearColor];
		challengerLabel.textAlignment = NSTextAlignmentCenter;
		challengerLabel.text = self.challengeVO.challengerName;
		[self addSubview:challengerLabel];
		
		UILabel *challengerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0, 35.0, 100.0, 16.0)];
		//self.creatorLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//self.creatorLabel = [SNAppDelegate snLinkColor];
		challengerScoreLabel.backgroundColor = [UIColor clearColor];
		challengerScoreLabel.textAlignment = NSTextAlignmentCenter;
		challengerScoreLabel.text = [NSString stringWithFormat:@"%d", self.challengeVO.scoreChallenger];
		[self addSubview:challengerScoreLabel];
		
		
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
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 18.0, 90.0, 16.0)];
		//timeLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//timeLabel = [SNAppDelegate snLinkColor];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textAlignment = NSTextAlignmentCenter;
		timeLabel.text = timeUntil;
		[self addSubview:timeLabel];
		
	} else if ([challengeVO.status isEqualToString:@"Ended"]) {
		if (self.challengeVO.scoreCreator > self.challengeVO.scoreChallenger) {
			_bgImgView.image = [UIImage imageNamed:@"winnerRowBackground.png"];
			
		} else if (self.challengeVO.scoreCreator < self.challengeVO.scoreChallenger) {
			_bgImgView.image = [UIImage imageNamed:@"loserRowBackground.png"];
		}
	}
}


//- (void)willTransitionToState:(UITableViewCellStateMask)state {
//	[super willTransitionToState:state];
//	
//	NSLog(@"willTransitionToState");
//	
//	if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
//		for (UIView *subview in self.subviews) {
//			if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
//				UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
//				[deleteBtn setImage:[UIImage imageNamed:@"genericGrayButton_nonActive.png"]];
//				[[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
//			}
//		}
//	}
//}

#pragma mark - Navigation
- (void)_goCTA {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ACCEPT_CHALLENGE" object:self.challengeVO];
}

- (void)_goDailyChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_CHALLENGE" object:nil];
}

- (void)didSelect {
	
	if ([self.challengeVO.status isEqualToString:@"Accept"]) {
		_bgImgView.image = [UIImage imageNamed:@"genericRowBackground_active.png"];
	
	} else if ([self.challengeVO.status isEqualToString:@"Started"]) {
		_bgImgView.image = [UIImage imageNamed:@"activeRowBackground_onTap.png"];
	}
	
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	if ([self.challengeVO.status isEqualToString:@"Accept"]) {
		_bgImgView.image = [UIImage imageNamed:@"genericRowBackground.png"];
		
	} else if ([self.challengeVO.status isEqualToString:@"Started"]) {
		_bgImgView.image = [UIImage imageNamed:@"activeRowBackground.png"];
	}
}

@end
