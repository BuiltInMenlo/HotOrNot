//
//  HONVerifyViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "HONVerifyViewController.h"
#import "HONVerifyViewCell.h"
#import "HONChallengeVO.h"
#import "HONUserVO.h"
#import "HONImagePickerViewController.h"
#import "HONTimelineViewController.h"
#import "HONImagingDepictor.h"
#import "HONCreateSnapButtonView.h"
#import "HONSearchBarHeaderView.h"
#import "HONAddContactsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONSettingsViewController.h"
#import "HONImagingDepictor.h"
#import "HONHeaderView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONFAQViewController.h"


const NSInteger kOlderThresholdSeconds = (60 * 60 * 24) / 4;


@interface HONVerifyViewController() <HONVerifyViewCellDelegate, HONSnapPreviewViewControllerDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *headers;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic) int blockCounter;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONProfileHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) HONHeaderView *headerView;
@end

@implementation HONVerifyViewController

- (id)init {
	if ((self = [super init])) {
		_challenges = [NSMutableArray array];
		_headers = [NSMutableArray array];
		_cells = [NSMutableArray array];
		_blockCounter = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedVerifyTab:) name:@"SELECTED_VERIFY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVerifyTab:) name:@"REFRESH_VERIFY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVerifyTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetVerifyList);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetVerifyList parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]]];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [parsedLists objectAtIndex:0]);
			
			_challenges = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					[_challenges addObject:vo];
				}
			}

			_emptyImageView.hidden = [_challenges count] > 0;
			[_tableView reloadData];

			_isRefreshing = NO;
			[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
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
	}];
}

- (void)_updateChallengeAsSeen {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 6], @"action",
									[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
									nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		//NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil)
			NSLog(@"AFNetworking HONChallengesViewController - Failed to parse JSON: %@", [error localizedFailureReason]);
		
		else {
			//NSLog(@"AFNetworking HONChallengesViewController: %@", result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_addFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target",
							@"0", @"auto", nil];
	
	NSLog(@"PARAMS:[%@]", params);
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_verifyUser:(int)userID asLegit:(BOOL)isApprove {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 10], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"targetID",
							[NSString stringWithFormat:@"%d", (int)isApprove], @"approves",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			if (isApprove) {
				int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"verifyAction_total"] intValue];
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"verifyAction_total"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				if (total == 0 && [HONAppDelegate switchEnabledForKey:@"verify_share"]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SHARE Volley with your friends?"
																		message:@"Get more subscribers now, tap OK."
																	   delegate:self
															  cancelButtonTitle:@"Cancel"
															  otherButtonTitles:@"OK", nil];
					[alertView setTag:0];
					[alertView show];
					
				}
			}
			
			[self _goRefresh];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
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
	//_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"verify_banner"] isEqualToString:@"YES"], [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"verify_banner"] isEqualToString:@"YES"])) style:UITableViewStylePlain];
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_isPrivate = NO;
	
	_emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noOneVerify"]];
	_emptyImageView.frame = CGRectOffset(_emptyImageView.frame, 0.0, ([[[NSUserDefaults standardUserDefaults] objectForKey:@"verify_banner"] isEqualToString:@"YES"] * 90.0));
	_emptyImageView.hidden = YES;
	[self.view addSubview:_emptyImageView];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) withHeaderOffset:YES];
	_refreshTableHeaderView.delegate = self;
	[_tableView addSubview:_refreshTableHeaderView];
	
	_profileHeaderButtonView = [[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)];
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Verify"];
	[_headerView addButton:_profileHeaderButtonView];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	[self _retrieveChallenges];
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
- (void)_goProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	[_profileHeaderButtonView toggleSelected:YES];
	
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	_blurredImageView.alpha = 0.0;
	[self.view addSubview:_blurredImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView attachedToViewController:YES];
	userPofileViewController.userID = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Create Volley%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
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

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Verify - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_isRefreshing = YES;
	[self _retrieveChallenges];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"verifyRefresh_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"verifyRefresh_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 3 && [HONAppDelegate switchEnabledForKey:@"verify_share"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SHARE Volley with your friends?"
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];
	}
}

- (void)_goCloseBanner {
	[[Mixpanel sharedInstance] track:@"Verify - Close Banner"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
		_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y - 90.0, _tableView.frame.size.width, _tableView.frame.size.height + 90.0);
		_emptyImageView.frame = CGRectOffset(_emptyImageView.frame, 0.0, -90.0);
	} completion:^(BOOL finished) {
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"verify_banner"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
}

