//
//  HONClubsTimelineViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 10:58 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"


#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

#import "HONClubsTimelineViewController.h"
#import "HONClubTimelineViewCell.h"
#import "HONTutorialView.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONCreateSnapButtonView.h"

#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONSelfieCameraViewController.h"

#import "HONTimelineItemVO.h"


@interface HONClubsTimelineViewController () <EGORefreshTableHeaderDelegate, HONClubTimelineViewCellDelegate, HONTutorialViewDelegate>
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *toggleListsButton;
@property (nonatomic, strong) HONTutorialView *tutorialView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NSMutableArray *dictItems;
@property (nonatomic, strong) NSMutableArray *allItems;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) NSMutableArray *invitedClubs;
@property (nonatomic, assign) HONClubsListType clubsListType;
@property (nonatomic, strong) HONUserClubVO *ownClub;
@end


@implementation HONClubsTimelineViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedClubsTab:) name:@"SELECTED_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareClubsTab:) name:@"TARE_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_CLUB_TAB" object:nil];
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
- (void)_retrieveTimeline {
	[[HONAPICaller sharedInstance] retrieveTimelineForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result) {
			[_dictItems addObject:dict];
		}
		
		[self _retrieveClubInvites];
	}];
}

- (void)_retrieveClubs {
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		
		if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0)
			_ownClub = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
		
		// --//> *** POPULATED FPO CLUB *** <//-- //
		[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:[[HONAppDelegate fpoClubDictionaries] objectAtIndex:1]]];
		[_dictItems addObject:[[HONAppDelegate fpoClubDictionaries] objectAtIndex:1]];
		
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"joined"]) {
			[_dictItems addObject:dict];
			[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		}
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)_retrieveClubInvites {
	
	// --//> *** POPULATED FPO CLUB - 6x *** <//-- //
	for (int i=0; i<3; i++) {
		for (NSDictionary *dict in [HONAppDelegate fpoClubDictionaries]) {
			[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
			[_dictItems addObject:dict];
		}
	}
		
	[[HONAPICaller sharedInstance] retrieveClubInvitesForUserWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result) {
			[_dictItems addObject:dict];
		}
		
		[self _sortItems];
	}];
}


#pragma mark - Data Tally
- (void)_sortItems {
	for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]])
		[_allItems addObject:[HONTimelineItemVO timelineItemWithDictionary:dict]];
	
	[_tableView reloadData];
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}



#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_clubsListType = HONClubsListTypeTimeline;
	
	_dictItems = [NSMutableArray array];
	_allItems = [NSMutableArray array];
	
	_invitedClubs = [NSMutableArray array];
	_joinedClubs = [NSMutableArray array];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	[_tableView setContentInset:UIEdgeInsetsMake(kNavHeaderHeight + 55.0, 0.0, -1.0, 0.0)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) usingTareOffset:kNavHeaderHeight + 55.0];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
	
	_toggleListsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_toggleListsButton.frame = CGRectMake(0.0, -50.0, 320.0, 44.0);
	[_toggleListsButton setBackgroundImage:[UIImage imageNamed:@"toggleClubs_timeline"] forState:UIControlStateNormal];
	[_toggleListsButton setBackgroundImage:[UIImage imageNamed:@"toggleClubs_timeline"] forState:UIControlStateHighlighted];
	[_toggleListsButton addTarget:self action:@selector(_goToggleList) forControlEvents:UIControlEventTouchUpInside];
	[_tableView addSubview:_toggleListsButton];
	
	UILabel *toggleNewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 12.0, 150.0, 17.0)];
	toggleNewsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	toggleNewsLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	toggleNewsLabel.backgroundColor = [UIColor clearColor];
	toggleNewsLabel.textAlignment = NSTextAlignmentCenter;
	toggleNewsLabel.text = @"News";
	[_toggleListsButton addSubview:toggleNewsLabel];
	
	UILabel *toggleClubsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 12.0, 150.0, 17.0)];
	toggleClubsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	toggleClubsLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	toggleClubsLabel.backgroundColor = [UIColor clearColor];
	toggleClubsLabel.textAlignment = NSTextAlignmentCenter;
	toggleClubsLabel.text = [NSString stringWithFormat:@"My Clubs (%d)", ((int)(_ownClub != nil) + [_joinedClubs count] + [_invitedClubs count])];
	[_toggleListsButton addSubview:toggleClubsLabel];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs"];
	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	[self _retrieveTimeline];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Refresh"];
	
	_dictItems = [NSMutableArray array];
	_allItems = [NSMutableArray array];
	
	_invitedClubs = [NSMutableArray array];
	_joinedClubs = [NSMutableArray array];
	
	[self _retrieveTimeline];
}

