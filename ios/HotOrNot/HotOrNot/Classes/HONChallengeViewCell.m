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
		UIButton *dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		//dailyButton.backgroundColor = [UIColor redColor];
		dailyButton.frame = CGRectMake(0.0, 0.0, 320.0, 55.0);
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_nonActive.png"] forState:UIControlStateNormal];
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_Active.png"] forState:UIControlStateHighlighted];
		[dailyButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:dailyButton];
		
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 25.0, 50.0, 16.0)];
		ptsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		ptsLabel.textColor = [UIColor whiteColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
		ptsLabel.textAlignment = NSTextAlignmentCenter;
		ptsLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		ptsLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		ptsLabel.text = [NSString stringWithFormat:@"%d", points];
		[self addSubview:ptsLabel];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 25.0, 140.0, 16.0)];
		subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		subjectLabel.text = subject;
		[self addSubview:subjectLabel];
	}
	
	return (self);
}

- (id)initAsBottomCell:(BOOL)isEnabled {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerTableRow_nonActive.png"];
		
		UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		loadMoreButton.frame = CGRectMake(100.0, -3.0, 120.0, 60.0);
		[loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_nonActive.png"] forState:UIControlStateNormal];
		[loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_Active.png"] forState:UIControlStateHighlighted];
		
		if (isEnabled)
			[loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:loadMoreButton];
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
	
	UIView *creatorImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 10.0, 50.0, 50.0)];
	creatorImgHolderView.clipsToBounds = YES;
	[self addSubview:creatorImgHolderView];
	
	UIImageView *creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kThumb1W, kThumb1H)];
	creatorImageView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
	[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.imageURL]] placeholderImage:nil];
	[creatorImgHolderView addSubview:creatorImageView];
	
	UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
	imgButton.frame = creatorImageView.frame;
	[imgButton addTarget:self action:@selector(_goPreview) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:imgButton];
	
	UILabel *creatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(89.0, 15.0, 100.0, 16.0)];
	creatorLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	creatorLabel.textColor = [HONAppDelegate honGreyTxtColor];
	creatorLabel.backgroundColor = [UIColor clearColor];
	creatorLabel.textAlignment = NSTextAlignmentCenter;
	creatorLabel.text = self.challengeVO.creatorName;
	[self addSubview:creatorLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(89.0, 33.0, 100.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.textAlignment = NSTextAlignmentCenter;
	subjectLabel.text = self.challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280.0, 20.0, 24.0, 24.0)];
	chevronImageView.image = [UIImage imageNamed:@"chevron.png"];
	[self addSubview:chevronImageView];
	
	if ([self.challengeVO.status isEqualToString:@"Waiting"]) {
		_bgImgView.image = [UIImage imageNamed:@"commonTableRow_nonActive.png"];
		creatorLabel.text = self.challengeVO.challengerName;
		
	} else if ([self.challengeVO.status isEqualToString:@"Accept"]) {
		_bgImgView.image = [UIImage imageNamed:@"commonTableRow_nonActive.png"];
		
	} else if ([self.challengeVO.status isEqualToString:@"Started"]) {
		_bgImgView.image = [UIImage imageNamed:@"liveTableRow_nonActive.png"];
		
		[subjectLabel removeFromSuperview];
		
		creatorImgHolderView.frame = CGRectMake(20.0, 10.0, 22.0, 50.0);
		[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.imageURL]] placeholderImage:nil];
		
		UIView *challengerImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(47.0, 10.0, 22.0, 50.0)];
		challengerImgHolderView.clipsToBounds = YES;
		[self addSubview:challengerImgHolderView];
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kThumb1W, kThumb1H)];
		challengerImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[challengerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.image2URL]] placeholderImage:nil];
		[challengerImgHolderView addSubview:challengerImageView];

		
		creatorLabel.frame = CGRectMake(60.0, 5.0, 100.0, 16.0);
		
		UILabel *creatorScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 35.0, 100.0, 16.0)];
		creatorScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		creatorScoreLabel.textColor = [HONAppDelegate honGreyTxtColor];
		creatorScoreLabel.backgroundColor = [UIColor clearColor];
		creatorScoreLabel.textAlignment = NSTextAlignmentCenter;
		creatorScoreLabel.text = [NSString stringWithFormat:@"%d", self.challengeVO.scoreCreator];
		[self addSubview:creatorScoreLabel];
		
		UILabel *challengerLabel = [[UILabel alloc] initWithFrame:CGRectMake(127.0, 5.0, 100.0, 16.0)];
		challengerLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		challengerLabel.textColor = [HONAppDelegate honBlueTxtColor];
		challengerLabel.backgroundColor = [UIColor clearColor];
		challengerLabel.textAlignment = NSTextAlignmentCenter;
		challengerLabel.text = self.challengeVO.challengerName;
		[self addSubview:challengerLabel];
		
		UILabel *challengerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(127.0, 35.0, 100.0, 16.0)];
		challengerScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		challengerScoreLabel.textColor = [HONAppDelegate honBlueTxtColor];
		challengerScoreLabel.backgroundColor = [UIColor clearColor];
		challengerScoreLabel.textAlignment = NSTextAlignmentCenter;
		challengerScoreLabel.text = [NSString stringWithFormat:@"%d", self.challengeVO.scoreChallenger];
		[self addSubview:challengerScoreLabel];
		
		
		int hours = [HONAppDelegate hoursBeforeDate:self.challengeVO.endDate];
		int mins = [HONAppDelegate minutesBeforeDate:self.challengeVO.endDate];
		int secs = [HONAppDelegate secondsBeforeDate:self.challengeVO.endDate];
		
		NSString *timeUntil;
		if (hours == 1)
			timeUntil = @"1 hour";
		
		else if (hours > 0) {
				timeUntil = [NSString stringWithFormat:@"%d hours", hours];
		
		} else {
			if (mins == 1)
				timeUntil = @"1 minute";
			
			else if (mins > 0)
				timeUntil = [NSString stringWithFormat:@"%d minutes", mins];
				
			else {
				if (secs == 1)
					timeUntil = @"1 second";
				
				else
					timeUntil = [NSString stringWithFormat:@"%d seconds", secs];
			}
		}
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(213.0, 18.0, 90.0, 16.0)];
		timeLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		timeLabel.textColor = [UIColor blackColor];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textAlignment = NSTextAlignmentCenter;
		timeLabel.text = timeUntil;
		//[self addSubview:timeLabel];
		
	} else if ([challengeVO.status isEqualToString:@"Completed"]) {
		_bgImgView.image = [UIImage imageNamed:@"liveTableRow_nonActive.png"];
		[subjectLabel removeFromSuperview];
		
		creatorLabel.frame = CGRectMake(65.0, 5.0, 100.0, 16.0);
		creatorImgHolderView.frame = CGRectMake(20.0, 10.0, 22.0, 50.0);
		[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.imageURL]] placeholderImage:nil];
		
		UIView *challengerImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(47.0, 10.0, 22.0, 50.0)];
		challengerImgHolderView.clipsToBounds = YES;
		[self addSubview:challengerImgHolderView];
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kThumb1W, kThumb1H)];
		challengerImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[challengerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.image2URL]] placeholderImage:nil];
		[challengerImgHolderView addSubview:challengerImageView];
		
		UILabel *creatorScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 35.0, 100.0, 16.0)];
		creatorScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		creatorScoreLabel.textColor = [HONAppDelegate honGreyTxtColor];
		creatorScoreLabel.backgroundColor = [UIColor clearColor];
		creatorScoreLabel.textAlignment = NSTextAlignmentCenter;
		creatorScoreLabel.text = [NSString stringWithFormat:@"%d", self.challengeVO.scoreCreator];
		[self addSubview:creatorScoreLabel];
		
		UILabel *challengerLabel = [[UILabel alloc] initWithFrame:CGRectMake(127.0, 5.0, 100.0, 16.0)];
		challengerLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		challengerLabel.textColor = [HONAppDelegate honBlueTxtColor];
		challengerLabel.backgroundColor = [UIColor clearColor];
		challengerLabel.textAlignment = NSTextAlignmentCenter;
		challengerLabel.text = self.challengeVO.challengerName;
		[self addSubview:challengerLabel];
		
		UILabel *challengerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(127.0, 35.0, 100.0, 16.0)];
		challengerScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		challengerScoreLabel.textColor = [HONAppDelegate honBlueTxtColor];
		challengerScoreLabel.backgroundColor = [UIColor clearColor];
		challengerScoreLabel.textAlignment = NSTextAlignmentCenter;
		challengerScoreLabel.text = [NSString stringWithFormat:@"%d", self.challengeVO.scoreChallenger];
		[self addSubview:challengerScoreLabel];
		
		creatorLabel.text = self.challengeVO.creatorName;
		
		// winning
		if (self.challengeVO.scoreCreator > self.challengeVO.scoreChallenger) {
		
			// losing
		} else if (self.challengeVO.scoreCreator < self.challengeVO.scoreChallenger) {
		
			// tie
		} else {
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
- (void)_goResults {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_RESULTS" object:nil];
}

- (void)_goDailyChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_CHALLENGE" object:nil];
}

- (void)_goPreview {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PREVIEW" object:self.challengeVO];
}

- (void)_goLoadMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_CHALLENGE_BLOCK" object:nil];
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
