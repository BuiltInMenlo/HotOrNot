//
//  HONFeedViewController.m
//  HotOrNot
//
//  Created by Jesse Boley on 2/9/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HONFeedViewController.h"

#import "HONAPICaller.h"
#import "HONChallengeVO.h"

#import "HONChallengeDetailsViewController.h"

#import "HONHeaderView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONCreateSnapButtonView.h"

#import "HONImageLoadingView.h"
#import "HONTimelineCellSubjectView.h"
#import "HONTimelineCellHeaderView.h"
#import "HONTimelineItemFooterView.h"

#import "HONDeviceTraits.h"

@interface HONFeedItemViewController : UIViewController
@property(nonatomic, weak) HONFeedViewController *feedViewController;
@property(nonatomic, strong) HONChallengeVO *challenge;
@end

//#import "HONTimelineItemViewCell.h"
//#import "HONOpponentVO.h"
//#import "HONUserVO.h"
//#import "HONRegisterViewController.h"
//#import "HONImagePickerViewController.h"

//#import "HONVotersViewController.h"
//#import "HONCommentsViewController.h"

//#import "HONAddContactsViewController.h"
//#import "HONSuggestedFollowViewController.h"
//#import "HONMatchContactsViewController.h"

//#import "HONColorAuthority.h"

//#import "HONFontAllocator.h"
//#import "HONImagingDepictor.h"

//#import "HONSnapPreviewViewController.h"
//#import "HONUserProfileViewController.h"
//#import "HONChangeAvatarViewController.h"


//#import "EGORefreshTableHeaderView.h"
//#import "MBProgressHUD.h"
//#import "UIImageView+AFNetworking.h"
//#import "UIImage+ImageEffects.h"

@interface HONFeedViewController () <UIScrollViewDelegate>
//<HONTimelineItemViewCellDelegate, HONSnapPreviewViewControllerDelegate, EGORefreshTableHeaderDelegate>
//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
//@property (nonatomic, strong) HONHeaderView *headerView;
//@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
//@property (nonatomic, strong) HONChallengeVO *challengeVO;
//@property (nonatomic, strong) HONOpponentVO *opponentVO;
//@property (nonatomic, strong) NSMutableArray *challenges;
//@property (nonatomic, strong) NSMutableArray *cells;
//@property (nonatomic, strong) MBProgressHUD *progressHUD;
//@property (nonatomic, strong) UIImageView *tutorialImageView;
//@property (nonatomic, strong) UIView *emptyTimelineView;
//@property (readonly, nonatomic, assign) HONTimelineScrollDirection timelineScrollDirection;
//@property (nonatomic) BOOL isScrollingDown;
//@property (nonatomic) BOOL isFirstLoad;
//@property (nonatomic) int imageQueueLocation;
@end

@implementation HONFeedViewController
{
	HONHeaderView *_headerView;
	UIView *_emptyStateView;
	
	UIScrollView *_pagedScrollView;
	NSMutableDictionary *_pagedItemControllers;
	NSMutableSet *_enqueuedItemControllers;
	HONFeedItemViewController *_appearingItemController;
	HONFeedItemViewController *_disappearingItemController;
	
	NSArray *_challenges;
	NSUInteger _prefetchIndex;
}

