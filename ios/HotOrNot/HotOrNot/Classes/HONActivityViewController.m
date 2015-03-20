//
//  HONUserProfileViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NSDate+BuiltinMenlo.h"

#import "HONActivityViewController.h"
#import "HONRefreshControl.h"
#import "HONActivityItemViewCell.h"
#import "HONTableView.h"
#import "HONTableHeaderView.h"

#import "HONUserClubVO.h"
#import "HONActivityItemVO.h"

@interface HONActivityViewController () <HONActivityItemViewCellDelegate>
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, assign, readonly) HONActivityProfileType userProfileType;
@property (nonatomic, strong) NSMutableArray *activityAlerts;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation HONActivityViewController

- (id)init {
	if ((self = [super init])) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVITY - enter"];
		
		_viewStateType = HONStateMitigatorViewStateTypeActivity;
		_totalType = HONStateMitigatorTotalTypeActivity;
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO {
	if ((self = [self init])) {
		_userVO = userVO;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshProfile:)
													 name:@"REFRESH_PROFILE" object:nil];
	}
	
	return  (self);
}

- (void)dealloc {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONActivityItemViewCell *cell = (HONActivityItemViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
}


#pragma mark - Data Calls
- (void)_retrieveUser {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", @"Loading…");
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] retrieveUserByUserID:_userVO.userID completion:^(NSDictionary *result) {
		if ([result objectForKey:@"id"] != nil) {
			_userVO = [HONUserVO userWithDictionary:result];
			_userProfileType = ([[HONUserAssistant sharedInstance] activeUserID] == _userVO.userID) ? HONActivityProfileTypeUser : HONActivityProfileTypeOpponent;
			[self _retrieveActivityItems];
			
		} else {
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"user_notfound", @"User not found!");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
			_progressHUD = nil;
		}
	}];
}

- (void)_retrieveActivityItems {
	_activityAlerts = [NSMutableArray array];
	[[HONAPICaller sharedInstance] retrieveNewActivityForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] completion:^(NSArray *result) {
		[result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *dict = (NSDictionary *)obj;
			[_activityAlerts addObject:[HONActivityItemVO activityWithDictionary:dict]];
		}];
		
//		[_activityAlerts addObject:[HONActivityItemVO activityWithDictionary:@{@"id"			: [NSString stringWithFormat:@"0_2394_%d", (int)[[NSDate date] timeIntervalSince1970]],
//																			   @"activity_type"	: @"0",
//																			   @"challengeID"	: @"0",
//																			   @"club_id"		: @"0",
//																			   @"club_name"		: @"",
//																			   @"time"			: [[[HONUserAssistant sharedInstance] activeUserSignupDate] formattedISO8601String],
//																			   @"user"			: @{@"id"			: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
//																									@"username"		: [[HONUserAssistant sharedInstance] activeUsername],
//																									@"avatar_url"	: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]},
//																			   @"recip"			: @{@"id"			: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
//																									@"username"		: [[HONUserAssistant sharedInstance] activeUsername]}}]];
		
		[self _didFinishDataRefresh];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeActivityRefresh];
	
	[self _reloadTableContent];
}

- (void)_reloadTableContent {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_activityAlerts = [NSMutableArray array];
	[_tableView reloadData];
	[self _retrieveActivityItems];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
	
	if ([_activityAlerts count] == 0) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityRowBG"]];
		[_tableView addSubview:imageView];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 7.0, 202.0, 28.0)];
		titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
		titleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = NSLocalizedString(@"no_results", nil);
		[imageView addSubview:titleLabel];
	}
}



#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_activityAlerts = [NSMutableArray array];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight - 20.0, 320.0, self.view.frame.size.height - (kNavHeaderHeight))];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.alwaysBounceVertical = YES;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_activity", @"Activity")];
	[_headerView addCloseButtonWithTarget:self action:@selector(_goClose)];
	[self.view addSubview:_headerView];
	
//	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	closeButton.frame = CGRectMake(6.0, 2.0, 44.0, 44.0);
//	closeButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20];
//	[closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//	[closeButton setTitleColor:[[HONColorAuthority sharedInstance] honGreyTextColor] forState:UIControlStateHighlighted];
//	[closeButton setTitle:@"Submit" forState:UIControlStateNormal];
//	[closeButton setTitle:@"Submit" forState:UIControlStateHighlighted];
//	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
//	[_headerView addButton:closeButton];
	
	_activityAlerts = [NSMutableArray array];
	[_tableView reloadData];
	[self _retrieveActivityItems];
}


#pragma mark - Navigation
- (void)_goClose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Close"];
	[self dismissViewControllerAnimated:NO completion:^(void) {
	}];
}


#pragma mark - Notifications
- (void)_refreshProfile:(NSNotification *)notification {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_activityAlerts = [NSMutableArray array];
	[_tableView reloadData];
	[self _retrieveActivityItems];
}


#pragma mark - UI Presentation


#pragma mark - ActivityItemView Delegates
- (void)activityItemViewCell:(HONActivityItemViewCell *)cell showProfileForUser:(HONUserVO *)userVO {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Show User Activity"
//									  withUser:userVO];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_activityAlerts count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONActivityItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[HONActivityItemViewCell alloc] init];
	}
	
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	cell.activityItemVO = (HONActivityItemVO *)[_activityAlerts objectAtIndex:indexPath.row];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (44.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	HONActivityItemVO *vo = [_activityAlerts objectAtIndex:indexPath.row];
	return ((vo.activityType == HONActivityItemTypeSignup) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONActivityItemVO *vo = [_activityAlerts objectAtIndex:indexPath.row];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Selected Row"];
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVITY - copied_id"];
	
	NSLog(@"vo:[%@]", vo.dictionary);
	NSLog(@"vo.activityType:[%@]", (vo.activityType == HONActivityItemTypeClubSubmission) ? @"ClubSubmission" : (vo.activityType == HONActivityItemTypeInviteAccepted) ? @"InviteAccepted" : (vo.activityType == HONActivityItemTypeInviteRequest) ? @"InviteRequest" : (vo.activityType == HONActivityItemTypeLike) ? @"Like" : (vo.activityType == HONActivityItemTypeShoutout) ? @"Shoutout" : @"UNKNOWN");
	
	UIViewController *viewController;
	if (vo.activityType == HONActivityItemTypeInviteAccepted) {
		
	} else if (vo.activityType == HONActivityItemTypeInviteRequest) {
		if (_userProfileType == HONActivityProfileTypeOpponent) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithUser:[HONUserVO userFromUserVO: _userVO]]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else {
//			HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.originUserID];
//			viewController = userPofileViewController;
		}
		
	} else if (vo.activityType == HONActivityItemTypeLike) {
//		HONClubTimelineViewController *clubTimelineViewControler = [[HONClubTimelineViewController alloc] initWithClubID:vo.clubID withClubPhotoID:vo.challengeID];
//		viewController = clubTimelineViewControler;
		
	} else if (vo.activityType == HONActivityItemTypeShoutout) {
//		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.originUserID];
//		viewController = userPofileViewController;
		
	} else if (vo.activityType == HONActivityItemTypeClubSubmission) {
//		HONClubTimelineViewController *userPofileViewController = [[HONClubTimelineViewController alloc] initWithClubID:vo.clubID withClubPhotoID:vo.challengeID];
//		viewController = userPofileViewController;
	}
	
	if (viewController != nil)
		[self.navigationController pushViewController:viewController animated:YES];
}


@end
