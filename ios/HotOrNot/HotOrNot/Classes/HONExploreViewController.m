//
//  HONExploreViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "HONExploreViewController.h"
#import "HONCreateSnapButtonView.h"
#import "HONImagePickerViewController.h"
#import "HONTimelineViewController.h"
#import "HONExploreViewCell.h"
#import "HONImagingDepictor.h"
#import "HONHeaderView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONChallengeDetailsViewController.h"
#import "HONImagingDepictor.h"
#import "HONUserProfileViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONPopularViewController.h"
#import "HONAddContactsViewController.h"
#import "HONChangeAvatarViewController.h"


@interface HONExploreViewController ()<HONExploreViewCellDelegate, HONSnapPreviewViewControllerDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UIImageView *emptySetImgView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@end

@implementation HONExploreViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedExploreTab:) name:@"SELECTED_EXPLORE_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareExploreTab:) name:@"TARE_EXPLORE_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshExploreTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshExploreTab:) name:@"REFRESH_EXPLORE_TAB" object:nil];
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
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 1]};
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tableView.alpha = 0.0;
	}];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIDiscover, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIDiscover parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			VolleyJSONLog(@"AFNetworking [-] %@: EXPLORE TOT:%@", [[self class] description], parsedLists);
			
//			NSMutableArray *orgChallenges = [NSMutableArray arrayWithCapacity:[parsedLists count] + 2];
			_challenges = [NSMutableArray arrayWithCapacity:[parsedLists count] + 2];
			[_challenges addObject:[HONChallengeVO challengeWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"empty_challenge_-1"]]];
			[_challenges addObject:[HONChallengeVO challengeWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"empty_challenge_0"]]];
			
			for (NSDictionary *serverList in parsedLists) {
				if (serverList != nil)
					[_challenges addObject:[HONChallengeVO challengeWithDictionary:serverList]];
			}
//			[orgChallenges addObject:[HONChallengeVO challengeWithDictionary:serverList]];
			
			NSLog(@"TOT PRE SWAP:[%d]", [_challenges count]);
			[_challenges exchangeObjectAtIndex:2 withObjectAtIndex:0];
			[_challenges exchangeObjectAtIndex:7 withObjectAtIndex:1];

//			[_challenges exchangeObjectAtIndex:(arc4random() % MIN(4, [_challenges count])) withObjectAtIndex:0];
//			[_challenges exchangeObjectAtIndex:(arc4random() % MAX(6, [_challenges count] - 6)) + 4 withObjectAtIndex:1];
			NSLog(@"TOT POST SWAP:[%d]", [_challenges count]);
			
//			[_challenges insertObject:[HONChallengeVO challengeWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"empty_challenge_-1"]] atIndex:2];
//			[_challenges insertObject:[HONChallengeVO challengeWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"empty_challenge_0"]] atIndex:7];
			
//			int totItems = [orgChallenges count];
//			for (int i=0; i<totItems; i++) {
//				int rnd = arc4random() % [orgChallenges count];
//				NSLog(@"POS[%d] -=\\> RND:[%d]", i, rnd);
//				
//				[_challenges addObject:[orgChallenges objectAtIndex:rnd]];
//				[orgChallenges removeObjectAtIndex:rnd];
//				
//				if ([orgChallenges count] == 0)
//					break;
//			}
			
//			_challenges = [orgChallenges mutableCopy];
			
			_emptySetImgView.hidden = ([_challenges count] > 0);
//			for (NSDictionary *serverList in parsedLists)
//				[_challenges addObject:[HONChallengeVO challengeWithDictionary:serverList]];
			
//			[_challenges addObject:[HONChallengeVO challengeWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"empty_challenge_-1"]]];
//			[_challenges addObject:[HONChallengeVO challengeWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"empty_challenge_0"]]];
//			
//			NSMutableArray *swapVOs = [NSMutableArray arrayWithArray:_challenges];
//			NSMutableArray *swapIndexes = [NSMutableArray array];
//			for (int i=0; i<[_challenges count]; i++)
//				[swapIndexes addObject:[NSNumber numberWithInt:i]];
//			
//			int swapIndex = [swapVOs count] - 1;
//			for (int i=0; i<[_challenges count]; i--) {
//				int rnd = arc4random() % [swapIndexes count];
//				
//				[_challenges exchangeObjectAtIndex:i withObjectAtIndex:swapIndex];
//				[swapIndexes removeObjectAtIndex:i];
//			}
			
//			int searchSwapIndex = arc4random() % MIN(0, [swapVOs count]);
//			[swapVOs removeObjectAtIndex:searchSwapIndex];
//
//			int inviteSwapIndex = arc4random() % MIN(0, [swapVOs count]);
//			[swapVOs removeObjectAtIndex:inviteSwapIndex];
						
