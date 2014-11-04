//
//  HONClubTimelineViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:39 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONClubTimelineViewController.h"
#import "HONComposeViewController.h"
#import "HONUserProfileViewController.h"
#import "HONClubPhotoViewCell.h"
#import "HONTableView.h"
#import "HONClubPhotoVO.h"
#import "HONHeaderView.h"
#import "HONHeaderView.h"

@interface HONClubTimelineViewController () <HONClubPhotoViewCellDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *emptySetView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONClubPhotoVO *clubPhotoVO;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic) int clubID;
@property (nonatomic, strong) NSArray *clubPhotos;
@property (nonatomic) int index;
@property (nonatomic) int clubPhotoID;
@end


@implementation HONClubTimelineViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeTimeline;
		_viewStateType = HONStateMitigatorViewStateTypeTimeline;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshClubTimeline:)
													 name:@"REFRESH_CLUB_TIMELINE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_tareClubTimeline:)
													 name:@"TARE_CLUB_TIMELINE" object:nil];
	}
	
	return (self);
}

- (void)dealloc {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoViewCell *cell = (HONClubPhotoViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}

- (id)initWithClub:(HONUserClubVO *)clubVO atPhotoIndex:(int)index {
	NSLog(@"%@ - initWithClub:[%d] atPhotoIndex:[%d]", [self description], clubVO.clubID, index);
	if ((self = [self init])) {
		_clubVO = clubVO;
		_clubID = _clubVO.clubID;
		_clubPhotoID = 0;
		_index = index;
		_clubPhotos = _clubVO.submissions;
		_clubPhotoVO = (HONClubPhotoVO *)[_clubVO.submissions objectAtIndex:_index];
		
//		NSLog(@"TIMELINE FOR CLUB:[%@]\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=", _clubVO.dictionary);
	}
	
	return (self);
}

- (id)initWithClubID:(int)clubID atPhotoIndex:(int)index {
	NSLog(@"%@ - initWithClubID:[%d] atPhotoIndex:[%d]", [self description], clubID, index);
	if ((self = [self init])) {
		_clubVO = nil;
		_clubID = clubID;
		_index = index;
		_clubPhotoID = 0;
		_clubPhotos = _clubVO.submissions;
	}
	
	return (self);
}

- (id)initWithClubID:(int)clubID withClubPhotoID:(int)photoID {
	NSLog(@"%@ - initWithClubID:[%d] withClubPhotoID:[%d]", [self description], clubID, photoID);
	if ((self = [self init])) {
		_clubVO = nil;
		_clubID = clubID;
		_index = 0;
		_clubPhotoID = photoID;
		_clubPhotos = _clubVO.submissions;
	}
	
	return (self);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	NSLog(@"touchesBegan");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	NSLog(@"touchesEnded");
}

#pragma mark - Data Calls
- (void)_retrieveClub {
	_tableView.hidden = YES;
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	_clubPhotos = [NSArray array];
	[_tableView reloadData];
	
	[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubID withOwnerID:(_clubVO == nil) ? [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] : _clubVO.ownerID completion:^(NSDictionary *result) {
		_clubVO = [HONUserClubVO clubWithDictionary:result];
		_clubPhotos = _clubVO.submissions;
		
		NSLog(@"TIMELINE FOR CLUB:[%@]\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n[%@]", _clubVO.dictionary, _clubVO.coverImagePrefix);
		
		_tableView.contentSize = CGSizeMake(_tableView.frame.size.width, _tableView.frame.size.height * [_clubPhotos count]);
		[self _didFinishDataRefresh];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Club Timeline - Refresh" withUserClub:_clubVO];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeTimelineRefresh];
	
	_index = 0;
	_clubPhotoID = 0;
	
	[self _retrieveClub];
}

- (void)_didFinishDataRefresh {
	_clubPhotoVO = (HONClubPhotoVO *)[_clubVO.submissions objectAtIndex:_index];
	
	[[HONClubAssistant sharedInstance] isStatusUpdateSeenWithID:_clubPhotoVO.challengeID completion:^(BOOL isSeen) {
		NSLog(@"!¡!¡!¡ SEEN : %@\n", [@"" stringFromBOOL:isSeen]);
		
		if (!isSeen) {
			[[HONAPICaller sharedInstance] markChallengeAsSeenWithChallengeID:_clubPhotoVO.challengeID completion:^(NSDictionary *result) {
				[[HONClubAssistant sharedInstance] writeStatusUpdateAsSeenWithID:_clubPhotoVO.challengeID onCompletion:nil];
			}];
		}
	}];
	
	
	[_headerView setTitle:_clubPhotoVO.username];
	
	[UIView animateWithDuration:0.25 animations:^(void){
		_emptySetView.alpha = (float)([_clubPhotos count] == 0);
	}];
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	_tableView.hidden = NO;
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	if (_index != 0 || _clubPhotoID != 0)
		[self _jumpToPhotoFromID];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	UIView *refreshHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[self.view addSubview:_emptySetView];
	refreshHolderView.frame = CGRectOffset(refreshHolderView.frame, 0.0, -300.0);
	
	_emptySetView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_emptySetView.backgroundColor = [UIColor blackColor];
	_emptySetView.alpha = 0.0;
	[self.view addSubview:_emptySetView];
	
	UILabel *emptySetLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, ([UIScreen mainScreen].bounds.size.height - 24.0) * 0.5, 280.0, 24.0)];
	emptySetLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:16];
	emptySetLabel.textColor = [UIColor whiteColor];
	emptySetLabel.textAlignment = NSTextAlignmentCenter;
	emptySetLabel.text = NSLocalizedString(@"empty_timeline", @"No status updates available");
	[_emptySetView addSubview:emptySetLabel];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_emptySetView.alpha = (float)([_clubPhotos count] == 0);
	}];

