//
//  HONUserClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"

#import "HONUserClubsViewController.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONTutorialView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONMessagesButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONUserClubViewCell.h"
#import "HONUserProfileViewController.h"
#import "HONMessagesViewController.h"
#import "HONImagePickerViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONUserClubDetailsViewController.h"
#import "HONCreateClubViewController.h"
#import "HONUserClubSettingsViewController.h"
#import "HONUserClubInviteViewController.h"
#import "HONUserClubVO.h"


#import "HONTrivialUserVO.h"

@interface HONUserClubsViewController () <EGORefreshTableHeaderDelegate, HONTutorialViewDelegate, HONUserClubViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONTutorialView *tutorialView;
@property (nonatomic, strong) HONUserClubVO *ownClub;
@property (nonatomic, strong) HONUserClubVO *selectedClub;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) NSMutableArray *invitedClubs;
@property (nonatomic, strong) HONProfileHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) NSArray *defaultCaptions;
@property (nonatomic, strong) NSArray *bakedClubs;
@end


@implementation HONUserClubsViewController

- (id)init {
	if ((self = [super init])) {
		_defaultCaptions = @[@"Add friends to my club",
							 @"Find my high school's club",
							 @"Selfieclubs nearby"];
		_defaultCaptions = @[];
		
		_bakedClubs = @[@{@"name": @"BFFs", @"img": @"https://d3j8du2hyvd35p.cloudfront.net/823ded776ab04e59a53eb166db67a78d_c54b3a029c25457389a188ac8a6dff24-1391186184Large_640x1136.jpg"},
						@{@"name": @"School", @"img": @"https://d3j8du2hyvd35p.cloudfront.net/3f3158660d1144a2ba2bb96d8fa79c96_5c7e2f9900fb4d9a930ac11a09b9facb-1389678527Large_640x1136.jpg"},
						@{@"name": @"Katy Perry", @"img" : @"https://s3.amazonaws.com/hotornot-challenges/katyPerryLarge_640x1136.jpg"}];
		
		_joinedClubs = [NSMutableArray array];
		_invitedClubs = [NSMutableArray array];
		
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
- (void)_retrieveClubs {
	for (NSDictionary *club in _bakedClubs) {
		[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:@{@"id"	: [NSString stringWithFormat:@"%d", arc4random() - 100],
																	@"name"	: [club objectForKey:@"name"],
																	@"img"	: [club objectForKey:@"img"]}]];
	}
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		
		if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0)
			_ownClub = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
				
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"joined"])
			[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)_retreiveClubInvites {
	for (NSDictionary *club in _bakedClubs) {
		[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:@{@"id"		: [NSString stringWithFormat:@"%d", arc4random() - 200],
																	 @"name"	: [club objectForKey:@"name"],
																	 @"img"		: [club objectForKey:@"img"]}]];//[[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:@"avatars"]] stringByAppendingString:kSnapLargeSuffix]}]];
	}
	
	[[HONAPICaller sharedInstance] retrieveClubInvitesForUserWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result) {
			[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		}
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)_joinClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] joinClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubs];
		[self _retreiveClubInvites];
	}];
}

- (void)_leaveClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] leaveClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubs];
		[self _retreiveClubInvites];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs"];
	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
//	[headerView addButton:[[HONMessagesButtonView alloc] initWithTarget:self action:@selector(_goMessages)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	[self _retrieveClubs];
	[self _retreiveClubInvites];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Refresh" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	_joinedClubs = [NSMutableArray array];
	_invitedClubs = [NSMutableArray array];
	
	[self _retrieveClubs];
	[self _retreiveClubInvites];
}

- (void)_goProfile {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Profile" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goMessages {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Messages" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController pushViewController:[[HONMessagesViewController alloc] init] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Create Challenge" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goClubSettings:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Settings"
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																								toUserClub:userClubVO]];
		
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goInviteFriends {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Invite Friends" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	if (_ownClub == nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Haven't Created A Club!"
															message:@"You need to create your own club before inviting anyone."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubInviteViewController alloc] initWithClub:_ownClub]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)_goFindSchoolClub {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Find High School" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[[[UIAlertView alloc] initWithTitle:@"No clubs found nearby!"
								message:@"Check back later"
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_goFindNearbyClubs {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Nearby Clubs" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[[[UIAlertView alloc] initWithTitle:@"No clubs found nearby!"
								message:@"Check back later"
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
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
	
	[self _retrieveClubs];
	[self _retreiveClubInvites];
}
- (void)_tareClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareClubsTab <|::");
	
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
}


