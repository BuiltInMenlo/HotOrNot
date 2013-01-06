//
//  HONChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+WebCache.h"


#import "HONChallengeViewCell.h"
#import "HONAppDelegate.h"

@interface HONChallengeViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
@end

@implementation HONChallengeViewCell
@synthesize challengeVO = _challengeVO;

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
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_nonActive"] forState:UIControlStateNormal];
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_Active"] forState:UIControlStateHighlighted];
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
		_bgImgView.image = [UIImage imageNamed:@"footerTableRow_nonActive"];
		
		UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		loadMoreButton.frame = CGRectMake(100.0, -3.0, 120.0, 60.0);
		[loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_nonActive"] forState:UIControlStateNormal];
		[loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_Active"] forState:UIControlStateHighlighted];
		
		if (isEnabled)
			[loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:loadMoreButton];
	}
	
	return (self);
}

- (id)initAsChallengeCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"rowGray_nonActive"];
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
	[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", _challengeVO.creatorImgPrefix]] placeholderImage:nil];
	[creatorImgHolderView addSubview:creatorImageView];
	
//	UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	imgButton.frame = creatorImageView.frame;
//	[imgButton addTarget:self action:@selector(_goPreview) forControlEvents:UIControlEventTouchUpInside];
//	[self addSubview:imgButton];
	
	UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 10.0, 200.0, 55.0)];
	challengeLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	challengeLabel.numberOfLines = 0;
	challengeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	challengeLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:challengeLabel];
	
	
	UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(275.0, 15.0, 34.0, 34.0)];
	chevronImageView.image = [UIImage imageNamed:@"chevron"];
	[self addSubview:chevronImageView];
	
	if ([_challengeVO.status isEqualToString:@"Created"]) {
		challengeLabel.text = [NSString stringWithFormat:@"You are waiting for someone to accept your \n%@", _challengeVO.subjectName];
		
	} else if ([_challengeVO.status isEqualToString:@"Waiting"]) {
		challengeLabel.text = [NSString stringWithFormat:@"You have challenged %@ to \n%@", _challengeVO.challengerName, _challengeVO.subjectName];
		
		if (_challengeVO.hasViewed)
			challengeLabel.text = [challengeLabel.text stringByAppendingString:@"\nOpened"];
		
	} else if ([_challengeVO.status isEqualToString:@"Accept"]) {
		challengeLabel.text = [NSString stringWithFormat:@"%@ has challenged you to \n%@", _challengeVO.creatorName, _challengeVO.subjectName];
		
		if (_challengeVO.hasViewed)
			challengeLabel.text = [challengeLabel.text stringByAppendingString:@"\nOpened"];
		
	} else if ([_challengeVO.status isEqualToString:@"Started"] || [_challengeVO.status isEqualToString:@"Completed"]) {
		creatorImgHolderView.frame = CGRectMake(20.0, 10.0, 22.0, 50.0);
		[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", _challengeVO.creatorImgPrefix]] placeholderImage:nil];
		
		UIView *challengerImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(47.0, 10.0, 22.0, 50.0)];
		challengerImgHolderView.clipsToBounds = YES;
		[self addSubview:challengerImgHolderView];
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kThumb1W, kThumb1H)];
		challengerImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[challengerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", _challengeVO.challengerImgPrefix]] placeholderImage:nil];
		[challengerImgHolderView addSubview:challengerImageView];
		
		UILabel *creatorScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 34.0, 22, 16.0)];
		creatorScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		creatorScoreLabel.textColor = [UIColor whiteColor];
		creatorScoreLabel.backgroundColor = [UIColor clearColor];
		creatorScoreLabel.shadowColor = [UIColor blackColor];
		creatorScoreLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		creatorScoreLabel.textAlignment = NSTextAlignmentCenter;
		creatorScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
		[creatorImgHolderView addSubview:creatorScoreLabel];
				
		UILabel *challengerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 34.0, 22.0, 16.0)];
		challengerScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		challengerScoreLabel.textColor = [UIColor whiteColor];
		challengerScoreLabel.shadowColor = [UIColor blackColor];
		challengerScoreLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		challengerScoreLabel.backgroundColor = [UIColor clearColor];
		challengerScoreLabel.textAlignment = NSTextAlignmentCenter;
		challengerScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
		[challengerImgHolderView addSubview:challengerScoreLabel];
		
		challengeLabel.text = (_challengeVO.creatorID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? [NSString stringWithFormat:@"You have challenged %@ to \n%@\nOpened & Accepted", _challengeVO.challengerName, _challengeVO.subjectName] : [NSString stringWithFormat:@"%@ has challenged you to \n%@\nOpened & Accepted", _challengeVO.creatorName, _challengeVO.subjectName];
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
//				[deleteBtn setImage:[UIImage imageNamed:@"genericGrayButton_nonActive"]];
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

//- (void)_goPreview {
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PREVIEW" object:_challengeVO];
//}

- (void)_goLoadMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_CHALLENGE_BLOCK" object:nil];
}

- (void)didSelect {
	_bgImgView.image = [UIImage imageNamed:@"rowGray_Active"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	_bgImgView.image = [UIImage imageNamed:@"rowGray_nonActive"];
}

@end
