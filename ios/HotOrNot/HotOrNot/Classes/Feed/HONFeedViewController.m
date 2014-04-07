//
//  HONFeedViewController.m
//  HotOrNot
//
//  Created by Jesse Boley on 2/9/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HONFeedViewController.h"

#import "HONAnalyticsParams.h"
#import "HONAPICaller.h"
#import "HONDeviceTraits.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"

#import "HONChallengeVO.h"

#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONUserProfileViewController.h"
#import "HONSuggestedFollowViewController.h"
#import "HONChallengeDetailsViewController.h"

#import "HONHeaderView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONMessagesButtonView.h"
#import "HONCreateSnapButtonView.h"

#import "HONImageLoadingView.h"
#import "HONTimelineCellSubjectView.h"
#import "HONTimelineCellHeaderView.h"
#import "HONTimelineItemFooterView.h"

#import "JLBPopSlideTransition.h"

@interface HONFeedItemViewController : UIViewController
@property(nonatomic, weak) HONFeedViewController *feedViewController;
@property(nonatomic, strong) HONChallengeVO *challenge;
@end

@implementation HONFeedViewController
{
	UIView *_emptyStateView;
	NSUInteger _prefetchIndex;
}

- (id)init
{
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_HOME_TAB" object:nil];
	}
	return self;
}

- (JLBPopSlideTransition *)_popSlideTransition
{
	return (JLBPopSlideTransition *)self.transitioningDelegate;
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.pagedScrollView registerClass:[HONFeedItemViewController class] forViewControllerReuseIdentifier:@"FeedItem"];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
}

#pragma mark - Empty State

- (UIView *)_makeEmptyStateView
{
	UIView *emptyStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 335.0)];
	[emptyStateView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_noFollowers"]]];
	
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
	[emptyStateView addSubview:inviteButton];
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
//	matchPhoneButton.frame = CGRectMake(0.0, 245.0//290.0, 320.0, 45.0);
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
	_challenges = [results mutableCopy];
	[self _updateEmptyState];
	[self _prefetchChallenges];
	
	[self.pagedScrollView reloadData];
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
				HONChallengeVO *vo = [_challenges objectAtIndex:i];
				NSString *type = [[HONDeviceTraits sharedInstance] isRetina4Inch] ? kSnapLargeSuffix : kSnapTabSuffix;
				NSString *url = [vo.creatorVO.imagePrefix stringByAppendingString:type];
				[imagesToFetch addObject:[NSURL URLWithString:url]];
			}
			if ([imagesToFetch count] > 0)
				[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(0, [imagesToFetch count]) fromURLs:imagesToFetch withTag:@"feed"];
		}
	}
}

#pragma mark - JLBPagedViewDataSource

- (NSUInteger)numberOfItemsForPagedView:(JLBPagedView *)pagedView
{
	return [_challenges count];
}

- (id)pagedView:(JLBPagedView *)pagedView itemAtIndex:(NSUInteger)index
{
	return (index < [_challenges count]) ? _challenges[index] : nil;
}

- (id)pagedView:(JLBPagedView *)pagedView viewControllerForItem:(id)item atIndex:(NSUInteger)index
{
	HONFeedItemViewController *feedItemViewController = [pagedView dequeueReusableViewControllerWithIdentifier:@"FeedItem" forIndex:index];
	feedItemViewController.feedViewController = self;
	feedItemViewController.challenge = item;
	return feedItemViewController;
}

#pragma mark - State

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
		[self _goRegistration];
	else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"passed_registration"] && ([_challenges count] == 0))
		[self _refreshChallengesFromServer];
	
#if __FORCE_SUGGEST__ == 1
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
		[self _goSuggested];
#endif
}

#pragma mark - Actions

