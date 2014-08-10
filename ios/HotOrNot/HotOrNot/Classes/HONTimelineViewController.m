//
//  HONTimelineViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "HONTimelineViewController.h"
#import "HONTimelineItemViewCell.h"
#import "HONOpponentVO.h"
#import "HONUserVO.h"
#import "HONFeedViewController.h"
#import "HONRegisterViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONCreateSnapButtonView.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONHeaderView.h"
#import "HONMessagesButtonView.h"
#import "HONAddContactsViewController.h"
#import "HONSuggestedFollowViewController.h"
#import "HONMatchContactsViewController.h"
#import "HONMessagesViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONActivityHeaderButtonView.h"

#import "JLBPopSlideTransition.h"

@interface HONTimelineViewController() <EGORefreshTableHeaderDelegate, HONSnapPreviewViewControllerDelegate, HONTimelineItemViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *clubs;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *emptyTimelineView;
@property (nonatomic, assign, readonly) HONTimelineScrollDirection timelineScrollDirection;
@property (nonatomic) BOOL isScrollingDown;
@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) int imageQueueLocation;
@end

@implementation HONTimelineViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedHomeTab:) name:@"SELECTED_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareHomeTab:) name:@"TARE_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshLikeCount:) name:@"REFRESH_LIKE_COUNT" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showInvite:) name:@"SHOW_INVITE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSuggestedFollowing:) name:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
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
	[[HONAPICaller sharedInstance] retrieveChallengesForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSArray *result) {
		_challenges = [NSMutableArray array];
		for (NSDictionary *dict in result) {
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
			[_challenges addObject:vo];
		}
				
		if ([_challenges count] > 0 && _imageQueueLocation < [_challenges count]) {
			int cnt = 0;
			NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length)];
			NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
			
			for (int i=queueRange.location; i<queueRange.length; i++) {
				[imageQueue addObject:[NSURL URLWithString:[((HONChallengeVO *)[_challenges objectAtIndex:i]).creatorVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
				
				cnt++;
				_imageQueueLocation++;
				
				if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_challenges count])
					break;
				
			}
			[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation) fromURLs:imageQueue withTag:@"home"];
		}
		
		_emptyTimelineView.hidden = ([_challenges count] > 0);
		
	 
		_isFirstLoad = NO;
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)_retrieveClubs {
	[[HONAPICaller sharedInstance] retrieveFeaturedClubsWithCompletion:^(NSObject *result) {
	
		_clubs = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result)
			[_challenges addObject:[HONChallengeVO challengeWithDictionary:dict]];
		
		[_tableView reloadData];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	_isFirstLoad = YES;
	
	_imageQueueLocation = 0;
	_challenges = [NSMutableArray array];
	_clubs = [NSMutableArray array];
	_cells = [NSMutableArray array];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.pagingEnabled = YES;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_emptyTimelineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 335.0)];
	[_emptyTimelineView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_noFollowers"]]];
	_emptyTimelineView.hidden = YES;
	[_tableView addSubview:_emptyTimelineView];
	
	UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	inviteButton.frame = CGRectMake(0.0, 200.0, 320.0, 45.0);
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
	[inviteButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
	[inviteButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[inviteButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
	[inviteButton setTitle:@"Find friends to follow" forState:UIControlStateNormal];
	[inviteButton setTitle:@"Find friends to follow" forState:UIControlStateHighlighted];
	inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[inviteButton addTarget:self action:@selector(_goAddContacts) forControlEvents:UIControlEventTouchUpInside];
	[_emptyTimelineView addSubview:inviteButton];
	
	UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createClubButton.frame = CGRectMake(0.0, 245.0, 320.0, 45.0);
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
	[createClubButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
	[createClubButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
	[createClubButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[createClubButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
	[createClubButton setTitle:@"Invite friends to join my club" forState:UIControlStateNormal];
	[createClubButton setTitle:@"Invite friends to join my club" forState:UIControlStateHighlighted];
	createClubButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[createClubButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
	[_emptyTimelineView addSubview:createClubButton];
	
	UIButton *matchPhoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	matchPhoneButton.frame = CGRectMake(0.0, 290.0, 320.0, 45.0);
	[matchPhoneButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
	[matchPhoneButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
	[matchPhoneButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
	[matchPhoneButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[matchPhoneButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
	[matchPhoneButton setTitle:@"Verify your phone number" forState:UIControlStateNormal];
	[matchPhoneButton setTitle:@"Verify your phone number" forState:UIControlStateHighlighted];
	matchPhoneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[matchPhoneButton addTarget:self action:@selector(_goMatchPhone) forControlEvents:UIControlEventTouchUpInside];
	[_emptyTimelineView addSubview:matchPhoneButton];
	
	
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];

	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@""];
//	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
//	[headerView addButton:[[HONMessagesButtonView alloc] initWithTarget:self action:@selector(_goMessages)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
//		[self _goRegistration];
//	
//	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] isEqualToString:@"YES"]) {
//		
//		[self performSelector:@selector(_retrieveClubs) withObject:nil afterDelay:0.33];
//		[self performSelector:@selector(_retrieveChallenges) withObject:nil afterDelay:0.33];
//	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[HONAppDelegate incTotalForCounter:@"timeline"];
	
#if __FORCE_SUGGEST__ == 1
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
#endif
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

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
	[HONAppDelegate incTotalForCounter:@"timelineRefresh"];
	[self _retrieveChallenges];
}

- (void)_goProfile {
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goMessages {
	[self.navigationController pushViewController:[[HONMessagesViewController alloc] init] animated:YES];
}

- (void)_goCreateChallenge {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRegistration {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {}];
}

- (void)_goAddContacts {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goMatchPhone {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateClub {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline - Create Club"];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_showInvite:(NSNotification *)notification {
	if ([HONAppDelegate switchEnabledForKey:@"firstrun_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Find & invite friends to Selfieclub?"
															message:@""
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:HONTimelineAlertTypeInvite];
		[alertView show];
	
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)_showSuggestedFollowing:(NSNotification *)notification {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuggestedFollowViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_showFirstRun:(NSNotification *)notification {
	[self _goRegistration];
}

- (void)_selectedHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedHomeTab <|::");
	
//	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	//[self _retrieveChallenges];
}

- (void)_refreshHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshHomeTab <|::");
	
	if (_tableView.contentOffset.y < 150.0)
		[_tableView setContentOffset:CGPointZero animated:YES];
	
	[self _retrieveChallenges];
}

- (void)_refreshLikeCount:(NSNotification *)notification {
	_challengeVO = [HONChallengeVO challengeWithDictionary:[notification object]];
	
	for (HONTimelineItemViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == _challengeVO.challengeID) {
			[cell updateChallenge:_challengeVO];
//			[cell upvoteUser:_challengeVO.creatorVO.userID onChallenge:_challengeVO];
		}
	}
}

- (void)_tareHomeTab:(NSNotification *)notification {
	NSLog(@"::|> tareHomeTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
	
//	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//	[_tableView setContentOffset:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) animated:NO];
}


#pragma mark - TimelineItemCell Delegates
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
				
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:opponentVO.userID] animated:YES];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:userID]];
//	[navigationController setNavigationBarHidden:YES];
//	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell upvoteCreatorForChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = challengeVO.creatorVO;
	
	NSLog(@"upvoteCreatorForChallenge:[%@]", _opponentVO.dictionary);

	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:challengeVO.challengeID forOpponent:challengeVO.creatorVO completion:^(NSDictionary *result) {
		_challengeVO = [HONChallengeVO challengeWithDictionary:result];
		for (HONTimelineItemViewCell *cell in _cells) {
			if (cell.challengeVO.challengeID == _challengeVO.challengeID)
				[cell updateChallenge:_challengeVO];
		}
		
		int cnt = 0;
		for (HONChallengeVO *vo in _challenges) {
			if (vo.challengeID == _challengeVO.challengeID) {
				[_challenges replaceObjectAtIndex:cnt withObject:_challengeVO];
				break;
			}
			
			cnt++;
		}
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO {
//	_challengeVO = challengeVO;
	

	
	[cell showTapOverlay];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell shareChallenge:(HONChallengeVO *)challengeVO {

}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showChallenge:(HONChallengeVO *)challengeVO {

	
	HONFeedViewController *feedViewController = [[HONFeedViewController alloc] init];
//	feedViewController.challenges = _challenges;<<
	JLBPopSlideTransition *transition = [JLBPopSlideTransition new];
	feedViewController.transitioningDelegate = transition;
	[self presentViewController:feedViewController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showVoters:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	

	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreviewForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;

	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO];
	_snapPreviewViewController.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showBannerForChallenge:(HONChallengeVO *)challengeVO {

	
	[self _goCreateChallenge];
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController upvoteOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
	
	for (HONTimelineItemViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == challengeVO.challengeID)
			[cell updateChallenge:_challengeVO];
//			[cell upvoteUser:opponentVO.userID onChallenge:_challengeVO];
	}
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController flagOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
//	NSLog(@"**_[egoRefreshTableHeaderDidTriggerRefresh]_**");
	
	_tableView.pagingEnabled = NO;
	[self _goRefresh];
}

- (void)egoRefreshTableHeaderDidFinishTareAnimation:(EGORefreshTableHeaderView *)view {
//	NSLog(@"**_[egoRefreshTableHeaderDidFinishTareAnimation]_**");
	_tableView.pagingEnabled = YES;
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_challenges count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONTimelineItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];
		cell = [[HONTimelineItemViewCell alloc] initAsBannerCell:((indexPath.section % 5 == -1) && indexPath.section != 0)];
		cell.challengeVO = vo;
	}
	
	[_cells addObject:cell];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (self.view.frame.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (0.0);
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//	HONChallengeVO *challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];
//	
//	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//	[imageView setImageWithURL:[NSURL URLWithString:[challengeVO.creatorVO.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
//	NSLog(@"tableView:didEndDisplayingCell:[%@]forRowAtIndexPath:[%d]", NSStringFromCGPoint(cell.frame.origin), indexPath.section);
	
	
	if ([_challenges count] > 0) {
		if (_timelineScrollDirection == HONTimelineScrollDirectionDown) {
//			HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];			
//			if ([HONAppDelegate isChallengeParticipant:vo] || [HONAppDelegate hasVoted:vo.challengeID])
//				[[HONAPICaller sharedInstance] markChallengeAsSeenWithChallengeID:vo.challengeID completion:nil];
//			
//			else
//				[[HONAPICaller sharedInstance] markChallengeAsUnseenWithChallengeID:vo.challengeID completion:nil];
			
			
			if (indexPath.section % [HONAppDelegate rangeForImageQueue].location == 0 || [_challenges count] - _imageQueueLocation <= [HONAppDelegate rangeForImageQueue].location) {
				NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
				NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:queueRange.length];
				
				int cnt = 0;
				//NSLog(@"QUEUEING:#%d -/> %d\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", queueRange.location, queueRange.length);
				for (int i=queueRange.location; i<queueRange.length; i++) {
					[imageQueue addObject:[NSURL URLWithString:[((HONChallengeVO *)[_challenges objectAtIndex:i]).creatorVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
					
					cnt++;
					_imageQueueLocation++;
					if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_challenges count])
						break;
					
				}
				[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation) fromURLs:imageQueue withTag:@"home"];
			}
		}
	}
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"**_[scrollViewDidScroll]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//	NSLog(@"**_[scrollViewWillEndDragging]_** offset:[%.02f] inset:[%.02f]", scrollView.contentOffset.y, scrollView.contentInset.top);
	_timelineScrollDirection = (velocity.y > 0.0) ? HONTimelineScrollDirectionDown : HONTimelineScrollDirectionUp;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	NSLog(@"**_[scrollViewDidEndDragging]_** offset:[%.02f] inset:[%.02f]", scrollView.contentOffset.y, scrollView.contentInset.top);
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	NSLog(@"**_[scrollViewDidEndScrollingAnimation]_**");
	scrollView.pagingEnabled = YES;
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONTimelineAlertTypeInvite) {
		
		if (buttonIndex == 0) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"are_you_sure", nil) //@"Are you sure?"
																message:@""
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"Yes", nil];
			[alertView setTag:HONTimelineAlertTypeInviteConfirm];
			[alertView show];
		}
		
		else if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if (alertView.tag == HONTimelineAlertTypeInviteConfirm) {
		
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


@end