- (id)init
{
	if ((self = [super init])) {
		self.automaticallyAdjustsScrollViewInsets = NO;
		_pagedItemControllers = [NSMutableDictionary new];
		_enqueuedItemControllers = [NSMutableSet new];
		[_enqueuedItemControllers addObject:[HONFeedItemViewController new]];
		[_enqueuedItemControllers addObject:[HONFeedItemViewController new]];
	}
	return self;
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[HONAppDelegate incTotalForCounter:@"timeline"];
	
	_pagedScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	_pagedScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_pagedScrollView.delegate = self;
	_pagedScrollView.pagingEnabled = YES;
	_pagedScrollView.showsHorizontalScrollIndicator = NO;
	_pagedScrollView.showsVerticalScrollIndicator = NO;
	_pagedScrollView.alwaysBounceHorizontal = YES;
	[self.view addSubview:_pagedScrollView];
	
	_headerView = [[HONHeaderView alloc] initWithBrandingWithTranslucency:YES];
	[_headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
//#if __FORCE_SUGGEST__ == 1
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
//#endif
	
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
//		[self _goRegistration];
	
//	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] isEqualToString:@"YES"])
//		[self performSelector:@selector(_retrieveChallenges) withObject:nil afterDelay:0.33];
}

#pragma mark - Empty State

- (UIView *)_makeEmptyStateView
{
	UIView *emptyStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 335.0)];
	[emptyStateView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_noFollowers"]]];
	
//	UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	inviteButton.frame = CGRectMake(0.0, 200.0, 320.0, 45.0);
//	[inviteButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
//	[inviteButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
//	[inviteButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
//	[inviteButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
//	[inviteButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
//	[inviteButton setTitle:@"Find friends to follow" forState:UIControlStateNormal];
//	[inviteButton setTitle:@"Find friends to follow" forState:UIControlStateHighlighted];
//	inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//	[inviteButton addTarget:self action:@selector(_goAddContacts) forControlEvents:UIControlEventTouchUpInside];
//	[emptyStateView addSubview:inviteButton];
//	
//	UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	createClubButton.frame = CGRectMake(0.0, 245.0, 320.0, 45.0);
//	[createClubButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
//	[createClubButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
//	[createClubButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
//	[createClubButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
//	[createClubButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
//	[createClubButton setTitle:@"Invite friends to join my club" forState:UIControlStateNormal];
//	[createClubButton setTitle:@"Invite friends to join my club" forState:UIControlStateHighlighted];
//	createClubButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//	[createClubButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
//	[emptyStateView addSubview:createClubButton];
//	
//	UIButton *matchPhoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	matchPhoneButton.frame = CGRectMake(0.0, 290.0, 320.0, 45.0);
//	[matchPhoneButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateNormal];
//	[matchPhoneButton setBackgroundImage:[UIImage imageNamed:@"activityBackground"] forState:UIControlStateHighlighted];
//	[matchPhoneButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15]];
//	[matchPhoneButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
//	[matchPhoneButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateHighlighted];
//	[matchPhoneButton setTitle:@"Verify your phone number" forState:UIControlStateNormal];
//	[matchPhoneButton setTitle:@"Verify your phone number" forState:UIControlStateHighlighted];
//	matchPhoneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//	[matchPhoneButton addTarget:self action:@selector(_goMatchPhone) forControlEvents:UIControlEventTouchUpInside];
//	[emptyStateView addSubview:matchPhoneButton];
	return emptyStateView;
}

#pragma mark - API

- (void)_refreshChallengesFromServer
{
	[[HONAPICaller sharedInstance] retrieveChallengesForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSArray *result) {
		NSMutableArray *challenges = [NSMutableArray array];
		for (NSDictionary *challengeData in result) {
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:challengeData];
			if (vo != nil)
				[challenges addObject:vo];
		}
		
		[self _didFinishRefreshingWithResults:[challenges copy]];
	}];
}

- (void)_didFinishRefreshingWithResults:(NSArray *)results
{
	_challenges = results;
	[self _updateEmptyState];
	[self _prefetchChallenges];
	
	_pagedScrollView.contentOffset = CGPointZero;
	[self _clearFeedItems];
	[self _refreshFeedItems];
}

- (void)_updateEmptyState
{
	if ([_challenges count] == 0) {
		if (_emptyStateView == nil)
			_emptyStateView = [self _makeEmptyStateView];
		[self.view addSubview:_emptyStateView];
	}
	else {
		[_emptyStateView removeFromSuperview];
	}
}

