//
//  HONSnapPreviewViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "ImageFilter.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "HONSnapPreviewViewController.h"
#import "HONImageLoadingView.h"
#import "HONUserVO.h"
#import "HONEmotionVO.h"
#import "HONHeaderView.h"
#import "HONTimelineItemFooterView.h"
#import "HONUserProfileGridView.h"
#import "HONUserProfileViewController.h"

@interface HONSnapPreviewViewController () <HONTimelineItemFooterViewDelegate>
@property (nonatomic, assign, readonly) HONSnapPreviewType snapPreviewType;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, retain) HONUserProfileViewController *userProfileViewController;
@property (nonatomic) BOOL hasTakenVerifyAction;
@end


@implementation HONSnapPreviewViewController
@synthesize delegate = _delegate;

- (id)initWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super init])) {
		_opponentVO = opponentVO;
		_challengeVO = challengeVO;
		_hasTakenVerifyAction = NO;
		_snapPreviewType = HONSnapPreviewTypeChallenge;
		
		//NSLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCHALLENGE DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n", _challengeVO.dictionary);
	}
	
	return (self);
}

- (id)initWithVerifyChallenge:(HONChallengeVO *)vo {
	if ((self = [self initWithOpponent:vo.creatorVO forChallenge:vo])) {
		_snapPreviewType = HONSnapPreviewTypeVerify;
	}
	
	return (self);
}

- (id)initFromProfileWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [self initWithOpponent:opponentVO forChallenge:challengeVO])) {
		_snapPreviewType = HONSnapPreviewTypeProfile;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	
	// <*] main image [*>
	//~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~~*~._
	_imageHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_imageHolderView];
	
	_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageHolderView asLargeLoader:NO];
	[_imageHolderView addSubview:_imageLoadingView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[_imageLoadingView stopAnimating];

		_imageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.33 animations:^(void) {
				_buttonHolderView.alpha = 1.0;
			}];
		}];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeSelfies completion:nil];
		
		[_imageLoadingView stopAnimating];
		[UIView animateWithDuration:0.33 animations:^(void) {
			_buttonHolderView.alpha = 1.0;
		}];
	};
	
	_imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	[_imageHolderView addSubview:_imageView];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_opponentVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]
														cachePolicy:kURLRequestCachePolicy
													timeoutInterval:[HONAppDelegate timeoutInterval]]
					  placeholderImage:nil
							   success:successBlock
							   failure:failureBlock];
	
	//NSLog(@"%@ --> HERO:[%@] DATA:[%@]\n", (_isVerify) ? @"VERIFY" : @"OPPONENT", _opponentVO.imagePrefix, _opponentVO.dictionary);
	
	
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = self.view.frame;
	[_closeButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:_closeButton];
	//]~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~·¯
	
	
	// <*] header [*>
	//~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~~*~._
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
	[self.view addSubview:headerView];
	
	
	//NSLog(@"AVATAR:[%@]", [_opponentVO.avatarURL stringByAppendingString:kSnapThumbSuffix]);
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:[_opponentVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
	[headerView addSubview:avatarImageView];
	
	CGSize size;
	CGFloat maxNameWidth = (_snapPreviewType == HONSnapPreviewTypeVerify) ? 255.0 : 105.0;
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0, 15.0, maxNameWidth, 18.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:13];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	[headerView addSubview:nameLabel];
	
	if ([[HONDeviceIntrinsics sharedInstance] isIOS7]) {
		size = [[_opponentVO.username stringByAppendingString:@"…"] boundingRectWithSize:CGSizeMake(maxNameWidth, 18.0)
																				 options:NSStringDrawingTruncatesLastVisibleLine
																			  attributes:@{NSFontAttributeName:nameLabel.font}
																				 context:nil].size;
		
	} //else
//		size = [_opponentVO.username sizeWithFont:nameLabel.font constrainedToSize:CGSizeMake(maxNameWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
	nameLabel.text = (_snapPreviewType == HONSnapPreviewTypeVerify) ? _opponentVO.username : (size.width >= maxNameWidth) ? _opponentVO.username : [_opponentVO.username stringByAppendingString:@"…"];
	nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, MIN(maxNameWidth, size.width), nameLabel.frame.size.height);
	
	if (_snapPreviewType != HONSnapPreviewTypeVerify) {
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + (nameLabel.frame.size.width + 3.0), 15.0, 320.0 - (nameLabel.frame.size.width + 110.0), 18.0)];
		subjectLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:13];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _opponentVO.subjectName;
		[headerView addSubview:subjectLabel];
		
		if ([[HONDeviceIntrinsics sharedInstance] isIOS7]) {
			size = [subjectLabel.text boundingRectWithSize:CGSizeMake(320.0 - (nameLabel.frame.size.width + maxNameWidth), 18.0)
												   options:NSStringDrawingTruncatesLastVisibleLine
												attributes:@{NSFontAttributeName:nameLabel.font}
												   context:nil].size;
			
		} //else
