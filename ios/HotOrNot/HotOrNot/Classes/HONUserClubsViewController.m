//
//  HONUserClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "EGORefreshTableHeaderView.h"
#import "JLBPopSlideTransition.h"
#import "MBProgressHUD.h"

#import "HONUserClubsViewController.h"
#import "HONClubsViewLayout.h"

#import "HONTableHeaderView.h"
#import "HONClubViewCell.h"
#import "HONHeaderView.h"
#import "HONCreateSnapButtonView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONSelfieCameraViewController.h"
#import "HONCreateClubViewController.h"
#import "HONClubSettingsViewController.h"
#import "HONClubInviteViewController.h"
#import "HONFeedViewController.h"
#import "HONUserClubVO.h"


#import "HONTrivialUserVO.h"

@interface HONUserClubsViewController () <EGORefreshTableHeaderDelegate, HONClubViewCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) NSMutableArray *ownedClubs;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) NSMutableArray *invitedClubs;
@property (nonatomic, strong) NSMutableArray *otherClubs;
@property (nonatomic, strong) HONUserClubVO *selectedClub;
@property (nonatomic, strong) HONActivityHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end


@implementation HONUserClubsViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedClubsTab:) name:@"SELECTED_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareClubsTab:) name:@"TARE_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_allClubs = [NSMutableArray array];
	_ownedClubs = [NSMutableArray array];
	_joinedClubs = [NSMutableArray array];
	_invitedClubs = [NSMutableArray array];
	_otherClubs = [NSMutableArray array];
	
	[_joinedClubs addObject:[[HONClubAssistant sharedInstance] fpoInviteClubs]];
	[_joinedClubs addObject:[[HONClubAssistant sharedInstance] fpoJoinedClubs]];
	[_joinedClubs addObject:[[HONClubAssistant sharedInstance] fpoInviteClubs]];
	[_joinedClubs addObject:[[HONClubAssistant sharedInstance] fpoJoinedClubs]];
	[_joinedClubs addObject:[[HONClubAssistant sharedInstance] fpoInviteClubs]];
	
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"owned"])
			[_ownedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		[_allClubs addObjectsFromArray:_ownedClubs];
		
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"member"])
			[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		[_allClubs addObjectsFromArray:_joinedClubs];
		
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"pending"])
			[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		[_allClubs addObjectsFromArray:_invitedClubs];
		
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"other"])
			[_otherClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		[_allClubs addObjectsFromArray:_otherClubs];
		
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[_collectionView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_collectionView];
	}];
}

- (void)_joinClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] joinClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
}

- (void)_leaveClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] leaveClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	editButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[editButton setBackgroundImage:[UIImage imageNamed:@"editClubsButton_nonActive"] forState:UIControlStateNormal];
	[editButton setBackgroundImage:[UIImage imageNamed:@"editClubsButton_Active"] forState:UIControlStateHighlighted];
	[editButton addTarget:self action:@selector(_goEditClubs) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs"];
	[headerView addButton:editButton];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) collectionViewLayout:[[HONClubsViewLayout alloc] init]];
	[_collectionView registerClass:[HONClubViewCell class] forCellWithReuseIdentifier:[HONClubViewCell cellReuseIdentifier]];
	[_collectionView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0)];
	_collectionView.backgroundColor = [UIColor whiteColor];
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	[self.view addSubview:_collectionView];
	
	
//	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) style:UITableViewStylePlain];
//	[_tableView setBackgroundColor:[UIColor clearColor]];
//	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0)];
//	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	_tableView.delegate = self;
//	_tableView.dataSource = self;
//	_tableView.showsHorizontalScrollIndicator = NO;
//	[self.view addSubview:_tableView];
//	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_collectionView.frame.size.height, _collectionView.frame.size.width, _collectionView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _collectionView;
	[_collectionView addSubview:_refreshTableHeaderView];
	
	[self _retrieveClubs];
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
	
	NSLog(@"clubsTab_total:[%d]", [HONAppDelegate totalForCounter:@"clubsTab"]);
	if ([HONAppDelegate incTotalForCounter:@"clubsTab"] == 1) {
		[[[UIAlertView alloc] initWithTitle:@"Clubs Tip"
									message:@"The more clubs you join the more your feed fills up!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
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
- (void)_goEditClubs {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Edit Clubs"];
	
	[self.navigationController pushViewController:[[HONUserClubsViewController alloc] init] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Create Challenge"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Refresh"];
	
	[self _retrieveClubs];
}

- (void)_goClubSettings:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Settings"
									   withUserClub:userClubVO];
		
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goShare {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Share"];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate facebookShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [HONImagingDepictor shareTemplateImageForType:HONImagingDepictorShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}


#pragma mark - Notifications
- (void)_selectedClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedClubsTab <|::");
}

- (void)_refreshClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshClubsTab <|::");
	[self _goRefresh];
}

- (void)_tareClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareClubsTab <|::");
	
//	if (_tableView.contentOffset.y > 0) {
//		_tableView.pagingEnabled = NO;
//		[_tableView setContentOffset:CGPointZero animated:YES];
//	}
}


