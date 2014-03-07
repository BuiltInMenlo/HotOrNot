//
//  HONUserProfileViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONUserProfileViewController.h"
#import "HONAPICaller.h"
#import "HONChallengeAssistant.h"
#import "HONColorAuthority.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"
#import "HONChangeAvatarViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONImagePickerViewController.h"
#import "HONAddContactsViewController.h"
#import "HONChallengeDetailsViewController.h"
#import "HONSearchUsersViewController.h"
#import "HONSuggestedFollowViewController.h"
#import "HONFAQViewController.h"
#import "HONSettingsViewController.h"
#import "HONImageLoadingView.h"
#import "HONUserProfileGridView.h"
#import "HONChallengeVO.h"
#import "HONOpponentVO.h"
#import "HONHeaderView.h"
#import "HONUserVO.h"
#import "HONEmotionVO.h"

#import "HONFollowingViewController.h"
#import "HONFollowersViewController.h"


@interface HONUserProfileViewController () <HONSnapPreviewViewControllerDelegate, HONParticipantGridViewDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (readonly, nonatomic, assign) HONUserProfileType userProfileType;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIButton *verifyButton;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) HONUserProfileGridView *profileGridView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UILabel *selfiesLabel;
@property (nonatomic, strong) UILabel *followersLabel;
@property (nonatomic, strong) UILabel *followingLabel;
//@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *challengeImages;
@property (nonatomic, strong) UIToolbar *footerToolbar;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UIButton *flagButton;
@property (nonatomic) int challengeCounter;
@property (nonatomic) int followingCounter;
@property (nonatomic) BOOL isFollowing;
@end


@implementation HONUserProfileViewController
@synthesize userID = _userID;

- (id)init {
	if ((self = [super init])) {
		_isFollowing = NO;
		_userID = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshProfile:) name:@"REFRESH_PROFILE" object:nil];
	}
	
	return (self);
}

