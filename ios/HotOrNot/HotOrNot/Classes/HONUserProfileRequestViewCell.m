//
//  HONUserProfileRequestViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/28/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONUserProfileRequestViewCell.h"

#define kStatsColor [UIColor colorWithRed:0.227 green:0.380 blue:0.349 alpha:1.0]

@interface HONUserProfileRequestViewCell() <UIAlertViewDelegate>
@property (nonatomic, strong) UIImageView *animationImageView;
@end

@implementation HONUserProfileRequestViewCell

@synthesize delegate = _delegate;
@synthesize userVO = _userVO;
@synthesize avatarURL = _avatarURL;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		//[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBackground"]]];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 20.0, 109.0, 109.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	_animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(138.0, 52.0, 44.0, 44.0)];
	_animationImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"profileAnimation_001"],
										   [UIImage imageNamed:@"profileAnimation_002"],
										   [UIImage imageNamed:@"profileAnimation_003"], nil];
	_animationImageView.animationDuration = 0.5f;
	_animationImageView.animationRepeatCount = 0;
	[_animationImageView startAnimating];
	[self addSubview:_animationImageView];
	
	
	UIImageView *avatar2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(195.0, 20.0, 109.0, 109.0)];
	[avatar2ImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:avatar2ImageView];
	
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	float yPos = 143.0;
	
	UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, yPos, 80.0, 16.0)];
	votesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	votesLabel.textColor = kStatsColor;
	votesLabel.backgroundColor = [UIColor clearColor];
	votesLabel.textAlignment = NSTextAlignmentCenter;
	votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:votesLabel];
	
	UILabel *dots1Label = [[UILabel alloc] initWithFrame:CGRectMake(96.0, yPos, 20.0, 20.0)];
	dots1Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	dots1Label.textColor = kStatsColor;
	dots1Label.backgroundColor = [UIColor clearColor];
	dots1Label.textAlignment = NSTextAlignmentCenter;
	dots1Label.text = @"•";
	[self addSubview:dots1Label];
	
	UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, yPos, 80.0, 16.0)];
	snapsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	snapsLabel.textColor = kStatsColor;
	snapsLabel.backgroundColor = [UIColor clearColor];
	snapsLabel.textAlignment = NSTextAlignmentCenter;
	snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:snapsLabel];
	
	UILabel *dots2Label = [[UILabel alloc] initWithFrame:CGRectMake(204.0, yPos, 20.0, 20.0)];
	dots2Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	dots2Label.textColor = kStatsColor;
	dots2Label.backgroundColor = [UIColor clearColor];
	dots2Label.textAlignment = NSTextAlignmentCenter;
	dots2Label.text = @"•";
	[self addSubview:dots2Label];
	
	UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(227.0, yPos, 80.0, 16.0)];
	ptsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	ptsLabel.textColor = kStatsColor;
	ptsLabel.backgroundColor = [UIColor clearColor];
	ptsLabel.textAlignment = NSTextAlignmentCenter;
	ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:ptsLabel];
	
	UIImageView *divider1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	divider1ImageView.frame = CGRectOffset(divider1ImageView.frame, 0.0, 186.0);
	[self addSubview:divider1ImageView];
	
	UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 206.0, 180.0, 20.0)];
	ageLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	ageLabel.textColor = [HONAppDelegate honOrthodoxGreenColor];
	ageLabel.backgroundColor = [UIColor clearColor];
	ageLabel.text = @"Requesting verification…";
	[self addSubview:ageLabel];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(254.0, 194.0, 59.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:moreButton];
	
	UIImageView *divider2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	divider2ImageView.frame = CGRectOffset(divider2ImageView.frame, 0.0, 246.0);
	[self addSubview:divider2ImageView];
	
//	UIButton *abuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	abuseButton.frame = CGRectMake(20.0, 380.0, 279.0, 44.0);
//	[abuseButton setBackgroundImage:[UIImage imageNamed:@"reportAbuseButton_nonActive"] forState:UIControlStateNormal];
//	[abuseButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
//	[abuseButton addTarget:self action:@selector(_goAbuse) forControlEvents:UIControlEventTouchUpInside];
//	[self addSubview:abuseButton];
//	
//	UIImageView *wompImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] < _userVO.age) ? @"tooYoung" : @"tooOld"]];
//	wompImageView.frame = CGRectOffset(wompImageView.frame, 30.0, 455.0);
//	[self addSubview:wompImageView];
//	
	[self performSelector:@selector(_showAlert) withObject:nil afterDelay:3.0];
}


#pragma mark - UI Presentation
- (void)_showAlert {
	[_animationImageView stopAnimating];
	[self.delegate profileRequestViewCellDoneAnimating:self];
	
//	if ([[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] < _userVO.age) {
//		[[[UIAlertView alloc] initWithTitle:@"Womp, you're too young!"
//									message:@"This profile is age range protected, send your selfie for approval!"
//								   delegate:self
//						  cancelButtonTitle:@"Cancel"
//						  otherButtonTitles:@"OK", nil] show];
//		
//	} else {
//		[[[UIAlertView alloc] initWithTitle:@"Womp, you're too old!"
//									message:@"This profile is age range protected, send your selfie for approval!"
//								   delegate:self
//						  cancelButtonTitle:@"Cancel"
//						  otherButtonTitles:@"OK", nil] show];
//	}
}


#pragma mark - Navigation
//- (void)_goAbuse {
//	[self.delegate profileRequestViewCell:self reportAbuse:_userVO];
//}

- (void)_goMore {
	[self.delegate profileRequestViewCell:self showMore:_userVO];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self.delegate profileRequestViewCell:self sendRequest:_userVO];
	}
}

@end
