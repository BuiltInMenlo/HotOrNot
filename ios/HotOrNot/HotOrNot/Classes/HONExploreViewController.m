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
#import "HONSearchBarHeaderView.h"
#import "HONImagePickerViewController.h"
#import "HONTimelineViewController.h"
#import "HONExploreViewCell.h"
#import "HONImagingDepictor.h"
#import "HONHeaderView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONChallengeDetailsViewController.h"
#import "HONImagingDepictor.h"
#import "HONCollectionViewFlowLayout.h"
#import "HONUserProfileViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONPopularViewController.h"
#import "HONAddContactsViewController.h"


@interface HONExploreViewController ()<HONExploreViewCellDelegate, HONSnapPreviewViewControllerDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UIView *collectionHolderView;
//@property (nonatomic, strong) HONCollectionViewFlowLayout *flowLayout;
//@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UIImageView *emptySetImgView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) NSMutableDictionary *allChallenges;
@property (nonatomic, strong) NSMutableArray *currChallenges;
@property (nonatomic, strong) HONSearchBarHeaderView *searchHeaderView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONProfileHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation HONExploreViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedDiscoveryTab:) name:@"SELECTED_DISCOVERY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshDiscoveryTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshDiscoveryTab:) name:@"REFRESH_DISCOVERY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSearchTable:) name:@"SHOW_SEARCH_TABLE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideSearchTable:) name:@"HIDE_SEARCH_TABLE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_resignSearchBarFocus:) name:@"RESIGN_SEARCH_BAR_FOCUS" object:nil];
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
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIDiscover, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIDiscover parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], parsedLists);
			
			_currChallenges = [NSMutableArray array];
			_allChallenges = [NSMutableDictionary dictionary];
//			NSMutableArray *retrievedChallenges = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *challengeVO = [HONChallengeVO challengeWithDictionary:serverList];
				[_currChallenges addObject:challengeVO];
//				[retrievedChallenges addObject:[NSNumber numberWithInt:challengeVO.challengeID]];
//				[_allChallenges setObject:challengeVO forKey:[NSString stringWithFormat:@"c_%d", challengeVO.challengeID]];
			}
			
//			for (NSNumber *cID in [HONAppDelegate fillDiscoverChallenges:retrievedChallenges])
//				[_currChallenges addObject:[_allChallenges objectForKey:[NSString stringWithFormat:@"c_%d", [cID intValue]]]];
			
			
			
			_emptySetImgView.hidden = ([_currChallenges count] > 0);
			[_tableView reloadData];
			[_refreshControl endRefreshing];
			
//			_flowLayout = [[HONCollectionViewFlowLayout alloc] init];
//			_flowLayout.itemSize = CGSizeMake(320.0, 370.0);
//			_flowLayout.minimumLineSpacing = 0.0;
						
//			[UIView animateWithDuration:0.5 animations:^(void) {
//				_collectionView.alpha = 1.0;
//			}];
			
//			NSLog(@"ALL:[%d]\nCURR:[%d]", [_allChallenges count], [_currChallenges count]);
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		_isRefreshing = NO;
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIDiscover, [error localizedDescription]);
		
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
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_profileHeaderButtonView = [[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)];
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Explore"];
	
	_emptySetImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 285.0)];
	_emptySetImgView.image = [UIImage imageNamed:@"noSnapsAvailable"];
	_emptySetImgView.hidden = YES;
	[self.view addSubview:_emptySetImgView];
	
	_bannerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 64.0, 320.0, 90.0)];
//	[self.view addSubview:_bannerView];
	
	UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
	[bannerImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate bannerForSection:1]] placeholderImage:nil];
	[_bannerView addSubview:bannerImageView];
	
	UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	bannerButton.frame = bannerImageView.frame;
	[bannerButton addTarget:self action:@selector(_goCloseBanner) forControlEvents:UIControlEventTouchUpInside];
	[_bannerView addSubview:bannerButton];
	
	_collectionHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_collectionHolderView];
	
//	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//	flowLayout.minimumLineSpacing = 0.0;
	
//	_collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
//	[_collectionView setDataSource:self];
//	[_collectionView setDelegate:self];
//	[_collectionView registerClass:[HONExploreViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
//	[_collectionHolderView addSubview:_collectionView];
	
//	_refreshControl = [[UIRefreshControl alloc] init];
//	_refreshControl.tintColor = [UIColor whiteColor];
//	[_refreshControl addTarget:self action:@selector(_retrieveChallenges) forControlEvents:UIControlEventValueChanged];
	
	//_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"], 320.0, [UIScreen mainScreen].bounds.size.height - (90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"])) style:UITableViewStylePlain];
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
//	[_tableView addSubview:_refreshControl];
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) withHeaderOffset:NO];
	_refreshTableHeaderView.delegate = self;
	[_tableView addSubview:_refreshTableHeaderView];
	[_refreshTableHeaderView refreshLastUpdatedDate];

	
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	searchButton.frame = CGRectMake(-14.0, [UIScreen mainScreen].bounds.size.height - 103.0, 64.0, 64.0);
	[searchButton setBackgroundImage:[UIImage imageNamed:@"exploreSearch_nonActive"] forState:UIControlStateNormal];
	[searchButton setBackgroundImage:[UIImage imageNamed:@"exploreSearch_Active"] forState:UIControlStateHighlighted];
	[searchButton addTarget:self action:@selector(_goSearch) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:searchButton];
		
	[_headerView addButton:_profileHeaderButtonView];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self _retrieveChallenges];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[HONAppDelegate offsetSubviewsForIOS7:self.view];
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
	
	[_profileHeaderButtonView toggleSelected:YES];
	
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	_blurredImageView.alpha = 0.0;
	[self.view addSubview:_blurredImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Discover - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_isRefreshing = YES;
	[self _retrieveChallenges];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"exploreRefresh_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"exploreRefresh_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 3 && [HONAppDelegate switchEnabledForKey:@"explore_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"INVITE your friends to Volley?"
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];
	}

	