- (id)initWithUserID:(int)userID {
	if ((self = [super init])) {
		_isFollowing = NO;
		_userID = userID;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshProfile:) name:@"REFRESH_PROFILE" object:nil];
	}
	
	return  (self);
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
- (void)_retrieveUser {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] retrieveUserByUserID:_userID completion:^(NSObject *result) {
		if ([(NSDictionary *)result objectForKey:@"id"] != nil) {
			_userVO = [HONUserVO userWithDictionary:(NSDictionary *)result];
			
			_userProfileType = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID) ? HONUserProfileTypeUser : HONUserProfileTypeOpponent;
			
			[_verifyButton setBackgroundImage:[UIImage imageNamed:((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_verified"] intValue]) ? @"userVerifiedButton_nonActive" : @"userNotVerifiedButton_nonActive"] forState:UIControlStateNormal];
			[_verifyButton setBackgroundImage:[UIImage imageNamed:((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_verified"] intValue]) ? @"userVerifiedButton_nonActive" : @"userNotVerifiedButton_nonActive"] forState:UIControlStateHighlighted];
			
//			[_verifyButton setBackgroundImage:[UIImage imageNamed:@"userVerifiedButton_nonActive"] forState:UIControlStateNormal];
//			[_verifyButton setBackgroundImage:[UIImage imageNamed:@"userVerifiedButton_nonActive"] forState:UIControlStateHighlighted];
			
			if (_userProfileType == HONUserProfileTypeOpponent) {
				[_verifyButton setBackgroundImage:[UIImage imageNamed:((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_verified"] intValue]) ? @"userVerifiedButton_Active" : @"userNotVerifiedButton_Active"] forState:UIControlStateHighlighted];
				[_verifyButton addTarget:self action:@selector(_goVerify) forControlEvents:UIControlEventTouchUpInside];
			}
			
			[[HONAPICaller sharedInstance] retrieveFollowingUsersForUserByUserID:_userVO.userID completion:^(NSObject *result){
				_followingCounter = [(NSArray *)result count];
				[self _retrieveChallenges];
			}];
			
		} else {
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = @"User not found!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
	}];
}

- (void)_retrieveChallenges {
	[[HONAPICaller sharedInstance] retrieveChallengesForUserByUsername:_userVO.username completion:^(NSObject *result){
		_challenges = [NSMutableArray array];
		
		for (NSDictionary *dict in (NSArray *)result) {
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
			
			if (vo != nil)
				[_challenges addObject:vo];
		}
		
		if ([_scrollView.subviews count] <= 1) {
			[self _orphanUI];
			[self _adoptUI];
			
//			[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
			
		} else {
			if (_selfiesLabel != nil) {
				_userVO.totalVolleys--;
				
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
				_selfiesLabel.text = [NSString stringWithFormat:@"%@ Selfie%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.totalVolleys]], (_userVO.totalVolleys == 1) ? @"" : @"s"];
			}
			
			[self _remakeGrid];
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	}];
}


#pragma mark - Public APIs
- (void)setUserID:(int)userID {
	_userID = userID;
	
	_isFollowing = [HONAppDelegate isFollowingUser:_userID];
	[_followButton setBackgroundImage:[UIImage imageNamed:(_isFollowing) ? @"unfollow_nonActive" : @"followUser_nonActive"] forState:UIControlStateNormal];
	[_followButton setBackgroundImage:[UIImage imageNamed:(_isFollowing) ? @"unfollow_Active" : @"followUser_Active"] forState:UIControlStateHighlighted];
	[_followButton addTarget:self action:(_isFollowing) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
	
	[self _retrieveUser];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//	_scrollView.frame = CGRectOffset(_scrollView.frame, 0.0, 0.0);
	_scrollView.showsHorizontalScrollIndicator = NO;
//	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
//	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_scrollView.frame.size.height, _scrollView.frame.size.width, _scrollView.frame.size.height) headerOverlaps:YES];
//	_refreshTableHeaderView.scrollView = _scrollView;
//	_refreshTableHeaderView.delegate = self;
//	[_refreshTableHeaderView setTag:666];
//	[_scrollView addSubview:_refreshTableHeaderView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@" "];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 94.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
//	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
//	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
//	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
//	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
//	[_headerView addButton:doneButton];
	
	_verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_verifyButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
//	[_headerView addButton:_verifyButton];
	
	
	_footerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
	[self.view addSubview:_footerToolbar];
	
	if (_userID != 0)
		[self _retrieveUser];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RESET_PROFILE_BUTTON" object:nil];
	
	if ([HONAppDelegate incTotalForCounter:@"profile"] == 0 && _userProfileType == HONUserProfileTypeUser) {
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
		_tutorialImageView.userInteractionEnabled = YES;
		_tutorialImageView.hidden = YES;
		_tutorialImageView.alpha = 0.0;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = _tutorialImageView.frame;
		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:closeButton];
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"User Profile - Done"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"participant", nil]];
	
	if ([HONAppDelegate totalForCounter:@"profile"] == 0 && _userProfileType == HONUserProfileTypeUser && [HONAppDelegate switchEnabledForKey:@"profile_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invite your friends to %@?", [HONAppDelegate brandedAppName]]
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:HONUserProfileAlertTypeInvite];
		[alertView show];
	
	} else {
		
//		if (!_isFollowing && [HONAppDelegate totalForCounter:@"profile"] < [HONAppDelegate profileSubscribeThreshold]) {
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//																message:[NSString stringWithFormat:@"Want to subscribe to %@'s updates?", _userVO.username]
//															   delegate:self
//													  cancelButtonTitle:@"No"
//													  otherButtonTitles:@"Yes", nil];
//			[alertView setTag:HONUserProfileAlertTypeFollowClose];
//			[alertView show];
//		
//		} else {
		
		if ([self parentViewController] != nil) {
			[self dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
			}];
		
		} else {
//			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
			[self.view removeFromSuperview];
		}
	}
}

- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"User Profile - Back"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"participant", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
//	[self dismissViewControllerAnimated:YES completion:nil];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goChangeAvatar {
	[[Mixpanel sharedInstance] track:@"User Profile - Take New Avatar"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[self _orphanUI];
	[_scrollView scrollRectToVisible:CGRectMake(0.0, 0.0, 320.0,[UIScreen mainScreen].bounds.size.height) animated:NO];
	[self _retrieveUser];
}

- (void)_goVerify {
	[[Mixpanel sharedInstance] track:@"User Profile - Verify User"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"participant", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Verify & follow user", @"Verify user only", [NSString stringWithFormat:@"This user does not look %d to %d", [HONAppDelegate ageRangeAsSeconds:NO].location, [HONAppDelegate ageRangeAsSeconds:NO].length], nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:HONUserProfileActionSheetTypeVerify];
	[actionSheet showInView:self.view];
}

- (void)_goSubscribe {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Subscribe%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will receive %@ updates from %@", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:HONUserProfileAlertTypeFollow];
	[alertView show];
}

- (void)_goUnsubscribe {
	[[Mixpanel sharedInstance] track:@"User Profile - Unsubscribe"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will no longer receive %@ updates from %@", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:HONUserProfileAlertTypeUnfollow];
	[alertView show];
}

- (void)_goShoutout {
	[[Mixpanel sharedInstance] track:@"User Profile - Shoutout"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	[[HONAPICaller sharedInstance] createShoutoutChallengeWithUserID:_userVO.userID completion:^(NSObject *result) {
		[[[UIAlertView alloc] initWithTitle:@"Shoutout Sent!"
									message:@"Check your Home timeline to like and reply."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
//		if (![result isEqual:[NSNull null]])
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
	}];
}

- (void)_goFlag {
	[[Mixpanel sharedInstance] track:@"User Profile - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:HONUserProfileAlertTypeFlag];
	[alertView show];
}

- (void)_goInviteFriends {
	[[Mixpanel sharedInstance] track:@"User Profile - Find People"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Find Friends", @"Search", @"Suggested People", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:HONUserProfileActionSheetTypeSocial];
	[actionSheet showInView:self.view];
}

- (void)_goShare {
	[[Mixpanel sharedInstance] track:@"User Profile - Share"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate facebookShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [HONImagingDepictor shareTemplateImageForType:HONImagingDepictorShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}

- (void)_goFAQ {
	[[Mixpanel sharedInstance] track:@"User Profile - Show FAQ"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFAQViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSettings {
	[[Mixpanel sharedInstance] track:@"User Profile - Settings"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


- (void)_goSubscribers {
	[[Mixpanel sharedInstance] track:@"User Profile - Followers"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"participant", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFollowersViewController alloc] initWithUserID:_userID]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSubscribees {
	[[Mixpanel sharedInstance] track:@"User Profile - Following"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"participant", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFollowingViewController alloc] initWithUserID:_userID]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goVolleys {
	[[Mixpanel sharedInstance] track:@"User Profile - Volleys"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_scrollView scrollRectToVisible:CGRectMake(0.0, 268.0 + ((int)(_userProfileType == HONUserProfileTypeOpponent) * 45.0), 320.0, MIN([UIScreen mainScreen].bounds.size.height - 8.0, (268.0 + ((int)(_userProfileType == HONUserProfileTypeOpponent) * 45.0)) + _profileGridView.frame.size.height)) animated:YES];
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



#pragma mark - Notifications
- (void)_refreshProfile:(NSNotification *)notification {
	[self _orphanUI];
	[_scrollView scrollRectToVisible:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height) animated:NO];
	[self _retrieveUser];
}


#pragma mark - UI Presentation
- (void)_removeSnapOverlay {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}

- (void)_orphanUI {
	if (_avatarImageView != nil) {
		[_avatarImageView removeFromSuperview];
		_avatarImageView = nil;
	}
	
	if (_selfiesLabel) {
		[_selfiesLabel removeFromSuperview];
		_selfiesLabel = nil;
	}
	
	if (_followersLabel) {
		[_followersLabel removeFromSuperview];
		_followersLabel = nil;
	}
	
	if (_followingLabel) {
		[_followingLabel removeFromSuperview];
		_followingLabel = nil;
	}
	
	for (UIView *view in _scrollView.subviews) {
		if (view.tag != 666)
			[view removeFromSuperview];
	}
}

- (void)_remakeGrid {
	if (_profileGridView != nil) {
		[_profileGridView removeFromSuperview];
		_profileGridView = nil;
	}
	
	CGFloat gridPos = 324.0 + ((int)(_userProfileType == HONUserProfileTypeOpponent) * 45.0);
	_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, (gridPos + 44.0) + (kSnapThumbSize.height * (([self _numberOfImagesForGrid] / 4) + ([self _numberOfImagesForGrid] % 4 != 0)))));
	_profileGridView = [[HONUserProfileGridView alloc] initAtPos:gridPos forChallenges:_challenges asPrimaryOpponent:[[HONChallengeAssistant sharedInstance] mostRecentOpponentInChallenge:[_challenges firstObject] byUserID:_userID]];
	_profileGridView.delegate = self;
	_profileGridView.clipsToBounds = YES;
	[_scrollView addSubview:_profileGridView];
}

- (void)_adoptUI {
	[_headerView setTitle:_userVO.username];
	
	[self _makeAvatarImage];
	[self _makeStats];
	[self _makeFooterBar];
}

- (void)_makeAvatarImage {
//	NSLog(@"AVATAR LOADING:[%@]", [_userVO.avatarURL stringByAppendingString:kSnapThumbSuffix]);
	
	UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(120.0, 85.0, 80.0, 80.0)];
	[_scrollView addSubview:avatarHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:avatarHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[avatarHolderView addSubview:imageLoadingView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:_userVO.avatarPrefix forAvatarBucket:YES completion:nil];
		
		_avatarImageView.alpha = 1.0;
		_avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapMediumSize];
	};
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
	[avatarHolderView addSubview:_avatarImageView];
	_avatarImageView.alpha = 0.0;
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarPrefix stringByAppendingString:kSnapMediumSuffix]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:imageSuccessBlock
									 failure:imageFailureBlock];
	
	UIButton *changeAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	changeAvatarButton.frame = CGRectMake(120.0, 85.0, 80.0, 80.0);
	[changeAvatarButton setBackgroundImage:[UIImage imageNamed:@"profilePhotoButton_nonActive"] forState:UIControlStateNormal];
	[changeAvatarButton setBackgroundImage:[UIImage imageNamed:@"profilePhotoButton_Active"] forState:UIControlStateHighlighted];
	[changeAvatarButton addTarget:self action:@selector(_goChangeAvatar) forControlEvents:UIControlEventTouchUpInside];
	changeAvatarButton.hidden = (_userProfileType == HONUserProfileTypeOpponent);
	[_scrollView addSubview:changeAvatarButton];
}

- (void)_makeStats {
	UIImageView *statsBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileLineBackground"]];
	statsBGImageView.frame = CGRectOffset(statsBGImageView.frame, 0.0, 180.0);
	[_scrollView addSubview:statsBGImageView];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_selfiesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 196.0, 107.0, 18.0)];
	_selfiesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	_selfiesLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	_selfiesLabel.backgroundColor = [UIColor clearColor];
	_selfiesLabel.textAlignment = NSTextAlignmentCenter;
	_selfiesLabel.text = [NSString stringWithFormat:@"%@ Selfie%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.totalVolleys]], (_userVO.totalVolleys == 1) ? @"" : @"s"];
	[_scrollView addSubview:_selfiesLabel];
	
	_followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(106.0, 196.0, 107.0, 18.0)];
	_followersLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	_followersLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	_followersLabel.backgroundColor = [UIColor clearColor];
	_followersLabel.textAlignment = NSTextAlignmentCenter;
	_followersLabel.text = [NSString stringWithFormat:@"%@ Follower%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
	[_scrollView addSubview:_followersLabel];
	
	_followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(213.0, 196.0, 107.0, 18.0)];
	_followingLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	_followingLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	_followingLabel.backgroundColor = [UIColor clearColor];
	_followingLabel.textAlignment = NSTextAlignmentCenter;
	_followingLabel.text = [NSString stringWithFormat:@"%@ Following", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_followingCounter]]];
	[_scrollView addSubview:_followingLabel];
	
//	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 432.0, 260.0, 35.0)];
//	_likesLabel.font = [[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:27];
//	_likesLabel.textColor = [HONAppDelegate honGreyTextColor];
//	_likesLabel.backgroundColor = [UIColor clearColor];
//	_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
//	[_scrollView addSubview:_likesLabel];
	
	UIButton *followersButton = [UIButton buttonWithType:UIButtonTypeCustom];
	followersButton.frame = _followersLabel.frame;
	[followersButton addTarget:self action:@selector(_goSubscribers) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:followersButton];
	
	UIButton *followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	followingButton.frame = _followingLabel.frame;
	[followingButton addTarget:self action:@selector(_goSubscribees) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:followingButton];
	
	UIButton *volleysButton = [UIButton buttonWithType:UIButtonTypeCustom];
	volleysButton.frame = _selfiesLabel.frame;
	[volleysButton addTarget:self action:@selector(_goVolleys) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:volleysButton];
	
	if (_userProfileType == HONUserProfileTypeUser) {
		UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		findFriendsButton.frame = CGRectMake(0.0, 233.0, 320.0, 45.0);
		[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findFriends_nonActive"] forState:UIControlStateNormal];
		[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findFriends_Active"] forState:UIControlStateHighlighted];
		[findFriendsButton addTarget:self action:@selector(_goInviteFriends) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:findFriendsButton];
		
		UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
		helpButton.frame = CGRectMake(0.0, 279.0, 320.0, 45.0);
		[helpButton setBackgroundImage:[UIImage imageNamed:@"helpButton_nonActive"] forState:UIControlStateNormal];
		[helpButton setBackgroundImage:[UIImage imageNamed:@"helpButton_Active"] forState:UIControlStateHighlighted];
		[helpButton addTarget:self action:@selector(_goFAQ) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:helpButton];
		
	} else {
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(0.0, 233.0, 320.0, 45.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:(_isFollowing) ? @"unfollow_nonActive" : @"followUser_nonActive"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:(_isFollowing) ? @"unfollow_Active" : @"followUser_Active"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:(_isFollowing) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:_followButton];
		
		UIButton *shoutoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shoutoutButton.frame = CGRectMake(0.0, 279.0, 320.0, 45.0);
		[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutoutButton_nonActive"] forState:UIControlStateNormal];
		[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutoutButton_Active"] forState:UIControlStateHighlighted];
		[shoutoutButton addTarget:self action:@selector(_goShoutout) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:shoutoutButton];
		
		UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
		reportButton.frame = CGRectMake(0.0, 325.0, 320.0, 45.0);
		[reportButton setBackgroundImage:[UIImage imageNamed:@"reportUser_nonActive"] forState:UIControlStateNormal];
		[reportButton setBackgroundImage:[UIImage imageNamed:@"reportUser_Active"] forState:UIControlStateHighlighted];
		[reportButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:reportButton];
	}
	
	float gridPos = 324.0 + ((int)(_userProfileType == HONUserProfileTypeOpponent) * 45.0);
	_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, (gridPos + 44.0) + (kSnapThumbSize.height * (([self _numberOfImagesForGrid] / 4) + ([self _numberOfImagesForGrid] % 4 != 0)))));
	_profileGridView = [[HONUserProfileGridView alloc] initAtPos:gridPos forChallenges:_challenges asPrimaryOpponent:[[HONChallengeAssistant sharedInstance] mostRecentOpponentInChallenge:[_challenges firstObject] byUserID:_userID]];
	_profileGridView.delegate = self;
	_profileGridView.clipsToBounds = YES;
	[_scrollView addSubview:_profileGridView];
}

- (void)_makeFooterBar {
	CGSize size;
	NSArray *footerElements;
	
	if (_userProfileType == HONUserProfileTypeUser) {
		UIButton *shareFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shareFooterButton.frame = CGRectMake(0.0, 0.0, 80.0, 44.0);
		[shareFooterButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
		[shareFooterButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
		[shareFooterButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17.0]];
		[shareFooterButton setTitle:@"Share" forState:UIControlStateNormal];
		[shareFooterButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		
		if ([[HONDeviceTraits sharedInstance] isIOS7]) {
			size = [shareFooterButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
												  options:NSStringDrawingTruncatesLastVisibleLine
											   attributes:@{NSFontAttributeName:shareFooterButton.titleLabel.font}
												  context:nil].size;
			
		} //else
//			size = [shareFooterButton.titleLabel.text sizeWithFont:shareFooterButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		shareFooterButton.frame = CGRectMake(shareFooterButton.frame.origin.x, shareFooterButton.frame.origin.y, size.width, size.height);
		
		UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		settingsButton.frame = CGRectMake(0.0, 0.0, 59.0, 44.0);
		[settingsButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
		[settingsButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
		[settingsButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17.0]];
		[settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
		[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
		
		if ([[HONDeviceTraits sharedInstance] isIOS7]) {
			size = [settingsButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
												  options:NSStringDrawingTruncatesLastVisibleLine
											   attributes:@{NSFontAttributeName:settingsButton.titleLabel.font}
												  context:nil].size;
			
		} //else
//			size = [settingsButton.titleLabel.text sizeWithFont:settingsButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		settingsButton.frame = CGRectMake(settingsButton.frame.origin.x, settingsButton.frame.origin.y, size.width, size.height);
		
		footerElements = @[[[UIBarButtonItem alloc] initWithCustomView:shareFooterButton],
						   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
						   [[UIBarButtonItem alloc] initWithCustomView:settingsButton]];
		
	} else {
		UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shareButton.frame = CGRectMake(0.0, 0.0, 80.0, 44.0);
		[shareButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
		[shareButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
		[shareButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17.0]];
		[shareButton setTitle:@"Share" forState:UIControlStateNormal];
		[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		
		if ([[HONDeviceTraits sharedInstance] isIOS7]) {
			size = [shareButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
												  options:NSStringDrawingTruncatesLastVisibleLine
											   attributes:@{NSFontAttributeName:shareButton.titleLabel.font}
												  context:nil].size;
			
		} //else
//			size = [shareButton.titleLabel.text sizeWithFont:shareButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		shareButton.frame = CGRectMake(shareButton.frame.origin.x, shareButton.frame.origin.y, size.width, size.height);
		
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
		[flagButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
		[flagButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
		[flagButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17.0]];
		[flagButton setTitle:@"Flag" forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		
		if ([[HONDeviceTraits sharedInstance] isIOS7]) {
			size = [flagButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
												  options:NSStringDrawingTruncatesLastVisibleLine
											   attributes:@{NSFontAttributeName:flagButton.titleLabel.font}
												  context:nil].size;
			
		} //else
//			size = [flagButton.titleLabel.text sizeWithFont:flagButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		flagButton.frame = CGRectMake(flagButton.frame.origin.x, flagButton.frame.origin.y, size.width, size.height);
		
		footerElements = @[[[UIBarButtonItem alloc] initWithCustomView:shareButton],
						   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
						   [[UIBarButtonItem alloc] initWithCustomView:flagButton]];
	}
	
	[_footerToolbar setItems:footerElements];
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - GridView Delegates
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
//	NSLog(@"participantGridView:[%@]showPreview:[%@]forChallenge:[%d]", participantGridView, opponentVO.dictionary, challengeVO.challengeID);
	
	[[Mixpanel sharedInstance] track:(_userProfileType == HONUserProfileTypeUser) ? [NSString stringWithFormat:@"User Profile - Remove Selfie%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"] : [NSString stringWithFormat:@"User Profile - Show Preview%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", opponentVO.userID], @"userID", nil]];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initFromProfileWithOpponent:opponentVO forChallenge:challengeVO];
	_snapPreviewViewController.delegate = self;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"participantGridView:showProfile:[%@]forChallenge:[%d]", opponentVO.dictionary, challengeVO.challengeID);
	
	[[Mixpanel sharedInstance] track:@"User Profile - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", opponentVO.userID], @"userID", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:opponentVO.userID]];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showDetailsForChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"User Profile - Show Details"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView removeParticipantItem:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Remove Selfie%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", opponentVO.userID], @"userID", nil]];
	
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete your selfie?"
														message:@""
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:HONUserProfileAlertTypeDeleteChallenge];
	[alertView show];
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController upvoteOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController flagOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController joinChallenge:(HONChallengeVO *)challengeVO {
	[self _removeSnapOverlay];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	[self _removeSnapOverlay];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
//	NSLog(@"[:|:] egoRefreshTableHeaderDidTriggerRefresh offset:[%.02f] inset:[%@] [:|:]", _scrollView.contentOffset.y, NSStringFromUIEdgeInsets(_scrollView.contentInset));
	[self _goRefresh];
}

- (void)egoRefreshTableHeaderDidFinishTareAnimation:(EGORefreshTableHeaderView *)view {
	_scrollView.pagingEnabled = YES;
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONUserProfileAlertTypeFollowClose) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Close Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] followUserWithUserID:_userVO.userID completion:^void(NSObject *result) {
				[HONAppDelegate writeFollowingList:(NSArray *)result];
			}];
		}
		
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
		
	} else if (alertView.tag == HONUserProfileAlertTypeDeleteChallenge) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Remove Selfie %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] removeChallengeForChallengeID:_challengeVO.challengeID withImagePrefix:_opponentVO.imagePrefix completion:^(NSObject *result) {
				if (result != nil)
					[self _retrieveChallenges];
			}];
		}
		
	} else if (alertView.tag == HONUserProfileAlertTypeFlag) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Flag %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] flagUserByUserID:_userVO.userID completion:nil];
		}
		
	} else if (alertView.tag == HONUserProfileAlertTypeFollow) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] followUserWithUserID:_userVO.userID completion:^void(NSObject *result) {
				[HONAppDelegate writeFollowingList:(NSArray *)result];
			}];
			
			[_followButton setBackgroundImage:[UIImage imageNamed:@"unfollow_nonActive"] forState:UIControlStateNormal];
			[_followButton setBackgroundImage:[UIImage imageNamed:@"unfollow_Active"] forState:UIControlStateHighlighted];
			[_followButton removeTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_followButton addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
			
			[_subscribeButton setTitle:@"Unfollow" forState:UIControlStateNormal];
			_subscribeButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
			[_subscribeButton removeTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_subscribeButton addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
		
	} else if (alertView.tag == HONUserProfileAlertTypeUnfollow) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Unsubscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] stopFollowingUserWithUserID:_userVO.userID completion:^(NSObject *result){
				[HONAppDelegate writeFollowingList:(NSArray *)result];
			}];
			
			[_followButton setBackgroundImage:[UIImage imageNamed:@"followUser_nonActive"] forState:UIControlStateNormal];
			[_followButton setBackgroundImage:[UIImage imageNamed:@"followUser_Active"] forState:UIControlStateHighlighted];
			[_followButton removeTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_followButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
			
			
			[_subscribeButton setTitle:@"Follow" forState:UIControlStateNormal];
			_subscribeButton.frame = CGRectMake(0.0, 0.0, 47.0, 44.0);
			[_subscribeButton removeTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
	
	} else if (alertView.tag == HONUserProfileAlertTypeInvite) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];

		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		
		} else {
			[self dismissViewControllerAnimated:YES completion:^(void) {
			}];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == HONUserProfileActionSheetTypeVerify) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Verify User%@", (buttonIndex == 0) ? @" & Follow" : (buttonIndex == 1) ? @"" : @"Flag"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"participant", nil]];
		
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] verifyUserWithUserID:_userVO.userID asLegit:YES completion:^void(NSObject *result) {
				[self _goRefresh];
			}];
			
			[[HONAPICaller sharedInstance] followUserWithUserID:_userVO.userID completion:^void(NSObject *result) {
				[HONAppDelegate writeFollowingList:(NSArray *)result];
			}];
		
		} else if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] verifyUserWithUserID:_userVO.userID asLegit:YES completion:^void(NSObject *result) {
				[self _goRefresh];
			}];
			
		} else if (buttonIndex == 2) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																message:@"This person will be flagged for review"
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"Yes, flag user", nil];
			
			[alertView setTag:HONUserProfileAlertTypeFlag];
			[alertView show];
		}
		
	} else if (actionSheet.tag == HONUserProfileActionSheetTypeSocial) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Find People %@", (buttonIndex == 0) ? @"Contacts" : (buttonIndex == 1) ? @"Search" : (buttonIndex == 2) ? @"Suggested" : @"Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex != 3) {
			NSArray *viewControllers = @[[[HONAddContactsViewController alloc] init],
										 [[HONSearchUsersViewController alloc] init],
										 [[HONSuggestedFollowViewController alloc] init]];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[viewControllers objectAtIndex:buttonIndex]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - Data Tally
- (int)_numberOfImagesForGrid {
	
	int tot = 0;
	for (HONChallengeVO *vo in _challenges) {
		if (_userID == vo.creatorVO.userID)
			tot++;
		
		for (HONOpponentVO *challenger in vo.challengers) {
			if (_userID == challenger.userID)
				tot++;
		}
	}
	
	return (tot);
}


@end
