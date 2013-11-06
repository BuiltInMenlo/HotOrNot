//
//  HONTimelineViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "HONTimelineViewController.h"
#import "HONTimelineItemViewCell.h"
#import "HONOpponentVO.h"
#import "HONUserVO.h"
#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONCreateSnapButtonView.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONHeaderView.h"
#import "HONEmptyTimelineView.h"
#import "HONAddContactsViewController.h"
#import "HONPopularViewController.h"
#import "HONVerifyAccountViewController.h"
#import "HONImagingDepictor.h"
#import "HONChallengeDetailsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONProfileHeaderButtonView.h"


@interface HONTimelineViewController() <HONTimelineItemViewCellDelegate, HONEmptyTimelineViewDelegate, HONSnapPreviewViewControllerDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) HONEmptyTimelineView *emptyTimelineView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isFirstLoad;
@end

@implementation HONTimelineViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedHomeTab:) name:@"SELECTED_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showInvite:) name:@"SHOW_INVITE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showPopular:) name:@"SHOW_POPULAR" object:nil];
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
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"action"		: [NSString stringWithFormat:@"%d", 10],
							 @"isPrivate"	: @"N"};
		
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"], params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSArray *challengesResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengesResult);
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [challengesResult objectAtIndex:0]);
			
			_challenges = [NSMutableArray array];
			for (NSDictionary *serverList in challengesResult) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil)
					[_challenges addObject:vo];
			}
			
			[_tableView reloadData];
//			[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		_isRefreshing = NO;
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
//		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView isInitialLoad:_isFirstLoad];
		_isFirstLoad = NO;
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
		
		_isRefreshing = NO;
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
//		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView isInitialLoad:_isFirstLoad];
		_isFirstLoad = NO;
	}];
}

- (void)_addFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target",
							@"0", @"auto", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_removeFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIRemoveFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIRemoveFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	//self.view.backgroundColor = [UIColor whiteColor];
	_isFirstLoad = YES;
	
	_challenges = [NSMutableArray array];
	_cells = [NSMutableArray array];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.contentInset = UIEdgeInsetsMake(44.0f, 0.0f, 0.0f, 0.0f);
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) withHeaderOffset:YES];
	_refreshTableHeaderView.delegate = self;
	[_tableView addSubview:_refreshTableHeaderView];

//	UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	inviteButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
//	[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteFriendsHome_nonActive"] forState:UIControlStateNormal];
//	[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteFriendsHome_Active"] forState:UIControlStateHighlighted];
//	[inviteButton addTarget:self action:@selector(_goAddContacts) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] initWithBranding];
	[_headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
		[self _goRegistration];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] isEqualToString:@"YES"])
		[self performSelector:@selector(_retrieveChallenges) withObject:nil afterDelay:0.33];
	
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[HONAppDelegate incTotalForCounter:@"timeline"];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Go Back"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Timeline - Refresh"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[HONAppDelegate incTotalForCounter:@"timeline"];
	
	_isRefreshing = YES;
	[self _retrieveChallenges];
}

- (void)_goProfile {
	[[Mixpanel sharedInstance] track:@"Timeline - Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	[self _addBlur];
	[self _removeTutorialBubbles];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Create Volley%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[self _removeTutorialBubbles];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:1];
		[alertView show];
	}
}

- (void)_goRegistration {
	[[Mixpanel sharedInstance] track:@"Register User"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
//	[[Mixpanel sharedInstance] track:@"Start First Run"
//						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
//	
	int boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++boot_total] forKey:@"boot_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	_tutorialImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"tutorial_home-568h@2x" : @"tutorial_home"];
	_tutorialImageView.userInteractionEnabled = YES;
	_tutorialImageView.hidden = YES;
	_tutorialImageView.alpha = 0.0;
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = _tutorialImageView.frame;
	[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
	[_tutorialImageView addSubview:closeButton];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {
	}];
}

