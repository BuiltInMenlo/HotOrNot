//
//  HONStatusUpdateSubmitViewController.m
//  HotOrNot
//
//  Created by BIM  on 9/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "CKRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONStatusUpdateSubmitViewController.h"


@interface HONStatusUpdateSubmitViewController () <HONClubViewCellDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSMutableArray *selectedClubs;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSMutableDictionary *submitParams;
@property (nonatomic, strong) NSMutableDictionary *userIDContactID;
@property (nonatomic, strong) HONClubViewCell *replyClubViewCell;
@end

@implementation HONStatusUpdateSubmitViewController


- (id)initWithSubmitParameters:(NSDictionary *)submitParams {
	if ((self = [super init])) {
		_submitParams = [submitParams mutableCopy];
	}
	
	return (self);
}



#pragma mark - Data Calls
- (void)_submitStatusUpdate:(HONUserClubVO *)clubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Submit"
									   withUserClub:clubVO];
	
	[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
		if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"Error!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		
		} else {
			
		}
	}];
}

- (void)_sendClubInvites:(HONUserClubVO *)clubVO {
	NSMutableArray *users = [NSMutableArray array];
	for (HONTrivialUserVO *vo in _selectedUsers)
		[users addObject:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:vo]];
	
	NSMutableArray *contacts = [NSMutableArray array];
	for (HONContactUserVO *vo in _selectedContacts)
		[contacts addObject:[[HONAnalyticsParams sharedInstance] propertyForContactUser:vo]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Send Club Invites"
									 withProperties:@{@"clubs"		: [[HONAnalyticsParams sharedInstance] propertyForUserClub:clubVO],
													  @"members"	: users,
													  @"contacts"	: contacts}];
	
	if ([_selectedUsers count] == 0 && [_selectedContacts count] == 0) {
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//		[self dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
		}];
	}
	
	if ([_selectedUsers count] > 0 && [_selectedContacts count] > 0) {
		[[HONAPICaller sharedInstance] inviteInAppUsers:_selectedUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID inviteNonAppContacts:_selectedContacts completion:^(NSDictionary *result) {
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//			[self dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
			}];
		}];
	
	} else {
		if ([_selectedUsers count] > 0) {
			[[HONAPICaller sharedInstance] inviteInAppUsers:_selectedUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//				[self dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
				}];
			}];
		}
		
		if ([_selectedContacts count] > 0) {
			[[HONAPICaller sharedInstance] inviteNonAppUsers:_selectedContacts toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				//[self dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
				}];
			}];
		}
	}
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Friends Tab - Refresh"];
	[super _goDataRefresh:sender];
}

- (void)_didFinishDataRefresh {
	
	if ([_matchedUserIDs count] < [_allDeviceContacts count]) {
		[_matchedUserIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			for (HONContactUserVO *contactUserVO in _allDeviceContacts) {
				NSString *altID = (NSString *)obj;
//				NSLog(@"altID:[%@]=- cell.contactUserVO.mobileNumber:[%@]", altID, contactUserVO.mobileNumber);
				
				if ([contactUserVO.mobileNumber isEqualToString:altID]) {
//					NSLog(@"********DELETE*********\n%@", contactUserVO.fullName);
					[_omittedDeviceContacts addObject:contactUserVO];
					break;
				}
			}
		}];
		
	} else {
		for (HONContactUserVO *contactUserVO in _allDeviceContacts) {
			[_matchedUserIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSString *altID = (NSString *)obj;
//				NSLog(@"altID:[%@]=- cell.contactUserVO.mobileNumber:[%@]", altID, contactUserVO.mobileNumber);
				
				if ([contactUserVO.mobileNumber isEqualToString:altID]) {
//					NSLog(@"********DELETE*********\n%@", contactUserVO.fullName);
					[_omittedDeviceContacts addObject:contactUserVO];
					*stop = YES;//break;
				}
			}];
		}
	}
	
	[super _didFinishDataRefresh];
	
	[_recentClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONUserClubVO *vo = (HONUserClubVO *)obj;
		if ([[_submitParams objectForKey:@"club_id"] intValue] == vo.clubID) {
			if (![_selectedClubs containsObject:vo])
				[_selectedClubs addObject:vo];
			
			_replyClubViewCell.clubVO = vo;
			[_replyClubViewCell toggleImageLoading:YES];
			_replyClubViewCell.hidden = NO;
		}
	}];
}

