//
//  HONComposeSubmitViewController.m
//  HotOrNot
//
//  Created by BIM  on 9/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONComposeSubmitViewController.h"

@interface HONComposeSubmitViewController () <HONClubViewCellDelegate, HONTableViewBGViewDelegate>
@property (nonatomic, strong) NSMutableArray *selectedClubs;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSMutableDictionary *submitParams;
@property (nonatomic, strong) HONClubViewCell *replyClubViewCell;
@end

@implementation HONComposeSubmitViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeComposeSubmit;
		_viewStateType = HONStateMitigatorViewStateTypeComposeSubmit;
	}
	
	return (self);
}

- (id)initWithSubmitParameters:(NSDictionary *)submitParams {
	if ((self = [self init])) {
		_submitParams = [submitParams mutableCopy];
	}
	
	return (self);
}

- (void)dealloc {
	[super destroy];
}


#pragma mark - Data Calls
- (void)_submitStatusUpdate:(HONUserClubVO *)clubVO {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Submit"
									   withProperties:[self _trackingProps]];
	
	[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
		if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"Error!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
			_progressHUD = nil;
			
		} else {
			HONChallengeVO *challengeVO = [HONChallengeVO challengeWithDictionary:result];
			[[HONClubAssistant sharedInstance] writeStatusUpdateAsSeenWithID:challengeVO.challengeID onCompletion:^(NSDictionary *result) {
				NSMutableArray *users = [NSMutableArray array];
				for (HONTrivialUserVO *vo in _selectedUsers)
					[users addObject:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:vo]];
				
				NSMutableArray *contacts = [NSMutableArray array];
				for (HONContactUserVO *vo in _selectedContacts)
					[contacts addObject:[[HONAnalyticsReporter sharedInstance] propertyForContactUser:vo]];
				
				[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Send Club Invites"
												   withProperties:@{@"clubs"	: [[HONAnalyticsReporter sharedInstance] propertyForUserClub:_userClubVO],
																	@"members"	: users,
																	@"contacts"	: contacts}];
				
				[[HONClubAssistant sharedInstance] sendClubInvites:_userClubVO toInAppUsers:_selectedUsers ToNonAppContacts:_selectedContacts onCompletion:^(BOOL success) {
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
					}];
				}];
			}];
		}
	}];
}



#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Refresh Contacts"];
	[super _goDataRefresh:sender];
	[self _goReloadTableViewContents];
}

- (void)_goReloadTableViewContents {
	[_refreshControl beginRefreshing];
	[super _goReloadTableViewContents];
}

