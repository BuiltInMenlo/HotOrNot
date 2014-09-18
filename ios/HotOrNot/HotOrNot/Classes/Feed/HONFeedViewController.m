//
//  HONFeedViewController.m
//  HotOrNot
//
//  Created by Jesse Boley on 2/9/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"

#import "HONFeedViewController.h"

#import "HONChallengeVO.h"

#import "HONRegisterViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONUserProfileViewController.h"
#import "HONSuggestedFollowViewController.h"

#import "HONHeaderView.h"
#import "HONActivityHeaderButtonView.h"
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
@property(nonatomic, strong) HONClubPhotoVO *clubPhotoVO;
@end

@implementation HONFeedViewController
{
	UIView *_emptyStateView;
	NSUInteger _prefetchIndex;
	NSArray *_clubPhotos;
}

- (id)init
{
	if ((self = [super init])) {
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
	
	self.view.backgroundColor = [UIColor blackColor];
	
	[self.pagedScrollView registerClass:[HONFeedItemViewController class] forViewControllerReuseIdentifier:@"FeedItem"];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backWhiteButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backWhiteButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
}

#pragma mark - Empty State

- (UIView *)_makeEmptyStateView
{
	UIView *emptyStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 335.0)];
	[emptyStateView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clubs_emptyFeed"]]];
	
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

- (void)_refreshClubFromSwerver
{
	[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubVO.clubID withOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
		NSMutableArray *clubPhotos = [NSMutableArray array];
		for (NSDictionary *clubData in result) {
			HONClubPhotoVO *vo = [HONClubPhotoVO clubPhotoWithDictionary:clubData];
			if (vo != nil)
				[clubPhotos addObject:vo];
		}
		
		[self _didFinishRefreshingWithResults:[clubPhotos copy]];
	}];
}

- (void)_didFinishRefreshingWithResults:(NSArray *)results
{
//	_challenges = [results mutableCopy];<<
	_clubPhotos = [results mutableCopy];
	[self _updateEmptyState];
	[self _prefetchChallenges];
	
	[self.pagedScrollView reloadData];
}

- (void)_updateEmptyState
{
	[_emptyStateView removeFromSuperview];
}