- (NSDictionary *)_trackingProps {
	NSMutableArray *clubs = [NSMutableArray array];
	for (HONUserClubVO *vo in _selectedClubs)
		[clubs addObject:[[HONAnalyticsParams sharedInstance] propertyForUserClub:vo]];
	
	NSMutableArray *users = [NSMutableArray array];
	for (HONTrivialUserVO *vo in _selectedUsers)
		[users addObject:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:vo]];
	
	NSMutableArray *contacts = [NSMutableArray array];
	for (HONContactUserVO *vo in _selectedContacts)
		[contacts addObject:[[HONAnalyticsParams sharedInstance] propertyForContactUser:vo]];
	
	NSMutableDictionary *props = [NSMutableDictionary dictionary];
	[props setValue:clubs forKey:@"clubs"];
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
	_headerView.frame = CGRectOffset(_headerView.frame, 0.0, -10.0);
	[_headerView removeBackground];
	
	_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y - 10.0, _tableView.frame.size.width, _tableView.frame.size.height + 10);
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(4.0, 2.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(0.0, self.view.frame.size.height - 48.0, 320.0, 48.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButtonLargeEnabled_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButtonLargeEnabled_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
	
	[self _retrieveRecentClubs];
	
	if ([[_submitParams objectForKey:@"club_id"] intValue] != 0) {
		_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y + kOrthodoxTableCellHeight, _tableView.frame.size.width, _tableView.frame.size.height - kOrthodoxTableCellHeight);

		_replyClubViewCell = [[HONClubViewCell alloc] initAsCellType:HONClubViewCellTypeBlank];
		_replyClubViewCell.frame = CGRectMake(0.0, kNavHeaderHeight - 10.0, 320.0, kOrthodoxTableCellHeight);
		[_replyClubViewCell setSize:_replyClubViewCell.frame.size];
		[_replyClubViewCell hideTimeStat];
		[self.view addSubview:_replyClubViewCell];
	}
	
	//[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom + 48.0, _tableView.contentInset.right)];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
//	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
	
	NSLog(@"\n\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]");
	UIViewController *parentVC = (UIViewController *)[self.navigationController.viewControllers firstObject];
	UIViewController *currentVC = (UIViewController *)[self.navigationController.viewControllers lastObject];
	NSLog(@"\nself.navigationController.VCs:[%@]\nparentVC:[%@]\ncurrentVC:[%@]", self.navigationController.viewControllers, parentVC, currentVC);
	
//	UINavigationController *navigationController = (UINavigationController *)self.presentedViewController;
//	UIViewController *presentedVC = (UIViewController *)[navigationController.viewControllers lastObject];
//	NSLog(@"\nnavigationController.VCs:[%@]\npresentedVC:[%@]", navigationController.viewControllers, presentedVC);
	NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n");
	
	if ([currentVC isKindOfClass:self.class]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	}
}


#pragma mark - UI Presentation
- (void)_finishSubmit {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
	}];
}


#pragma mark - Navigation
- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Back"];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
	
	if ([gestureRecognizer velocityInView:self.view].x >= 2000) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Back SWIPE"];
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Submit SWIPE"];
		[self _goSubmit];
	}
}