- (void)_didFinishDataRefresh {
	if ([_matchedUserIDs count] < [_allDeviceContacts count]) {
		[_matchedUserIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			for (HONContactUserVO *contactUserVO in _allDeviceContacts) {
				NSString *altID = (NSString *)obj;
				NSLog(@"altID:[%@]=- cell.contactUserVO.mobileNumber:[%@]", altID, contactUserVO.mobileNumber);
				
				if ([contactUserVO.mobileNumber isEqualToString:altID]) {
					NSLog(@"********DELETE*********\n%@", contactUserVO.fullName);
					[_omittedDeviceContacts addObject:contactUserVO];
					break;
				}
			}
		}];
		
	} else {
		for (HONContactUserVO *contactUserVO in _allDeviceContacts) {
			[_matchedUserIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSString *altID = (NSString *)obj;
				NSLog(@"altID:[%@]=- cell.contactUserVO.mobileNumber:[%@]", altID, contactUserVO.mobileNumber);
				
				if ([contactUserVO.mobileNumber isEqualToString:altID]) {
					NSLog(@"********DELETE*********\n%@", contactUserVO.fullName);
					[_omittedDeviceContacts addObject:contactUserVO];
					*stop = YES;//break;
				}
			}];
		}
	}
	
	NSLog(@"%@._didFinishDataRefresh - _clubs() = [%d]", self.class, [_clubs count]);
	[_clubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONUserClubVO *vo = (HONUserClubVO *)obj;
		
		NSLog(@"%d <> %d", [[_submitParams objectForKey:@"club_id"] intValue], vo.clubID);
		if ([[_submitParams objectForKey:@"club_id"] intValue] == vo.clubID) {
			if (![_selectedClubs containsObject:vo])
				[_selectedClubs addObject:vo];
			
			_replyClubViewCell.clubVO = vo;
			[_replyClubViewCell toggleImageLoading:YES];
			_replyClubViewCell.hidden = NO;
		}
	}];
	
	[_clubs removeAllObjects];
	[super _didFinishDataRefresh];
	
	_emptyContactsBGView.hidden = YES;
	[_refreshControl endRefreshing];
	[_tableView reloadData];
	
	NSLog(@"%@._didFinishDataRefresh - _selectedClubs() = [%d]", self.class, [_selectedClubs count]);
	
	if ([_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (NSDictionary *)_trackingProps {
	NSMutableArray *users = [NSMutableArray array];
	for (HONTrivialUserVO *vo in _selectedUsers)
		[users addObject:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:vo]];
	
	NSMutableArray *contacts = [NSMutableArray array];
	for (HONContactUserVO *vo in _selectedContacts)
		[contacts addObject:[[HONAnalyticsReporter sharedInstance] propertyForContactUser:vo]];
	
	NSMutableDictionary *props = [NSMutableDictionary dictionary];
	[props setValue:users forKey:@"members"];
	[props setValue:contacts forKey:@"contacts"];
	
	return ([props copy]);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_selectedClubs = [NSMutableArray array];
	_selectedContacts = [NSMutableArray array];
	_selectedUsers = [NSMutableArray array];
	
	[_headerView setTitle:NSLocalizedString(@"header_selectFriends", @"Select Friends")];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(4.0, 2.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(0.0, self.view.frame.size.height - 50.0, 320.0, 50.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submit1Button_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submit1Button_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
	
	[_refreshControl beginRefreshing];
	
//	[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom - submitButton.frame.size.height, _tableView.contentInset.right)];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	[self _goReloadTableViewContents];
}


#pragma mark - UI Presentation
- (void)_finishSubmit {
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
	}];
}


#pragma mark - Navigation
- (void)_goBack {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Back"];
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
	
	if ([gestureRecognizer velocityInView:self.view].x >= 2000) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Back SWIPE"];
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Submit SWIPE"];
		[self _goSubmit];
	}
}

