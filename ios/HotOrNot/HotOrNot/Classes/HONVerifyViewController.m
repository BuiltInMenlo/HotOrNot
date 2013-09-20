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
#import "HONRefreshButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONSearchBarHeaderView.h"
#import "HONAddContactsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONAddContactsViewController.h"
#import "HONSettingsViewController.h"
#import "HONImagingDepictor.h"
#import "HONHeaderView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONUserProfileView.h"
#import "HONUserProfileViewController.h"
#import "HONCollectionViewFlowLayout.h"

const NSInteger kOlderThresholdSeconds = (60 * 60 * 24) / 4;


@interface HONVerifyViewController() <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, UIAlertViewDelegate, HONVerifyViewCellDelegate, HONSnapPreviewViewControllerDelegate, HONUserProfileViewDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) HONCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIView *collectionHolderView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *headers;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSMutableArray *dynamics;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONRefreshButtonView *refreshButtonView;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic) int blockCounter;
@property (nonatomic, strong) UIImageView *togglePrivateImageView;
@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONProfileHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) HONUserProfileView *userProfileView;
@property (nonatomic, strong) UIView *profileOverlayView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation HONVerifyViewController

- (id)init {
	if ((self = [super init])) {
		_challenges = [NSMutableArray array];
		_headers = [NSMutableArray array];
		_cells = [NSMutableArray array];
		_blockCounter = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedChallengesTab:) name:@"SELECTED_CHALLENGES_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshChallengesTab:) name:@"REFRESH_CHALLENGES_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshChallengesTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
- (void)_retrieveUser:(int)userID {
	if ([HONAppDelegate infoForUser]) {
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 5], @"action",
										[NSString stringWithFormat:@"%d", userID], @"userID",
										nil];
		
		VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
		AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
		[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			if (error != nil) {
				VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
				
				[_refreshButtonView toggleRefresh:NO];
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
			} else {
				NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
				
				HONUserVO *userVO = [HONUserVO userWithDictionary:userResult];
				_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
				_blurredImageView.alpha = 0.0;
				[self.view addSubview:_blurredImageView];
				
				[UIView animateWithDuration:0.25 animations:^(void) {
					_blurredImageView.alpha = 1.0;
				} completion:^(BOOL finished) {
				}];
				
				HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
				userPofileViewController.userVO = userVO;
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
				[navigationController setNavigationBarHidden:YES];
				[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
			
			[_refreshButtonView toggleRefresh:NO];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}];
	}
}

- (void)_retrieveChallenges {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetVerifyList);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetVerifyList parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			[_refreshButtonView toggleRefresh:NO];
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]]];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [parsedLists objectAtIndex:0]);
			
			int count = 0;
			_challenges = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					[_challenges addObject:vo];
				}
				
				count++;
				
				if (count >= 50)
					break;
			}

			[_refreshButtonView toggleRefresh:NO];
			_emptyImageView.hidden = [_challenges count] > 0;
			_bannerView.hidden = ![[[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"] isEqualToString:@"YES"];
			
//			[_collectionView reloadData];
			[_refreshControl endRefreshing];
			
			_flowLayout = [[HONCollectionViewFlowLayout alloc] init];
			_flowLayout.minimumLineSpacing = 0.0;
			
			_collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:_flowLayout];
			[_collectionView setDataSource:self];
			[_collectionView setDelegate:self];
			_collectionView.alpha = 0.0;
//			_collectionView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
			_collectionView.alwaysBounceVertical = YES;
			[_collectionView registerClass:[HONVerifyViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
			[_collectionHolderView addSubview:_collectionView];
			
			_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) withHeaderOffset:NO];
			_refreshTableHeaderView.delegate = self;
			[_collectionView addSubview:_refreshTableHeaderView];
			[_refreshTableHeaderView refreshLastUpdatedDate];
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_collectionView.alpha = 1.0;
			}];

			
			_isRefreshing = NO;
//			[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_collectionView];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
		[_refreshButtonView toggleRefresh:NO];
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
		
		[_collectionView reloadData];
		
		_isRefreshing = NO;