- (void)_goRefresh
{
	[[Mixpanel sharedInstance] track:@"Timeline - Refresh" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[HONAppDelegate incTotalForCounter:@"timeline"];
	[self _refreshChallengesFromServer];
}

- (void)_goBack
{
	[[Mixpanel sharedInstance] track:@"Timeline - Back" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[[self _popSlideTransition] setInteractiveDismissEnabled:NO];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goSuggested {
	[[Mixpanel sharedInstance] track:@"Timeline - Suggested" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuggestedFollowViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goCreateChallenge
{
	[[Mixpanel sharedInstance] track:@"Timeline - Create Volley" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRegistration
{
	[[Mixpanel sharedInstance] track:@"Register User" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[[Mixpanel sharedInstance] track:@"Start First Run" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goAddContacts
{
//	[[Mixpanel sharedInstance] track:@"Timeline - Invite Friends" properties:[[HONAnalyticsSupport sharedInstance] userProperty]];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goMatchPhone
{
//	[[Mixpanel sharedInstance] track:@"Timeline - Match Phone" properties:[[HONAnalyticsSupport sharedInstance] userProperty]];
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

- (void)_refreshHomeTab:(NSNotification *)notification
{
	[self _refreshChallengesFromServer];
}

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

#pragma mark - TimelineItemCell Delegates

/*
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showProfileForUserID:(int)userID forChallenge:(HONChallengeVO *)challengeVO
{
	[[Mixpanel sharedInstance] track:@"Timeline - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", userID], @"userID", nil]];
	
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
	
	[[Mixpanel sharedInstance] track:@"Timeline - Upvote Challenge"
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

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO
{
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Show Photo Detail"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
	
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

#pragma mark - FeedItem Delegate Replacement
- (void)feedItem:(HONFeedItemViewController *)feedItemViewController showChallenge:(HONChallengeVO *)challengeVO
{
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	properties[@"challenge"] = [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName];
	[[Mixpanel sharedInstance] track:@"Timeline - Show Challenge" properties:properties];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)feedItem:(HONFeedItemViewController *)feedItemViewController upvoteChallenge:(HONChallengeVO *)challengeVO forParticipant:(HONOpponentVO *)opponentVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	properties[@"challenge"] = [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName];
	properties[@"participant"] = [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username];
	[[Mixpanel sharedInstance] track:@"Timeline - Upvote Challenge" properties:properties];
	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:challengeVO.challengeID forOpponent:opponentVO completion:^(NSObject *result) {
		feedItemViewController.challenge = [HONChallengeVO challengeWithDictionary:(NSDictionary *)result];
		
		NSMutableArray *mutableChallenges = [_challenges mutableCopy];
		__block NSUInteger foundIndex = NSNotFound;
		[mutableChallenges enumerateObjectsUsingBlock:^(HONChallengeVO *vo, NSUInteger idx, BOOL *stop) {
			if (vo.challengeID == challengeVO.challengeID) {
				foundIndex = idx;
				*stop = YES;
			}
		}];
		if (foundIndex != NSNotFound)
			[mutableChallenges replaceObjectAtIndex:foundIndex withObject:challengeVO];
		_challenges = [mutableChallenges copy];
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]]];
}

- (void)feedItem:(HONFeedItemViewController *)feedItemViewController joinChallenge:(HONChallengeVO *)challengeVO
{
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	properties[@"challenge"] = [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName];
	[[Mixpanel sharedInstance] track:@"Timeline - Join Challenge" properties:properties];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)feedItem:(HONFeedItemViewController *)feedItemViewController shareChallenge:(HONChallengeVO *)challengeVO fromParticipant:(HONOpponentVO *)opponentVO withImage:(UIImage *)image {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	properties[@"challenge"] = [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName];
	[[Mixpanel sharedInstance] track:@"Timeline - Share Challenge" properties:properties];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:0], challengeVO.subjectName, opponentVO.username];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], challengeVO.subjectName, opponentVO.username, [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], challengeVO.subjectName, opponentVO.username, [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:0], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:0] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:0] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: image,
																							@"url"				: [challengeVO.creatorVO.imagePrefix stringByAppendingString:kSnapLargeSuffix],
																							@"mp_event"			: @"Timeline Details",
																							@"view_controller"	: self}];

}


/*
#pragma mark - SnapPreview Delegates
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

//#pragma mark - Alert View Delegate
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

//]=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=]>>

#pragma mark -
#pragma mark - HONFeedItemViewController Implementation

@implementation HONFeedItemViewController
{
	UIView *_heroHolderView;
	UIView *_footerView;
	HONImageLoadingView *_loadingIndicatorView;
	UIImageView *_heroImageView;
	HONTimelineCellSubjectView *_timelineSubjectView;
	HONTimelineCellHeaderView *_creatorHeaderView;
	HONTimelineItemFooterView *_timelineFooterView;
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
	[_heroHolderView addSubview:_heroImageView];

	_timelineSubjectView = [[HONTimelineCellSubjectView alloc] initAtOffsetY:CGRectGetHeight(bounds) - 105.0 withSubjectName:nil withUsername:nil];
	//timelineCellSubjectView.delegate = self;
	[self.view addSubview:_timelineSubjectView];
	
	_creatorHeaderView = [[HONTimelineCellHeaderView alloc] initWithChallenge:nil];
	_creatorHeaderView.frame = CGRectOffset(_creatorHeaderView.frame, 0.0, 37.0);
	//_creatorHeaderView.delegate = self;
	[self.view addSubview:_creatorHeaderView];
	
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(bounds) - 44.0, 320.0, 44.0)];
	[self.view addSubview:_footerView];
	
	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likeButton.frame = CGRectMake(0.0, 0.0, 94.0, 44.0);
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
	[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:likeButton];
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(113.0, 0.0, 94.0, 44.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyButton_Active"] forState:UIControlStateHighlighted];
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:replyButton];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(220.0, 0.0, 94.0, 44.0);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active"] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:shareButton];
	
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
	
	NSLog(@"IMAGE:[%@]", imageUrl);
	
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
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selfieFullSizeGradientOverlay"]];
	gradientImageView.frame = _heroImageView.frame;
	[_heroImageView addSubview:gradientImageView];
	
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
	[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:opponent.imagePrefix forBucketType:HONS3BucketTypeSelfies completion:nil];
	_heroImageView.frame = CGRectMake(_heroImageView.frame.origin.x, _heroImageView.frame.origin.y, kSnapLargeSize.width, kSnapLargeSize.height);
	[_heroImageView setImageWithURL:[NSURL URLWithString:[opponent.imagePrefix stringByAppendingString:kSnapLargeSuffix]] placeholderImage:nil];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selfieFullSizeGradientOverlay"]];
	gradientImageView.frame = _heroImageView.frame;
	[_heroImageView addSubview:gradientImageView];
}

#pragma mark - Actions

- (void)_goLike {
	[_feedViewController feedItem:self upvoteChallenge:_challenge forParticipant:_challenge.creatorVO];
}

- (void)_goReply {
	[_feedViewController feedItem:self joinChallenge:_challenge];
}

- (void)_goShare {
	[_feedViewController feedItem:self shareChallenge:_challenge fromParticipant:_challenge.creatorVO withImage:_heroImageView.image];
}

@end