- (void)_prefetchChallenges
{
	if (([_challenges count] > 0) && (_prefetchIndex < [_challenges count])) {
		NSRange prefetchRange = NSMakeRange(_prefetchIndex, MIN([_challenges count] - _prefetchIndex, [HONAppDelegate rangeForImageQueue].length));
		if (prefetchRange.length > 0) {
			NSMutableArray *imagesToFetch = [NSMutableArray array];
			for (NSUInteger i = prefetchRange.location; i < NSMaxRange(prefetchRange); i++) {
				HONChallengeVO *vo = _challenges[i];
				NSString *type = [[HONDeviceTraits sharedInstance] isRetina4Inch] ? kSnapLargeSuffix : kSnapTabSuffix;
				NSString *url = [vo.creatorVO.imagePrefix stringByAppendingString:type];
				[imagesToFetch addObject:[NSURL URLWithString:url]];
			}
			if ([imagesToFetch count] > 0)
				[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(0, [imagesToFetch count]) fromURLs:imagesToFetch withTag:@"feed"];
		}
	}
}

#pragma mark - Scrolling

- (void)_refreshFeedItems
{
	_pagedScrollView.contentSize = CGSizeMake(_pagedScrollView.bounds.size.width * [_challenges count], self.view.bounds.size.height);
	
	NSInteger currentIndex = [self _pageIndexForOffset:_pagedScrollView.contentOffset.x];
	[self _loadFeedItemAtIndex:currentIndex];
	[self _loadFeedItemAtIndex:(currentIndex + 1)];
	[self _loadFeedItemAtIndex:(currentIndex + 2)];
}

- (void)_clearFeedItems
{
	for (HONFeedItemViewController *itemViewController in [_pagedItemControllers allValues]) {
		[itemViewController willMoveToParentViewController:nil];
		[itemViewController.view removeFromSuperview];
		[itemViewController removeFromParentViewController];
		[self _enqueueFeedItemViewController:itemViewController];
	}
	[_pagedItemControllers removeAllObjects];
}

- (NSInteger)_pageIndexForOffset:(CGFloat)offset
{
	return offset / _pagedScrollView.bounds.size.width;
}

- (void)_loadFeedItemAtIndex:(NSInteger)index
{
	if (index >= [_challenges count])
		return;
	
	HONFeedItemViewController *itemViewController = _pagedItemControllers[@(index)];
	if (itemViewController == nil) {
		itemViewController = [self _dequeueFeedItemViewController];
		itemViewController.challenge = _challenges[index];
		_pagedItemControllers[@(index)] = itemViewController;
	}
	
	if (itemViewController.parentViewController == nil) {
		CGFloat pageWidth = _pagedScrollView.bounds.size.width;
		itemViewController.view.frame = CGRectMake(index * pageWidth, 0.0, _pagedScrollView.bounds.size.width, _pagedScrollView.bounds.size.height);
		
		[self addChildViewController:itemViewController];
		[_pagedScrollView addSubview:itemViewController.view];
		[itemViewController didMoveToParentViewController:self];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	//_timelineScrollDirection = (velocity.y > 0.0) ? HONTimelineScrollDirectionDown : HONTimelineScrollDirectionUp;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
		[self _refreshFeedItems];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self _refreshFeedItems];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self _refreshFeedItems];
}

#pragma mark - Feed Items

- (HONFeedItemViewController *)_dequeueFeedItemViewController
{
	HONFeedItemViewController *itemViewController = [_enqueuedItemControllers anyObject];
	if (itemViewController != nil)
		[_enqueuedItemControllers removeObject:itemViewController];
	else
		itemViewController = [[HONFeedItemViewController alloc] init];
	itemViewController.feedViewController = self;
	return itemViewController;
}

- (void)_enqueueFeedItemViewController:(HONFeedItemViewController *)itemViewController
{
	if (itemViewController != nil) {
		itemViewController.feedViewController = nil;
		itemViewController.challenge = nil;
		[_enqueuedItemControllers addObject:itemViewController];
	}
}

#pragma mark - State

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
		[self _goRegistration];
	else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"passed_registration"] && ([_challenges count] == 0))
		[self _refreshChallengesFromServer];
}

