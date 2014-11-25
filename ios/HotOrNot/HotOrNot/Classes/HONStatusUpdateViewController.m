//
//  HONStatusUpdateViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONStatusUpdateViewController.h"
#import "HONClubPhotoViewCell.h"
#import "HONTableView.h"
#import "HONClubPhotoVO.h"
#import "HONRefreshControl.h"

@interface HONStatusUpdateViewController () <HONClubPhotoViewCellDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONClubPhotoVO *statusUpdateVO;
@end

@implementation HONStatusUpdateViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeStatusUpdate;
		_viewStateType = HONStateMitigatorViewStateTypeStatusUpdate;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshStatusUpdate:)
													 name:@"REFRESH_STATUS_UPDATE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_tareStatusUpdate:)
													 name:@"TARE_STATUS_UPDATE" object:nil];
	}
	
	return (self);
}

- (id)initWithStatusUpdate:(HONClubPhotoVO *)statusUpdateVO {
	NSLog(@"%@ - initWithStatusUpdate:[%@]", [self description], statusUpdateVO.dictionary);
	if ((self = [self init])) {
		_statusUpdateVO = statusUpdateVO;
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
	
	[self destroy];
}


#pragma mark - Public APIs
- (void)destroy {
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveScore {
	
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Status Update - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeFriendsTabRefresh];
	
	[self _goReloadTableViewContents];
}

- (void)_goReloadTableViewContents {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	[_tableView reloadData];
	
	[self _retrieveScore];
}

- (void)_didFinishDataRefresh {
	[_tableView reloadData];
	[_refreshControl endRefreshing];
	
	NSLog(@"%@._didFinishDataRefresh", self.class);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_tableView = [[HONTableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[_tableView setContentInset:UIEdgeInsetsMake(-20.0, 0.0, 0.0, 0.0)];
//	[_tableView setContentOffset:CGPointMake(0.0, -20.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
//	_tableView.pagingEnabled = YES;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Details"];
	[_headerView addCloseButtonWithTarget:self action:@selector(_goClose)];
	[self.view addSubview:_headerView];
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(280.0, 0.0, 44.0, 44.0);
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:flagButton];
}


#pragma mark - Navigation
- (void)_goClose {
	[self dismissViewControllerAnimated:NO completion:^(void) {
	}];
}

- (void)_goFlag {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
		[mailComposeViewController setSubject:@"Flag"];
		[mailComposeViewController setMessageBody:@"" isHTML:NO];
//		mailComposeViewController.mailComposeDelegate = self;
		
		[self presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
		
	} else {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"email_error", @"Email Error")
									message:NSLocalizedString(@"email_errormsg", @"Cannot send email from this device!")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Club Row Swipe"
	//										 withUserClub:cell.clubVO];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -1500) {
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}


#pragma mark - Notifications
- (void)_refreshStatusUpdate:(NSNotification *)notification {
	NSLog(@"::|> _refreshStatusUpdate <|::");
	
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoViewCell *viewCell = (HONClubPhotoViewCell *)obj;
		[viewCell destroy];
	}];
	
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	[self _retrieveScore];
}

- (void)_tareStatusUpdate:(NSNotification *)notification {
	NSLog(@"::|> _tareStatusUpdate <|::");
	
	if ([_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - ClubPhotoViewCell Delegates
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell upvotePhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:upvotePhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Upvote"
	//										withClubPhoto:clubPhotoVO];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - up"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:clubPhotoVO.challengeID isUpvote:YES completion:^(NSDictionary *result) {
		_statusUpdateVO = clubPhotoVO;
		_statusUpdateVO.score++;
		
		[[HONClubAssistant sharedInstance] writeStatusUpdateAsVotedWithID:_statusUpdateVO.challengeID asUpvote:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SCORE" object:_statusUpdateVO];
	}];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell downVotePhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:downVotePhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Down Vote"
	//										  withClubPhoto:clubPhotoVO];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - down"];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:clubPhotoVO.challengeID isUpvote:NO completion:^(NSDictionary *result) {
		_statusUpdateVO = clubPhotoVO;
		_statusUpdateVO.score--;
		
		[[HONClubAssistant sharedInstance] writeStatusUpdateAsVotedWithID:_statusUpdateVO.challengeID asUpvote:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SCORE" object:_statusUpdateVO];
	}];
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubPhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubPhotoViewCell alloc] init];
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	cell.delegate = self;
	
	cell.clubPhotoVO = _statusUpdateVO;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	if (!tableView.decelerating)
		[cell toggleImageLoading:YES];
	
	return (cell);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([UIScreen mainScreen].bounds.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoViewCell *cell = (HONClubPhotoViewCell *)obj;
		[cell toggleImageLoading:YES];
	}];
}

#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
}


@end
