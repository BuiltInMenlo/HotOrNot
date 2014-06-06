//
//  HONVerifyViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

#import "HONVerifyViewController.h"
#import "HONTutorialView.h"
#import "HONHeaderView.h"
#import "HONVerifyFlagButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONVerifyViewCell.h"
#import "HONChallengeVO.h"
#import "HONUserVO.h"
#import "HONUserClubVO.h"
#import "HONAddContactsViewController.h"
#import "HONImagePickerViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"

@interface HONVerifyViewController() <EGORefreshTableHeaderDelegate, HONSnapPreviewViewControllerDelegate, HONTutorialViewDelegate, HONVerifyViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *headers;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) UIImageView *emptySetImageView;
@property (nonatomic, strong) HONTutorialView *tutorialView;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic) int imageQueueLocation;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL isScrollingIgnored;
@end

@implementation HONVerifyViewController

- (id)init {
	if ((self = [super init])) {
		_challenges = [NSMutableArray array];
		_headers = [NSMutableArray array];
		_cells = [NSMutableArray array];
		
		_isScrollingIgnored = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedVerifyTab:) name:@"SELECTED_VERIFY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareVerifyTab:) name:@"TARE_VERIFY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVerifyTab:) name:@"REFRESH_VERIFY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVerifyTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
- (void)_retrieveVerifyList {
	[[HONAPICaller sharedInstance] retrieveVerifyListForUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		_challenges = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result) {
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
			[_challenges addObject:vo];
		}
		
		_emptySetImageView.hidden = [_challenges count] > 0;
		[_tableView reloadData];
		
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
		_imageQueueLocation = 0;
		if ([_challenges count] > 0) {
			NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
			NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length)];
			
			int cnt = 0;
			for (int i=queueRange.location; i<queueRange.length; i++) {
				[imageQueue addObject:[NSURL URLWithString:[((HONChallengeVO *)[_challenges objectAtIndex:i]).creatorVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
				
				cnt++;
				_imageQueueLocation++;
				if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_challenges count])
					break;
				
			}
			[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation) fromURLs:imageQueue withTag:@"verify"];
		}
	}];
}

- (void)_cacheNextImagesWithRange:(NSRange)range {
	NSLog(@"RANGE:[%@]", NSStringFromRange(range));
	
	NSMutableArray *imagesToFetch = [NSMutableArray array];
	for (int i=range.location; i<MIN(range.length, [_challenges count]); i++) {
		HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:i];
		NSString *type = [[HONDeviceIntrinsics sharedInstance] isRetina4Inch] ? kSnapLargeSuffix : kSnapTabSuffix;
		NSString *url = [vo.creatorVO.imagePrefix stringByAppendingString:type];
		[imagesToFetch addObject:[NSURL URLWithString:url]];
	}
	
	if ([imagesToFetch count] > 0)
		[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(0, [imagesToFetch count]) fromURLs:imagesToFetch withTag:@"verify"];
	
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor blackColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.pagingEnabled = YES;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.scrollView = _tableView;
	_refreshTableHeaderView.delegate = self;
	[_tableView addSubview:_refreshTableHeaderView];
	
	_emptySetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifyEmpty"]];
	_emptySetImageView.frame = CGRectOffset(_emptySetImageView.frame, 0.0, 58.0);
	_emptySetImageView.hidden = YES;
	[_tableView addSubview:_emptySetImageView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Discover" hasBackground:NO];
	[headerView addButton:[[HONVerifyFlagButtonView alloc] initWithTarget:self action:@selector(_goFlag)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:YES]];
	[headerView toggleLightStyle:YES];
	[self.view addSubview:headerView];
	
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0)
			_userClubVO = [HONUserClubVO clubWithDictionary:[[((NSDictionary *)result) objectForKey:@"owned"] objectAtIndex:0]];
		
		[self _retrieveVerifyList];
	}];
}

- (void)viewDidLoad {
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

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goFlag {
	NSIndexPath *indexPath = (NSIndexPath *)[[_tableView indexPathsForVisibleRows] firstObject];
	_challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Flag"
							   withChallengeCreator:_challengeVO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Flag this user?"
														message:@""
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"OK", nil];
	[alertView setTag:HONVerifyAlertTypeFlag];
	[alertView show];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Create Snap"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Refresh"];
	[self _retrieveVerifyList];
}


#pragma mark - Notifications
- (void)_selectedVerifyTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedVerifyTab <|::");
	
//	if ([HONAppDelegate incTotalForCounter:@"verifyTab"] == 0) {
//		_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:@"tutorial_verify"]];
//		_tutorialView.delegate = self;
//		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialView];
//		[_tutorialView introWithCompletion:nil];
//	}
}

