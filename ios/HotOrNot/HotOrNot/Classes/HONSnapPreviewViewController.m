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
#import "HONAPICaller.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"
#import "HONImageLoadingView.h"
#import "HONUserVO.h"
#import "HONEmotionVO.h"
#import "HONHeaderView.h"
#import "HONTimelineItemFooterView.h"
#import "HONUserProfileGridView.h"
#import "HONUserProfileViewController.h"

@interface HONSnapPreviewViewController () <HONTimelineItemFooterViewDelegate>
@property (nonatomic) HONSnapPreviewType snapPreviewType;
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
		
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		
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
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_opponentVO.imagePrefix forBucketType:HONS3BucketTypeSelfies completion:nil];
		
		[_imageLoadingView stopAnimating];
		[UIView animateWithDuration:0.33 animations:^(void) {
			_buttonHolderView.alpha = 1.0;
		}];
	};
	
	_imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	[_imageHolderView addSubview:_imageView];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_opponentVO.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
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
	
	if ([[HONDeviceTraits sharedInstance] isIOS7]) {
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
		
		if ([[HONDeviceTraits sharedInstance] isIOS7]) {
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
	doneButton.frame = CGRectMake(253.0, 2.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
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
		[approveButton setBackgroundImage:[UIImage imageNamed:@"yayVerifyButton_nonActive"] forState:UIControlStateNormal];
		[approveButton setBackgroundImage:[UIImage imageNamed:@"yayVerifyButton_Active"] forState:UIControlStateHighlighted];
		[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:approveButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(0.0, 78.0, 64.0, 64.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"nayVerifyButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"nayVerifyButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:skipButton];
		
		UIButton *shoutoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shoutoutButton.frame = CGRectMake(0.0, 155.0, 64.0, 64.0);
		[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutout_nonActive"] forState:UIControlStateNormal];
		[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutout_Active"] forState:UIControlStateHighlighted];
		[shoutoutButton addTarget:self action:@selector(_goShoutout) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:shoutoutButton];
		
		UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		followButton.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 45.0, 94.0, 44.0);
		[followButton setBackgroundImage:[UIImage imageNamed:@"verifyMoreButton_nonActive"] forState:UIControlStateNormal];
		[followButton setBackgroundImage:[UIImage imageNamed:@"verifyMoreButton_Active"] forState:UIControlStateHighlighted];
		[followButton addTarget:self action:@selector(_goFollowUser) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:followButton];
		
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
	NSLog(@"[:-:] snapPreviewViewController._goClose [:-:]");
	
	if (_snapPreviewType == HONSnapPreviewTypeVerify && _hasTakenVerifyAction)
		[self.delegate snapPreviewViewController:self removeVerifyChallenge:_challengeVO];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	[self _goClose];
}

- (void)_goUpvote {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]]];
	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:_challengeVO.challengeID forOpponent:_opponentVO completion:^(NSObject *result){
		_challengeVO = [HONChallengeVO challengeWithDictionary:(NSDictionary *)result];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:result];
		[self.delegate snapPreviewViewController:self upvoteOpponent:_opponentVO forChallenge:_challengeVO];
	 
		[self _goClose];
	}];
	
	if ([HONAppDelegate incTotalForCounter:@"like"] == 0 && [HONAppDelegate switchEnabledForKey:@"like_share"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Selfieclub with your friends?"
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:HONSnapPreviewAlertTypeShare];
		[alertView show];
	}
}

- (void)_goProfile {
//	NSLog(@"USER:[%@]", _userVO.dictionary);
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	_userProfileViewController = [[HONUserProfileViewController alloc] init];
	_userProfileViewController.userID = _opponentVO.userID;
	[self.view addSubview:_userProfileViewController.view];
}

- (void)_goFlag {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
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
	[[Mixpanel sharedInstance] track:@"Volley Preview - Verify Approve"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	if ([HONAppDelegate switchEnabledForKey:@"autosubscribe"]) {
		[[HONAPICaller sharedInstance] followUserWithUserID:_challengeVO.creatorVO.userID completion:^(NSObject *result) {
			[HONAppDelegate writeFollowingList:(NSArray *)result];
		}];
	}
	
	[[HONAPICaller sharedInstance] verifyUserWithUserID:_challengeVO.creatorVO.userID asLegit:YES completion:^(NSObject *result){
		_hasTakenVerifyAction = YES;
		
		if ([HONAppDelegate incTotalForCounter:@"verifyAction"] == 0 && [HONAppDelegate switchEnabledForKey:@"verify_share"]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Selfieclub with your friends?"
																message:@"Get more subscribers now, tap OK."
															   delegate:self
													  cancelButtonTitle:@"Cancel"
													  otherButtonTitles:@"OK", nil];
			[alertView setTag:HONSnapPreviewAlertTypeShare];
			[alertView show];
			
		} else
			[self _goClose];
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"approveAnimation"]]];
}

- (void)_goDisprove {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Flag Sheet"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[HONAppDelegate verifyCopyForKey:@"nay_txt"]
														message:@""
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:HONSnapPreviewAlertTypeDisprove];
	[alertView show];
}

