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

const NSInteger kOlderThresholdSeconds = (60 * 60 * 24) / 4;


@interface HONVerifyViewController() <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, HONVerifyViewCellDelegate, HONSnapPreviewViewControllerDelegate, HONUserProfileViewDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *headers;
@property (nonatomic, strong) NSMutableArray *cells;
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
				
				if ([userResult objectForKey:@"id"] != [NSNull null])
					[HONAppDelegate writeUserInfo:userResult];
				
				HONUserVO *userVO = [HONUserVO userWithDictionary:userResult];
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
			
			_challenges = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					[_challenges addObject:vo];
				}
			}

			[_refreshButtonView toggleRefresh:NO];
			_emptyImageView.hidden = [_challenges count] > 0;
			_bannerView.hidden = ![[[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"] isEqualToString:@"YES"];
			
			_isRefreshing = NO;
			[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
			[_tableView reloadData];
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
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
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
	
	//_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"] isEqualToString:@"YES"], [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"] isEqualToString:@"YES"])) style:UITableViewStylePlain];
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) withHeaderOffset:YES];
	_refreshTableHeaderView.delegate = self;
	[_tableView addSubview:_refreshTableHeaderView];
	[_refreshTableHeaderView refreshLastUpdatedDate];
	
	_profileOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
	_profileOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
	_profileOverlayView.alpha = 0.0;
	_profileOverlayView.hidden = YES;
	[self.view addSubview:_profileOverlayView];
	
	UIButton *closeProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeProfileButton.frame = _profileOverlayView.frame;
	[closeProfileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[_profileOverlayView addSubview:closeProfileButton];
	
	_userProfileView = [[HONUserProfileView alloc] initWithFrame:CGRectMake(0.0, -300.0, 320.0, 300.0)];
	_userProfileView.hidden = YES;
	_userProfileView.delegate = self;
	[self.view addSubview:_userProfileView];
	
	[_headerView addButton:_profileHeaderButtonView];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	[_refreshButtonView toggleRefresh:YES];
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
		} completion:^(BOOL finished) {
			_profileOverlayView.hidden = YES;
			_userProfileView.hidden = YES;
		}];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
		
	} else {
		[_userProfileView show];
		[_profileHeaderButtonView toggleSelected:YES];
		
		_profileOverlayView.hidden = NO;
		_userProfileView.hidden = NO;
		[UIView animateWithDuration:kProfileTime animations:^(void) {
			_profileOverlayView.alpha = 1.0;
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
		_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y - 90.0, _tableView.frame.size.width, _tableView.frame.size.height + 90.0);
		_emptyImageView.frame = CGRectOffset(_emptyImageView.frame, 0.0, -90.0);
	} completion:^(BOOL finished) {
		[_bannerView removeFromSuperview];
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"activity_banner"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
}


#pragma mark - Notifications
- (void)_selectedChallengesTab:(NSNotification *)notification {
//	[_tableView setContentOffset:CGPointZero animated:YES];
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
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	//_blurredImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fullScreenBlurBackground"]];
	[self.view addSubview:_blurredImageView];
	
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
	
	UITableViewCell *tableCell;
	for (HONVerifyViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == _challengeVO.challengeID) {
			tableCell = (UITableViewCell *)cell;
			break;
		}
	}
	
	_indexPath = [_tableView indexPathForCell:tableCell];
	
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
	heartImageView.frame = CGRectOffset(heartImageView.frame, 29.0, ([UIScreen mainScreen].bounds.size.height * 0.5) + 77.0);
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
	return ((indexPath.section == [_challenges count] - 1) ? 245.0 : 198.0);
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
	
	[[Mixpanel sharedInstance] track:@"Verify - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	//_blurredImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fullScreenBlurBackground"]];
	[self.view addSubview:_blurredImageView];
	
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
