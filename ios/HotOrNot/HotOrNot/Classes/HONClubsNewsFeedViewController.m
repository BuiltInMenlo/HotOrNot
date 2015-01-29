//
//  HONClubsNewsFeedViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 10:58 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "HONRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONClubsNewsFeedViewController.h"
#import "HONClubTimelineViewController.h"
//#import "HONUserProfileViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONCreateClubViewController.h"
#import "HONUserClubsViewController.h"
//#import "HONInviteContactsViewController.h"
#import "HONContactsSearchViewController.h"
#import "HONTabBannerView.h"
#import "HONClubNewsFeedViewCell.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONTableHeaderView.h"


@interface HONClubsNewsFeedViewController () <HONClubNewsFeedViewCellDelegate, HONTabBannerViewDelegate>
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONActivityHeaderButtonView *activityHeaderView;
@property (nonatomic, strong) HONTabBannerView *tabBannerView;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;
@property (nonatomic, strong) NSMutableDictionary *segmentedClubIDs;
@property (nonatomic, strong) NSMutableDictionary *clubIDs;
@property (nonatomic, strong) NSMutableDictionary *clubVOPhotoIDs;
@property (nonatomic, strong) NSMutableArray *ownedClubs;
@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) NSMutableArray *dictClubs;
@property (nonatomic, strong) NSMutableArray *dictClubPhotos;
@property (nonatomic, strong) NSArray *suggestedClubs;
@property (nonatomic, strong) NSMutableArray *timelineItems;
@end

@implementation HONClubsNewsFeedViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedNewsTab:) name:@"SELECTED_NEWS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareNewsTab:) name:@"TARE_NEWS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshNewsTab:) name:@"REFRESH_NEWS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshNewsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		
		_ownedClubs = [[NSMutableArray alloc] init];
		_allClubs = [[NSMutableArray alloc] init];
		_dictClubs = [[NSMutableArray alloc] init];
		_dictClubPhotos = [[NSMutableArray alloc] init];
		_timelineItems = [[NSMutableArray alloc] init];
		_clubIDs = [[NSMutableDictionary alloc] init];
		_clubVOPhotoIDs = [[NSMutableDictionary alloc] init];
		_segmentedClubIDs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array],
																[NSMutableArray array],
																[NSMutableArray array],
																[NSMutableArray array]]
													  forKeys:[[HONClubAssistant sharedInstance] clubTypeKeys]];
	}
	
	return (self);
}

- (void)dealloc {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubNewsFeedViewCell *cell = (HONClubNewsFeedViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
}


#pragma mark - Data Calls
- (void)_retrieveTimeline {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDDisplayTime;
	_progressHUD.taskInProgress = YES;
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_tableView.alpha = 0.0;
	}];
	
	_ownedClubs = [[NSMutableArray alloc] init];
	_allClubs = [[NSMutableArray alloc] init];
	_dictClubs = [[NSMutableArray alloc] init];
	_clubIDs = [[NSMutableDictionary alloc] init];
	_clubVOPhotoIDs = [[NSMutableDictionary alloc] init];
	_dictClubPhotos = [[NSMutableArray alloc] init];
	_timelineItems = [[NSMutableArray alloc] init];
	_segmentedClubIDs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array],
															[NSMutableArray array],
															[NSMutableArray array],
															[NSMutableArray array]]
												  forKeys:[[HONClubAssistant sharedInstance] clubTypeKeys]];
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] completion:^(NSDictionary *result) {
		[[HONClubAssistant sharedInstance] writeUserClubs:result];
		
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			if ([key isEqual:@"pending"])
				continue;
			
			NSMutableArray *clubIDs = [_segmentedClubIDs objectForKey:key];
			
			for (NSDictionary *dict in [result objectForKey:key]) {
				HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:dict];
				if ([key isEqualToString:@"owned"])
					[_ownedClubs addObject:vo];
				
				[_allClubs addObject:vo];
				if ([vo.submissions count] > 0 || vo.clubEnrollmentType == HONClubEnrollmentTypePending) {
					[clubIDs addObject:[NSNumber numberWithInt:vo.clubID]];
					[_dictClubs addObject:dict];
				}
			}
			