- (void)_prefetchChallenges
{
//	if (([_challenges count] > 0) && (_prefetchIndex < [_challenges count])) {<<
	if (([_clubPhotos count] > 0) && (_prefetchIndex < [_clubPhotos count])) {
//		NSRange prefetchRange = NSMakeRange(_prefetchIndex, MIN([_challenges count] - _prefetchIndex, [HONAppDelegate rangeForImageQueue].length));<<
		NSRange prefetchRange = NSMakeRange(_prefetchIndex, MIN([_clubPhotos count] - _prefetchIndex, [HONAppDelegate rangeForImageQueue].length));
		if (prefetchRange.length > 0) {
			NSMutableArray *imagesToFetch = [NSMutableArray array];
			for (NSUInteger i = prefetchRange.location; i < NSMaxRange(prefetchRange); i++) {
//				HONChallengeVO *vo = [_challenges objectAtIndex:i];<<
				HONClubPhotoVO *vo = [_clubPhotos objectAtIndex:i];
				NSString *type = [[HONDeviceIntrinsics sharedInstance] isRetina4Inch] ? kSnapLargeSuffix : kSnapTabSuffix;
//				NSString *url = [vo.creatorVO.imagePrefix stringByAppendingString:type];<<
				NSString *url = [vo.imagePrefix stringByAppendingString:type];
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
//	return [_challenges count];<<
	return ([_clubPhotos count]);
}

- (id)pagedView:(JLBPagedView *)pagedView itemAtIndex:(NSUInteger)index
{
//	return (index < [_challenges count]) ? _challenges[index] : nil;<<
	return (index < [_clubPhotos count]) ? _clubPhotos[index] : nil;
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
	else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"passed_registration"] && ([_clubPhotos count] == 0))
		[self _refreshChallengesFromServer];
}

#pragma mark - Actions

- (void)_goRefresh
{
	[HONAppDelegate incTotalForCounter:@"timeline"];
	[self _refreshChallengesFromServer];
}

- (void)_goBack
{
//	[[self _popSlideTransition] setInteractiveDismissEnabled:NO];
//	[self dismissViewControllerAnimated:YES completion:nil];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goSuggested {
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuggestedFollowViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goCreateChallenge
{
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRegistration
{
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goAddContacts
{
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline - Invite Friends"];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
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


#pragma mark - TimelineItemCell Delegates

/*
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showProfileForUserID:(int)userID forChallenge:(HONChallengeVO *)challengeVO
{
 [[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline - Show Profile" 
 withChallenge:challengeVO
 andParticipant:opponentVO];
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
	
 [[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline - Upvote Challenge"
 withChallengeCreator:challengeVO];
 
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

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO
{
//	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
 [[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline - Show Photo Details"
 withChallenge:challengeVO
 andParticipant:opponentVO];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO];
	_snapPreviewViewController.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showBannerForChallenge:(HONChallengeVO *)challengeVO
{
 [[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline - Banner"
 withChallenge:challengeVO];
	[self _goCreateChallenge];
}
*/

#pragma mark - FeedItem Delegate Replacement
- (void)feedItem:(HONFeedItemViewController *)feedItemViewController showChallenge:(HONChallengeVO *)challengeVO
{
	
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONClubPhotoViewController alloc] initWithChallenge:challengeVO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)feedItem:(HONFeedItemViewController *)feedItemViewController upvoteChallenge:(HONChallengeVO *)challengeVO forParticipant:(HONOpponentVO *)opponentVO {

	
//	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:challengeVO.challengeID forOpponent:opponentVO completion:^(NSDictionary *result) {
//		feedItemViewController.challenge = [HONChallengeVO challengeWithDictionary:result];
//		
//		NSMutableArray *mutableChallenges = [_challenges mutableCopy];<<
//		NSMutableArray *mutableChallenges = [_clubPhotos mutableCopy];
//		__block NSUInteger foundIndex = NSNotFound;
//		[mutableChallenges enumerateObjectsUsingBlock:^(HONChallengeVO *vo, NSUInteger idx, BOOL *stop) {
//			if (vo.challengeID == challengeVO.challengeID) {
//				foundIndex = idx;
//				*stop = YES;
//			}
//		}];
//		if (foundIndex != NSNotFound)
//			[mutableChallenges replaceObjectAtIndex:foundIndex withObject:challengeVO];
//		_challenges = [mutableChallenges copy];
//		_clubPhotos = [mutableChallenges copy];
//	}];
//	
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
}

- (void)feedItem:(HONFeedItemViewController *)feedItemViewController joinChallenge:(HONChallengeVO *)challengeVO
{

	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)feedItem:(HONFeedItemViewController *)feedItemViewController shareChallenge:(HONChallengeVO *)challengeVO fromParticipant:(HONOpponentVO *)opponentVO withImage:(UIImage *)image {


	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:0], [challengeVO.subjectNames firstObject], opponentVO.username];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], [challengeVO.subjectNames firstObject], opponentVO.username, [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], [challengeVO.subjectNames firstObject], opponentVO.username, [HONAppDelegate shareURL]];
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
//	return [_challenges count];<<
	return [_clubPhotos count];
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
//		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Timeline - Invite Friends %@" stringByAppendingString:(buttonIndex == 0) ? @"No" : @"Yes"]];
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
//		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Timeline - Invite Confirm " stringByAppendingString:(buttonIndex == 0) ? @"No" : @"Yes"]];
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
//	HONTimelineCellSubjectView *_timelineSubjectView;
//	HONTimelineCellHeaderView *_creatorHeaderView;
//	HONTimelineItemFooterView *_timelineFooterView;
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
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_heroHolderView = [[UIView alloc] initWithFrame:bounds];
	_heroHolderView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_heroHolderView];
	
	_loadingIndicatorView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView asLargeLoader:NO];
	_loadingIndicatorView.frame = CGRectOffset(_loadingIndicatorView.frame, 0.0, 40.0);
	[_heroHolderView addSubview:_loadingIndicatorView];
	
	_heroImageView = [[UIImageView alloc] initWithFrame:bounds];
	[_heroHolderView addSubview:_heroImageView];