//	NSLog(@"[UIScreen mainScreen].bounds:[%@]", NSStringFromCGRect([UIScreen mainScreen].bounds));
	_tableView = [[HONTableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_tableView.contentSize = CGSizeMake(_tableView.frame.size.width, _tableView.frame.size.height * [_clubPhotos count]);
	[_tableView setContentInset:UIEdgeInsetsMake(-20.0, 0.0, 20.0 - (kNavHeaderHeight + 5.0), 0.0)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundView = _emptySetView;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.pagingEnabled = YES;
	_tableView.showsHorizontalScrollIndicator = NO;
	_tableView.alwaysBounceVertical = YES;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	NSString *titleCaption = [NSString stringWithFormat:@"%@, ", _clubVO.ownerName];//(_clubVO.ownerID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"Me, " : @"";
	
	for (HONTrivialUserVO *vo in _clubVO.activeMembers)
		titleCaption = [titleCaption stringByAppendingFormat:@"%@, ", vo.username];//(vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"Me" : vo.username];
	
	for (HONTrivialUserVO *vo in _clubVO.pendingMembers) {
		if ([vo.username length] == 0)
			continue;
		
		titleCaption = [titleCaption stringByAppendingFormat:@"%@, ", vo.username];//(vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"Me" : vo.username];
	}
	
	titleCaption = ((HONClubPhotoVO *)[_clubVO.submissions firstObject]).username; //([titleCaption rangeOfString:@", "].location != NSNotFound) ? [titleCaption substringToIndex:[titleCaption length] - 2] : titleCaption;
	
//	_headerView = [[HONHeaderView alloc] initWithTitleUsingCartoGothic:@""];
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[_headerView removeBackground];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(-2.0, 1.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(272.0, 0.0, 44.0, 44.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"headerCameraButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"headerCameraButton_Active"] forState:UIControlStateHighlighted];
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:replyButton];
	
//	NSLog(@"CONTENT SIZE:[%@]", NSStringFromCGSize(_tableView.contentSize));
	
	if (_clubVO == nil && _clubID > 0)
		[self _retrieveClub];
	
	if (_index > 0) {
		_index = MIN(MAX(0, _index), [_clubPhotos count] - 1);
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_TABS" object:@"HIDE"];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
	
	if ([((UINavigationController *)self.presentedViewController).viewControllers firstObject] == nil)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}


#pragma mark - Navigation
- (void)_goReply {
	NSLog(@"[*:*] _goReply:(%d - %@)", _clubPhotoVO.userID, _clubPhotoVO.username);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Club Timeline - Reply"
										 withClubPhoto:_clubPhotoVO];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:_clubVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:[[HONAnimationOverseer sharedInstance] isSegueAnimationEnabledForModalViewController:navigationController.presentingViewController] completion:^(void) {
	}];
}

- (void)_goBack {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Club Timeline - Back"
									   withUserClub:_clubVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_TABS" object:@"SHOW"];
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].x >= 2000) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Club Timeline - Back SWIPE"
										   withUserClub:_clubVO];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_TABS" object:@"SHOW"];
		[self.navigationController popViewControllerAnimated:YES];
	}
	
//	if ([gestureRecognizer velocityInView:self.view].x <= -2000) {
//		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Club Timeline - Reply SWIPE"
//										  withClubPhoto:_clubPhotoVO];
//		
//		[self _goReply];
//	}
}



#pragma mark - Notifications
- (void)_refreshClubTimeline:(NSNotification *)notification {
	NSLog(@"::|> _refreshClubTimeline <|::");
	_index = 0;
	_clubPhotoID = 0;
	
	[self _retrieveClub];
}

