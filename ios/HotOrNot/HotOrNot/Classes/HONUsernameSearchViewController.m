//
//  HONSearchUsersViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "UIImageView+AFNetworking.h"

#import "HONUsernameSearchViewController.h"
#import "HONClubViewCell.h"
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"
#import "HONTableView.h"
#import "HONSearchBarView.h"
#import "HONRefreshControl.h"
#import "HONActivityViewController.h"
#import "HONComposeTopicViewController.h"

@interface HONUsernameSearchViewController () <HONClubViewCellDelegate, HONSearchBarViewDelegate>
@property (nonatomic, strong) NSMutableArray *searchUsers;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) HONSearchBarView *searchHeaderView;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end


@implementation HONUsernameSearchViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeSearchUsername;
		_viewStateType = HONStateMitigatorViewStateTypeSearchUsername;
	}
	
	return (self);
}

- (void)dealloc {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubViewCell *cell = (HONClubViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveUsers:(NSString *)username {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] searchForUsersByUsername:username completion:^(NSArray *result) {
		_searchUsers = [NSMutableArray array];
		for (NSDictionary *dict in result) {
			[_searchUsers addObject:[HONTrivialUserVO userWithDictionary:@{@"id"		: [dict objectForKey:@"id"],
																		   @"username"	: [dict objectForKey:@"username"],
																		   @"img_url"	: [dict objectForKey:@"avatar_url"]}]];
		}
		
		if (_progressHUD != nil) {
			if ([_searchUsers count] == 0) {
				_progressHUD.minShowTime = kProgressHUDMinDuration;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
				_progressHUD = nil;
				
				_searchUsers = [NSMutableArray array];
				
			} else {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}
		
		[self _didFinishDataRefresh];
	}];
}

#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[self performSelector:@selector(_didFinishDataRefresh) withObject:nil afterDelay:0.33];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}

- (NSDictionary *)_trackingProps {
	NSMutableArray *users = [NSMutableArray array];
	for (HONTrivialUserVO *vo in _selectedUsers)
		[users addObject:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:vo]];

	NSMutableDictionary *props = [NSMutableDictionary dictionary];
	[props setValue:users forKey:@"members"];
	
	return ([props copy]);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_searchUsers = [NSMutableArray array];
	_selectedUsers = [NSMutableArray array];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_search", @"Search")];
	[_headerView addCloseButtonWithTarget:self action:@selector(_goClose)];
	[_headerView addNextButtonWithTarget:self action:@selector(_goDone)];
	[self.view addSubview:_headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, [UIScreen mainScreen].bounds.size.height - kNavHeaderHeight)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.alwaysBounceVertical = YES;
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.scrollsToTop = NO;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
	[_searchHeaderView becomeFirstResponder];
}