- (void)_goAddContacts {
	[[Mixpanel sharedInstance] track:@"Verify - Invite Friends"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goFAQ {
	[[Mixpanel sharedInstance] track:@"Verify - FAQ"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFAQViewController alloc] init]];
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
- (void)_selectedVerifyTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	[self _retrieveChallenges];
	
	
//	if ([HONAppDelegate totalForCounter:@"verify"] == 0) {
//		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//		_tutorialImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"tutorial_verify-568h@2x" : @"tutorial_verify"];
//		_tutorialImageView.userInteractionEnabled = YES;
//		_tutorialImageView.hidden = YES;
//		_tutorialImageView.alpha = 0.0;
//		[self.view addSubview:_tutorialImageView];
//		
//		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		closeButton.frame = _tutorialImageView.frame;
//		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
//		[_tutorialImageView addSubview:closeButton];
//		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
//		
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			_tutorialImageView.alpha = 1.0;
//		}];
//	}
}

- (void)_refreshVerifyTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	[self _retrieveChallenges];
}


#pragma mark - VerifyCell Delegates
- (void)verifyViewCell:(HONVerifyViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.creatorVO.userID, challengeVO.creatorVO.username], @"opponent", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
		
		_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
		_blurredImageView.alpha = 0.0;
		[self.view addSubview:_blurredImageView];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blurredImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView attachedToViewController:YES];
		userPofileViewController.userID = challengeVO.creatorVO.userID;
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
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

- (void)verifyViewCellShowPreview:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	[[Mixpanel sharedInstance] track:@"Verify - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
		
		_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
		_blurredImageView.alpha = 0.0;
		[self.view addSubview:_blurredImageView];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blurredImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView attachedToViewController:YES];
		userPofileViewController.userID = challengeVO.creatorVO.userID;
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
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

//- (void)verifyViewCellShowPreviewControls:(HONVerifyViewCell *)cell {
//	[[Mixpanel sharedInstance] track:@"Verify - Hide Detail"
//						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
//									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
//	
//	[_snapPreviewViewController showControls];
//}

- (void)verifyViewCellApprove:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Approve%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		UITableViewCell *tableCell;
		for (HONVerifyViewCell *cell in _cells) {
			if (cell.challengeVO.challengeID == _challengeVO.challengeID) {
				tableCell = (UITableViewCell *)cell;
				break;
			}
		}
		
		_indexPath = [_tableView indexPathForCell:tableCell];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Verify user & follow updates", @"Verify user only", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:0];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:6];
		[alertView show];
	}
}

- (void)verifyViewCellDisprove:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Disprove%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		UITableViewCell *tableCell;
		for (HONVerifyViewCell *cell in _cells) {
			if (cell.challengeVO.challengeID == _challengeVO.challengeID) {
				tableCell = (UITableViewCell *)cell;
				break;
			}
		}
		
		_indexPath = [_tableView indexPathForCell:tableCell];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:[NSString stringWithFormat:@"This user does not look %d - %d", [HONAppDelegate ageRangeAsSeconds:NO].location, [HONAppDelegate ageRangeAsSeconds:NO].length], nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:1];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:7];
		[alertView show];
	}
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerFlag:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 4.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 43.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
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
	return ([_challenges count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONVerifyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONVerifyViewCell alloc] initAsEvenRow:indexPath.row % 2 == 0];
	
	cell.delegate = self;
	cell.challengeVO = [_challenges objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	[_cells addObject:cell];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return ((indexPath.row == [_challenges count] - 1) ? 329.0 : 282.0);
	return (kHeroVolleyTableCellHeight + ((int)(indexPath.row == [_challenges count] - 1) * 47.0));
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONVerifyViewCell *cell = (HONVerifyViewCell *)[_cells objectAtIndex:indexPath.row];
	[cell showTapOverlay];
	
	HONChallengeVO *challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row];
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Show Detail%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		NSLog(@"didSelectRowAtIndexPath:[%d]\n%@", indexPath.row, challengeVO.dictionary);
		
		_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithVerifyChallenge:_challengeVO];
		_snapPreviewViewController.delegate = self;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:5];
		[alertView show];
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - %@", (buttonIndex == 0) ? @"Approve & Follow" : (buttonIndex == 1) ? @"Approve" : @" Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0) {
			[self _addFriend:_challengeVO.creatorVO.userID];
			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:YES];
		
		} else if (buttonIndex == 1) {
			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:YES];
		}
	
	} else if (actionSheet.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Disprove %@", (buttonIndex == 0) ? @"Confirm" : @"Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0) {
			[[[UIAlertView alloc] initWithTitle:@""
										message:[NSString stringWithFormat:@"@%@ has been flagged & notified!", _challengeVO.creatorVO.username]
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:NO];
			
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Share %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																									@"image"			: [HONAppDelegate avatarImage],
																									@"url"				: @"",
																									@"mp_event"			: @"Verify - Share",
																									@"view_controller"	: self}];
		}
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - FAQ %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFAQViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if (alertView.tag == 3) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Create Volley Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
		
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Show Profile Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
		
	} else if (alertView.tag == 5) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Show Detail Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
		
	} else if (alertView.tag == 6) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Approve Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
		
	} else if (alertView.tag == 7) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Disprove Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	}
}

@end