- (void)_refreshVerifyTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshVerifyTab <|::");
	[self _retrieveVerifyList];
}

- (void)_tareVerifyTab:(NSNotification *)notification {
	NSLog(@"::|> _tareVerifyTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
}


#pragma mark - UI Presentation
- (void)_removeSnapOverlay {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	_isScrollingIgnored = NO;
}

- (void)_removeCellForChallenge:(HONChallengeVO *)challengeVO {
	UITableViewCell *tableCell;
	
	for (HONVerifyViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == challengeVO.challengeID) {
			tableCell = (UITableViewCell *)cell;
			[_cells removeObject:tableCell];
			break;
		}
	}
	
	int ind = -1;
	for (HONChallengeVO *vo in _challenges) {
		ind++;
		
		if (challengeVO.challengeID == vo.challengeID) {
			[_challenges removeObject:vo];
			break;
		}
	}
	
	if (tableCell != nil) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:ind];
		
		if (indexPath != nil) {
			[_tableView beginUpdates];
			[_tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
			[_tableView endUpdates];
			_emptySetImageView.hidden = [_challenges count] > 0;
		}
	}
}


#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Close Tutorial"];
		
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewTakeAvatar:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Tutorial Take Avatar"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}


#pragma mark - VerifyViewCell Delegates
- (void)verifyViewCell:(HONVerifyViewCell *)cell showCreatorProfile:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Show Profile"
							   withChallengeCreator:challengeVO];
	
	_challengeVO = challengeVO;
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:challengeVO.creatorVO.userID] animated:YES];
}

- (void)verifyViewCell:(HONVerifyViewCell *)cell approveChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Approve"
							   withChallengeCreator:challengeVO];
	
	[[HONAPICaller sharedInstance] verifyUserWithUserID:challengeVO.creatorVO.userID asLegit:YES completion:nil];
	[self _removeCellForChallenge:challengeVO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yayOverlay"]]];
}

- (void)verifyViewCell:(HONVerifyViewCell *)cell unapproveChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Unapprove"
							   withChallengeCreator:challengeVO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disprove Confirm"
														message:@""
													   delegate:self
											  cancelButtonTitle:@"Nah"
											  otherButtonTitles:@"Fo Shizzle!", nil];
	[alertView setTag:HONVerifyAlertTypeDisproveConfirm];
	[alertView show];
}

- (void)verifyViewCell:(HONVerifyViewCell *)cell skipChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Skip"
							   withChallengeCreator:challengeVO];
		
	_challengeVO = challengeVO;
	[[HONAPICaller sharedInstance] removeUserFromVerifyListWithUserID:challengeVO.creatorVO.userID completion:nil];
	[self _removeCellForChallenge:challengeVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nayOverlay"]]];
}

- (void)verifyViewCell:(HONVerifyViewCell *)cell inviteChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Invite"
							   withChallengeCreator:challengeVO];
	
	if (_userClubVO == nil) {
		[[[UIAlertView alloc] initWithTitle:@"You Haven't Created A Club!"
									message:@"You need to create your own club before inviting anyone."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else {
		[[HONAPICaller sharedInstance] inviteInAppUsers:[NSArray arrayWithObject:[HONTrivialUserVO userFromOpponentVO:challengeVO.creatorVO]] toClubWithID:_userClubVO.clubID withClubOwnerID:_userClubVO.ownerID completion:^(NSObject *result) {
			[[HONAPICaller sharedInstance] removeUserFromVerifyListWithUserID:challengeVO.creatorVO.userID completion:nil];
			[self _removeCellForChallenge:challengeVO];
		}];
	}
}

- (void)verifyViewCell:(HONVerifyViewCell *)cell moreActionsForChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - More Shelf"
							   withChallengeCreator:challengeVO];
	
	_challengeVO = challengeVO;
	[self _removeCellForChallenge:challengeVO];
		
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Invite user", @"Inappropriate content", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
}

- (void)verifyViewCell:(HONVerifyViewCell *)cell fullSizeDisplayForChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Preview"
							   withChallengeCreator:challengeVO];
	
	_challengeVO = challengeVO;
	[cell showTapOverlay];
	
	_isScrollingIgnored = YES;
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithVerifyChallenge:_challengeVO];
	_snapPreviewViewController.delegate = self;
	
	[[HONScreenManager sharedInstance] appWindowAdoptsView:_snapPreviewViewController.view];
}

