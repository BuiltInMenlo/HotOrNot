//
//  HONVoteItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ASIFormDataRequest.h"
#import "Mixpanel.h"
#import "UIImageView+WebCache.h"

#import "HONVoteItemViewCell.h"
#import "HONAppDelegate.h"
#import "HONVoterVO.h"


@interface HONVoteItemViewCell() <AVAudioPlayerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UIView *lHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) UILabel *lScoreLabel;
@property (nonatomic, strong) UILabel *rScoreLabel;
@property (nonatomic, strong) UIButton *votesButton;
@property (nonatomic, strong) UITapGestureRecognizer *rSingleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *rDoubleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *lSingleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *lDoubleTapRecognizer;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic) BOOL hasChallenger;
@property (nonatomic, strong) AVAudioPlayer *sfxPlayer;
@end

@implementation HONVoteItemViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsWaitingCell {
	if ((self = [super init])) {
		_hasChallenger = NO;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 346.0)];
		bgImgView.image = [UIImage imageNamed:@"challengeWall_notInProgress"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (id)initAsStartedCell {
	if ((self = [super init])) {
		_hasChallenger = YES;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 244.0)];
		bgImgView.image = [UIImage imageNamed:@"challengeWall_inProgress"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	UILabel *ctaLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 5.0, 260.0, 16.0)];
	ctaLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
	ctaLabel.textColor = [HONAppDelegate honGreyTxtColor];
	ctaLabel.backgroundColor = [UIColor clearColor];
	ctaLabel.text = [HONAppDelegate ctaForChallenge:_challengeVO];
	[self addSubview:ctaLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 24.0, 200.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:13];
	subjectLabel.textColor = [UIColor blackColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(271.0, 6.0, 34.0, 34.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:moreButton];
	}
	
	if (_hasChallenger) {
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 46.0, 153.0, 153.0)];
		_lHolderView.clipsToBounds = YES;
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, kMediumW, kMediumH)];
		lImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil options:SDWebImageLowPriority];
		lImgView.userInteractionEnabled = YES;
		[_lHolderView addSubview:lImgView];
		
		UIImageView *lScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 123.0, 153.0, 30.0)];
		lScoreImageView.image = [UIImage imageNamed:@"challengeWallScore_Overlay"];
		[_lHolderView addSubview:lScoreImageView];
		
		_lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 7.0, 144.0, 18.0)];
		_lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		_lScoreLabel.backgroundColor = [UIColor clearColor];
		_lScoreLabel.textColor = [UIColor whiteColor];
		_lScoreLabel.textAlignment = NSTextAlignmentRight;
		_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
		[lScoreImageView addSubview:_lScoreLabel];
		
		_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(160.0, 46.0, 153.0, 153.0)];
		_rHolderView.clipsToBounds = YES;
		[self addSubview:_rHolderView];
		
		UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, kMediumW, kMediumH)];
		rImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[rImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.challengerImgPrefix]] placeholderImage:nil options:SDWebImageLowPriority];
		rImgView.userInteractionEnabled = YES;
		[_rHolderView addSubview:rImgView];
		
		UIImageView *rScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 123.0, 153.0, 30.0)];
		rScoreImageView.image = [UIImage imageNamed:@"challengeWallScore_Overlay"];
		[_rHolderView addSubview:rScoreImageView];
		
		_rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 7.0, 140.0, 18.0)];
		_rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		_rScoreLabel.backgroundColor = [UIColor clearColor];
		_rScoreLabel.textColor = [UIColor whiteColor];
		_rScoreLabel.textAlignment = NSTextAlignmentRight;
		_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
		[rScoreImageView addSubview:_rScoreLabel];

		_lSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goSingleTap:)];
		_lDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goDoubleTap:)];
	
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
			[_lSingleTapRecognizer requireGestureRecognizerToFail:_lDoubleTapRecognizer];
			[_lDoubleTapRecognizer setNumberOfTapsRequired:2];
			[lImgView addGestureRecognizer:_lSingleTapRecognizer];
			[lImgView addGestureRecognizer:_lDoubleTapRecognizer];
			
			_rSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goSingleTap:)];
			_rDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goDoubleTap:)];
			
			[_rSingleTapRecognizer requireGestureRecognizerToFail:_rDoubleTapRecognizer];
			[_rDoubleTapRecognizer setNumberOfTapsRequired:2];
			[rImgView addGestureRecognizer:_rSingleTapRecognizer];
			[rImgView addGestureRecognizer:_rDoubleTapRecognizer];
		}
		
		_votesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_votesButton.frame = CGRectMake(12.0, 204.0, 84.0, 34.0);
		[_votesButton setBackgroundImage:[UIImage imageNamed:@"voteButton_nonActive"] forState:UIControlStateNormal];
		[_votesButton setBackgroundImage:[UIImage imageNamed:@"voteButton_Active"] forState:UIControlStateHighlighted];
		_votesButton.titleLabel.font = [[HONAppDelegate qualcommBold] fontWithSize:14];
		[_votesButton setTitleColor:[HONAppDelegate honGreyTxtColor] forState:UIControlStateNormal];
		[_votesButton setTitle:[NSString stringWithFormat:@"%d VOTES", (_challengeVO.creatorScore + _challengeVO.challengerScore)] forState:UIControlStateNormal];
		[_votesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_votesButton];
		
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID]) {
			[lImgView removeGestureRecognizer:_lSingleTapRecognizer];
			[lImgView removeGestureRecognizer:_lDoubleTapRecognizer];
			
			[rImgView removeGestureRecognizer:_rSingleTapRecognizer];
			[rImgView removeGestureRecognizer:_rDoubleTapRecognizer];
			
			
			UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"challengeWallScore_loserOverlay"]];
			overlayImageView.frame = CGRectOffset(overlayImageView.frame, (_challengeVO.creatorScore > _challengeVO.challengerScore) ? 160.0 : 7.0, 46.0);
			[self addSubview:overlayImageView];
			
			UIImageView *resultsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_challengeVO.creatorScore > _challengeVO.challengerScore) ? @"WINNING_OverlayGraphic" : @"LOSING_OverlayGraphic"]];
			resultsImageView.frame = CGRectOffset(resultsImageView.frame, (_challengeVO.creatorScore > _challengeVO.challengerScore) ? 56.0 : 130.0, 90.0);
			[self addSubview:resultsImageView];
		}
		
	} else {
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 46.0, 306.0, 306.0)];
		_lHolderView.clipsToBounds = YES;
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW * 0.5, kLargeW * 0.5)]; //x408
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil options:SDWebImageProgressiveDownload];
		lImgView.userInteractionEnabled = YES;
		[_lHolderView addSubview:lImgView];
		
		UIImageView *overlayWaitingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 236.0, 306.0, 70.0)];
		overlayWaitingImageView.image = [UIImage imageNamed:@"waitingImageOverlay"];
		overlayWaitingImageView.userInteractionEnabled = YES;
		[lImgView addSubview:overlayWaitingImageView];
		
		UILabel *challengerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(92.0, 253.0, 144.0, 16.0)];
		challengerNameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		challengerNameLabel.backgroundColor = [UIColor clearColor];
		challengerNameLabel.textColor = [HONAppDelegate honGreyTxtColor];
		challengerNameLabel.shadowColor = [UIColor blackColor];
		challengerNameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		challengerNameLabel.text = [NSString stringWithFormat:@"%@ is…", _challengeVO.creatorName];
		[lImgView addSubview:challengerNameLabel];
		
		_lSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goSingleTap:)];
		_lDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goDoubleTap:)];
		
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
			[_lSingleTapRecognizer requireGestureRecognizerToFail:_lDoubleTapRecognizer];
			[_lDoubleTapRecognizer setNumberOfTapsRequired:2];
			[lImgView addGestureRecognizer:_lSingleTapRecognizer];
			[lImgView addGestureRecognizer:_lDoubleTapRecognizer];
		}
	}
}