#pragma mark - Actions

- (NSDictionary *)_defaultAnalyticsProperties
{
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		properties = @{@"user": [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]]};
	});
	return properties;
}

- (void)_goRefresh
{
	[[Mixpanel sharedInstance] track:@"Timeline - Refresh" properties:[self _defaultAnalyticsProperties]];
	[HONAppDelegate incTotalForCounter:@"timeline"];
	[self _refreshChallengesFromServer];
}

- (void)_goProfile
{
//	[[Mixpanel sharedInstance] track:@"Timeline - Profile" properties:[self _defaultAnalyticsProperties]];
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
//	
//	[self _removeTutorialBubbles];
//	
//	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
//	userPofileViewController.userID = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
//	[navigationController setNavigationBarHidden:YES];
//	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateChallenge
{
//	[[Mixpanel sharedInstance] track:@"Timeline - Create Volley" properties:[self _defaultAnalyticsProperties]];
//	
//	[self _removeTutorialBubbles];
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRegistration
{
//	[[Mixpanel sharedInstance] track:@"Register User" properties:[self _defaultAnalyticsProperties]];
//	[[Mixpanel sharedInstance] track:@"Start First Run" properties:[self _defaultAnalyticsProperties]];
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goTakeAvatar
{
//	[[Mixpanel sharedInstance] track:@"Timeline - Take New Avatar" properties:[self _defaultAnalyticsProperties]];
//	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		if (_tutorialImageView != nil) {
//			_tutorialImageView.alpha = 0.0;
//		}
//	} completion:^(BOOL finished) {
//		if (_tutorialImageView != nil) {
//			[_tutorialImageView removeFromSuperview];
//			_tutorialImageView = nil;
//		}
//		
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:NO completion:nil];
//	}];
}

- (void)_goRemoveTutorial
{
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		if (_tutorialImageView != nil) {
//			_tutorialImageView.alpha = 0.0;
//		}
//	} completion:^(BOOL finished) {
//		if ([HONAppDelegate switchEnabledForKey:@"firstrun_invite"])
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_INVITE" object:nil];
//	}];
}

- (void)_goAddContacts
{
//	[[Mixpanel sharedInstance] track:@"Timeline - Invite Friends" properties:[self _defaultAnalyticsProperties]];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goMatchPhone
{
//	[[Mixpanel sharedInstance] track:@"Timeline - Match Phone" properties:[self _defaultAnalyticsProperties]];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateClub
{
//	[Mixpanel sharedInstance] track:@"Timeline - Create Club" properties:[self _defaultAnalyticsProperties]];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Notifications

//- (void)_showInvite:(NSNotification *)notification
//{
//	if ([HONAppDelegate switchEnabledForKey:@"firstrun_invite"]) {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Find & invite friends to %@?", [HONAppDelegate brandedAppName]]
//															message:@""
//														   delegate:self
//												  cancelButtonTitle:@"Cancel"
//												  otherButtonTitles:@"OK", nil];
//		[alertView setTag:HONTimelineAlertTypeInvite];
//		[alertView show];
//	
//	} else {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:YES completion:nil];
//	}
//}

//- (void)_showSuggestedFollowing:(NSNotification *)notification
//{
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuggestedFollowViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:nil];
//}

//- (void)_showFirstRun:(NSNotification *)notification
//{
//	[self _goRegistration];
//}

//- (void)_selectedHomeTab:(NSNotification *)notification
//{
//	if (_tutorialImageView != nil) {
//		[_tutorialImageView removeFromSuperview];
//		_tutorialImageView = nil;
//	}
//}

//- (void)_refreshHomeTab:(NSNotification *)notification
//{
//	if (_tableView.contentOffset.y < 150.0)
//		[_tableView setContentOffset:CGPointZero animated:YES];
//	
//	[self _retrieveChallenges];
//}

//- (void)_refreshLikeCount:(NSNotification *)notification
//{
//	_challengeVO = [HONChallengeVO challengeWithDictionary:[notification object]];
//	
//	for (HONTimelineItemViewCell *cell in _cells) {
//		if (cell.challengeVO.challengeID == _challengeVO.challengeID) {
//			[cell updateChallenge:_challengeVO];
//		}
//	}
//}

- (void)_showHomeTutorial:(NSNotification *)notification
{
//	if ([HONAppDelegate incTotalForCounter:@"timeline"] == 1) {
//		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//		_tutorialImageView.image = [UIImage imageNamed:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? @"tutorial_home-568h@2x" : @"tutorial_home"];
//		_tutorialImageView.userInteractionEnabled = YES;
//		_tutorialImageView.alpha = 0.0;
//		
//		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		closeButton.frame = CGRectMake(241.0, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 97.0 : 50.0, 44.0, 44.0);
//		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_nonActive"] forState:UIControlStateNormal];
//		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_Active"] forState:UIControlStateHighlighted];
//		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
//		[_tutorialImageView addSubview:closeButton];
//		
//		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		avatarButton.frame = CGRectMake(-1.0, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 416.0 : 374.0, 320.0, 64.0);
//		[avatarButton setBackgroundImage:[UIImage imageNamed:@"tutorial_profilePhoto_nonActive"] forState:UIControlStateNormal];
//		[avatarButton setBackgroundImage:[UIImage imageNamed:@"tutorial_profilePhoto_Active"] forState:UIControlStateHighlighted];
//		[avatarButton addTarget:self action:@selector(_goTakeAvatar) forControlEvents:UIControlEventTouchDown];
//		[_tutorialImageView addSubview:avatarButton];
//		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
//		
//		[UIView animateWithDuration:0.33 animations:^(void) {
//			_tutorialImageView.alpha = 1.0;
//		}];
//	}
}

#pragma mark - UI Presentation

- (void)_removeTutorialBubbles
{
//	for (HONTimelineItemViewCell *cell in _cells) {
//		[cell removeTutorialBubble];
//	}
}

#pragma mark - TimelineItemCell Delegates

/*
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showProfileForUserID:(int)userID forChallenge:(HONChallengeVO *)challengeVO
{
	[[Mixpanel sharedInstance] track:@"Timeline - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", userID], @"userID", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
	
	[self _removeTutorialBubbles];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
	userPofileViewController.userID = userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell upvoteCreatorForChallenge:(HONChallengeVO *)challengeVO
{
	_challengeVO = challengeVO;
	_opponentVO = challengeVO.creatorVO;
	
	NSLog(@"upvoteCreatorForChallenge:[%@]", _opponentVO.dictionary);
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Upvote Challenge%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:challengeVO.challengeID forOpponent:challengeVO.creatorVO completion:^(NSObject *result){
		_challengeVO = [HONChallengeVO challengeWithDictionary:(NSDictionary *)result];
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
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]]];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO
{
//	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Join Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[cell showTapOverlay];
	[self _removeTutorialBubbles];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO
{
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Comments"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self _removeTutorialBubbles];
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showVoters:(HONChallengeVO *)challengeVO
{
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Show Voters"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self _removeTutorialBubbles];
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO
{
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Show Photo Detail%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
	
	[self _removeTutorialBubbles];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO];
	_snapPreviewViewController.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showBannerForChallenge:(HONChallengeVO *)challengeVO
{
	[[Mixpanel sharedInstance] track:@"Timeline - Banner"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	[self _goCreateChallenge];
}
*/

- (void)feedItem:(HONFeedItemViewController *)feedItemViewController showChallenge:(HONChallengeVO *)challengeVO
{
	NSMutableDictionary *properties = [[self _defaultAnalyticsProperties] mutableCopy];
	properties[@"challenge"] = [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName];
	[[Mixpanel sharedInstance] track:@"Timeline - Show Challenge" properties:properties];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - SnapPreview Delegates

/*
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController upvoteOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO
{
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

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController flagOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO
{
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController
{
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}
*/

#pragma mark - TableView DataSource Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [_challenges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	HONTimelineItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
//	
//	if (cell == nil) {
//		HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];
//		cell = [[HONTimelineItemViewCell alloc] initAsBannerCell:((indexPath.section % 5 == 0) && indexPath.section != 0)];
//		cell.challengeVO = vo;
//	}
//	
//	[_cells addObject:cell];
//	cell.delegate = self;
//	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//	return (cell);
	return nil;
}

#pragma mark - TableView Delegates

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return self.view.frame.size.height;
//}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
//	if ([_challenges count] > 0) {
//		if (_timelineScrollDirection == HONTimelineScrollDirectionDown) {
//			if (indexPath.section % [HONAppDelegate rangeForImageQueue].location == 0 || [_challenges count] - _imageQueueLocation <= [HONAppDelegate rangeForImageQueue].location) {
//				NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
//				NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:queueRange.length];
//				
//				int cnt = 0;
//				//NSLog(@"QUEUEING:#%d -/> %d\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", queueRange.location, queueRange.length);
//				for (int i=queueRange.location; i<queueRange.length; i++) {
//					[imageQueue addObject:[NSURL URLWithString:[((HONChallengeVO *)[_challenges objectAtIndex:i]).creatorVO.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
//					
//					cnt++;
//					_imageQueueLocation++;
//					if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_challenges count])
//						break;
//					
//				}
//				[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation) fromURLs:imageQueue withTag:@"home"];
//			}
//		}
//	}
}

#pragma mark - Alert View Delegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//	if (alertView.tag == HONTimelineAlertTypeInvite) {
//		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Invite Friends %@", (buttonIndex == 0) ? @"No" : @"Yes"]
//							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
//		
//		if (buttonIndex == 0) {
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
//																message:@""
//															   delegate:self
//													  cancelButtonTitle:@"No"
//													  otherButtonTitles:@"Yes", nil];
//			[alertView setTag:HONTimelineAlertTypeInviteConfirm];
//			[alertView show];
//		}
//		
//		else if (buttonIndex == 1) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
//		}
//	
//	}
//	else if (alertView.tag == HONTimelineAlertTypeInviteConfirm) {
//		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Invite Confirm %@", (buttonIndex == 0) ? @"No" : @"Yes"]
//							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
//		
//		if (buttonIndex == 0) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] initAsFirstRun:YES]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
//		}
//	}
//}

@end

@implementation HONFeedItemViewController
{
	UIView *_heroHolderView;
	HONImageLoadingView *_loadingIndicatorView;
	UIImageView *_heroImageView;
	HONTimelineCellSubjectView *_timelineSubjectView;
	HONTimelineCellHeaderView *_creatorHeaderView;
	HONTimelineItemFooterView *_timelineFooterView;
	UIButton *_detailsButton;
}

- (id)init
{
	if ((self = [super initWithNibName:nil bundle:nil])) {
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	CGRect bounds = self.view.bounds;
	
	_heroHolderView = [[UIView alloc] initWithFrame:bounds];
	_heroHolderView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_heroHolderView];
	
	_loadingIndicatorView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView asLargeLoader:NO];
	_loadingIndicatorView.frame = CGRectOffset(_loadingIndicatorView.frame, 0.0, 40.0);
	[_heroHolderView addSubview:_loadingIndicatorView];
	
	_heroImageView = [[UIImageView alloc] initWithFrame:bounds];
	_heroImageView.userInteractionEnabled = YES;
	[_heroHolderView addSubview:_heroImageView];
	
	_timelineSubjectView = [[HONTimelineCellSubjectView alloc] initAtOffsetY:floor((CGRectGetHeight(bounds) - 44.0) * 0.5) withSubjectName:nil withUsername:nil];
	//timelineCellSubjectView.delegate = self;
	[self.view addSubview:_timelineSubjectView];
	
	_creatorHeaderView = [[HONTimelineCellHeaderView alloc] initWithChallenge:nil];
	_creatorHeaderView.frame = CGRectOffset(_creatorHeaderView.frame, 0.0, 64.0);
	//_creatorHeaderView.delegate = self;
	[self.view addSubview:_creatorHeaderView];
	
	_timelineFooterView = [[HONTimelineItemFooterView alloc] initAtPosY:CGRectGetHeight(bounds) - 106.0 withChallenge:nil];
	//_timelineFooterView.delegate = self;
	[self.view addSubview:_timelineFooterView];
	
	_detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_detailsButton.frame = bounds;
	[_detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_detailsButton];

//	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
//	lpGestureRecognizer.minimumPressDuration = 0.25;
//	[self addGestureRecognizer:lpGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (_challenge != nil)
		[self _refreshChallengeViews];
}

- (void)setChallenge:(HONChallengeVO *)challenge
{
	if (challenge != _challenge) {
		if ((_challenge != nil) && [self isViewLoaded])
			[self _cleanUpChallengeViews];
		_challenge = challenge;
		if ((_challenge != nil) && [self isViewLoaded])
			[self _refreshChallengeViews];
	}
}

- (void)_cleanUpChallengeViews
{
	[_heroImageView cancelImageRequestOperation];
}

- (void)_refreshChallengeViews
{
	_loadingIndicatorView.alpha = 1.0;
	[_loadingIndicatorView startAnimating];
	
	_creatorHeaderView.challengeVO = _challenge;
	[_timelineFooterView updateChallenge:_challenge];
	[_timelineSubjectView updateChallenge:_challenge];
	
	HONOpponentVO *opponent = _challenge.creatorVO;
	NSString *imageUrl = [opponent.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix];
	NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl] cachePolicy:(kIsImageCacheEnabled ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:[HONAppDelegate timeoutInterval]];
	
	__weak HONFeedItemViewController *weakSelf = self;
	[_heroImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[weakSelf _heroImageFinishedLoadingWithImage:image];
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		[weakSelf _heroImageFinishedLoadingWithError:error];
	}];
	
//		NSDictionary *sticker = [HONAppDelegate stickerForSubject:_challenge.subjectName];
//		if (sticker != nil) {
//			UIImageView *stickerImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//			[stickerImageView setImageWithURL:[NSURL URLWithString:[[[sticker objectForKey:@"img"] stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix] stringByReplacingOccurrencesOfString:@".jpg" withString:@".png"]] placeholderImage:nil];
//			[self.view addSubview:stickerImageView];
//
//			if ([[sticker objectForKey:@"user_id"] intValue] != 0) {
//				UIButton *stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//				stickerButton.frame = stickerImageView.frame;
//				[stickerButton setTag:[[sticker objectForKey:@"user_id"] intValue]];
//				[stickerButton addTarget:self action:@selector(_goStickerProfile:) forControlEvents:UIControlEventTouchUpInside];
//				[self.view addSubview:stickerButton];
//			}
//		}
}

- (void)_heroImageFinishedLoadingWithImage:(UIImage *)image
{
	_heroImageView.image = image;
	
	[UIView animateWithDuration:0.25 animations:^{
		_loadingIndicatorView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_loadingIndicatorView stopAnimating];
		[_loadingIndicatorView removeFromSuperview];
	}];
}

- (void)_heroImageFinishedLoadingWithError:(NSError *)error
{
	HONOpponentVO *opponent = _challenge.creatorVO;
	[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:opponent.imagePrefix forAvatarBucket:NO completion:nil];
	_heroImageView.frame = CGRectMake(_heroImageView.frame.origin.x, _heroImageView.frame.origin.y, kSnapLargeSize.width, kSnapLargeSize.height);
	[_heroImageView setImageWithURL:[NSURL URLWithString:[opponent.imagePrefix stringByAppendingString:kSnapLargeSuffix]] placeholderImage:nil];
}

#pragma mark - Actions

- (void)_goDetails
{
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[self.view addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.125 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
	
	[_feedViewController feedItem:self showChallenge:_challenge];
}

@end