//		size = [subjectLabel.text sizeWithFont:subjectLabel.font constrainedToSize:CGSizeMake(320.0 - (nameLabel.frame.size.width + maxNameWidth), CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		subjectLabel.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y, MIN(320.0 - (nameLabel.frame.size.width + maxNameWidth), size.width), subjectLabel.frame.size.height);
	}
	
	//NSLog(@"NAME:_[%@]_ <|> SUB:_[%@]_", NSStringFromCGSize(nameLabel.frame.size), NSStringFromCGSize(subjectLabel.frame.size));
	
//	BOOL isEmotionFound = NO;
//	if (!_isVerify) {
//		HONEmotionVO *emotionVO = [self _emotionForParticipant:_opponentVO];
//		isEmotionFound = (emotionVO != nil);
//		
//		if (isEmotionFound) {
//			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-1.0, 0.0, 43.0, 43.0)];
//			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
//			[_nameHolderView addSubview:emoticonImageView];
//		}
//		
//		participantLabel.frame = CGRectOffset(participantLabel.frame, ((int)isEmotionFound) * 34.0, 0.0);
//		subjectLabel.frame = CGRectOffset(subjectLabel.frame, ((int)isEmotionFound) * 34.0, 0.0);
//	}
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(0.0, 0.0, nameLabel.frame.origin.x + nameLabel.frame.size.width, headerView.frame.size.height);
	[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:profileButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneButton];
	//]~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~·¯
	
	
	// <*] buttons [*>
	//~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~~*~._
	_buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(239.0, [UIScreen mainScreen].bounds.size.height - (159.0 + (((_snapPreviewType == HONSnapPreviewTypeVerify)) * 80.0)), 64.0, 219.0)];
	_buttonHolderView.alpha = 0.0;
	[self.view addSubview:_buttonHolderView];
	
	if (_snapPreviewType == HONSnapPreviewTypeVerify) {
		UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		approveButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
		[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_nonActive"] forState:UIControlStateNormal];
		[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_Active"] forState:UIControlStateHighlighted];
		[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:approveButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(0.0, 78.0, 64.0, 64.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"nayButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"nayButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:skipButton];
		
		UIButton *shoutoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shoutoutButton.frame = CGRectMake(0.0, 155.0, 64.0, 64.0);
		[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutoutButton_nonActive"] forState:UIControlStateNormal];
		[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutoutButton_Active"] forState:UIControlStateHighlighted];
		[shoutoutButton addTarget:self action:@selector(_goShoutout) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:shoutoutButton];
		
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 64.0, 64.0, 64.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"verifyInviteButton_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"verifyInviteButton_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:inviteButton];
		
//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[¡]~=~=~=~=~=~=~=~=~=~=~=~=~=~[//
	} else {
		HONTimelineItemFooterView *timelineItemFooterView = [[HONTimelineItemFooterView alloc] initAtPosY:self.view.frame.size.height - 56.0 withChallenge:_challengeVO];
		timelineItemFooterView.delegate = self;
		[self.view addSubview:timelineItemFooterView];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goClose {
	if (_snapPreviewType == HONSnapPreviewTypeVerify && _hasTakenVerifyAction)
		[self.delegate snapPreviewViewController:self removeVerifyChallenge:_challengeVO];
	
	[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goDone {
	[self _goClose];
}

- (void)_goUpvote {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:_challengeVO.challengeID forOpponent:_opponentVO completion:^(NSDictionary *result) {
		_challengeVO = [HONChallengeVO challengeWithDictionary:result];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:result];
		[self.delegate snapPreviewViewController:self upvoteOpponent:_opponentVO forChallenge:_challengeVO];
	 
		[self _goClose];
	}];
}

- (void)_goProfile {
//	NSLog(@"USER:[%@]", _userVO.dictionary);


	_userProfileViewController = [[HONUserProfileViewController alloc] init];
	_userProfileViewController.userID = _opponentVO.userID;
	[self.view addSubview:_userProfileViewController.view];
}

- (void)_goFlag {

	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"//@"Nevermind"
											  otherButtonTitles:@"Yes, flag user", nil];
//											  otherButtonTitles:@"Yes, kick 'em out", nil];
	
	[alertView setTag:HONSnapPreviewAlertTypeFlag];
	[alertView show];
}

- (void)_goApprove {

					
	[[HONAPICaller sharedInstance] verifyUserWithUserID:_challengeVO.creatorVO.userID asLegit:YES completion:^(NSObject *result) {
		_hasTakenVerifyAction = YES;
		[self _goClose];
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yayOverlay"]]];
}

- (void)_goDisprove {

	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[HONAppDelegate verifyCopyForKey:@"nay_txt"]
														message:@""
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:HONSnapPreviewAlertTypeDisprove];
	[alertView show];
}

- (void)_goSkip {

	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nayOverlay"]]];
}

- (void)_goShoutout {
	
	[[HONAPICaller sharedInstance] createShoutoutChallengeWithChallengeID:_challengeVO.creatorVO.userID completion:^(NSObject *result) {
		_hasTakenVerifyAction = YES;
		[self _goClose];
	}];
	
	[[HONAPICaller sharedInstance] removeUserFromVerifyListWithUserID:_opponentVO.userID completion:^(NSObject *result) {
		_hasTakenVerifyAction = YES;
		[self _goClose];
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shoutoutOverlay"]]];
}

- (void)_goInvite {

}

- (void)_goMore {

	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""//[NSString stringWithFormat:[_tabInfo objectForKey:@"nay_format"], _challengeVO.creatorVO.username]
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Follow user", @"Inappropriate content", nil];
	[actionSheet setTag:HONSnapPreviewActionSheetTypeMore];
	[actionSheet showInView:self.view];
}

- (void)_goRemoveTutorial {
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		if (_tutorialImageView != nil) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}
	}];
}

- (void)_goTapHoldAlert {
	[[[UIAlertView alloc] initWithTitle:@"Tap and hold to view full screen!"
								message:@""
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}


#pragma mark - TimelineItemFooterView Delegates
- (void)footerView:(HONTimelineItemFooterView *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {

	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:opponentVO.userID] animated:YES];
}

- (void)footerView:(HONTimelineItemFooterView *)cell joinChallenge:(HONChallengeVO *)challengeVO {
	[self.delegate snapPreviewViewController:self joinChallenge:challengeVO];
}

- (void)footerView:(HONTimelineItemFooterView *)cell showDetailsForChallenge:(HONChallengeVO *)challengeVO {
}

- (void)footerView:(HONTimelineItemFooterView *)cell likeChallenge:(HONChallengeVO *)challengeVO {
	[self _goUpvote];
}

#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == HONSnapPreviewActionSheetTypeFlag) {

		
		if (buttonIndex == 0) {
			[self _goClose];
			
		} else if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] flagUserByUserID:_opponentVO.userID completion:^(NSObject *result) {
				_hasTakenVerifyAction = YES;
				
				[self _goClose];
				[self.delegate snapPreviewViewController:self flagOpponent:_opponentVO forChallenge:_challengeVO];
			}];
		}
	
	} else if (actionSheet.tag == HONSnapPreviewActionSheetTypeMore) {

		
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] removeUserFromVerifyListWithUserID:_challengeVO.creatorVO.userID completion:^(NSObject *result) {
				_hasTakenVerifyAction = YES;
				[self _goClose];
			}];
			
		} else if (buttonIndex == 1) {
			[[[UIAlertView alloc] initWithTitle:@""
										message:[NSString stringWithFormat:@"@%@ has been flagged & notified!", _challengeVO.creatorVO.username]
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[[HONAPICaller sharedInstance] verifyUserWithUserID:_challengeVO.creatorVO.userID asLegit:NO completion:^(NSObject *result) {
				_hasTakenVerifyAction = YES;
				[self _goClose];
			}];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONSnapPreviewAlertTypeFlag) {

		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] flagUserByUserID:_opponentVO.userID completion:^(NSObject *result) {
				_hasTakenVerifyAction = YES;
				
				[self _goClose];
				[self.delegate snapPreviewViewController:self flagOpponent:_opponentVO forChallenge:_challengeVO];
			}];
		}
		
	} else if (alertView.tag == HONSnapPreviewAlertTypeDisprove) {

		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] verifyUserWithUserID:_challengeVO.creatorVO.userID asLegit:NO completion:^(NSObject *result) {
				_hasTakenVerifyAction = YES;
				[self _goClose];
			}];
		}
	}
}


@end