- (void)_goProfile {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Profile"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Create Challenge"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goToggleList {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Clubs Timeline - Toggle %@ List", (_clubsListType == HONClubsListTypeTimeline) ? @"My Clubs" : @"News"]];
	_clubsListType = (_clubsListType == HONClubsListTypeTimeline) ? HONClubsListTypeSubscriptions : HONClubsListTypeTimeline;
	
	[_toggleListsButton setBackgroundImage:[UIImage imageNamed:(_clubsListType == HONClubsListTypeTimeline) ? @"toggleClubs_timeline" : @"toggleClubs_subscriptions"] forState:UIControlStateNormal];
	[_toggleListsButton setBackgroundImage:[UIImage imageNamed:(_clubsListType == HONClubsListTypeTimeline) ? @"toggleClubs_timeline" : @"toggleClubs_subscriptions"] forState:UIControlStateHighlighted];
}


#pragma mark - Notifications
- (void)_selectedClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedClubsTab <|::");
	
//	if ([HONAppDelegate incTotalForCounter:@"clubs"] == 0) {
//		_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:@"tutorial_messages"]];
//		_tutorialView.delegate = self;
//
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialView];
//		[_tutorialView introWithCompletion:nil];
//	}
}

- (void)_refreshClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshClubsTab <|::");
	
	[self _retrieveTimeline];
	[self _retrieveClubInvites];
}
- (void)_tareClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareClubsTab <|::");
	
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
}


#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Close Tutorial"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewTakeAvatar:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Tutorial Take Avatar"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}


#pragma mark - ClubsTimelineViewCell Delegates
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell selectedCTARow:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubTimelineViewCell:selectedCTARow:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Selected CTA Row"
									   withUserClub:userClubVO];
	
	
}

- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell selectedClubRow:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] selectedClubRow:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Selected Club Row"
									   withUserClub:userClubVO];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_allItems count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubTimelineViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubTimelineViewCell alloc] init];
	
	cell.timelineItemVO = (HONTimelineItemVO *)[_allItems objectAtIndex:indexPath.row];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONTimelineItemVO *vo = (HONTimelineItemVO *)[_allItems objectAtIndex:indexPath.row];
	return ((vo.timelineItemType == HONTimelineItemTypeSelfie) ? 330.0 : 100.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONClubTimelineViewCell *cell = (HONClubTimelineViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) {
		HONTimelineItemVO *vo = (HONTimelineItemVO *)[_allItems objectAtIndex:indexPath.row];
		vo.userClubVO.clubID = 40;
		
		NSLog(@"/// SHOW CLUB TIMELINE:(%@ - %@)", [vo.dictionary objectForKey:@"id"], [vo.dictionary objectForKey:@""]);
		[[HONAPICaller sharedInstance] retrieveClubByClubID:40 completion:^(NSObject *result) {
			
		}];
		
		
	} else if (cell.timelineItemVO.timelineItemType == HONTimelineItemTypeInviteRequest) {
		NSLog(@"/// SHOW CLUB STATS:(%@)", ((HONTimelineItemVO *)[_allItems objectAtIndex:indexPath.row]).dictionary);
	
	} else
		NSLog(@"/// SOMETHING ELSE:(%@)", ((HONTimelineItemVO *)[_allItems objectAtIndex:indexPath.row]).dictionary);
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[_tableView setContentOffset:CGPointZero animated:NO];
}



@end
