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
	
	//[self addSubview:[[HONImageLoadingView alloc] initAtPos:CGPointMake(127.0, 31.0)]];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100.0, 17.0, 120.0, 120.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] placeholderImage:nil];
//	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]]
//															  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//														  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];
	[self addSubview:avatarImageView];
	
	UIImageView *avatar1MaskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mask"]];
	avatar1MaskImageView.frame = avatarImageView.frame;
	[self addSubview:avatar1MaskImageView];
	
	_animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(150.0, 145.0, 20.0, 64.0)];
	_animationImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"profileAnimation_001"],
										   [UIImage imageNamed:@"profileAnimation_002"],
										   [UIImage imageNamed:@"profileAnimation_003"], nil];
	_animationImageView.animationDuration = 0.5f;
	_animationImageView.animationRepeatCount = 0;
	[_animationImageView startAnimating];
	[self addSubview:_animationImageView];
	
	
	UIImageView *avatar2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100.0, 217.0, 120.0, 120.0)];
	[avatar2ImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
//	[avatar2ImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_userVO.imageURL]
//															  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//														  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];
	[self addSubview:avatar2ImageView];
	
	UIImageView *avatar2MaskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mask"]];
	avatar2MaskImageView.frame = avatar2ImageView.frame;
	[self addSubview:avatar2MaskImageView];
	
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	float yPos = 351.0;
	
	//_votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, yPos, 80.0, 16.0)];
	UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, yPos, 80.0, 16.0)];
	votesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	votesLabel.textColor = kStatsColor;
	votesLabel.backgroundColor = [UIColor clearColor];
	votesLabel.textAlignment = NSTextAlignmentCenter;
	votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:votesLabel];
	
	UILabel *dots1Label = [[UILabel alloc] initWithFrame:CGRectMake(105.0, yPos - 2.0, 20.0, 20.0)];
	dots1Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:14];
	dots1Label.textColor = kStatsColor;
	dots1Label.backgroundColor = [UIColor clearColor];
	dots1Label.textAlignment = NSTextAlignmentCenter;
	dots1Label.text = @"•";
	[self addSubview:dots1Label];
	
	UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, yPos, 80.0, 16.0)];
	snapsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	snapsLabel.textColor = kStatsColor;
	snapsLabel.backgroundColor = [UIColor clearColor];
	snapsLabel.textAlignment = NSTextAlignmentCenter;
	snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:snapsLabel];
	
	UILabel *dots2Label = [[UILabel alloc] initWithFrame:CGRectMake(195.0, yPos - 2.0, 20.0, 20.0)];
	dots2Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:14];
	dots2Label.textColor = kStatsColor;
	dots2Label.backgroundColor = [UIColor clearColor];
	dots2Label.textAlignment = NSTextAlignmentCenter;
	dots2Label.text = @"•";
	[self addSubview:dots2Label];
	
	UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0, yPos, 80.0, 16.0)];
	ptsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	ptsLabel.textColor = kStatsColor;
	ptsLabel.backgroundColor = [UIColor clearColor];
	ptsLabel.textAlignment = NSTextAlignmentCenter;
	ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:ptsLabel];
	
	UIButton *abuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	abuseButton.frame = CGRectMake(20.0, 380.0, 279.0, 44.0);
	[abuseButton setBackgroundImage:[UIImage imageNamed:@"reportAbuseButton_nonActive"] forState:UIControlStateNormal];
	[abuseButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
	[abuseButton addTarget:self action:@selector(_goAbuse) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:abuseButton];
	
	UIImageView *wompImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] < _userVO.age) ? @"tooYoung" : @"tooOld"]];
	wompImageView.frame = CGRectOffset(wompImageView.frame, 30.0, 455.0);
	[self addSubview:wompImageView];
	
	[self performSelector:@selector(_animateUp) withObject:nil afterDelay:3.0];
}


#pragma mark - UI Presentation
- (void)_animateUp {
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
		self.frame = CGRectOffset(self.frame, 0.0, -203.0);
	} completion:^(BOOL finished) {
		[_animationImageView stopAnimating];
		[self.delegate profileRequestViewCellDoneAnimating:self];
		
		if ([[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] < _userVO.age) {
			[[[UIAlertView alloc] initWithTitle:@"Womp, you're too young!"
										message:@"This profile is age range protected, send your selfie for approval!"
									   delegate:self
							  cancelButtonTitle:@"Cancel"
							  otherButtonTitles:@"OK", nil] show];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Womp, you're too old!"
										message:@"This profile is age range protected, send your selfie for approval!"
									   delegate:self
							  cancelButtonTitle:@"Cancel"
							  otherButtonTitles:@"OK", nil] show];
		}
	}];
}


#pragma mark - Navigation
- (void)_goAbuse {
	[self.delegate profileRequestViewCell:self reportAbuse:_userVO];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self.delegate profileRequestViewCell:self sendRequest:_userVO];
	}
}

@end