//	NSLog(@"refresh:[%d]", [_allChallenges count]);
//	_currChallenges = [NSMutableArray array];
//	
//	if ([_allChallenges count] > 0) {
//		for (NSNumber *cID in [HONAppDelegate refreshDiscoverChallenges])
//			[_currChallenges addObject:[_allChallenges objectForKey:[NSString stringWithFormat:@"c_%d", [cID intValue]]]];
//		
//		[self performSelector:@selector(_doneRefreshing) withObject:nil afterDelay:0.125];
//	}
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Explore - Create Volley"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goSearch {
	[[Mixpanel sharedInstance] track:@"Explore - Search"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPopularViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCloseBanner {
	[[Mixpanel sharedInstance] track:@"Explore - Close Banner"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
		_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y - 90.0, _tableView.frame.size.width, _tableView.frame.size.height + 90.0);
	} completion:^(BOOL finished) {
		[_bannerView removeFromSuperview];
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"discover_banner"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
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
- (void)_selectedDiscoveryTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	[self _goRefresh];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"explore_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"explore_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 0) {
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
		_tutorialImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"tutorial_explore-568h@2x" : @"tutorial_explore"];
		_tutorialImageView.userInteractionEnabled = YES;
		_tutorialImageView.alpha = 0.0;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = _tutorialImageView.frame;
		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:closeButton];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_tutorialImageView.alpha = 1.0;
		}];
	}
}

- (void)_refreshDiscoveryTab:(NSNotification *)notification {
	[self _goRefresh];
}

- (void)_showSearchTable:(NSNotification *)notification {
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[UIView animateWithDuration:0.125 delay:0.125 options:UIViewAnimationOptionCurveLinear animations:^(void) {
		//_tableView.frame = CGRectMake(0.0, 0.0, _tableView.frame.size.width, _tableView.frame.size.height);
		//_tableView.frame = CGRectOffset(_tableView.frame, 0.0, (-90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"]));
		_bannerView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_bannerView.hidden = YES;
	}];
}

- (void)_hideSearchTable:(NSNotification *)notification {
	_bannerView.hidden = NO;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void) {
//		_tableView.frame = CGRectMake(0.0, (90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"]), _tableView.frame.size.width, _tableView.frame.size.height);
//		_tableView.frame = CGRectOffset(_tableView.frame, 0.0, (90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"]));
		_bannerView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (void)_resignSearchBarFocus:(NSNotification *)notification {
	if (_searchHeaderView != nil)
		[_searchHeaderView toggleFocus:NO];
}


#pragma mark - UI Presentation
- (void)_doneRefreshing {
	[_tableView reloadData];
	
	_isRefreshing = NO;
//	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_collectionView];
}


#pragma mark - ExploreViewCell Delegates
- (void)exploreViewCellShowPreview:(HONExploreViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Explore - Show Detail"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:_challengeVO.creatorVO forChallenge:_challengeVO asRoot:YES];
	_snapPreviewViewController.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)exploreViewCellHidePreview:(HONExploreViewCell *)cell {
	[[Mixpanel sharedInstance] track:@"Explore - Hide Detail"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	[_snapPreviewViewController showControls];
}

- (void)exploreViewCell:(HONExploreViewCell *)cell selectLeftChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Explore - Select Volley"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	_challengeVO = challengeVO;
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	_blurredImageView.alpha = 0.0;
	[self.view addSubview:_blurredImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 1.0;
	} completion:^(BOOL finished) {
		//.modalTransitionStyle
	}];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:_challengeVO withBackground:_blurredImageView]];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)exploreViewCell:(HONExploreViewCell *)cell selectRightChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Explore - Select Volley"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	_challengeVO = challengeVO;
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	_blurredImageView.alpha = 0.0;
	[self.view addSubview:_blurredImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 1.0;
	} completion:^(BOOL finished) {
		//.modalTransitionStyle
	}];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:_challengeVO withBackground:_blurredImageView]];
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

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return ([NSDate date]);
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
	return (ceil([_currChallenges count] * 0.5));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	_searchHeaderView = [[HONSearchBarHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, kSearchHeaderHeight)];
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONExploreViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[HONExploreViewCell alloc] init];
	}
	
	cell.lChallengeVO = [_currChallenges objectAtIndex:(indexPath.row * 2)];
	
	if ((indexPath.row * 2) + 1 < [_currChallenges count])
		cell.rChallengeVO = [_currChallenges objectAtIndex:(indexPath.row * 2) + 1];
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row == ceil([_currChallenges count] * 0.5) - 1) ? 211.0 : 160);
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
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		}
	}
}


/*
#pragma mark - CollectionView DataSource Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (ceil([_currChallenges count] * 0.5));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	HONExploreViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
//    cell.backgroundColor = (indexPath.row % 2 == 0) ? [UIColor greenColor] : [UIColor redColor];
	cell.lChallengeVO = [_currChallenges objectAtIndex:(indexPath.row * 2)];
	
	if ((indexPath.row * 2) + 1 < [_currChallenges count])
		cell.rChallengeVO = [_currChallenges objectAtIndex:(indexPath.row * 2) + 1];
	
	cell.delegate = self;
	
    return (cell);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return (CGSizeMake(320.0, (indexPath.row == ceil([_currChallenges count] * 0.5) - 1) ? 211.0 : 160)); //47
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return (NO);
}*/


@end