//			if ([key isEqualToString:@"member"])
//				[_dictClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]];
			
			[_segmentedClubIDs setValue:clubIDs forKey:key];
		}
		
		for (NSDictionary *dict in _dictClubs) {
			[[dict objectForKey:@"submissions"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSDictionary *photoDict = (NSDictionary *)obj;
				[_dictClubPhotos addObject:photoDict];
				[_clubVOPhotoIDs setValue:dict forKey:[photoDict objectForKey:@"challenge_id"]];
			}];
		}
		
		_timelineItems = nil;
		_timelineItems = [NSMutableArray array];
//		for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]]])
//			[_timelineItems addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		
		for (NSDictionary *dict in [NSArray arrayWithArray:[_dictClubPhotos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]])
			[_timelineItems addObject:[HONClubPhotoVO clubPhotoWithDictionary:dict]];
	
		[self _didFinishDataRefresh];
	}];
}

- (void)_joinClub:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] joinClub:userClubVO withMemberID:[[HONUserAssistant sharedInstance] activeUserID] completion:^(NSDictionary *result) {
		_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
		[self _retrieveTimeline];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:nil];
	}];
}


- (void)_createClubWithProtoVO:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] createClubWithTitle:userClubVO.clubName withDescription:userClubVO.blurb withImagePrefix:userClubVO.coverImagePrefix completion:^(NSDictionary *result) {
		_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
		[self _retrieveTimeline];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:nil];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[self _retrieveTimeline];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	_tableView.alpha = 1.0;
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];

	[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeSelfieclub ignoringCache:NO completion:nil];
	[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeFree ignoringCache:NO completion:nil];
	[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypePaid ignoringCache:NO completion:nil];
	[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeInviteBonus ignoringCache:YES completion:nil];
	
	_activityHeaderView = [[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)];
	_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_news", nil)];
	[_headerView addButton:_activityHeaderView];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
//	HONSearchBarView *searchBarView = [[HONSearchBarView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kSearchHeaderHeight)];
//	searchBarView.userInteractionEnabled = NO;
//	[self.view addSubview:searchBarView];
//	
//	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	searchButton.frame = searchBarView.frame;
//	[searchButton addTarget:self action:@selector(_goContactsSearch) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:searchButton];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, (kNavHeaderHeight + kSearchHeaderHeight), 320.0, self.view.frame.size.height - (kNavHeaderHeight + kSearchHeaderHeight))];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	if ([_timelineItems count] == 0)
		[self _retrieveTimeline];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewWillAppear:animated];
	
	if ([HONAppDelegate totalForCounter:@"background"] >= 3 && _tabBannerView == nil) {
		[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom + 65.0, _tableView.contentInset.right)];
		
		_tabBannerView = [[HONTabBannerView alloc] init];
		_tabBannerView.delegate = self;
		[self.view addSubview:_tabBannerView];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
	NSLog(@"newsTab_total:[%d]", [HONAppDelegate totalForCounter:@"newsTab"]);
	[_activityHeaderView updateActivityBadge];
}


#pragma mark - Navigation
- (void)_goProfile {
	//[[HONAnalyticsParams sharedInstance] trackEvent:@"Newsfeed - Activity"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[HONUserAssistant sharedInstance] activeUserID]] animated:YES];
}

- (void)_goCreateChallenge {
	//[[HONAnalyticsParams sharedInstance] trackEvent:@"Newsfeed - Create Selfie"];
	
	HONSelfieCameraViewController *selfieCameraViewController = [[HONSelfieCameraViewController alloc] initAsNewChallenge];
	selfieCameraViewController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selfieCameraViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[self _retrieveTimeline];
}

- (void)_goCreateClub {
	//[[HONAnalyticsParams sharedInstance] trackEvent:@"Newsfeed - Create Club"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goContactsSearch {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONContactsSearchViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_selectedNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedNewsTab <|::");
	[_activityHeaderView updateActivityBadge];
}

- (void)_refreshNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshNewsTab <|::");
	[_activityHeaderView updateActivityBadge];
	[self _goRefresh];
}

- (void)_tareNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareNewsTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
}


#pragma mark - SelfieCameraViewController Delegates
- (void)selfieCameraViewControllerDidDismissByInviteOverlay:(HONSelfieCameraViewController *)viewController {
	NSLog(@"[*:*] selfieCameraViewControllerDidDismissByInviteOverlay");
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - TabBannerView Delegates
- (void)tabBannerView:(HONTabBannerView *)bannerView joinAreaCodeClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:joinAreaCodeClub:[%@]", clubVO.clubName);
	
	_selectedClubVO = clubVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)tabBannerView:(HONTabBannerView *)bannerView joinFamilyClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:joinFamilyClub:[%@]", clubVO.clubName);
	
	_selectedClubVO = clubVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)tabBannerView:(HONTabBannerView *)bannerView joinSchoolClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:joinSchoolClub:[%d - %@]", clubVO.clubID, clubVO.clubName);
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
	