- (void)_goSkip {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Verify Skip"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dislikeOverlayAnimation"]]];
}

- (void)_goShoutout {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Verify Shoutout"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	[[HONAPICaller sharedInstance] createShoutoutChallengeWithChallengeID:_challengeVO.creatorVO.userID completion:^(NSObject *result){
		_hasTakenVerifyAction = YES;
		[self _goClose];
	}];
	
	[[HONAPICaller sharedInstance] removeUserFromVerifyListWithUserID:_opponentVO.userID completion:^(NSObject *result){
		_hasTakenVerifyAction = YES;
		[self _goClose];
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shoutOutOverlayAnimation"]]];
}

- (void)_goFollowUser {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Follow"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	[[HONAPICaller sharedInstance] followUserWithUserID:_challengeVO.creatorVO.userID completion:^(NSObject *result){
		[HONAppDelegate writeFollowingList:(NSArray *)result];
		
		
		[[[UIAlertView alloc] initWithTitle:@""
									message:[NSString stringWithFormat:@"You are now following %@", _challengeVO.creatorVO.username]
								   delegate:nil cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		_hasTakenVerifyAction = YES;
		[self _goClose];
	}];
}

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Volley Preview - More Sheet"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
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


#pragma mark - UI Presentation


#pragma mark - Data Tally
- (HONEmotionVO *)_emotionForParticipant:(HONOpponentVO *)opponentVO {
	NSLog(@"_emotionForParticipant:[%@]", opponentVO.subjectName);
	
	BOOL isEmotionFound = NO;
	HONEmotionVO *emotionVO;
	
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
//		NSLog(@"CHECKING:[%@]><[%@]", opponentVO.subjectName, vo.hastagName);
		if ([vo.hastagName isEqualToString:opponentVO.subjectName]) {
			emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
			isEmotionFound = YES;
			break;
		}
	}
	
	if (!isEmotionFound) {
		for (HONEmotionVO *vo in [HONAppDelegate replyEmotions]) {
//			NSLog(@"CHECKING:[%@]><[%@]", opponentVO.subjectName, vo.hastagName);
			if ([vo.hastagName isEqualToString:opponentVO.subjectName]) {
				emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
				isEmotionFound = YES;
				break;
			}
		}
	}
	
	return (emotionVO);
}


#pragma mark - TimelineItemFooterView Delegates
- (void)footerView:(HONTimelineItemFooterView *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Volley Preview - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:opponentVO.userID] animated:YES];
//	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:opponentVO.userID];
//	userPofileViewController.userID = opponentVO.userID;
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)footerView:(HONTimelineItemFooterView *)cell joinChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Join Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
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
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Flag Sheet %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0) {
			[self _goClose];
			
		} else if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] flagUserByUserID:_opponentVO.userID completion:^(NSObject *result){
				_hasTakenVerifyAction = YES;
				
				[self _goClose];
				[self.delegate snapPreviewViewController:self flagOpponent:_opponentVO forChallenge:_challengeVO];
			}];
		}
	
	} else if (actionSheet.tag == HONSnapPreviewActionSheetTypeMore) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - More Sheet %@", (buttonIndex == 0) ? @"Subscribe" : (buttonIndex == 1) ? @"Flag" : @"Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] followUserWithUserID:_challengeVO.creatorVO.userID completion:^(NSObject *result) {
				[HONAppDelegate writeFollowingList:(NSArray *)result];
			}];
			
			[[HONAPICaller sharedInstance] removeUserFromVerifyListWithUserID:_challengeVO.creatorVO.userID completion:^(NSObject *result){
				_hasTakenVerifyAction = YES;
				[self _goClose];
			}];
			
		} else if (buttonIndex == 1) {
			[[[UIAlertView alloc] initWithTitle:@""
										message:[NSString stringWithFormat:@"@%@ has been flagged & notified!", _challengeVO.creatorVO.username]
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[[HONAPICaller sharedInstance] verifyUserWithUserID:_challengeVO.creatorVO.userID asLegit:NO completion:^(NSObject *result){
				_hasTakenVerifyAction = YES;
				[self _goClose];
			}];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONSnapPreviewAlertTypeFlag) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Flag %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] flagUserByUserID:_opponentVO.userID completion:^(NSObject *result){
				_hasTakenVerifyAction = YES;
				
				[self _goClose];
				[self.delegate snapPreviewViewController:self flagOpponent:_opponentVO forChallenge:_challengeVO];
			}];
		}
		
	} else if (alertView.tag == HONSnapPreviewAlertTypeDisprove) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Verify Disprove %@", (buttonIndex == 0) ? @"Cancel" : @" Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] verifyUserWithUserID:_challengeVO.creatorVO.userID asLegit:NO completion:^(NSObject *result){
				_hasTakenVerifyAction = YES;
				[self _goClose];
			}];
		}

	} else if (alertView.tag == HONSnapPreviewAlertTypeShare) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Share %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																									@"image"			: [HONAppDelegate avatarImage],
																									@"url"				: @"",
																									@"mp_event"			: @"Volley Preview - Share",
																									@"view_controller"	: self}];
		}
	}
}


@end