//	_timelineSubjectView = [[HONTimelineCellSubjectView alloc] initAtOffsetY:CGRectGetHeight(bounds) - 105.0 withSubjectName:nil withUsername:nil];
//	timelineCellSubjectView.delegate = self;
//	[self.view addSubview:_timelineSubjectView];
//	
//	_creatorHeaderView = [[HONTimelineCellHeaderView alloc] initWithChallenge:nil];
//	_creatorHeaderView.frame = CGRectOffset(_creatorHeaderView.frame, 0.0, 37.0);
//	_creatorHeaderView.delegate = self;
//	[self.view addSubview:_creatorHeaderView];
	
	UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	detailsButton.frame = _heroHolderView.frame;
	[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:detailsButton];
	
	
	UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 129.0, 320.0, 69.0)];
	//UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 69.0)];
	[self.view addSubview:infoView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 288.0, 18.0)];
	usernameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	usernameLabel.textColor = [UIColor whiteColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.shadowColor = [UIColor blackColor];
	usernameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	usernameLabel.text = _challenge.creatorVO.username;
	[infoView addSubview:usernameLabel];
	
	UILabel *emotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 25.0, 120.0, 18.0)];
	emotionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:14];
	emotionLabel.textColor = [UIColor whiteColor];
	emotionLabel.backgroundColor = [UIColor clearColor];
	emotionLabel.shadowColor = [UIColor blackColor];
	emotionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
//	emotionLabel.text = [[@"- is feeling " stringByAppendingString:[_challengeVO.subjectNames] firstObject] ];
	[infoView addSubview:emotionLabel];
	
	int xOffset = 0;
	for (int i=0; i<4; i++) {
		UIImageView *emoticonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fpo_emotionIcon-SM"]];
		emoticonImageView.frame = CGRectMake((emotionLabel.frame.origin.x + emotionLabel.frame.size.width) + xOffset, 16.0, 44.0, 44.0);
		[infoView addSubview:emoticonImageView];
		
		xOffset += 44;
	}
	
	xOffset = 4;
	for (int i=0; i<5; i++) {
		UIImageView *emoticonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fpo_emotionIcon-SM"]];
		emoticonImageView.frame = CGRectMake(xOffset, 58.0, 44.0, 44.0);
		[infoView addSubview:emoticonImageView];
		
		xOffset += 44;
	}
	
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(bounds) - 47.0, 320.0, 44.0)];
	[self.view addSubview:_footerView];
	
	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likeButton.frame = CGRectMake(-1.0, 2.0, 44.0, 44.0);
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
	[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:likeButton];
	
	UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(36.0, 9.0, 160.0, 28.0)];
	likesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
	likesLabel.textColor = [UIColor whiteColor];
	likesLabel.backgroundColor = [UIColor clearColor];
	likesLabel.shadowColor = [UIColor blackColor];
	likesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	likesLabel.text = [NSString stringWithFormat:@"Likes (%d)", MIN(_challenge.totalLikes, 999)];
	[_footerView addSubview:likesLabel];
	
	UIButton *like2Button = [UIButton buttonWithType:UIButtonTypeCustom];
	like2Button.frame = likesLabel.frame;
	[like2Button addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:like2Button];
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(86.0, 0.0, 44.0, 44.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_Active"] forState:UIControlStateHighlighted];
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:replyButton];
	
	UILabel *repliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(128.0, 9.0, 160.0, 28.0)];
	repliesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
	repliesLabel.textColor = [UIColor whiteColor];
	repliesLabel.backgroundColor = [UIColor clearColor];
	repliesLabel.shadowColor = [UIColor blackColor];
	repliesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	repliesLabel.text = [NSString stringWithFormat:@"Replies (%d)", MIN([_challenge.challengers count], 999)];
	[_footerView addSubview:repliesLabel];
	
	UIButton *reply2Button = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = repliesLabel.frame;
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:reply2Button];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(265.0, 2.0, 44.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:moreButton];
	
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
	
//	_creatorHeaderView.challengeVO = _challenge;
//	[_timelineFooterView updateChallenge:_challenge];
//	[_timelineSubjectView updateChallenge:_challenge];
	
	HONOpponentVO *opponent = _challenge.creatorVO;
	NSString *imageUrl = [opponent.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix];
	NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl] cachePolicy:kURLRequestCachePolicy timeoutInterval:[HONAppDelegate timeoutInterval]];
	
	
	
	__weak HONFeedItemViewController *weakSelf = self;
	[_heroImageView setImageWithURLRequest:imageRequest placeholderImage:nil
								   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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

- (void)_goDetails {
	[_feedViewController feedItem:self showChallenge:_challenge];
}

@end