- (void)_goSubmit {
	if ([_selectedUsers count] == 0 && [_selectedContacts count] == 0) {
		[[[UIAlertView alloc] initWithTitle:@"You must select at least one friend to submit"
									message:@""
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else {
		NSMutableArray *participants = [NSMutableArray array];

		for (HONTrivialUserVO *vo in _selectedUsers)
			[participants addObject:vo.username];

		for (HONContactUserVO *vo in _selectedContacts)
			[participants addObject:([HONTrivialUserVO userFromContactUserVO:vo]).username];

		NSString *names = @"";
		for (NSString *name in participants)
			names = [names stringByAppendingFormat:@"%@, ", name];
		names = ([names rangeOfString:@", "].location != NSNotFound) ? [names substringToIndex:[names length] - 2] : names;
		
		NSLog(@"CLUB -=- (CREATE) -=-");
		NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
		[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], (int)[[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSince1970]] forKey:@"name"];
		_userClubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
		
		[[HONAPICaller sharedInstance] createClubWithTitle:_userClubVO.clubName withDescription:_userClubVO.blurb withImagePrefix:_userClubVO.coverImagePrefix completion:^(NSDictionary *result) {
			_userClubVO = [HONUserClubVO clubWithDictionary:result];
			[_submitParams replaceObject:[@"" stringFromInt:_userClubVO.clubID] forExistingKey:@"club_id"];
			
			[self _submitStatusUpdate:_userClubVO];
		}];
	}
	
		
//		if ([_selectedClubs count] > 0) {
//			__block NSString *names = @"";
//			__block HONUserClubVO *submitClubVO = nil;
//			NSMutableArray *participants = [NSMutableArray array];
//			
//			[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//				HONUserClubVO *clubVO = (HONUserClubVO *)obj;
//				
//				[clubVO.activeMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//					HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
//					[_selectedUsers addObject:vo];
//					[participants addObject:vo.username];
//					names = [names stringByAppendingFormat:@"%@, ", vo.username];
//				}];
//				
//				[clubVO.pendingMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//					HONContactUserVO *contactUserVO = (HONContactUserVO *)obj;
//					HONTrivialUserVO *trivialUserVO = [HONTrivialUserVO userFromContactUserVO:(HONContactUserVO *)obj];
//					
//					[_selectedContacts addObject:contactUserVO];
//					[participants addObject:trivialUserVO.username];
//					names = [names stringByAppendingFormat:@"%@, ", trivialUserVO.username];
//				}];
//				
//				names = ([names rangeOfString:@", "].location != NSNotFound) ? [names substringToIndex:[names length] - 2] : names;
//
//				NSLog(@"CLUB -=- (CREATE) -=-");
//				NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
//				[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], (int)[[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSince1970]] forKey:@"name"];
//				submitClubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
//				
//				[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"CREATING CLUB [%@]", submitClubVO.clubName]
//											message:[NSString stringWithFormat:@"%@", names]
//										   delegate:nil
//								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//								  otherButtonTitles:nil] show];
//				
//				
//				//
//				//				[[HONAPICaller sharedInstance] createClubWithTitle:submitClubVO.clubName withDescription:submitClubVO.blurb withImagePrefix:submitClubVO.coverImagePrefix completion:^(NSDictionary *result) {
//				//					HONUserClubVO *submitClubVO = [HONUserClubVO clubWithDictionary:result];
//				//					[_submitParams replaceObject:[@"" stringFromInt:submitClubVO.clubID] forExistingKey:@"club_id"];
//				//					NSLog(@"SUBMITTING:[%@]", _submitParams);
//				//
//				//					[self _submitStatusUpdate:submitClubVO];
//				//					[self _sendClubInvites:submitClubVO];
//				//				}];
//			}];
//		}
		
		//		if ([_selectedClubs count] > 0) {
		//			if ([_selectedUsers count] > 0 || [_selectedContacts count] > 0) {
		//				NSMutableArray *participants = [NSMutableArray array];
		//
		//				for (HONTrivialUserVO *vo in _selectedUsers)
		//					[participants addObject:vo.username];
		//
		//				for (HONContactUserVO *vo in _selectedContacts)
		//					[participants addObject:([HONTrivialUserVO userFromContactUserVO]).username];
		//
		//				NSString *names = @"";
		//				for (NSString *name in participants)
		//					names = [names stringByAppendingFormat:@"%@, ", name];
		//				names = ([names rangeOfString:@", "].location != NSNotFound) ? [names substringToIndex:[names length] - 2] : names;
		//
		//
		//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add to club?"
		//																	message:[NSString stringWithFormat:@"Are you sure you want to add %@ to the club%@ you have selected?", names, ([_selectedClubs count] != 1) ? @"s" : @""]
		//																   delegate:self
		//														  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
		//														  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
		//				[alertView setTag:10];
		//				[alertView show];
		//
		//			} else {
		//				[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		//					HONUserClubVO *submitClubVO = (HONUserClubVO *)obj;
		//
		//					[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
		//					NSLog(@"SUBMITTING:[%@]", _submitParams);
		//
		//					[self _submitStatusUpdate:submitClubVO];
		//					[self _sendClubInvites:submitClubVO];
		//				}];
		//			}
		//
		//		} else {
		//			if ([_selectedUsers count] == 0 && [_selectedContacts count] == 0) {
		//				HONUserClubVO *submitClubVO = [[HONClubAssistant sharedInstance] userSignupClub];
		//				NSLog(@"CLUB -=- (JOIN:userSignupClub) -=-");
		//				[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
		//
		//				NSLog(@"SUBMITTING:[%@]", _submitParams);
		//
		//				[self _submitStatusUpdate:submitClubVO];
		//				[self _sendClubInvites:submitClubVO];
		//
		//			} else {
		//				NSMutableArray *participants = [NSMutableArray array];
		//
		//				for (HONTrivialUserVO *vo in _selectedUsers)
		//					[participants addObject:vo];
		//
		//				for (HONContactUserVO *vo in _selectedContacts)
		//					[participants addObject:[HONTrivialUserVO userFromContactUserVO]];
		//
		//				__block HONUserClubVO *submitClubVO = [[HONClubAssistant sharedInstance] clubWithParticipants:participants];
		//				if (submitClubVO != nil) {
		//					NSLog(@"CLUB -=- (JOIN) -=-");
		//
		//					[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
		//					NSLog(@"SUBMITTING:[%@]", _submitParams);
		//
		//					[_selectedUsers removeAllObjects];
		//					[_selectedContacts removeAllObjects];
		//
		//					[self _submitStatusUpdate:submitClubVO];
		//					[self _sendClubInvites:submitClubVO];
		//
		//				} else {
		//					NSLog(@"CLUB -=- (CREATE) -=-");
		//
		//					NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
		//					[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], (int)[[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSince1970]] forKey:@"name"];
		//					submitClubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
		//
		//					[[HONAPICaller sharedInstance] createClubWithTitle:submitClubVO.clubName withDescription:submitClubVO.blurb withImagePrefix:submitClubVO.coverImagePrefix completion:^(NSDictionary *result) {
		//						submitClubVO = [HONUserClubVO clubWithDictionary:result];
		//						[_submitParams setValue:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
		//						NSLog(@"SUBMITTING:[%@]", _submitParams);
		//
		//						[self _submitStatusUpdate:submitClubVO];
		//						[self _sendClubInvites:submitClubVO];
		//					}];
		//				}
		//			}
		//		}
//	}
}


#pragma mark - TableViewBGView Delegates
- (void)tableViewBGViewDidSelect:(HONTableViewBGView *)bgView {
	NSLog(@"[*:*] tableViewBGViewDidSelect [*:*]");
	
	if (bgView.viewType == HONTableViewBGViewTypeAccessContacts) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Access Contacts"
										   withProperties:@{@"access"	: (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"undetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"authorized" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"denied" : @"other"}];
	}
	
	[super tableViewBGViewDidSelect:bgView];
}

#pragma mark - ClubViewCell Delegates
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[*:*] clubViewCell:didSelectContactUser");
	
	NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
	[props setValue:[[HONAnalyticsReporter sharedInstance] propertyForContactUser:contactUserVO] forKey:@"contact"];
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Selected Contact"
									   withProperties:props];
	
	[super clubViewCell:viewCell didSelectContactUser:contactUserVO];
	if ([_selectedContacts containsObject:viewCell.trivialUserVO])
		[_selectedContacts removeObject:viewCell.trivialUserVO];
	
	else
		[_selectedContacts addObject:viewCell.trivialUserVO];
}

- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[*:*] clubViewCell:didSelectTrivialUser");
	
	NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
	[props setValue:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:trivialUserVO] forKey:@"member"];
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
									   withProperties:props];
	
	[super clubViewCell:viewCell didSelectTrivialUser:trivialUserVO];
	if ([_selectedUsers containsObject:viewCell.trivialUserVO])
		[_selectedUsers removeObject:viewCell.trivialUserVO];
	
	else
		[_selectedUsers addObject:viewCell.trivialUserVO];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? 1 : (section == 1) ? 0 : (section == 2) ? [_inAppUsers count] : [_shownDeviceContacts count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ((section == 1) ? nil : [[HONTableHeaderView alloc] initWithTitle:(section == 2) ? ([_allDeviceContacts count] == 0 && [_inAppUsers count] == 0) ? @"No results" : @"Friends" : (section == 3) ? ([_allDeviceContacts count] == 0 && [_inAppUsers count] == 0) ? @"No results" : @"Contacts" : @""]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubViewCell *cell = (HONClubViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	[cell hideTimeStat];
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers) {
		if (indexPath.section == 1) {
		} else if (indexPath.section == 2) {
			[_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
				//				NSLog(@"CELL:[%d] -=- [%d]VO", cell.trivialUserVO.userID, vo.userID);
				[cell toggleSelected:(vo.userID == cell.trivialUserVO.userID)];
				*stop = cell.isSelected;
			}];
		}
		
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		if (indexPath.section == 1) {
		} else if (indexPath.section == 2) {
			[_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
				//				NSLog(@"CELL:[%d] -=- [%d]VO", cell.trivialUserVO.userID, vo.userID);
				[cell toggleSelected:(vo.userID == cell.trivialUserVO.userID)];
				*stop = cell.isSelected;
			}];
			
			[_matchedUserIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSString *altID = (NSString *)obj;
				if ([cell.trivialUserVO.altID isEqualToString:altID]) {
					//					NSLog(@"********MERGE ATTEMPT*********\n");
					[_allDeviceContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
						HONContactUserVO *vo = (HONContactUserVO *)obj;
						
						if ([vo.mobileNumber isEqualToString:altID] && [cell.caption rangeOfString:vo.fullName].location == 0) {
							NSLog(@"********MERGE FOUND!!! [%d](%@)*********", cell.trivialUserVO.userID, vo.fullName);
							[cell setCaption:vo.fullName];
							[cell addSubtitleCaption:[NSString stringWithFormat:@"%@", cell.trivialUserVO.username]];
							//[cell addSubtitleCaption:[NSString stringWithFormat:@"%@", vo.fullName]];
							*stop = YES;
						}
					}];
				}
			}];
			
			
		} else if (indexPath.section == 3) {
			[_selectedContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONContactUserVO *vo = (HONContactUserVO *)obj;
				//				NSLog(@"CELL:[%@] -=- [%@]VO", cell.contactUserVO.mobileNumber, vo.mobileNumber);
				[cell toggleSelected:([vo.mobileNumber isEqualToString:cell.contactUserVO.mobileNumber])];
				*stop = cell.isSelected;
			}];
		}
	}
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((section == 2 || section == 3) ? kOrthodoxTableHeaderHeight : 0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return (proposedDestinationIndexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	HONClubViewCell *cell = (HONClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"[[- cell.contactUserVO.userID:[%d]", cell.contactUserVO.userID);
	NSLog(@"[[- cell.trivialUserVO.userID:[%d]", cell.trivialUserVO.userID);
	if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers) {
		if (indexPath.section == 0) {
			//			[[HONAnalyticsParams sharedInstance] trackEvent:@"Friends Tab - Access Contacts"
			//											 withProperties:@{@"access"	: (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"undetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"authorized" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"denied" : @"other"}];
			
		} else if (indexPath.section == 1) {
			NSLog(@"RECENT CLUB:[%@]", cell.clubVO.clubName);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsReporter sharedInstance] propertyForUserClub:cell.clubVO] forKey:@"club"];
			//			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Club"
			//											 withProperties:props];
			
		} else if (indexPath.section == 2) {
			NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:cell.trivialUserVO] forKey:@"member"];
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
											   withProperties:props];
			[cell invertSelected];
			if ([_selectedUsers containsObject:cell.trivialUserVO])
				[_selectedUsers removeObject:cell.trivialUserVO];
			
			else
				[_selectedUsers addObject:cell.trivialUserVO];
		}
		
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		if (indexPath.section == 0) {
			//			[[HONAnalyticsParams sharedInstance] trackEvent:@"Friends Tab - Access Contacts"
			//											 withProperties:@{@"access"	: (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"undetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"authorized" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"denied" : @"other"}];
			
		} else if (indexPath.section == 1) {
			NSLog(@"RECENT CLUB:[%@]", cell.clubVO.clubName);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsReporter sharedInstance] propertyForUserClub:cell.clubVO] forKey:@"club"];
			//			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Club"
			//											 withProperties:props];
			
		} else if (indexPath.section == 2) {
			NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:cell.trivialUserVO] forKey:@"member"];
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
											   withProperties:props];
			
			[cell invertSelected];
			if ([_selectedUsers containsObject:cell.trivialUserVO])
				[_selectedUsers removeObject:cell.trivialUserVO];
			
			else
				[_selectedUsers addObject:cell.trivialUserVO];
			
		} else if (indexPath.section == 3) {
			NSLog(@"DEVICE CONTACT:[%@]", cell.contactUserVO.fullName);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsReporter sharedInstance] propertyForContactUser:cell.contactUserVO] forKey:@"contact"];
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
											   withProperties:props];
			
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Selected Contact"
											  withContactUser:cell.contactUserVO];
			[cell invertSelected];
			if ([_selectedContacts containsObject:cell.contactUserVO])
				[_selectedContacts removeObject:cell.contactUserVO];
			
			else
				[_selectedContacts addObject:cell.contactUserVO];
		}
	}
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
	if (alertView.tag == 10) {
		NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
		[props setValue:(buttonIndex == 0) ? @"Cancel" : @"Confirm" forKey:@"btn"];
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Invite Alert"
										   withProperties:props];
		
		if (buttonIndex == 1) {
			[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONUserClubVO *submitClubVO = (HONUserClubVO *)obj;
				
				[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
				NSLog(@"SUBMITTING:[%@]", _submitParams);
				
				[self _submitStatusUpdate:submitClubVO];
			}];
		}
	}
}

@end
