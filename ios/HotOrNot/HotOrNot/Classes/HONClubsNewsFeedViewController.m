//
//  HONClubsNewsFeedViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 10:58 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "NSString+DataTypes.h"

#import "CKRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONClubsNewsFeedViewController.h"
#import "HONClubTimelineViewController.h"
#import "HONUserProfileViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONCreateClubViewController.h"
#import "HONUserClubsViewController.h"
#import "HONInviteContactsViewController.h"
#import "HONClubNewsFeedViewCell.h"
#import "HONTableView.h"
#import "HONInviteOverlayView.h"
#import "HONHeaderView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONTableHeaderView.h"


@interface HONClubsNewsFeedViewController () <HONClubNewsFeedViewCellDelegate, HONInviteOverlayViewDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;

@property (nonatomic, strong) NSMutableDictionary *clubIDs;
@property (nonatomic, strong) NSMutableArray *ownedClubs;
@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) NSMutableArray *dictClubs;
@property (nonatomic, strong) NSArray *suggestedClubs;
@property (nonatomic, strong) NSMutableArray *timelineItems;
@property (nonatomic, strong) HONInviteOverlayView *inviteOverlayView;
@property (nonatomic) BOOL isFromCreateClub;
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
		_timelineItems = [[NSMutableArray alloc] init];
		_clubIDs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array],
																[NSMutableArray array],
																[NSMutableArray array],
																[NSMutableArray array]]
													  forKeys:[[HONClubAssistant sharedInstance] clubTypeKeys]];
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
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	_ownedClubs = [[NSMutableArray alloc] init];
	_allClubs = [[NSMutableArray alloc] init];
	_dictClubs = [[NSMutableArray alloc] init];
	_timelineItems = [[NSMutableArray alloc] init];
	_clubIDs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array],
															[NSMutableArray array],
															[NSMutableArray array],
															[NSMutableArray array]]
												  forKeys:[[HONClubAssistant sharedInstance] clubTypeKeys]];
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		[[HONClubAssistant sharedInstance] writeUserClubs:result];
		
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
			
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
			
			[_clubIDs setValue:clubIDs forKey:key];
		}
		
		
		_timelineItems = nil;
		_timelineItems = [NSMutableArray array];
		for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]]])
			[_timelineItems addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		_suggestedClubs = nil;
		_suggestedClubs = [[HONClubAssistant sharedInstance] suggestedClubs];
//		_feedContentType = HONFeedContentTypeEmpty;
//		_feedContentType += (((int)[[_clubIDs objectForKey:@"other"] count] > 0) * HONFeedContentTypeAutoGenClubs);
//		_feedContentType += (((int)[[_clubIDs objectForKey:@"owned"] count] > 0) * HONFeedContentTypeOwnedClubs);
//		_feedContentType += (((int)[[_clubIDs objectForKey:@"member"] count] > 0) * HONFeedContentTypeJoinedClubs);
//		_feedContentType += (((int)[[_clubIDs objectForKey:@"pending"] count] > 0) * HONFeedContentTypeClubInvites);
		
		[self _didFinishDataRefresh];
	}];
}

- (void)_joinClub:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] joinClub:userClubVO withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
	}];
}


- (void)_createClubWithProtoVO:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] createClubWithTitle:userClubVO.clubName withDescription:userClubVO.blurb withImagePrefix:userClubVO.coverImagePrefix completion:^(NSDictionary *result) {
		_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
		[self _retrieveTimeline];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[self _retrieveTimeline];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_isFromCreateClub = NO;
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle: NSLocalizedString(@"header_news", nil)];
	[headerView addButton:[[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) style:UITableViewStylePlain];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
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
	
	NSLog(@"newsTab_total:[%d]", [HONAppDelegate totalForCounter:@"newsTab"]);
	if ([HONAppDelegate incTotalForCounter:@"newsTab"] == 1) {
//		[[[UIAlertView alloc] initWithTitle:@"News Tip"
//									message:@"The more clubs you join the more your feed fills up!"
//								   delegate:nil
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil] show];
	}
	
	if (_isFromCreateClub) {
		_isFromCreateClub = NO;
		
		_inviteOverlayView = [[HONInviteOverlayView alloc] initWithContentImage:@"tutorial_resume"];
		_inviteOverlayView.delegate = self;
		
		[[HONScreenManager sharedInstance] appWindowAdoptsView:_inviteOverlayView];
		[_inviteOverlayView introWithCompletion:nil];
	}
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
- (void)_goProfile {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Newsfeed - Activity"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Create Selfie"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[self _retrieveTimeline];
}

- (void)_goConfirmClubs {
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateClub {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Create Club"];
	
	_isFromCreateClub = YES;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_selectedNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedNewsTab <|::");
}

- (void)_refreshNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshNewsTab <|::");
	[self _goRefresh];
}

- (void)_tareNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareNewsTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
}