#pragma mark - Navigation
- (void)_goDoubleTap:(UITapGestureRecognizer *)recogizer {
	_tappedOverlayView = [[UIView alloc] initWithFrame:recogizer.view.frame];
	_tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.33];
	[recogizer.view addSubview:_tappedOverlayView];
	[self performSelector:@selector(_removeTapOverlay) withObject:self afterDelay:0.25];
	
	if (_hasChallenger) {
		if ([recogizer isEqual:_lDoubleTapRecognizer]) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																						delegate:self
																			cancelButtonTitle:@"Cancel"
																	 destructiveButtonTitle:nil
																			otherButtonTitles:@"Like", @"Challenge", @"Poke", nil];
			actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
			
			[actionSheet setTag:0];
			[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
		} else {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																						delegate:self
																			cancelButtonTitle:@"Cancel"
																	 destructiveButtonTitle:nil
																			otherButtonTitles:@"Like", @"Challenge", @"Poke", nil];
			actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
			
			[actionSheet setTag:1];
			[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		}
	
	} else {
		[[Mixpanel sharedInstance] track:@"Vote Wall - Challenge Challenger"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
													 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_SUB" object:_challengeVO];
	}
}

- (void)_goSingleTap:(UITapGestureRecognizer *)recogizer {
	_tappedOverlayView = [[UIView alloc] initWithFrame:recogizer.view.frame];
	_tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[recogizer.view addSubview:_tappedOverlayView];
	[self performSelector:@selector(_removeTapOverlay) withObject:self afterDelay:0.25];
	
	if (_hasChallenger) {
		[self _upvote];
		
		if ([recogizer isEqual:_lSingleTapRecognizer]) {
			[self _upvoteLeft];
		
		} else {
			[self _upvoteRight];
		}
	
	} else {
		[self _goMore];
	}
}