//#pragma mark - UserClubViewCell Delegates
//- (void)userClubViewCell:(HONUserClubViewCell *)cell acceptInviteForClub:(HONUserClubVO *)userClubVO {
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Accept Invite"
//									   withUserClub:userClubVO];
//	
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accept Invite to the %@ club?", userClubVO.clubName]
//														message:@""
//													   delegate:self
//											  cancelButtonTitle:@"No"
//											  otherButtonTitles:@"Yes", nil];
//	[alertView setTag:0];
//	[alertView show];
//}
//
//- (void)userClubViewCell:(HONUserClubViewCell *)cell settingsForClub:(HONUserClubVO *)userClubVO {
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Edit Settings"
//									   withUserClub:userClubVO];
//		
//	_selectedClub = userClubVO;
//	
//	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
//															 delegate:self
//													cancelButtonTitle:@"Cancel"
//											   destructiveButtonTitle:nil
//													otherButtonTitles:@"Quit this club", nil];
//	[actionSheet setTag:0];
//	[actionSheet showInView:self.view];
//
//}


#pragma mark - ClubViewCell Delegates



#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - CollectionViewDataSource Delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return (1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return ([_allClubs count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	HONClubViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HONClubViewCell cellReuseIdentifier] forIndexPath:indexPath];
	cell.clubVO = [_allClubs objectAtIndex:indexPath.row];
	cell.delegate = self;
	
    return (cell);
}


//#pragma mark - TableView DataSource Delegates
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	return ((section == 0) ? 1 + [_joinedClubs count] : [_invitedClubs count]);
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	return (2);
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	return (nil);
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	HONUserClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
//	
//	if (cell == nil)
//		cell = [[HONUserClubViewCell alloc] initAsInviteCell:(indexPath.section == 1)];
//	
//	
//	if (indexPath.section == 0) {
//		if (indexPath.row == 0) {
//			if (_ownClub == nil) {
//				cell.textLabel.frame = CGRectOffset(cell.textLabel.frame, 0.0, -2.0);
//				cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12];
//				cell.textLabel.textColor = [UIColor blackColor];
//				cell.textLabel.textAlignment = NSTextAlignmentLeft;
//				cell.textLabel.text = @"Create club";
//				
//				UIImageView *plusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plusButton_nonActive"]];
//				plusImageView.frame = CGRectOffset(plusImageView.frame, 240.0, 5.0);
//				[cell.contentView addSubview:plusImageView];
//				
//			} else {
//				cell.userClubVO = _ownClub;
//				cell.delegate = self;
//			}
//		
//		} else {
//			cell.userClubVO = (HONUserClubVO *)[_joinedClubs objectAtIndex:indexPath.row - 1]; //>-1
//			cell.delegate = self;
//		}
//		
//	} else if (indexPath.section == 1) {
//		cell.userClubVO = [_invitedClubs objectAtIndex:indexPath.row];
//		cell.delegate = self;
//	}
//	
//	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
//	
//	return (cell);
//}
//
//
//#pragma mark - TableView Delegates
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return (84.0);
//	
//	if (indexPath.section == 0 || indexPath.section == 1)
//		return (kOrthodoxTableCellHeight);
//	
//	else
//		return (45.0);
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return (0.0);//(section == 0 || section == 1) ? kOrthodoxTableHeaderHeight : 0.0);
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	return (indexPath);
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
//	
//	if (indexPath.section == 0) {
//		if (indexPath.row == 0) {
//			if (_ownClub == nil) {
//				[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Create Club"];
//				
//				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
//				[navigationController setNavigationBarHidden:YES];
//				[self presentViewController:navigationController animated:YES completion:nil];
//				
//			} else {
////				[self _retrieveChallenges];
//			}
//		
//		} else {
////			[self _retrieveChallenges];
//		}
//		
//	} else if (indexPath.section == 1) {
//		HONUserClubVO *vo = (HONUserClubVO *)[_invitedClubs objectAtIndex:indexPath.row];
//		
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accept Invite to the %@ club?", vo.clubName]
//															message:@""
//														   delegate:self
//												  cancelButtonTitle:@"No"
//												  otherButtonTitles:@"Yes", nil];
//		[alertView setTag:0];
//		[alertView show];
//		
//	} else if (indexPath.section == 2) {
//		if (indexPath.row == 0)
//			[self _goInviteFriends];
//			
//		else if (indexPath.row == 1)
//			[self _goFindSchoolClub];
//		
////		else if (indexPath.row == 2)
////			[self _goShare];//[self _goFindNearbyClubs];
//	}
//}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[_collectionView setContentOffset:CGPointZero animated:NO];
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs - Settings " stringByAppendingString:(buttonIndex == 0) ? @"Quit" : @"Cancel"]
										   withUserClub:_selectedClub];
		
		if (buttonIndex == 0)
			[self _leaveClub:_selectedClub];
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs - Accept Invite " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]
										   withUserClub:_selectedClub];		
		if (buttonIndex == 1)
			[self _joinClub:_selectedClub];
	}
}

@end