#pragma mark - ClubNewsFeedItemViewCell Delegates
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell createClubWithProtoVO:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:createClubWithProtoVO:(%@ - %@)", userClubVO.clubName, userClubVO.blurb);
	
	_selectedClubVO = userClubVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
														message:[NSString stringWithFormat:@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
													   delegate:self
											  cancelButtonTitle:@"Yes"
											  otherButtonTitles:@"No", nil];
	[alertView setTag:HONClubsNewsFeedAlertTypeCreateClub];
	[alertView show];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell enterTimelineForClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:enterTimelineForClub:(%@ - %@)", userClubVO.clubName, userClubVO.blurb);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Newsfeed - Club Timeline"
									   withUserClub:userClubVO];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:userClubVO atPhotoIndex:0] animated:YES];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell joinClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:joinClub:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Newsfeed - Join Club"
									   withUserClub:userClubVO];
	
	_selectedClubVO = userClubVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
														message:[NSString stringWithFormat:@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:@"Cancel", nil];
	
	[alertView setTag:HONClubsNewsFeedAlertTypeJoinClub];
	[alertView show];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell replyToClubPhoto:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:replyToClubPhoto:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithClub:userClubVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell upvoteClubPhoto:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:likeClubChallenge:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Newsfeed - Upvote"
									   withUserClub:userClubVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	[[HONAPICaller sharedInstance] verifyUserWithUserID:((HONClubPhotoVO *)[userClubVO.submissions lastObject]).userID asLegit:YES completion:^(NSDictionary *result) {
		[[HONAPICaller sharedInstance] retrieveUserByUserID:((HONClubPhotoVO *)[userClubVO.submissions lastObject]).userID completion:^(NSDictionary *result) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:[HONChallengeVO challengeWithDictionary:result]];
		}];
	}];
}

- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell showUserProfileForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:showUserProfileForClubPhoto:(%d - %@)", clubPhotoVO.clubID, clubPhotoVO.username);
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Newsfeed - Activity Avatar"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:clubPhotoVO.userID] animated:YES];
}


#pragma mark - InviteOverlayView Delegates
- (void)inviteOverlayViewClose:(HONInviteOverlayView *)inviteOverlayView {
	[_inviteOverlayView outroWithCompletion:^(BOOL finished) {
		[_inviteOverlayView removeFromSuperview];
		_inviteOverlayView = nil;
	}];
}

- (void)inviteOverlayViewInvite:(HONInviteOverlayView *)inviteOverlayView {
	[_inviteOverlayView outroWithCompletion:^(BOOL finished) {
		[_inviteOverlayView removeFromSuperview];
		_inviteOverlayView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}];
}

- (void)inviteOverlayViewSkip:(HONInviteOverlayView *)inviteOverlayView {
	[_inviteOverlayView outroWithCompletion:^(BOOL finished) {
		[_inviteOverlayView removeFromSuperview];
		_inviteOverlayView = nil;
	}];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? 1 : (section == 1) ? [_suggestedClubs count] : [_timelineItems count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (3);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubNewsFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubNewsFeedViewCell alloc] init];
	
	
	if (indexPath.section == 0) {
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"createPostNewsFeedBG"]];
			
	} else if (indexPath.section == 1) {
		cell.clubVO = (HONUserClubVO *)[_suggestedClubs objectAtIndex:indexPath.row];
	
	} else {
		cell.clubVO = (HONUserClubVO *)[_timelineItems objectAtIndex:indexPath.row];
	}
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if ([_allClubs count] == 0)
			return (0.0);
		
		else
			return (([[_clubIDs objectForKey:@"owned"] count] == 0 && [[_clubIDs objectForKey:@"member"] count] == 0) ? kOrthodoxTableCellHeight : 0.0);
	
	} else if (indexPath.section == 1) {
		return (50.0);
	
	} else {
		HONUserClubVO *vo = [_allClubs objectAtIndex:indexPath.row];
		return ((vo.clubEnrollmentType == HONClubEnrollmentTypePending) ? 50 : 74.0);
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
		NSLog(@"OWNED:[%@]", [_ownedClubs firstObject]);
		
		[[HONAPICaller sharedInstance] retrieveClubByClubID:((HONUserClubVO *)[_ownedClubs firstObject]).clubID withOwnerID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithClub:[HONUserClubVO clubWithDictionary:result]]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}];
	
	} else if (indexPath.section == 1) {
		_selectedClubVO = (HONUserClubVO *)[_suggestedClubs objectAtIndex:indexPath.row];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:[NSString stringWithFormat:@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
														   delegate:self
												  cancelButtonTitle:@"Yes"
												  otherButtonTitles:@"No", nil];
		[alertView setTag:HONClubsNewsFeedAlertTypeCreateClub];
		[alertView show];
	
	} else {
		_selectedClubVO = (HONUserClubVO *)[_timelineItems objectAtIndex:indexPath.row];
		
		if (cell.clubVO.clubEnrollmentType == HONClubEnrollmentTypeOwner || cell.clubVO.clubEnrollmentType == HONClubEnrollmentTypeMember) {
			NSLog(@"/// SHOW CLUB TIMELINE:(%d - %@)", _selectedClubVO.clubID, _selectedClubVO.clubName);
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
			[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:_selectedClubVO atPhotoIndex:0] animated:YES];
		
		} else {
			NSLog(@"/// JOIN CLUB:(%d - %@)", _selectedClubVO.clubID, _selectedClubVO.clubName);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:@"Cancel", nil];
			[alertView setTag:HONClubsNewsFeedAlertTypeJoinClub];
			[alertView show];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONClubsNewsFeedAlertTypeJoinClub) {
		if (buttonIndex == 0) {
			[self _joinClub:_selectedClubVO];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:@"Want to invite friends to %@?", _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"Not Now", nil];
			[alertView setTag:HONClubsNewsFeedAlertTypeInviteFriends];
			[alertView show];
		}
	
	} else if (alertView.tag == HONClubsNewsFeedAlertTypeInviteFriends) {
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		
		} else
			[self _retrieveTimeline];
	
	} else if (alertView.tag == HONClubsNewsFeedAlertTypeCreateClub) {
		if (buttonIndex == 0) {
			[self _createClubWithProtoVO:_selectedClubVO];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:@"Want to invite friends to %@?", _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"Not Now", nil];
			[alertView setTag:HONClubsNewsFeedAlertTypeInviteFriends];
			[alertView show];
		}
	}
}

@end
