//
//  HONTimelineViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "HONTimelineViewController.h"
#import "HONTimelineItemViewCell.h"
#import "HONOpponentVO.h"
#import "HONUserVO.h"
#import "HONFeedViewController.h"
#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONCreateSnapButtonView.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONHeaderView.h"
#import "HONMessagesButtonView.h"
#import "HONAddContactsViewController.h"
#import "HONSuggestedFollowViewController.h"
#import "HONMatchContactsViewController.h"
#import "HONMessagesViewController.h"
#import "HONAnalyticsParams.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"
#import "HONChallengeDetailsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONProfileHeaderButtonView.h"

#import "JLBPopSlideTransition.h"

@interface HONTimelineViewController() <HONTimelineItemViewCellDelegate, HONSnapPreviewViewControllerDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *clubs;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIView *emptyTimelineView;
@property (readonly, nonatomic, assign) HONTimelineScrollDirection timelineScrollDirection;
@property (nonatomic) BOOL isScrollingDown;
@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) int imageQueueLocation;
@end

@implementation HONTimelineViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedHomeTab:) name:@"SELECTED_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareHomeTab:) name:@"TARE_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshLikeCount:) name:@"REFRESH_LIKE_COUNT" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showInvite:) name:@"SHOW_INVITE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSuggestedFollowing:) name:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showHomeTutorial:) name:@"SHOW_HOME_TUTORIAL" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFirstRun:) name:@"SHOW_FIRST_RUN" object:nil];
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
- (void)_retrieveChallenges {
	[[HONAPICaller sharedInstance] retrieveChallengesForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
		_challenges = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result) {
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
			[_challenges addObject:vo];
		}
				
		if ([_challenges count] > 0 && _imageQueueLocation < [_challenges count]) {
			int cnt = 0;
			NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length)];
			NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
			
			for (int i=queueRange.location; i<queueRange.length; i++) {
				[imageQueue addObject:[NSURL URLWithString:[((HONChallengeVO *)[_challenges objectAtIndex:i]).creatorVO.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
				
				cnt++;
				_imageQueueLocation++;
				
				if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_challenges count])
					break;
				
			}
			[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation) fromURLs:imageQueue withTag:@"home"];
		}
		
		_emptyTimelineView.hidden = ([_challenges count] > 0);
		
	 
		_isFirstLoad = NO;
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)_retrieveClubs {
	[[HONAPICaller sharedInstance] retrieveFeaturedClubsWithCompletion:^(NSObject *result) {
	
		_clubs = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result)
			[_challenges addObject:[HONChallengeVO challengeWithDictionary:dict]];
		
		[_tableView reloadData];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	NSLog(@"<</ loadView \\>>");
	
	[super loadView];
	_isFirstLoad = YES;
	
	_imageQueueLocation = 0;
	_challenges = [NSMutableArray array];
	_clubs = [NSMutableArray array];
	_cells = [NSMutableArray array];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.pagingEnabled = YES;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_emptyTimelineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 335.0)];
	[_emptyTimelineView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_noFollowers"]]];
	_emptyTimelineView.hidden = YES;
	[_tableView addSubview:_emptyTimelineView];
	
	UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	inviteButton.frame = CGRectMake(0.0, 200.0, 320.0, 45.0);
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
	[inviteButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
	[inviteButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[inviteButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
	[inviteButton setTitle:@"Find friends to follow" forState:UIControlStateNormal];
	[inviteButton setTitle:@"Find friends to follow" forState:UIControlStateHighlighted];
	inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[inviteButton addTarget:self action:@selector(_goAddContacts) forControlEvents:UIControlEventTouchUpInside];
	[_emptyTimelineView addSubview:inviteButton];
	
	UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createClubButton.frame = CGRectMake(0.0, 245.0, 320.0, 45.0);
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
	[createClubButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
	[createClubButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[createClubButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
	[createClubButton setTitle:@"Invite friends to join my club" forState:UIControlStateNormal];
	[createClubButton setTitle:@"Invite friends to join my club" forState:UIControlStateHighlighted];
	createClubButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[createClubButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
	[_emptyTimelineView addSubview:createClubButton];
	
	UIButton *matchPhoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	matchPhoneButton.frame = CGRectMake(0.0, 290.0, 320.0, 45.0);
	[matchPhoneButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
	[matchPhoneButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
	[matchPhoneButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
	[matchPhoneButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[matchPhoneButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
	[matchPhoneButton setTitle:@"Verify your phone number" forState:UIControlStateNormal];
	[matchPhoneButton setTitle:@"Verify your phone number" forState:UIControlStateHighlighted];
	matchPhoneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[matchPhoneButton addTarget:self action:@selector(_goMatchPhone) forControlEvents:UIControlEventTouchUpInside];
	[_emptyTimelineView addSubview:matchPhoneButton];
	
	
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];

	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONMessagesButtonView alloc] initWithTarget:self action:@selector(_goMessages)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:headerView];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
		[self _goRegistration];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] isEqualToString:@"YES"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_STATUS_BAR_TINT" object:@"YES"];
		
		[self performSelector:@selector(_retrieveClubs) withObject:nil afterDelay:0.33];
		[self performSelector:@selector(_retrieveChallenges) withObject:nil afterDelay:0.33];
	}
}

- (void)viewDidLoad {
	NSLog(@"<</ viewDidLoad \\>>");
	[super viewDidLoad];
	
	[HONAppDelegate incTotalForCounter:@"timeline"];
	
#if __FORCE_SUGGEST__ == 1
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"<</ viewWillAppear \\>>");
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_STATUS_BAR_TINT" object:[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"]];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"<</ viewDidAppear \\>>");
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_STATUS_BAR_TINT" object:[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Timeline - Refresh"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[HONAppDelegate incTotalForCounter:@"timeline"];
	[self _retrieveChallenges];
}

- (void)_goProfile {
	[[Mixpanel sharedInstance] track:@"Timeline - Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goMessages {
	[[Mixpanel sharedInstance] track:@"Timeline - Messages" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController pushViewController:[[HONMessagesViewController alloc] init] animated:YES];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline - Create Volley"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRegistration {
	[[Mixpanel sharedInstance] track:@"Register User"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[Mixpanel sharedInstance] track:@"Start First Run"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {}];
}

- (void)_goTakeAvatar {
	[[Mixpanel sharedInstance] track:@"Timeline - Take New Avatar"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		if (_tutorialImageView != nil) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}

- (void)_goRemoveTutorial {
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		if ([HONAppDelegate switchEnabledForKey:@"firstrun_invite"])
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_INVITE" object:nil];
	}];
}

- (void)_goAddContacts {
	[[Mixpanel sharedInstance] track:@"Timeline - Invite Friends"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goMatchPhone {
	[[Mixpanel sharedInstance] track:@"Timeline - Match Phone"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateClub {
	[[Mixpanel sharedInstance] track:@"Timeline - Create Club"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_showInvite:(NSNotification *)notification {
	if ([HONAppDelegate switchEnabledForKey:@"firstrun_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Find & invite friends to %@?", [HONAppDelegate brandedAppName]]
															message:@""
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:HONTimelineAlertTypeInvite];
		[alertView show];
	
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)_showSuggestedFollowing:(NSNotification *)notification {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuggestedFollowViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_showFirstRun:(NSNotification *)notification {
	[self _goRegistration];
}

- (void)_selectedHomeTab:(NSNotification *)notification {
//	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	//[self _retrieveChallenges];
	
	if (_tutorialImageView != nil) {
		[_tutorialImageView removeFromSuperview];
		_tutorialImageView = nil;
	}
}

- (void)_refreshHomeTab:(NSNotification *)notification {
//	NSLog(@"_refreshHomeTab");
	
	if (_tableView.contentOffset.y < 150.0)
		[_tableView setContentOffset:CGPointZero animated:YES];
	
	[self _retrieveChallenges];
}

- (void)_refreshLikeCount:(NSNotification *)notification {
	_challengeVO = [HONChallengeVO challengeWithDictionary:[notification object]];
	
	for (HONTimelineItemViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == _challengeVO.challengeID) {
			[cell updateChallenge:_challengeVO];
//			[cell upvoteUser:_challengeVO.creatorVO.userID onChallenge:_challengeVO];
		}
	}
}

- (void)_tareHomeTab:(NSNotification *)notification {
	NSLog(@"::|> tareHomeTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
	
//	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//	[_tableView setContentOffset:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) animated:NO];
}

- (void)_showHomeTutorial:(NSNotification *)notification {
	if ([HONAppDelegate incTotalForCounter:@"timeline"] == 1) {
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
		_tutorialImageView.image = [UIImage imageNamed:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? @"tutorial_home-568h@2x" : @"tutorial_home"];
		_tutorialImageView.userInteractionEnabled = YES;
		_tutorialImageView.alpha = 0.0;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(241.0, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 97.0 : 50.0, 44.0, 44.0);
		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_Active"] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:closeButton];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = CGRectMake(-1.0, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 416.0 : 374.0, 320.0, 64.0);
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"tutorial_profilePhoto_nonActive"] forState:UIControlStateNormal];
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"tutorial_profilePhoto_Active"] forState:UIControlStateHighlighted];
		[avatarButton addTarget:self action:@selector(_goTakeAvatar) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:avatarButton];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_tutorialImageView.alpha = 1.0;
		}];
	}
}


#pragma mark - TimelineItemCell Delegates
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showProfileForUserID:(int)userID forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", userID], @"userID", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:userID]];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell upvoteCreatorForChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = challengeVO.creatorVO;
	
	NSLog(@"upvoteCreatorForChallenge:[%@]", _opponentVO.dictionary);
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Upvote Challenge%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:challengeVO.challengeID forOpponent:challengeVO.creatorVO completion:^(NSObject *result){
		_challengeVO = [HONChallengeVO challengeWithDictionary:(NSDictionary *)result];
		for (HONTimelineItemViewCell *cell in _cells) {
			if (cell.challengeVO.challengeID == _challengeVO.challengeID)
				[cell updateChallenge:_challengeVO];
		}
		
		int cnt = 0;
		for (HONChallengeVO *vo in _challenges) {
			if (vo.challengeID == _challengeVO.challengeID) {
				[_challenges replaceObjectAtIndex:cnt withObject:_challengeVO];
				break;
			}
			
			cnt++;
		}
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]]];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO {
//	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Join Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[cell showTapOverlay];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell shareChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - Share Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - Show Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	HONFeedViewController *feedViewController = [[HONFeedViewController alloc] init];
	feedViewController.challenges = _challenges;
	JLBPopSlideTransition *transition = [JLBPopSlideTransition new];
	feedViewController.transitioningDelegate = transition;
	[self presentViewController:feedViewController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Comments"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showVoters:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Show Voters"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Show Photo Detail%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO];
	_snapPreviewViewController.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showBannerForChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - Banner"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	[self _goCreateChallenge];
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController upvoteOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
	
	for (HONTimelineItemViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == challengeVO.challengeID)
			[cell updateChallenge:_challengeVO];
//			[cell upvoteUser:opponentVO.userID onChallenge:_challengeVO];
	}
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController flagOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
//	NSLog(@"**_[egoRefreshTableHeaderDidTriggerRefresh]_**");
	
	_tableView.pagingEnabled = NO;
	[self _goRefresh];
}

- (void)egoRefreshTableHeaderDidFinishTareAnimation:(EGORefreshTableHeaderView *)view {
//	NSLog(@"**_[egoRefreshTableHeaderDidFinishTareAnimation]_**");
	_tableView.pagingEnabled = YES;
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_challenges count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 5.0)];
//	footerView.backgroundColor = [UIColor greenColor];
//	footerView.alpha = 0.0;
//	
//	return (footerView);
	
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONTimelineItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];
		cell = [[HONTimelineItemViewCell alloc] initAsBannerCell:((indexPath.section % 5 == -1) && indexPath.section != 0)];
		cell.challengeVO = vo;
	}
	
	[_cells addObject:cell];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//return (kSnapTabSize.height + ((int)(indexPath.section == [_challenges count] - 1) * 47.0));
	return (self.view.frame.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (0.0);
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//	HONChallengeVO *challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];
//	
//	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//	[imageView setImageWithURL:[NSURL URLWithString:[challengeVO.creatorVO.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
//	NSLog(@"tableView:didEndDisplayingCell:[%@]forRowAtIndexPath:[%d]", NSStringFromCGPoint(cell.frame.origin), indexPath.section);
	
	
	if ([_challenges count] > 0) {
		if (_timelineScrollDirection == HONTimelineScrollDirectionDown) {
//			HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];			
//			if ([HONAppDelegate isChallengeParticipant:vo] || [HONAppDelegate hasVoted:vo.challengeID])
//				[[HONAPICaller sharedInstance] markChallengeAsSeenWithChallengeID:vo.challengeID completion:nil];
//			
//			else
//				[[HONAPICaller sharedInstance] markChallengeAsUnseenWithChallengeID:vo.challengeID completion:nil];
			
			
			if (indexPath.section % [HONAppDelegate rangeForImageQueue].location == 0 || [_challenges count] - _imageQueueLocation <= [HONAppDelegate rangeForImageQueue].location) {
				NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
				NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:queueRange.length];
				
				int cnt = 0;
				//NSLog(@"QUEUEING:#%d -/> %d\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", queueRange.location, queueRange.length);
				for (int i=queueRange.location; i<queueRange.length; i++) {
					[imageQueue addObject:[NSURL URLWithString:[((HONChallengeVO *)[_challenges objectAtIndex:i]).creatorVO.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
					
					cnt++;
					_imageQueueLocation++;
					if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_challenges count])
						break;
					
				}
				[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation) fromURLs:imageQueue withTag:@"home"];
			}
		}
	}
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"**_[scrollViewDidScroll]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//	NSLog(@"**_[scrollViewWillEndDragging]_** offset:[%.02f] inset:[%.02f]", scrollView.contentOffset.y, scrollView.contentInset.top);
	_timelineScrollDirection = (velocity.y > 0.0) ? HONTimelineScrollDirectionDown : HONTimelineScrollDirectionUp;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	NSLog(@"**_[scrollViewDidEndDragging]_** offset:[%.02f] inset:[%.02f]", scrollView.contentOffset.y, scrollView.contentInset.top);
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	NSLog(@"**_[scrollViewDidEndScrollingAnimation]_**");
	scrollView.pagingEnabled = YES;
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONTimelineAlertTypeInvite) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Invite Friends %@", (buttonIndex == 0) ? @"No" : @"Yes"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 0) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																message:@""
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"Yes", nil];
			[alertView setTag:HONTimelineAlertTypeInviteConfirm];
			[alertView show];
		}
		
		else if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if (alertView.tag == HONTimelineAlertTypeInviteConfirm) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Invite Confirm %@", (buttonIndex == 0) ? @"No" : @"Yes"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


@end