- (void)_tareClubTimeline:(NSNotification *)notification {
	NSLog(@"::|> _tareClubTimeline <|::");
	
	if ([_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - UI Presentation
- (void)_advanceTimelineFromCell:(HONClubPhotoViewCell *)cell byAmount:(int)amount {
	int rows = MIN(amount, (([_tableView numberOfSections] - 1) - [_tableView indexPathForCell:cell].section));
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Club Timeline - Next Update"
									  withClubPhoto:cell.clubPhotoVO];
	
	_index = MIN(MAX(0, [_tableView indexPathForCell:(UITableViewCell *)cell].section + rows), [_clubPhotos count] - 1);
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)_jumpToPhotoFromID {
	[_clubPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoVO *vo = (HONClubPhotoVO *)obj;
		
		if (vo.challengeID == _clubPhotoID) {
			_index = idx;
			*stop = YES;
		}
	}];
	
	_index = MIN(_index, [_clubPhotos count]);
	
	if (_index > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


#pragma mark - ClubPhotoViewCell Delegates
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell advancePhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:advancePhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	[self _advanceTimelineFromCell:cell byAmount:1];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell showUserProfileForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:showUserProfileForClubPhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:clubPhotoVO.userID] animated:YES];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell replyToPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:replyToPhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Reply From Cell"
//									  withClubPhoto:clubPhotoVO];
	
	[self _goReply];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell upvotePhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:upvotePhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Upvote"
//									  withClubPhoto:clubPhotoVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:clubPhotoVO.challengeID forOpponent:clubPhotoVO completion:^(NSDictionary *result) {
		[[HONAPICaller sharedInstance] retrieveUserByUserID:clubPhotoVO.userID completion:^(NSDictionary *result) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:[HONChallengeVO challengeWithDictionary:result]];
		}];
		
		[self _advanceTimelineFromCell:cell byAmount:1];
	}];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_clubPhotos count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubPhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubPhotoViewCell alloc] init];
	
	cell.delegate = self;
	[cell hideChevron];
	[cell setSize:[UIScreen mainScreen].bounds.size];
	cell.indexPath = indexPath;
	cell.clubVO = _clubVO;
	cell.clubPhotoVO = (HONClubPhotoVO *)[_clubPhotos objectAtIndex:MIN(MAX(0, indexPath.section), [_clubPhotos count] - 1)];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([UIScreen mainScreen].bounds.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self _advanceTimelineFromCell:(HONClubPhotoViewCell *)[tableView cellForRowAtIndexPath:indexPath] byAmount:1];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return (proposedDestinationIndexPath);
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	_index = ((NSIndexPath *)[[_tableView indexPathsForVisibleRows] firstObject]).section;
	
	_clubPhotoVO = ((HONClubPhotoViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]]).clubPhotoVO;
	
	if ([_headerView.title isEqualToString:_clubPhotoVO.username]) {
		[_headerView setTitle:_clubPhotoVO.username];
	
	} else
		[_headerView transitionTitle:_clubPhotoVO.username];
	
	
	[[HONClubAssistant sharedInstance] isStatusUpdateSeenWithID:_clubPhotoVO.challengeID completion:^(BOOL isSeen) {
		NSLog(@"!¡!¡!¡ SEEN : %@\n", [@"" stringFromBOOL:isSeen]);
		
		if (!isSeen) {
			[[HONAPICaller sharedInstance] markChallengeAsSeenWithChallengeID:_clubPhotoVO.challengeID completion:^(NSDictionary *result) {
				[[HONClubAssistant sharedInstance] writeStatusUpdateAsSeenWithID:_clubPhotoVO.challengeID onCompletion:nil];
			}];
		}
	}];
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		if (buttonIndex == 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"captions"			: @{@"instagram"	: [NSString stringWithFormat:[HONAppDelegate instagramShareMessage], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"twitter"		: [NSString stringWithFormat:[HONAppDelegate twitterShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"sms"			: [NSString stringWithFormat:[HONAppDelegate smsShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"email"		: @[[[HONAppDelegate emailShareComment] objectForKey:@"subject"], [NSString stringWithFormat:[[HONAppDelegate emailShareComment] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"]]],//  [[[[HONAppDelegate emailShareComment] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareComment] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"]]],
																															@"clipboard"	: [NSString stringWithFormat:[HONAppDelegate smsShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]]},
																									@"image"			: _clubPhotoVO.imagePrefix, //([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [[HONImageBroker sharedInstance] shareTemplateImageForType:HONImageBrokerShareTemplateTypeDefault],
																									@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																									@"club"				: _clubVO.dictionary,
																									@"mp_event"			: @"Club Timeline - More Action Sheet _Share",
																									@"view_controller"	: self}];

		
		} else if (buttonIndex == 1) {
			NSLog(@"[*:*] _clubPhotoVO:(%d - %@)", _clubPhotoVO.userID, _clubPhotoVO.username);
//			[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - More Action Sheet _Upvote"
//											  withClubPhoto:_clubPhotoVO];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
			[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:_clubPhotoVO.challengeID forOpponent:_clubPhotoVO completion:^(NSDictionary *result) {
				[[HONAPICaller sharedInstance] retrieveUserByUserID:_clubPhotoVO.userID completion:^(NSDictionary *result) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:[HONChallengeVO challengeWithDictionary:result]];
				}];
				
				[self _advanceTimelineFromCell:(HONClubPhotoViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]] byAmount:1];
			}];
		
		} else if (buttonIndex == 2) {
			NSLog(@"[*:*] _clubPhotoVO:(%d - %@)", _clubPhotoVO.userID, _clubPhotoVO.username);
//			[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - More Action Sheet _Reply"
//											  withClubPhoto:_clubPhotoVO];
			[self _goReply];
		}
	}
}


@end