#pragma mark - Navigation
- (void)_goClose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Username - Cancel"];
	
	[_searchHeaderView resignFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goDone {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Username - Done"
//									 withProperties:[self _trackingProps]];
	
	
	if ([_selectedUsers count] > 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add to club?"
															message:[NSString stringWithFormat:@"Are you sure you want to add %d %@ to a club?", (int)[_selectedUsers count], ((int)[_selectedUsers count] == 1) ? @"person" : @"people"]
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
		[alertView setTag:0];
		[alertView show];
		
	} else {
		[[[UIAlertView alloc] initWithTitle:@"Nothing Selected!"
									message:@"You need to enter a username to search for first"
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		[_searchHeaderView becomeFirstResponder];
	}
}

- (void)_goSelectAll {
//	[[HONAnalyticsParams sharedInstance] trackEvent:[@"User Search - Select All Toggle " stringByAppendingString:([_selectedUsers count] == [_searchUsers count]) ? @"On" : @"Off"]];
	
	if ([_selectedUsers count] == [_searchUsers count])
		[_selectedUsers removeAllObjects];
	
	else {
		for (HONTrivialUserVO *vo in _searchUsers) {
			if (![_selectedUsers containsObject:vo])
				[_selectedUsers addObject:vo];
		}
	}
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search - Cancel SWIPE"];
		
		[_searchHeaderView resignFirstResponder];
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		if ([_selectedUsers count] > 0) {
//			[[HONAnalyticsParams sharedInstance] trackEvent:@"User Search - Invite Alert SWIPE"
//											 withProperties:[self _trackingProps]];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add to club?"
																message:[NSString stringWithFormat:@"Are you sure you want to add %d %@ to a club?", (int)[_selectedUsers count], ((int)[_selectedUsers count] == 1) ? @"person" : @"people"]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
			[alertView setTag:0];
			[alertView show];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Nothing Selected!"
										message:@"You need to enter a username to search for first"
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			[_searchHeaderView becomeFirstResponder];
		}
	}
}


#pragma mark - ClubViewCell Delegates
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[*:*] clubViewCell:didSelectTrivialUser");
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Username - Selected In-App User"
//									withTrivialUser:trivialUserVO];
	
	if ([_selectedUsers containsObject:viewCell.trivialUserVO])
		[_selectedUsers removeObject:viewCell.trivialUserVO];
	
	else
		[_selectedUsers addObject:viewCell.trivialUserVO];
}


#pragma mark - SearchBarHeader Delegates
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView {
	NSLog(@"[*:*] searchBarViewHasFocus:");
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Username - Search Bar"
//									 withProperties:@{@"state"	: @"focus"}];
	
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
}

- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView {
	NSLog(@"[*:*] searchBarViewCancel:");
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Username - Search Bar"
//									 withProperties:@{@"state"	: @"cancel"}];
	
	_tableView.separatorStyle = ([_searchUsers count] == 0) ? UITableViewCellSeparatorStyleSingleLineEtched : UITableViewCellSeparatorStyleNone;
}

- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery {
	NSLog(@"[*:*] searchBarView:enteredSearch:");
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Username - Entered Username"
//									 withProperties:@{@"username"	: searchQuery}];
	
	if (![searchQuery isEqualToString:[[HONUserAssistant sharedInstance] activeUsername]])
		  [self _retrieveUsers:searchQuery];
	
	else {
		[[[UIAlertView alloc] initWithTitle:@"Cannot Search For Yourself!"
									message:@"You cannot search w/ this query, try again"
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
//		[_searchHeaderView becomeFirstResponder];
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_searchUsers count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	_searchHeaderView = [[HONSearchBarView alloc] initWithFrame:CGRectFromSize(CGSizeMake(tableView.frame.size.width, kSearchHeaderHeight))];
	_searchHeaderView.delegate = self;
	
	return (_searchHeaderView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubViewCell alloc] initAsCellType:HONClubViewCellTypeBlank];
	
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	
	HONTrivialUserVO *vo = (HONTrivialUserVO *)[_searchUsers objectAtIndex:indexPath.row];
	cell.trivialUserVO = vo;
	
	[_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
		[cell toggleSelected:(vo.userID == cell.trivialUserVO.userID)];
		*stop = cell.isSelected;
	}];
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kSearchHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONClubViewCell *cell = (HONClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"[[- cell.trivialUserVO.userID:[%d]", cell.trivialUserVO.userID);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Username - Selected In-App User"
//									withTrivialUser:cell.trivialUserVO];
	
	NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
	
	[cell invertSelected];
	if ([_selectedUsers containsObject:cell.trivialUserVO])
		[_selectedUsers removeObject:cell.trivialUserVO];
	
	else
		[_selectedUsers addObject:cell.trivialUserVO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 1.0;
//	cell.alpha = 0.0;
//	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
//		cell.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
		[props setValue:(buttonIndex == 0) ? @"Cancel" : @"Confirm" forKey:@"btn"];
		
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Username - Results Alert"
//										 withProperties:[props copy]];
		
		if (buttonIndex == 1) {
			_isPushing = YES;
//			__block HONUserClubVO *clubVO = [[HONClubAssistant sharedInstance] clubWithParticipants:_selectedUsers];
//			
//			if (clubVO != nil) {
//				NSLog(@"CLUB -=- (JOIN) -=-");
//				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:clubVO]];
//				[navigationController setNavigationBarHidden:YES];
//				[self presentViewController:navigationController animated:YES completion:nil];
			
//				[[HONAPICaller sharedInstance] inviteInAppUsers:_selectedUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
//					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:clubVO]];
//					[navigationController setNavigationBarHidden:YES];
//					[self presentViewController:navigationController animated:YES completion:nil];
//				}];
				
//			} else {
				
				NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] clubDictionaryWithOwner:@{} activeMembers:@[] pendingMembers:_selectedUsers];
				[dict setValue:[NSString stringWithFormat:@"%d_%d", [[HONUserAssistant sharedInstance] activeUserID], [NSDate elapsedUTCSecondsSinceUnixEpoch]] forKey:@"name"];
				[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImageURL] forKey:@"img"];
				HONUserClubVO *clubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
			
			NSLog(@"CLUB -=- (GENERATE) -=-\n%@", clubVO.dictionary);
//				[[HONAPICaller sharedInstance] createClubWithTitle:clubVO.clubName withDescription:clubVO.blurb withImagePrefix:clubVO.coverImagePrefix completion:^(NSDictionary *result) {
//					clubVO = [HONUserClubVO clubWithDictionary:result];
//					
//					[[HONAPICaller sharedInstance] inviteInAppUsers:_selectedUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
						UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeTopicViewController alloc] initWithClub:clubVO]];
						[navigationController setNavigationBarHidden:YES];
						[self presentViewController:navigationController animated:YES completion:nil];
//					}];
//				}];
//			}
		}
	}
}

@end
