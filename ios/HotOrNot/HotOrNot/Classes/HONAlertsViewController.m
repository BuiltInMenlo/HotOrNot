//
//  HONAlertsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:17 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONAlertsViewController.h"
#import "HONColorAuthority.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONAlertItemVO.h"
#import "HONChallengeVO.h"
#import "HONUserVO.h"
#import "HONHeaderView.h"
#import "HONCreateSnapButtonView.h"
#import "HONAlertItemViewCell.h"
#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONChallengeDetailsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONImagePickerViewController.h"
#import "HONAddContactsViewController.h"
#import "HONPopularViewController.h"
#import "HONSuggestedFollowViewController.h"
#import "HONAPICaller.h"
#import "HONImagingDepictor.h"
#import "HONMatchContactsViewController.h"


@interface HONAlertsViewController () <HONAlertItemViewCellDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSMutableArray *alertItems;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSMutableArray *headers;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIImageView *emptySetImageView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONProfileHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) NSArray *defaultCaptions;
@end


@implementation HONAlertsViewController

- (id)init {
	if ((self = [super init])) {
		_alertItems = [NSMutableArray array];
		
		_defaultCaptions = @[@"Find friends from contacts",
							 @"Find friends from my email",
							 @"Find friends from my phone #",
							 @"Search",
							 @"Suggested people"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedAlertsTab:) name:@"SELECTED_ALERTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareAlertsTab:) name:@"TARE_ALERTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshAlertsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshAlertsTab:) name:@"REFRESH_ALERTS_TAB" object:nil];
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
- (void)_retrieveAlerts {
	[[HONAPICaller sharedInstance] retrieveAlertsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
		_alertItems = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result) {
			if (dict != nil)
				[_alertItems addObject:[HONAlertItemVO alertWithDictionary:dict]];
		}
		
		_emptySetImageView.hidden = ([_alertItems count] > 0);
		[_tableView reloadData];
		
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:NO];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
	
	_emptySetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noMoreToVerify"]];
	_emptySetImageView.frame = CGRectOffset(_emptySetImageView.frame, 0.0, 58.0);
	_emptySetImageView.hidden = YES;
