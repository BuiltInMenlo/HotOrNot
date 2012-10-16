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
		dailyButton.frame = CGRectMake(0.0, 0.0, 320.0, 70.0);
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_nonActive.png"] forState:UIControlStateNormal];
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_Active.png"] forState:UIControlStateHighlighted];
		[dailyButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:dailyButton];
		
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 40.0, 50.0, 16.0)];
		ptsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:20];
		ptsLabel.textColor = [HONAppDelegate honBlueTxtColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
		ptsLabel.text = [NSString stringWithFormat:@"%d", points];
		[self addSubview:ptsLabel];
		
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 40.0, 150.0, 16.0)];
		subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:20];
		subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.text = [NSString stringWithFormat:@"#%@", subject];
		[self addSubview:subjectLabel];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerTableRow_nonActive.png"];
		
		UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		loadMoreButton.frame = CGRectMake(100.0, 0.0, 120.0, 60.0);
		[loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_nonActive.png"] forState:UIControlStateNormal];
		[loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_Active.png"] forState:UIControlStateHighlighted];
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
	
	UIImageView *creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-15.0, 0.0, 81.0, 60.0)];
	creatorImageView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
	[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.imageURL]] placeholderImage:nil];
	creatorImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
	[creatorImgHolderView addSubview:creatorImageView];
	
	UILabel *creatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 10.0, 100.0, 16.0)];
	creatorLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
	creatorLabel.textColor = [HONAppDelegate honGreyTxtColor];
	creatorLabel.backgroundColor = [UIColor clearColor];
	creatorLabel.textAlignment = NSTextAlignmentCenter;
	creatorLabel.text = self.challengeVO.creatorName;
	[self addSubview:creatorLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 100.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.textAlignment = NSTextAlignmentCenter;
	subjectLabel.text = [NSString stringWithFormat:@"#%@", self.challengeVO.subjectName];
	[self addSubview:subjectLabel];
	
	UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
	ctaButton.frame = CGRectMake(210.0, 5.0, 98.0, 60.0);
	[ctaButton addTarget:self action:@selector(_goCTA) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:ctaButton];
	
	if ([self.challengeVO.status isEqualToString:@"Waiting"]) {
		_bgImgView.image = [UIImage imageNamed:@"commonTableRow_nonActive.png"];
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonWaiting_nonActive.png"] forState:UIControlStateNormal];
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonWaiting_Active.png"] forState:UIControlStateHighlighted];
	
	} else if ([self.challengeVO.status isEqualToString:@"Accept"]) {
		_bgImgView.image = [UIImage imageNamed:@"commonTableRow_nonActive.png"];
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonAccept_nonActive.png"] forState:UIControlStateNormal];
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonAccept_Active.png"] forState:UIControlStateHighlighted];
		
	} else if ([self.challengeVO.status isEqualToString:@"Started"]) {
		_bgImgView.image = [UIImage imageNamed:@"liveTableRow_nonActive.png"];
		
		[ctaButton removeFromSuperview];
		[subjectLabel removeFromSuperview];
		
		creatorImgHolderView.frame = CGRectMake(20.0, 10.0, 22.0, 50.0);
		[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.imageURL]] placeholderImage:nil];
		
		UIView *challengerImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(47.0, 10.0, 22.0, 50.0)];
		challengerImgHolderView.clipsToBounds = YES;
		[self addSubview:challengerImgHolderView];
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-15.0, 10.0, 81.0, 60.0)];
		challengerImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		challengerImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
		[challengerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.image2URL]] placeholderImage:nil];
		[challengerImgHolderView addSubview:challengerImageView];

		
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
		
	} else if ([challengeVO.status isEqualToString:@"Completed"]) {
		_bgImgView.image = [UIImage imageNamed:@"liveTableRow_nonActive.png"];
		creatorImgHolderView.frame = CGRectMake(20.0, 10.0, 22.0, 50.0);
		[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.imageURL]] placeholderImage:nil];
		
		UIView *challengerImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(47.0, 10.0, 22.0, 50.0)];
		challengerImgHolderView.clipsToBounds = YES;
		[self addSubview:challengerImgHolderView];
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-15.0, 10.0, 81.0, 60.0)];
		challengerImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		challengerImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
		[challengerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", self.challengeVO.image2URL]] placeholderImage:nil];
		[challengerImgHolderView addSubview:challengerImageView];
		
		if (self.challengeVO.scoreCreator > self.challengeVO.scoreChallenger) {
			[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonWinner_nonActive.png"] forState:UIControlStateNormal];
			[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonWinner_Active.png"] forState:UIControlStateHighlighted];
			
			if (self.challengeVO.scoreCreator == 1)
				[ctaButton setTitle:@"1 point" forState:UIControlStateNormal];
			else
				[ctaButton setTitle:[NSString stringWithFormat:@"%d points", self.challengeVO.scoreCreator] forState:UIControlStateNormal];
			
			creatorLabel.text = self.challengeVO.creatorName;
			
		} else if (self.challengeVO.scoreCreator < self.challengeVO.scoreChallenger) {
			[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonLoser_nonActive.png"] forState:UIControlStateNormal];
			[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonLoser_Active.png"] forState:UIControlStateHighlighted];
			
			creatorLabel.text = self.challengeVO.challengerName;
		
		} else {
			[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonTie_nonActive.png"] forState:UIControlStateNormal];
			[ctaButton setBackgroundImage:[UIImage imageNamed:@"tableButtonTie_Active.png"] forState:UIControlStateHighlighted];
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