- (void)verifyViewCell:(HONVerifyViewCell *)cell bannerTappedForChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Verify - Banner"
							   withChallengeCreator:challengeVO];
	
	_challengeVO = challengeVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	NSLog(@"\n**_[snapPreviewViewControllerClose]_**\n");
	
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController flagOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController upvoteOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController removeVerifyChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"\n**_[snapPreviewViewController]_**\n");
	
	[self _removeCellForChallenge:challengeVO];
}

#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	_tableView.pagingEnabled = NO;
	[self _goRefresh];
}

- (void)egoRefreshTableHeaderDidFinishTareAnimation:(EGORefreshTableHeaderView *)view {
	_tableView.pagingEnabled = YES;
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"**_[scrollViewDidScroll(%d)]_**", !_isScrollingIgnored);
	
	if (!_isScrollingIgnored)
		[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	NSLog(@"**_[scrollViewDidEndDragging]_**");
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//	NSLog(@"**_[scrollViewDidEndScrollingAnimation]_**");
	scrollView.pagingEnabled = YES;
	[_tableView setContentOffset:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) animated:NO];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONVerifyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONVerifyViewCell alloc] initAsBannerCell:((indexPath.section % 5) == -1 && indexPath.section > 0)];
	
	cell.delegate = self;
	cell.challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];
	cell.indexPath = indexPath;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	[_cells addObject:cell];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (self.view.bounds.size.height + ((int)(indexPath.section == [_challenges count] - 1) * 47.0));
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
//	NSLog(@"tableView:didEndDisplayingCell:[%@]forRowAtIndexPath:[%d]", NSStringFromCGPoint(cell.frame.origin), indexPath.section);
	
	if (indexPath.section % [HONAppDelegate rangeForImageQueue].location == 0 || [_challenges count] - _imageQueueLocation <= [HONAppDelegate rangeForImageQueue].location) {
		NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_challenges count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
		//NSLog(@"QUEUEING:#%d -/> %d\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", queueRange.location, queueRange.length);
		
		int cnt = 0;
		NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:queueRange.length];
		for (int i=queueRange.location; i<queueRange.length; i++) {
			[imageQueue addObject:[NSURL URLWithString:[((HONChallengeVO *)[_challenges objectAtIndex:i]).creatorVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
			
			cnt++;
			_imageQueueLocation++;
			if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_challenges count])
				break;
			
		}
		[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation) fromURLs:imageQueue withTag:@"verify"];
	}
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return (proposedDestinationIndexPath);
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Verify - More Sheet %@" stringByAppendingString:(buttonIndex == 0) ? @"Invite" : (buttonIndex == 1) ? @"Flag" : @"Cancel"]
								   withChallengeCreator:_challengeVO];
		
		[self _removeCellForChallenge:_challengeVO];
		if (buttonIndex == 0) {
			if (_userClubVO == nil) {
				[[[UIAlertView alloc] initWithTitle:@"You Haven't Created A Club!"
											message:@"You need to create your own club before inviting anyone."
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				
			} else {
				[[HONAPICaller sharedInstance] inviteInAppUsers:[NSArray arrayWithObject:[HONTrivialUserVO userFromOpponentVO:_challengeVO.creatorVO]] toClubWithID:_userClubVO.clubID withClubOwnerID:_userClubVO.ownerID completion:^(NSObject *result) {
					[[HONAPICaller sharedInstance] removeUserFromVerifyListWithUserID:_challengeVO.creatorVO.userID completion:nil];
					[self _removeCellForChallenge:_challengeVO];
				}];
			}
			
		} else if (buttonIndex == 1) {
			[[[UIAlertView alloc] initWithTitle:@""
										message:[NSString stringWithFormat:@"@%@ has been flagged & notified!", _challengeVO.creatorVO.username]
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[[HONAPICaller sharedInstance] verifyUserWithUserID:_challengeVO.creatorVO.userID asLegit:NO completion:nil];
			[self _removeCellForChallenge:_challengeVO];
		
		} else if (buttonIndex == 2) {
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONVerifyAlertTypeDisproveConfirm) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Verify - Dissaprove " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @" Confirm"]
								   withChallengeCreator:_challengeVO];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] verifyUserWithUserID:_challengeVO.creatorVO.userID asLegit:NO completion:nil];
			[self _removeCellForChallenge:_challengeVO];
		}
	
	} else if (alertView.tag == HONVerifyAlertTypeFlag) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Verify - Flag " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]
								   withChallengeCreator:_challengeVO];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] flagChallengeByChallengeID:_challengeVO.challengeID completion:nil];
			[self _removeCellForChallenge:_challengeVO];
		}
	}
}

@end