- (void)_goSubmit {
	if ([_selectedClubs count] == 0 && [_selectedUsers count] == 0 && [_selectedContacts count] == 0) {
		[[[UIAlertView alloc] initWithTitle:@"You must select at least one friend to submit"
									message:@""
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	
	} else {
		if ([_selectedClubs count] > 0) {
			if ([_selectedUsers count] > 0 || [_selectedContacts count] > 0) {
				NSMutableArray *participants = [NSMutableArray array];
				
				for (HONTrivialUserVO *vo in _selectedUsers)
					[participants addObject:vo.username];
				
				for (HONContactUserVO *vo in _selectedContacts)
					[participants addObject:([HONTrivialUserVO userFromContactVO:vo]).username];
				
				NSString *names = @"";
				for (NSString *name in participants)
					names = [names stringByAppendingFormat:@"%@, ", name];
				names = ([names rangeOfString:@", "].location != NSNotFound) ? [names substringToIndex:[names length] - 2] : names;
				
				
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Invite Alert"
												 withProperties:[self _trackingProps]];
				
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add to club?"
																	message:[NSString stringWithFormat:@"Are you sure you want to add %@ to the club%@ you have selected?", names, ([_selectedClubs count] != 1) ? @"s" : @""]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
														  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
				[alertView setTag:10];
				[alertView show];
			
			} else {
				[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					HONUserClubVO *submitClubVO = (HONUserClubVO *)obj;
					
					[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
					NSLog(@"SUBMITTING:[%@]", _submitParams);
					
					[self _submitStatusUpdate:submitClubVO];
					[self _sendClubInvites:submitClubVO];
				}];
			}
		
		} else {
			if ([_selectedUsers count] == 0 && [_selectedContacts count] == 0) {
				HONUserClubVO *submitClubVO = [[HONClubAssistant sharedInstance] userSignupClub];
				NSLog(@"CLUB -=- (JOIN:userSignupClub) -=-");
				[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
				
				NSLog(@"SUBMITTING:[%@]", _submitParams);
				
				[self _submitStatusUpdate:submitClubVO];
				[self _sendClubInvites:submitClubVO];
			
			} else {
				NSMutableArray *participants = [NSMutableArray array];
				
				for (HONTrivialUserVO *vo in _selectedUsers)
					[participants addObject:vo];
				
				for (HONContactUserVO *vo in _selectedContacts)
					[participants addObject:[HONTrivialUserVO userFromContactVO:vo]];
				
				__block HONUserClubVO *submitClubVO = [[HONClubAssistant sharedInstance] clubWithParticipants:participants];
				if (submitClubVO != nil) {
					NSLog(@"CLUB -=- (JOIN) -=-");
					
					[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
					NSLog(@"SUBMITTING:[%@]", _submitParams);
					
					[_selectedUsers removeAllObjects];
					[_selectedContacts removeAllObjects];
					
					[self _submitStatusUpdate:submitClubVO];
					[self _sendClubInvites:submitClubVO];
					
				} else {
					NSLog(@"CLUB -=- (CREATE) -=-");
					
					NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
					[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], (int)[[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSince1970]] forKey:@"name"];
					submitClubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
					
					[[HONAPICaller sharedInstance] createClubWithTitle:submitClubVO.clubName withDescription:submitClubVO.blurb withImagePrefix:submitClubVO.coverImagePrefix completion:^(NSDictionary *result) {
						submitClubVO = [HONUserClubVO clubWithDictionary:result];
						[_submitParams setValue:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
						NSLog(@"SUBMITTING:[%@]", _submitParams);
						
						[self _submitStatusUpdate:submitClubVO];
						[self _sendClubInvites:submitClubVO];
					}];
				}
			}
		}
	}
}

//- (void)_goSelectToggle {
//	[_selectedRecipientViewCell invertSelected];
//	
//	if (_selectedRecipientViewCell.clubVO != nil) {
//		if ([_selectedClubs containsObject:_selectedRecipientViewCell.clubVO])
//			[_selectedClubs removeObject:_selectedRecipientViewCell.clubVO];
//		
//		else
//			[_selectedClubs addObject:_selectedRecipientViewCell.clubVO];
//	}
//	
//	if (_selectedRecipientViewCell.trivialUserVO != nil) {
//		if ([_selectedUsers containsObject:_selectedRecipientViewCell.trivialUserVO])
//			[_selectedUsers removeObject:_selectedRecipientViewCell.trivialUserVO];
//		
//		else
//			[_selectedUsers addObject:_selectedRecipientViewCell.trivialUserVO];
//	}
//	
//	if (_selectedRecipientViewCell.contactUserVO != nil) {
//		if ([_selectedContacts containsObject:_selectedRecipientViewCell.contactUserVO])
//			[_selectedContacts removeObject:_selectedRecipientViewCell.contactUserVO];
//		
//		else
//			[_selectedContacts addObject:_selectedRecipientViewCell.contactUserVO];
//	}
//}


#pragma mark - ClubViewCell Delegates
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectClub:(HONUserClubVO *)clubVO {
	NSLog(@"[*:*] clubViewCell:didSelectClub");
	
	NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
	[props setValue:[[HONAnalyticsParams sharedInstance] propertyForUserClub:clubVO] forKey:@"club"];
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Club"
									 withProperties:props];
	
	[super clubViewCell:viewCell didSelectClub:clubVO];
	if ([_selectedClubs containsObject:viewCell.clubVO])
		[_selectedClubs removeObject:viewCell.clubVO];
	
	else
		[_selectedClubs addObject:viewCell.clubVO];
}

- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[*:*] clubViewCell:didSelectContactUser");
	
	NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
	[props setValue:[[HONAnalyticsParams sharedInstance] propertyForContactUser:contactUserVO] forKey:@"contact"];
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Contact"
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
	[props setValue:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:trivialUserVO] forKey:@"member"];
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
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
	return ((section == 1) ? nil : [[HONTableHeaderView alloc] initWithTitle:(section == 2) ? @"Tap one or more" : (section == 3) ? ([_allDeviceContacts count] == 0) ? @"No results" : @"Contacts" : @""]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubViewCell *cell = (HONClubViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	[cell hideTimeStat];
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers) {
		if (indexPath.section == 1) {
//			[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//				HONUserClubVO *vo = (HONUserClubVO *)obj;
//				NSLog(@"CELL:[%d] -=- [%d]VO", cell.clubVO.clubID, vo.clubID);
//				[cell toggleSelected:(vo.clubID == cell.clubVO.clubID)];
//				*stop = cell.isSelected;
//			}];
//			
//			if ([[_submitParams objectForKey:@"club_id"] intValue] == cell.clubVO.clubID) {
//				if (![_selectedClubs containsObject:cell.clubVO]) {
//					[_selectedClubs addObject:cell.clubVO];
//					[cell toggleSelected:YES];
//				}
//			}
		
		} else if (indexPath.section == 2) {
			[_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
//				NSLog(@"CELL:[%d] -=- [%d]VO", cell.trivialUserVO.userID, vo.userID);
				[cell toggleSelected:(vo.userID == cell.trivialUserVO.userID)];
				*stop = cell.isSelected;
			}];
			
//			if ([[_submitParams objectForKey:@"recipients"] intValue] == cell.trivialUserVO.userID) {
//				if (![_selectedUsers containsObject:cell.trivialUserVO]) {
//					[_selectedUsers addObject:cell.trivialUserVO];
//					[cell toggleSelected:YES];
//				}
//			}
		}
		
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		if (indexPath.section == 1) {
//			[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//				HONUserClubVO *vo = (HONUserClubVO *)obj;
//				NSLog(@"CELL:[%d] -=- [%d]VO", cell.clubVO.clubID, vo.clubID);
//				[cell toggleSelected:(vo.clubID == cell.clubVO.clubID)];
//				*stop = cell.isSelected;
//			}];
//			
//			if ([[_submitParams objectForKey:@"club_id"] intValue] == cell.clubVO.clubID) {
//				if (![_selectedClubs containsObject:cell.clubVO]) {
//					[_selectedClubs addObject:cell.clubVO];
//					[cell toggleSelected:YES];
//				}
//			}
			
		} else if (indexPath.section == 2) {
			[_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
//				NSLog(@"CELL:[%d] -=- [%d]VO", cell.trivialUserVO.userID, vo.userID);
				[cell toggleSelected:(vo.userID == cell.trivialUserVO.userID)];
				*stop = cell.isSelected;
			}];
			
//			if ([[_submitParams objectForKey:@"recipients"] intValue] == cell.trivialUserVO.userID) {
//				if (![_selectedUsers containsObject:cell.trivialUserVO]) {
//					[_selectedUsers addObject:cell.trivialUserVO];
//					[cell toggleSelected:YES];
//				}
//			}
			
			[_matchedUserIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSString *altID = (NSString *)obj;
				if ([cell.trivialUserVO.altID isEqualToString:altID]) {
//					NSLog(@"********MERGE ATTEMPT*********\n");
					[_allDeviceContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
						HONContactUserVO *vo = (HONContactUserVO *)obj;
						
						if ([vo.mobileNumber isEqualToString:altID] && [cell.caption rangeOfString:vo.fullName].location == 0) {
							NSLog(@"********MERGE FOUND!!! [%d](%@)*********", cell.trivialUserVO.userID, vo.fullName);
							[cell addSubtitleCaption:[NSString stringWithFormat:@" is “%@”", vo.fullName]];
//							[cell appendTitleCaption:[NSString stringWithFormat:@" - %@", vo.fullName]];
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
//
//			if ([[_submitParams objectForKey:@"recipients"] isEqualToString:(cell.contactUserVO.isSMSAvailable) ? cell.contactUserVO.mobileNumber : cell.contactUserVO.email]) {
//				if (![_selectedContacts containsObject:cell.contactUserVO]) {
//					[_selectedContacts addObject:cell.contactUserVO];
//					[cell toggleSelected:YES];
//				}
//			}
			
//			[_matchedUserIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//				NSString *altID = (NSString *)obj;
//				NSLog(@"altID:[%@]=- cell.contactUserVO.mobileNumber:[%@]", altID, cell.contactUserVO.mobileNumber);
//				if ([cell.contactUserVO.mobileNumber isEqualToString:altID]) {
//					NSLog(@"********DELETE*********\n%@", cell.contactUserVO.fullName);
//					cell.contentView.alpha = 0.875;
//					cell.backgroundView = nil;
//					cell.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugOrangeColor];
////					[self _removeMatchedContactCell:cell];
//					*stop = YES;
//				}
//			}];
		}
	}
	
	return (cell);
}

- (void)_removeMatchedContactCell:(HONClubViewCell *)viewCell {
	
	__block int ind = -1;
	[_allDeviceContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONContactUserVO *vo = (HONContactUserVO *)obj;
		if ([vo.mobileNumber isEqualToString:viewCell.contactUserVO.mobileNumber]) {
			ind = idx;
			*stop = YES;
		}
	}];
	
	if (ind >= 0) {
		[_allDeviceContacts removeObjectAtIndex:ind];
		
		[_tableView beginUpdates];
		[_tableView deleteRowsAtIndexPaths:@[[_tableView indexPathForCell:viewCell]] withRowAnimation:UITableViewRowAnimationAutomatic];
		[_tableView endUpdates];
	}
}

#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((section == 2) ? kOrthodoxTableHeaderHeight : 0.0f);
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
			[[HONAnalyticsParams sharedInstance] trackEvent:[@"Camera Step - Access Contacts " stringByAppendingString:(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"(UNDETERMINED)" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"(AUTHORIZED)" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"(DENIED)" : @"(OTHER)"]];
			
		} else if (indexPath.section == 1) {
			NSLog(@"RECENT CLUB:[%@]", cell.clubVO.clubName);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsParams sharedInstance] propertyForUserClub:cell.clubVO] forKey:@"club"];
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Club"
											 withProperties:props];
			
			[cell invertSelected];
			if ([_selectedClubs containsObject:cell.clubVO])
				[_selectedClubs removeObject:cell.clubVO];
			
			else
				[_selectedClubs addObject:cell.clubVO];
			
		} else if (indexPath.section == 2) {
			NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:cell.trivialUserVO] forKey:@"member"];
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
											withProperties:props];
			[cell invertSelected];
			if ([_selectedUsers containsObject:cell.trivialUserVO])
				[_selectedUsers removeObject:cell.trivialUserVO];
			
			else
				[_selectedUsers addObject:cell.trivialUserVO];
		}
		
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		if (indexPath.section == 0) {
			[[HONAnalyticsParams sharedInstance] trackEvent:[@"Camera Step - Access Contacts " stringByAppendingString:(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"(UNDETERMINED)" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"(AUTHORIZED)" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"(DENIED)" : @"(OTHER)"]];
			
		} else if (indexPath.section == 1) {
			NSLog(@"RECENT CLUB:[%@]", cell.clubVO.clubName);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsParams sharedInstance] propertyForUserClub:cell.clubVO] forKey:@"club"];
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Club"
											 withProperties:props];
			
			[cell invertSelected];
			if ([_selectedClubs containsObject:cell.clubVO])
				[_selectedClubs removeObject:cell.clubVO];
			
			else
				[_selectedClubs addObject:cell.clubVO];
			
		} else if (indexPath.section == 2) {
			NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:cell.trivialUserVO] forKey:@"member"];
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
											 withProperties:props];
			
			[cell invertSelected];
			if ([_selectedUsers containsObject:cell.trivialUserVO])
				[_selectedUsers removeObject:cell.trivialUserVO];
			
			else
				[_selectedUsers addObject:cell.trivialUserVO];
			
		} else if (indexPath.section == 3) {
			NSLog(@"DEVICE CONTACT:[%@]", cell.contactUserVO.fullName);
			
			NSMutableDictionary *props = [[self _trackingProps] mutableCopy];
			[props setValue:[[HONAnalyticsParams sharedInstance] propertyForContactUser:cell.contactUserVO] forKey:@"contact"];
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
											 withProperties:props];
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Contact"
											withContactUser:cell.contactUserVO];
			[cell invertSelected];
			if ([_selectedContacts containsObject:cell.contactUserVO])
				[_selectedContacts removeObject:cell.contactUserVO];
			
			else
				[_selectedContacts addObject:cell.contactUserVO];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 10) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Camera Step - Invite Alert %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
										 withProperties:[self _trackingProps]];
		
		if (buttonIndex == 1) {
			[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONUserClubVO *submitClubVO = (HONUserClubVO *)obj;
				
				[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
				NSLog(@"SUBMITTING:[%@]", _submitParams);
				
				[self _submitStatusUpdate:submitClubVO];
				[self _sendClubInvites:submitClubVO];
			}];
		}
	}
}

@end