- (void)_goScore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_VOTERS" object:_challengeVO];
}

- (void)_goDailyChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_CHALLENGE" object:nil];
}

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Vote - More"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																				delegate:self
																	cancelButtonTitle:@"Cancel"
															 destructiveButtonTitle:@"Report Abuse"
																	otherButtonTitles:@"Challenge", @"Poke", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	
	[actionSheet setTag:2];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}


#pragma mark - Behaviors
- (void)_upvote {
	[_lSingleTapRecognizer.view removeGestureRecognizer:_lSingleTapRecognizer];
	[_lDoubleTapRecognizer.view removeGestureRecognizer:_lDoubleTapRecognizer];
	
	[_rSingleTapRecognizer.view removeGestureRecognizer:_rSingleTapRecognizer];
	[_rDoubleTapRecognizer.view removeGestureRecognizer:_rDoubleTapRecognizer];
	
	_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
	_sfxPlayer.delegate = self;
	[_sfxPlayer play];
	
	[HONAppDelegate setVote:_challengeVO.challengeID];
	[_votesButton setTitle:[NSString stringWithFormat:@"%d VOTES", 1 + (_challengeVO.creatorScore + _challengeVO.challengerScore)] forState:UIControlStateNormal];
}

- (void)_upvoteLeft {
	[[Mixpanel sharedInstance] track:@"Upvote Left"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	_lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.creatorScore + 1)];
	
	UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"challengeWallScore_loserOverlay"]];
	overlayImageView.frame = CGRectOffset(overlayImageView.frame, ((_challengeVO.creatorScore + 1) > _challengeVO.challengerScore) ? 160.0 : 7.0, 46.0);
	[self addSubview:overlayImageView];
	
	UIImageView *resultsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:((_challengeVO.creatorScore + 1) > _challengeVO.challengerScore) ? @"WINNING_OverlayGraphic" : @"LOSING_OverlayGraphic"]];
	resultsImageView.frame = CGRectOffset(resultsImageView.frame, ((_challengeVO.creatorScore + 1) > _challengeVO.challengerScore) ? 56.0 : 130.0, 90.0);
	[self addSubview:resultsImageView];
	
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
	[voteRequest setPostValue:@"Y" forKey:@"creator"];
	[voteRequest startAsynchronous];
}

- (void)_upvoteRight {
	[[Mixpanel sharedInstance] track:@"Upvote Right"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	_rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.challengerScore + 1)];
	
	UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"challengeWallScore_loserOverlay"]];
	overlayImageView.frame = CGRectOffset(overlayImageView.frame, (_challengeVO.creatorScore > (_challengeVO.challengerScore + 1)) ? 160.0 : 7.0, 46.0);
	[self addSubview:overlayImageView];
	
	UIImageView *resultsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_challengeVO.creatorScore > (_challengeVO.challengerScore + 1)) ? @"WINNING_OverlayGraphic" : @"LOSING_OverlayGraphic"]];
	resultsImageView.frame = CGRectOffset(resultsImageView.frame, (_challengeVO.creatorScore > (_challengeVO.challengerScore + 1)) ? 56.0 : 130.0, 90.0);
	[self addSubview:resultsImageView];
	
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
	[voteRequest setPostValue:@"N" forKey:@"creator"];
	[voteRequest startAsynchronous];
}

- (void)_removeTapOverlay {
	[_tappedOverlayView removeFromSuperview];
	_tappedOverlayView = nil;
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	ASIFormDataRequest *voteRequest;

	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0:
				[self _upvote];
				[self _upvoteLeft];
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Vote Wall - Challenge Creator"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_MAIN" object:_challengeVO];
				break;
				
			case 3:
				[[Mixpanel sharedInstance] track:@"Poke Creator"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.creatorID] forKey:@"pokeeID"];
				[voteRequest startAsynchronous];
				break;
		}
		
	} else if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 0:
				[self _upvote];
				[self _upvoteRight];				
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Vote Wall - Challenge Challenger"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_SUB" object:_challengeVO];
				break;
				
			case 3:
				[[Mixpanel sharedInstance] track:@"Vote Wall - Poke Challenger"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengerID] forKey:@"pokeeID"];
				[voteRequest startAsynchronous];
				break;
		}
	
	} else if (actionSheet.tag == 2) {
		switch (buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Vote Wall - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
				
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 11] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
				[voteRequest startAsynchronous];
				break;
				
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MORE" object:_challengeVO];
				break;
				
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_CHALLENGE" object:_challengeVO];
				break;
		}
	}
}


@end