//	[_tableView addSubview:_emptySetImageView];
	
	_profileHeaderButtonView = [[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)];
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Activity" hasTranslucency:YES];
	[_headerView addButton:_profileHeaderButtonView];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	[self _retrieveAlerts];
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
	[[Mixpanel sharedInstance] track:@"Activity Alerts - Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
	userPofileViewController.userID = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_challengeDetails {
	[[Mixpanel sharedInstance] track:@"Activity Alerts - Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
	userPofileViewController.userID = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Activity Alerts - Create Volley%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
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
	[[Mixpanel sharedInstance] track:@"Activity Alerts - Refresh"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _retrieveAlerts];
	
	if ([HONAppDelegate incTotalForCounter:@"verifyRefresh"] == 3 && [HONAppDelegate switchEnabledForKey:@"verify_share"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Share %@ with your friends?", [HONAppDelegate brandedAppName]]
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];
	}
}

- (void)_goAddContacts {
	[[Mixpanel sharedInstance] track:@"Activity Alerts - Invite Friends"
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

- (void)_goMatchEmail {
	[[Mixpanel sharedInstance] track:@"Timeline - Match Email"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:YES]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSearch {
	[[Mixpanel sharedInstance] track:@"Activity Alerts - Search"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPopularViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSuggested {
	[[Mixpanel sharedInstance] track:@"Activity Alerts - Suggested Follow"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuggestedFollowViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goTakeAvatar {
	[[Mixpanel sharedInstance] track:@"Activity Alerts - Take New Avatar"
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
		if (_tutorialImageView != nil) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}
	}];
}

- (void)_goShare {
	[[Mixpanel sharedInstance] track:@"Activity Alerts - Share"
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
																							@"mp_event"			: @"Activity Alerts - Share",
																							@"view_controller"	: self}];
}


#pragma mark - Notifications
- (void)_selectedAlertsTab:(NSNotification *)notification {
	NSLog(@"_selectedAlertsTab");
	
	if ([HONAppDelegate incTotalForCounter:@"alerts"] == 1) {
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
		_tutorialImageView.image = [UIImage imageNamed:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? @"tutorial_activity-568h@2x" : @"tutorial_activity"];
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
		
		if (_tutorialImageView != nil) {
			[UIView animateWithDuration:0.33 animations:^(void) {
				_tutorialImageView.alpha = 1.0;
			}];
		}
	}
}

- (void)_refreshAlertsTab:(NSNotification *)notification {
	[self _retrieveAlerts];
}
- (void)_tareAlertsTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
}

#pragma mark - UI Presentation
- (void)_removeCellForAlertItem:(HONAlertItemVO *)alertItemVO {
	UITableViewCell *tableCell;
	for (HONAlertItemViewCell *cell in _cells) {
		if (cell.alertItemVO.alertID == alertItemVO.alertID) {
			tableCell = (UITableViewCell *)cell;
			[_cells removeObject:tableCell];
			break;
		}
	}
	
	//	NSLog(@"TABLECELL:[%@]", ((HONFollowTabViewCell *)tableCell).challengeVO.creatorVO.username);
	
	int ind = -1;
	for (HONAlertItemVO *vo in _alertItems) {
		ind++;
		
		if (vo.alertID == vo.alertID) {
			[_alertItems removeObject:vo];
			break;
		}
	}
	
	//	NSLog(@"CHALLENGE:(%d)[%@]", ind, challengeVO.creatorVO.username);
	
	if (tableCell != nil) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ind inSection:0];
		
		if (indexPath != nil) {
			[_tableView beginUpdates];
			[_tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationTop];
			[_tableView endUpdates];
			
			_emptySetImageView.hidden = [_alertItems count] > 0;
		}
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Activity Alerts - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - AlertViewCell Delegates
- (void)alertItemViewCell:(HONAlertItemViewCell *)cell alertItem:(HONAlertItemVO *)alertItemVO {
	NSLog(@"alertItemViewCell:[%@]", alertItemVO.dictionary);
	
	UIViewController *viewController;
	UINavigationController *navigationController;
	
	if (alertItemVO.triggerType == HONAlertCellTypeVerify) {
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
		userPofileViewController.userID = alertItemVO.userID;
		viewController = userPofileViewController;
		
	} else if (alertItemVO.triggerType == HONAlertCellTypeFollow) {
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
		userPofileViewController.userID = alertItemVO.userID;
		viewController = userPofileViewController;
		
	} else if (alertItemVO.triggerType == HONAlertCellTypeLike) {
		[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:alertItemVO.challengeID completion:^(NSObject *result){
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:(NSDictionary *)result]]];
			[navigationController setNavigationBarHidden:YES];
			[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
		}];
		
	} else if (alertItemVO.triggerType == HONAlertCellTypeShoutout) {
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
		userPofileViewController.userID = alertItemVO.userID;
		viewController = userPofileViewController;
		
	} else if (alertItemVO.triggerType == HONAlertCellTypeReply) {
		[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:alertItemVO.challengeID completion:^(NSObject *result){
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:(NSDictionary *)result]]];
			[navigationController setNavigationBarHidden:YES];
			[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
		}];
		
	} else {
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
		userPofileViewController.userID = alertItemVO.userID;
		viewController = userPofileViewController;
	}
	
	
	if (viewController != nil) {
		navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[navigationController setNavigationBarHidden:YES];
		[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_alertItems count] + 6);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 64.0, 320.0, 80.0)];
	bannerImageView.userInteractionEnabled = YES;
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectOffset(bannerImageView.frame, 0.0, -bannerImageView.frame.origin.y);
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[bannerImageView addSubview:shareButton];
	
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		bannerImageView.image = image;
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		bannerImageView.image = [UIImage imageNamed:@"banner_activity"];
	};
	
	[bannerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://s3.amazonaws.com/hotornot-banners/banner_activity.png"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:successBlock
									failure:failureBlock];
	
	return (bannerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONAlertItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONAlertItemViewCell alloc] initWithBackground:(indexPath.row < [_alertItems count] + 5)];
	
	
	if (indexPath.row < [_alertItems count]) {
		cell.alertItemVO = (HONAlertItemVO *)[_alertItems objectAtIndex:indexPath.row];
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	} else if (indexPath.row < [_alertItems count] + 5) {
		[cell removeChevron];
		cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
		cell.textLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
		cell.textLabel.text = [_defaultCaptions objectAtIndex:indexPath.row - [_alertItems count]];
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	} else {
		[cell removeChevron];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [_alertItems count] + 5)
		return ((([_alertItems count] + 5) > 7 + ((int)([[HONDeviceTraits sharedInstance] isPhoneType5s]) * 2)) ? 49.0 : 0.0);
	
	return (49.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (80.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row < [_alertItems count] || indexPath.row == [_alertItems count] + 5) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	switch (indexPath.row - [_alertItems count]) {
		case 0:
			[self _goAddContacts];
			break;
			
		case 1:
			[self _goMatchEmail];
			break;
			
		case 2:
			[self _goMatchPhone];
			break;
			
		case 3:
			[self _goSearch];
			break;
			
		case 4:
			[self _goSuggested];
			break;
			
		default:
			break;
	}
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"**_[scrollViewDidScroll]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	NSLog(@"**_[scrollViewDidEndDragging]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//	NSLog(@"**_[scrollViewDidEndScrollingAnimation]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_tableView setContentOffset:CGPointZero animated:NO];
}


@end