//		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_collectionView];
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
	//_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"] isEqualToString:@"YES"], [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"] isEqualToString:@"YES"])) style:UITableViewStylePlain];
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_isPrivate = NO;
	
	_profileHeaderButtonView = [[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)];
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Verify"];
	
	_bannerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 64.0, 320.0, 90.0)];
	_bannerView.hidden = ![[[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"] isEqualToString:@"YES"];
//	[self.view addSubview:_bannerView];
	
	UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
	[bannerImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate bannerForSection:2]] placeholderImage:nil];
	[_bannerView addSubview:bannerImageView];
	
	UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	bannerButton.frame = bannerImageView.frame;
	[bannerButton addTarget:self action:@selector(_goCloseBanner) forControlEvents:UIControlEventTouchUpInside];
	[_bannerView addSubview:bannerButton];
	
	_emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noOneVerify"]];
	_emptyImageView.frame = CGRectOffset(_emptyImageView.frame, 0.0, ([[[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"] isEqualToString:@"YES"] * 90.0));
	_emptyImageView.hidden = YES;
	[self.view addSubview:_emptyImageView];
	
	_collectionHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_collectionHolderView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
//	_refreshControl.tintColor = [UIColor whiteColor];
//	[_refreshControl addTarget:self action:@selector(_retrieveChallenges) forControlEvents:UIControlEventValueChanged];
//	[_collectionView addSubview:_refreshControl];

	
	_profileOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
	_profileOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
	_profileOverlayView.hidden = YES;
	[self.view addSubview:_profileOverlayView];
	
	UIButton *closeProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeProfileButton.frame = _profileOverlayView.frame;
	[closeProfileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[_profileOverlayView addSubview:closeProfileButton];
	
	_userProfileView = [[HONUserProfileView alloc] initWithFrame:CGRectMake(0.0, -391.0, 320.0, 455.0)];
	_userProfileView.delegate = self;
	_userProfileView.alpha = 0.0;
	[self.view addSubview:_userProfileView];
	
	[_headerView addButton:_profileHeaderButtonView];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	[_refreshButtonView toggleRefresh:YES];
	
	_dynamics = [NSMutableArray array];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[HONAppDelegate offsetSubviewsForIOS7:self.view];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self _retrieveChallenges];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goProfile {
	if (_userProfileView.isOpen) {
		[_userProfileView hide];
		[_profileHeaderButtonView toggleSelected:NO];
		
		[UIView animateWithDuration:kProfileTime animations:^(void) {
			_profileOverlayView.alpha = 0.0;
			_blurredImageView.alpha = 0.0;
			_userProfileView.alpha = 0.0;
		} completion:^(BOOL finished) {
			_profileOverlayView.hidden = YES;
			_userProfileView.hidden = YES;
			
			[_blurredImageView removeFromSuperview];
			_blurredImageView = nil;
		}];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
		
	} else {
		[_userProfileView show];
		[_profileHeaderButtonView toggleSelected:YES];
		
//		_blurredImageView = [[UIImageView alloc] initWithImage:[[HONImagingDepictor createImageFromView:self.view] applyBlurWithRadius:2.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.5] saturationDeltaFactor:1.0 maskImage:nil]];
//		_blurredImageView.alpha = 0.0;
//		[self.view addSubview:_blurredImageView];
		
		_profileOverlayView.hidden = NO;
		_userProfileView.hidden = NO;
		[UIView animateWithDuration:kProfileTime animations:^(void) {
			_profileOverlayView.alpha = 1.0;
			_blurredImageView.alpha = 1.0;
			_userProfileView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	}
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Verify - Create Volley"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Verify - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_isRefreshing = YES;
	[_refreshButtonView toggleRefresh:YES];
	[self _retrieveChallenges];
}

- (void)_goCloseBanner {
	[[Mixpanel sharedInstance] track:@"Verify - Close Banner"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
		_collectionView.frame = CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y - 90.0, _collectionView.frame.size.width, _collectionView.frame.size.height + 90.0);
		_emptyImageView.frame = CGRectOffset(_emptyImageView.frame, 0.0, -90.0);
	} completion:^(BOOL finished) {
		[_bannerView removeFromSuperview];
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"activity_banner"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
}


#pragma mark - Notifications
- (void)_selectedChallengesTab:(NSNotification *)notification {
	[_collectionView setContentOffset:CGPointZero animated:YES];
	[_refreshButtonView toggleRefresh:YES];
	[self _retrieveChallenges];
}

- (void)_refreshChallengesTab:(NSNotification *)notification {
	[_refreshButtonView toggleRefresh:YES];
	[self _retrieveChallenges];
}


#pragma mark - UserProfile Delegates
- (void)userProfileViewChangeAvatar:(HONUserProfileView *)userProfileView {
	[[Mixpanel sharedInstance] track:@"Profile - Take New Avatar"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _goProfile];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)userProfileViewInviteFriends:(HONUserProfileView *)userProfileView {
	[[Mixpanel sharedInstance] track:@"Profile - Find Friends Button"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _goProfile];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userProfileViewPromote:(HONUserProfileView *)userProfileView {
	[[Mixpanel sharedInstance] track:@"Profile - Promote Instagram"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _goProfile];
	UIImage *image = [HONImagingDepictor prepImageForSharing:[UIImage imageNamed:@"share_template"] avatarImage:[HONAppDelegate avatarImage] username:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_TO_INSTAGRAM" object:[NSDictionary dictionaryWithObjectsAndKeys:
																							[HONAppDelegate instagramShareComment], @"caption",
																							image, @"image", nil]];
}

- (void)userProfileViewSettings:(HONUserProfileView *)userProfileView {
	[[Mixpanel sharedInstance] track:@"Profile - Settings"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _goProfile];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userProfileViewTimeline:(HONUserProfileView *)userProfileView {
	[[Mixpanel sharedInstance] track:@"Profile - Timeline"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _goProfile];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:[[HONAppDelegate infoForUser] objectForKey:@"username"]];
}


#pragma mark - VerifyCell Delegates
- (void)challengeViewCell:(HONVerifyViewCell *)cell creatorProfile:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Verify - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	[self _retrieveUser:challengeVO.creatorVO.userID];
}

- (void)challengeViewCellShowPreview:(HONVerifyViewCell *)cell forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Verify - Show Detail"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithChallenge:_challengeVO asRoot:YES];
	_snapPreviewViewController.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)challengeViewCellHidePreview:(HONVerifyViewCell *)cell {
	[[Mixpanel sharedInstance] track:@"Verify - Hide Detail"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	[_snapPreviewViewController showControls];
}

- (void)challengeViewCell:(HONVerifyViewCell *)cell approveUser:(BOOL)isApproved forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	UICollectionViewCell *tableCell;
	for (HONVerifyViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == _challengeVO.challengeID) {
			tableCell = (UICollectionViewCell *)cell;
			break;
		}
	}
	
	_indexPath = [_collectionView indexPathForCell:tableCell];
	
	//NSLog(@"APPROVE:[%@]", _indexPath);
	
	if (isApproved) {
		[[Mixpanel sharedInstance] track:@"Verify - Approve"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", challengeVO.creatorVO.userID, challengeVO.creatorVO.username], @"opponent", nil]];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to verify @%@?", _challengeVO.creatorVO.username]
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Verify only", @"Verify & subscribe", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:0];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
	} else {
		[[Mixpanel sharedInstance] track:@"Verify - Disprove"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", challengeVO.creatorVO.userID, challengeVO.creatorVO.username], @"opponent", nil]];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Why should @%@ be flagged?", _challengeVO.creatorVO.username]
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Looks fake", @"Abusive content", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:0];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
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
	heartImageView.frame = CGRectOffset(heartImageView.frame, 29.0, ([UIScreen mainScreen].bounds.size.height * 0.5) + 32.0);
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


#pragma mark - CollectionView DataSource Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ([_challenges count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	HONVerifyViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
//    cell.backgroundColor = (indexPath.row % 2 == 0) ? [UIColor greenColor] : [UIColor redColor];
	cell.challengeVO = [_challenges objectAtIndex:indexPath.row];
	cell.delegate = self;
	
	[_cells addObject:cell];
    return (cell);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return (CGSizeMake(320.0, (indexPath.row == [_challenges count] - 1) ? 245.0 : 198.0)); //47
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	HONVerifyViewCell *cell = (HONVerifyViewCell *)[_cells objectAtIndex:indexPath.row];
	[cell showTapOverlay];
	
	HONChallengeVO *challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row];
	
	[[Mixpanel sharedInstance] track:@"Verify - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	[self _retrieveUser:challengeVO.creatorVO.userID];
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"BUTTON INDEX:[%d]", buttonIndex);
	
	if (actionSheet.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Approve%@", (buttonIndex == 0) ? @"" : (buttonIndex == 1) ? @" & Subscribe" : @" Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0) {
			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:YES];
		
		} else if (buttonIndex == 1) {
			[self _addFriend:_challengeVO.creatorVO.userID];
			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:YES];
		}
	
	} else if (actionSheet.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Verify - Disprove %@", (buttonIndex == 0) ? @"Fake" : (buttonIndex == 1) ? @"Abusive" : @"Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0 || buttonIndex == 1) {
			[[[UIAlertView alloc] initWithTitle:@""
										message:[NSString stringWithFormat:@"@%@ has been flagged & notified!", _challengeVO.creatorVO.username]
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:NO];
		}
	}
}

@end