//			[_challenges replaceObjectAtIndex:inviteIndex withObject:inviteVO];
//			[_challenges replaceObjectAtIndex:searchIndex withObject:searchVO];
			
			[_tableView reloadData];
		}
		
		_tableView.alpha = 1.0;
		[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:NO];
		_isRefreshing = NO;
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIDiscover, [error localizedDescription]);
		
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
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
//	self.view.backgroundColor = [UIColor whiteColor];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Explore"];
	
	_emptySetImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 285.0)];
	_emptySetImgView.image = [UIImage imageNamed:@"noSnapsAvailable"];
	_emptySetImgView.hidden = YES;
	[self.view addSubview:_emptySetImgView];
	
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
	
//	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	searchButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
//	[searchButton setBackgroundImage:[UIImage imageNamed:@"exploreSearch_nonActive"] forState:UIControlStateNormal];
//	[searchButton setBackgroundImage:[UIImage imageNamed:@"exploreSearch_Active"] forState:UIControlStateHighlighted];
//	[searchButton addTarget:self action:@selector(_goSearch) forControlEvents:UIControlEventTouchUpInside];
	
	[_headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	[self _retrieveChallenges];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	[self _addBlur];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Discover - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	_isRefreshing = YES;
	[self _retrieveChallenges];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"exploreRefresh_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"exploreRefresh_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 3 && [HONAppDelegate switchEnabledForKey:@"explore_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"INVITE your friends to Selfieclub?"
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];
	}
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Create Volley%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
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
		[alertView setTag:1];
		[alertView show];
	}
}

- (void)_goAddContacts {
	[[Mixpanel sharedInstance] track:@"Explore - Invite Friends"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSearch {
	[[Mixpanel sharedInstance] track:@"Explore - Search"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPopularViewController alloc] init]];
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
- (void)_selectedExploreTab:(NSNotification *)notification {
//	_isRefreshing = YES;
//	[self _retrieveChallenges];
	
//	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
//	_progressHUD.mode = MBProgressHUDModeIndeterminate;
//	_progressHUD.minShowTime = kHUDTime;
//	_progressHUD.taskInProgress = YES;
	
//	if (total == 0) {
//		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//		_tutorialImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"tutorial_explore-568h@2x" : @"tutorial_explore"];
//		_tutorialImageView.userInteractionEnabled = YES;
//		_tutorialImageView.hidden = YES;
//		_tutorialImageView.alpha = 0.0;
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

- (void)_refreshExploreTab:(NSNotification *)notification {
	_isRefreshing = YES;
	[self _retrieveChallenges];
}
- (void)_tareExploreTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
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

#pragma mark - ExploreViewCell Delegates
- (void)exploreViewCellShowPreview:(HONExploreViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Show Detail%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:_challengeVO.creatorVO forChallenge:_challengeVO];
		_snapPreviewViewController.delegate = self;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
		
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

- (void)exploreViewCell:(HONExploreViewCell *)cell selectLeftChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Select Volley%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
		
		[self _addBlur];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:_challengeVO withBackground:_blurredImageView]];
		[navigationController setNavigationBarHidden:YES];
		[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
		
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

- (void)exploreViewCell:(HONExploreViewCell *)cell selectRightChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Select Volley%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
		
		[self _addBlur];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:_challengeVO withBackground:_blurredImageView]];
		[navigationController setNavigationBarHidden:YES];
		[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
		
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

- (void)exploreViewCellShowInvite:(HONExploreViewCell *)cell {
	[self _goAddContacts];
}

- (void)exploreViewCellShowSearch:(HONExploreViewCell *)cell {
	[self _goSearch];
}

- (void)exploreViewCell:(HONExploreViewCell *)cell showProfile:(HONOpponentVO *)opponentVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"challenge", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	[self _addBlur];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = opponentVO.userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
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
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]]];
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

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (ceil([_challenges count] * 0.5));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONExploreViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[HONExploreViewCell alloc] init];
	}
	
	cell.lChallengeVO = [_challenges objectAtIndex:(indexPath.row * 2)];
	
	if ((indexPath.row * 2) + 1 < [_challenges count])
		cell.rChallengeVO = [_challenges objectAtIndex:(indexPath.row * 2) + 1];
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row == ceil([_challenges count] * 0.5) - 1) ? 211.0 : 160);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		}
	
	} else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Create Volley Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Show Detail Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	
	} else if (alertView.tag == 3) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Explore - Select Volley Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	}
}


@end