#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Close Tutorial" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewTakeAvatar:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Tutorial Take Avatar" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}


#pragma mark - UserClubViewCell Delegates
- (void)userClubViewCell:(HONUserClubViewCell *)cell acceptInviteForClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Accept Invite"
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																								toUserClub:userClubVO]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accept Invite to the %@ club?", userClubVO.clubName]
														message:@""
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)userClubViewCell:(HONUserClubViewCell *)cell settingsForClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Edit Settings"
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																								toUserClub:userClubVO]];
		
	_selectedClub = userClubVO;
	
	if (userClubVO.clubID == _ownClub.clubID) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubSettingsViewController alloc] initWithClub:_ownClub]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];

	} else {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubSettingsViewController alloc] initWithClub:userClubVO]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:YES completion:nil];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Quit this club", nil];
		[actionSheet setTag:0];
		[actionSheet showInView:self.view];
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? 1 + [_joinedClubs count] : (section == 1) ? [_invitedClubs count] : (section == 2) ? [_defaultCaptions count] : 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (4);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:(section == 0) ? @"CLUBS" : @"ACCEPT"]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONUserClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONUserClubViewCell alloc] initAsInviteCell:(indexPath.section == 1)];
	
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			if (_ownClub == nil) {
				cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
				cell.textLabel.frame = CGRectOffset(cell.textLabel.frame, 0.0, -2.0);
				cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
				cell.textLabel.text = @"Tap here to start your own Selfieclub";
				cell.textLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
			
			} else {
				cell.userClubVO = _ownClub;
				cell.delegate = self;
			}
		
		} else {
			cell.userClubVO = (HONUserClubVO *)[_joinedClubs objectAtIndex:indexPath.row - 1];
			cell.delegate = self;
		}
		
	} else if (indexPath.section == 1) {
		cell.userClubVO = [_invitedClubs objectAtIndex:indexPath.row];
		cell.delegate = self;
	
	} else if (indexPath.section == 2) {
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
		cell.textLabel.frame = CGRectOffset(cell.textLabel.frame, 0.0, -2.0);
		cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		cell.textLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.text = [_defaultCaptions objectAtIndex:indexPath.row];
	
	} else {
		cell.backgroundView = nil;
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 || indexPath.section == 1)
		return (kOrthodoxTableCellHeight);
	
	else if (indexPath.section == 2)
		return (45.0);
	
	else
		return ((([_joinedClubs count] + [_invitedClubs count]) < 6 + ((int)([[HONDeviceTraits sharedInstance] isPhoneType5s]) * 2)) ? 0.0 : 49.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((section < 2) ? kOrthodoxTableHeaderHeight : 0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section < 3) ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			if (_ownClub == nil) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Create Club" withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				
			} else
				[self.navigationController pushViewController:[[HONUserClubDetailsViewController alloc] initWithClub:_ownClub] animated:YES];
		
		} else {
			[self.navigationController pushViewController:[[HONUserClubDetailsViewController alloc] initWithClub:(HONUserClubVO *)[_joinedClubs objectAtIndex:indexPath.row - 1]] animated:YES];
		}
		
	} else if (indexPath.section == 1) {
		HONUserClubVO *vo = (HONUserClubVO *)[_invitedClubs objectAtIndex:indexPath.row];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accept Invite to the %@ club?", vo.clubName]
															message:@""
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:0];
		[alertView show];
		
	} else if (indexPath.section == 2) {
		if (indexPath.row == 0)
			[self _goInviteFriends];
			
		else if (indexPath.row == 1)
			[self _goFindSchoolClub];
		
		else if (indexPath.row == 2)
			[self _goFindNearbyClubs];
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


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Clubs - Settings %@", (buttonIndex == 0) ? @"Quit" : @"Cancel"]
										 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																									toUserClub:_selectedClub]];
		
		if (buttonIndex == 0)
			[self _leaveClub:_selectedClub];
	}
}

#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Clubs - Accept Invite %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
										 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																									toUserClub:_selectedClub]];
		
		if (buttonIndex == 1)
			[self _joinClub:_selectedClub];
	}
}

@end