//	_selectedClubVO = clubVO;
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//														message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
//													   delegate:self
//											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//											  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
//	[alertView setTag:HONClubsNewsFeedAlertTypeJoinClub];
//	[alertView show];
}

- (void)tabBannerView:(HONTabBannerView *)bannerView createBaeClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:createBaeClub:[%d - %@]", clubVO.clubID, clubVO.clubName);
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)tabBannerViewInviteContacts:(HONTabBannerView *)bannerView {
	NSLog(@"[[*:*]] tabBannerViewInviteContacts");
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] userSignupClub] viewControllerPushed:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	
//	[self presentViewController:navigationController animated:YES completion:^(void) {
//	}];
//}


#pragma mark - ClubNewsFeedItemViewCell Delegates
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell createClubWithProtoVO:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:createClubWithProtoVO:(%@ - %@)", userClubVO.clubName, userClubVO.blurb);
	
	_selectedClubVO = userClubVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
														message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_no", nil), nil];
	[alertView setTag:HONClubsNewsFeedAlertTypeCreateClub];
	[alertView show];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell joinThresholdClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:joinThresholdClub:(%@ - %@)", userClubVO.clubName, userClubVO.blurb);
	
	_selectedClubVO = ([[HONContactsAssistant sharedInstance] totalInvitedContacts] >= [HONAppDelegate clubInvitesThreshold]) ? userClubVO : [[HONClubAssistant sharedInstance] userSignupClub];
	if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] < [HONAppDelegate clubInvitesThreshold]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_lockedClub_t", nil)
															message:[NSString stringWithFormat:NSLocalizedString(@"alert_lockedClub_m", nil), [HONAppDelegate clubInvitesThreshold], _selectedClubVO.clubName] //@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_invite", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
		[alertView setTag:HONClubsNewsFeedAlertTypeInviteFriends];
		[alertView show];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
		[alertView setTag:HONClubsNewsFeedAlertTypeJoinClub];
		[alertView show];
	}
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell enterTimelineForClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:enterTimelineForClub:(%@ - %@)", userClubVO.clubName, userClubVO.blurb);
	
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Newsfeed - Club Timeline"
//									   withUserClub:userClubVO];
	
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:userClubVO atPhotoIndex:0] animated:YES];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell joinClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:joinClub:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Newsfeed - Join Club"
//									   withUserClub:userClubVO];
	
	_selectedClubVO = userClubVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
														message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
	[alertView setTag:HONClubsNewsFeedAlertTypeJoinClub];
	[alertView show];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell replyToClubPhoto:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:replyToClubPhoto:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	HONSelfieCameraViewController *selfieCamerViewController = [[HONSelfieCameraViewController alloc] initWithClub:userClubVO];
	selfieCamerViewController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selfieCamerViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell upvoteClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:likeClubChallenge:(%d - %d)", clubPhotoVO.clubID, clubPhotoVO.userID);
	
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Newsfeed - Upvote"
//									  withClubPhoto:clubPhotoVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:clubPhotoVO.challengeID forOpponent:clubPhotoVO completion:^(NSDictionary *result) {
		[[HONAPICaller sharedInstance] retrieveUserByUserID:clubPhotoVO.userID completion:^(NSDictionary *result) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:[HONChallengeVO challengeWithDictionary:result]];
		}];
	}];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell showUserProfileForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:showUserProfileForClubPhoto:(%d - %@)", clubPhotoVO.clubID, clubPhotoVO.username);
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Newsfeed - Activity Avatar"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:clubPhotoVO.userID] animated:YES];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? 1 : [_timelineItems count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubNewsFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubNewsFeedViewCell alloc] init];
	
	if (indexPath.section == 0) {
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noPostsYetRow"]];
		
	} else {
		HONClubPhotoVO *clubPhotoVO = (HONClubPhotoVO *)[_timelineItems objectAtIndex:indexPath.row];
		HONUserClubVO *clubVO = [HONUserClubVO clubWithDictionary:[_clubVOPhotoIDs objectForKey:NSStringFromInt(clubPhotoVO.challengeID])];
		
		cell.clubVO = clubVO;
		cell.clubPhotoVO = clubPhotoVO;
		
		if (!tableView.decelerating)
			[cell toggleImageLoading:YES];
		
//		[cell setClubPhotoIndex:[cell.clubVO.submissions count] - 1];
	}
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125 delay:indexPath.row * 0.1 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return (([_allClubs count] == 0 || [_timelineItems count] == 0) ? kOrthodoxTableCellHeight : 0.0);
		
	else {
		HONClubPhotoVO *clubPhotoVO = (HONClubPhotoVO *)[_timelineItems objectAtIndex:indexPath.row];
		HONUserClubVO *clubVO = [HONUserClubVO clubWithDictionary:[_clubVOPhotoIDs objectForKey:NSStringFromInt(clubPhotoVO.challengeID])];
		
		return ((clubVO.clubEnrollmentType == HONClubEnrollmentTypePending) ? 50.0 : kOrthodoxTableCellHeight);
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONClubNewsFeedViewCell *cell = (HONClubNewsFeedViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		NSLog(@"OWNED:[%@]", [[HONClubAssistant sharedInstance] userSignupClub].dictionary);
		
		[[HONAPICaller sharedInstance] retrieveClubByClubID:[[HONClubAssistant sharedInstance] userSignupClub].clubID withOwnerID:[[HONClubAssistant sharedInstance] userSignupClub].ownerID completion:^(NSDictionary *result) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithClub:[HONUserClubVO clubWithDictionary:result]]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}];
		
	} else if (indexPath.section == 1) {
		_selectedClubVO = cell.clubVO;
		
		if (cell.clubVO.clubEnrollmentType == HONClubEnrollmentTypeOwner || cell.clubVO.clubEnrollmentType == HONClubEnrollmentTypeMember) {
			NSLog(@"/// SHOW CLUB TIMELINE:(%d - %@)", _selectedClubVO.clubID, _selectedClubVO.clubName);
//			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
			[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:_selectedClubVO atPhotoIndex:cell.clubPhotoIndex] animated:YES];
			
		} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeThreshold) {
			if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] < [HONAppDelegate clubInvitesThreshold]) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_lockedClub_t", nil)
																	message:[NSString stringWithFormat:NSLocalizedString(@"alert_lockedClub_m", nil), [HONAppDelegate clubInvitesThreshold], _selectedClubVO.clubName] //@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_invite", nil)
														  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
				[alertView setTag:HONClubsNewsFeedAlertTypeInviteFriends];
				[alertView show];
				
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
														  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
				[alertView setTag:HONClubsNewsFeedAlertTypeJoinClub];
				[alertView show];
			}
			
		} else if (cell.clubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
			NSLog(@"/// JOIN CLUB:(%d - %@)", _selectedClubVO.clubID, _selectedClubVO.clubName);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
			[alertView setTag:HONClubsNewsFeedAlertTypeJoinClub];
			[alertView show];
		}
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubNewsFeedViewCell *viewCell = (HONClubNewsFeedViewCell *)cell;
	[viewCell toggleImageLoading:NO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	NSArray *visibleCells = [_tableView visibleCells];
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubNewsFeedViewCell *cell = (HONClubNewsFeedViewCell *)obj;
		[cell toggleImageLoading:YES];
	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONClubsNewsFeedAlertTypeJoinClub) {
		if (buttonIndex == 0) {
			[self _joinClub:_selectedClubVO];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:NSLocalizedString(@"want_invite", nil), _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
													  otherButtonTitles:NSLocalizedString(@"not_now", nil), nil];
			[alertView setTag:HONClubsNewsFeedAlertTypeInviteFriends];
			[alertView show];
		}
		
	} else if (alertView.tag == HONClubsNewsFeedAlertTypeInviteFriends) {
		if (buttonIndex == 0) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == HONClubsNewsFeedAlertTypeCreateClub) {
		if (buttonIndex == 0) {
			[self _createClubWithProtoVO:_selectedClubVO];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat: NSLocalizedString(@"want_invite", nil), _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
													  otherButtonTitles:NSLocalizedString(@"not_now", nil), nil];
			[alertView setTag:HONClubsNewsFeedAlertTypeInviteFriends];
			[alertView show];
		}
	}
}

@end