- (void)_goVerify {
	if (_emptyTimelineView == nil) {
		_emptyTimelineView = [[HONEmptyTimelineView alloc] initWithFrame:self.view.bounds];
		_emptyTimelineView.delegate = self;
		[self.view addSubview:_emptyTimelineView];
	}
}

- (void)_goAddContacts {
	[[Mixpanel sharedInstance] track:@"Timeline - Invite Friends"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
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


#pragma mark - Notifications
- (void)_showInvite:(NSNotification *)notification {
	[self.view addSubview:_tutorialImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tutorialImageView.alpha = 1.0;
	}];
	
	if ([HONAppDelegate switchEnabledForKey:@"firstrun_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Find & invite friends to Volley?"
															message:@""
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];
	
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)_showPopular:(NSNotification *)notification {
	if ([HONAppDelegate switchEnabledForKey:@"firstrun_subscribe"]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPopularViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)_showFirstRun:(NSNotification *)notification {
	[self _goRegistration];
}

- (void)_selectedHomeTab:(NSNotification *)notification {
//	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	//[self _retrieveChallenges];
}

- (void)_refreshHomeTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	[self _retrieveChallenges];
}


#pragma mark - UI Presentation
- (void)_addBlur {
//	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
//	_blurredImageView.alpha = 0.0;
//	[self.view addSubview:_blurredImageView];
//	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_blurredImageView.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}

- (void)_removeTutorialBubbles {
	for (HONTimelineItemViewCell *cell in _cells) {
		[cell removeTutorialBubble];
	}
}


#pragma mark - TimelineItemCell Delegates
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showProfileForUserID:(int)userID forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", userID], @"userID", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
		
		[self _addBlur];
		[self _removeTutorialBubbles];
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
		userPofileViewController.userID = userID;
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
		[navigationController setNavigationBarHidden:YES];
		[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:2];
		[alertView show];
	}
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Join Challenge%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[cell showTapOverlay];
		[self _removeTutorialBubbles];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:3];
		[alertView show];
	}
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Show Challenge%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
		
		_challengeVO = challengeVO;
		[self _addBlur];
		[self _removeTutorialBubbles];
		
		[cell showTapOverlay];
		
		HONChallengeDetailsViewController *challengeDetailsViewController = [[HONChallengeDetailsViewController alloc] initWithChallenge:_challengeVO withBackground:_blurredImageView];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:challengeDetailsViewController];
		[navigationController setNavigationBarHidden:YES];
		[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:4];
		[alertView show];
	}
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Comments"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self _removeTutorialBubbles];
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showVoters:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Show Voters"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self _removeTutorialBubbles];
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Show Photo Detail%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent",
									  nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[self _removeTutorialBubbles];
		
		_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO];
		_snapPreviewViewController.delegate = self;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:4];
		[alertView show];
	}
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 5.0, [UIScreen mainScreen].bounds.size.height - 130.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
	
	for (HONTimelineItemViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == challengeVO.challengeID)
			[cell upvoteUser:opponentVO.userID onChallenge:_challengeVO];
	}
}

- (void)snapPreviewViewControllerFlag:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
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


#pragma mark - EmptyTimelineView Delegates
- (void)emptyTimelineViewVerify:(HONEmptyTimelineView *)emptyTimelineView {
	[[Mixpanel sharedInstance] track:@"Timeline - Verify"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Use mobile #", @"Use email address", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:0];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return (_isRefreshing);
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
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
		cell = [[HONTimelineItemViewCell alloc] init];
		cell.challengeVO = vo;
	}
	
	[_cells addObject:cell];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kHeroVolleyTableCellHeight + ((int)(indexPath.section == [_challenges count] - 1) * 47.0));
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyAccountViewController alloc] initAsEmailVerify:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
					
		} else if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyAccountViewController alloc] initAsEmailVerify:YES]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Create Volley Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline Header - Show Profile Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	
	} else if (alertView.tag == 3) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Join Challenge Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
		
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Show Photo Detail Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent",
										  nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
		
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Show Challenge Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	}
}


@end
