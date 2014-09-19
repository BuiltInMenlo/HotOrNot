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
//@property (nonatomic, strong) HONClubViewCell *selectedRecipientViewCell;
@end

@implementation HONStatusUpdateSubmitViewController


- (id)initWithSubmitParameters:(NSDictionary *)submitParams {
	if ((self = [super init])) {
		_submitParams = [submitParams mutableCopy];
	}
	
	return (self);
}



#pragma mark - Data Calls
- (void)_submitStatusUpdate {
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
		}
	}];
}

- (void)_sendClubInvites:(HONUserClubVO *)clubVO {
	if ([_selectedUsers count] == 0 && [_selectedContacts count] == 0) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
		}];
	}
	
	if ([_selectedUsers count] > 0 && [_selectedContacts count] > 0) {
		[[HONAPICaller sharedInstance] inviteInAppUsers:_selectedUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID inviteNonAppContacts:_selectedContacts completion:^(NSDictionary *result) {
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
			}];
		}];
	
	} else {
		if ([_selectedUsers count] > 0) {
			[[HONAPICaller sharedInstance] inviteInAppUsers:_selectedUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
				}];
			}];
		}
		
		if ([_selectedContacts count] > 0) {
			[[HONAPICaller sharedInstance] inviteNonAppUsers:_selectedContacts toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
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
	[super _didFinishDataRefresh];
	
//	[_recentClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONUserClubVO *vo = (HONUserClubVO *)obj;
//		if ([[_submitParams objectForKey:@"club_id"] intValue] == vo.clubID) {
//			if (![_selectedClubs containsObject:vo])
//				[_selectedClubs addObject:vo];
//			
//			_selectedRecipientViewCell.clubVO = vo;
//			[_selectedRecipientViewCell toggleImageLoading:YES];
//			_selectedRecipientViewCell.hidden = NO;
//		}
//	}];
//	
//	[_inAppUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
//		if ([[_submitParams objectForKey:@"recipients"] intValue] == vo.userID) {
//			if (![_selectedUsers containsObject:vo])
//				[_selectedUsers addObject:vo];
//			
//			_selectedRecipientViewCell.trivialUserVO = vo;
//			[_selectedRecipientViewCell toggleImageLoading:YES];
//			_selectedRecipientViewCell.hidden = NO;
//		}
//	}];
//	
//	[_deviceContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONContactUserVO *vo = (HONContactUserVO *)obj;
//		if ([[_submitParams objectForKey:@"recipients"] isEqualToString:(vo.isSMSAvailable) ? vo.mobileNumber : vo.email]) {
//			if (![_selectedContacts containsObject:vo])
//				[_selectedContacts addObject:vo];
//			
//			_selectedRecipientViewCell.contactUserVO = vo;
//			[_selectedRecipientViewCell toggleImageLoading:YES];
//			_selectedRecipientViewCell.hidden = NO;
//		}
//	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_selectedClubs = [NSMutableArray array];
	_selectedContacts = [NSMutableArray array];
	_selectedUsers = [NSMutableArray array];
	
	//[_headerView setTitle:NSLocalizedString(@"select_club", @"Select Club")];
	[_headerView addTitleImage:[UIImage imageNamed:@"selectFriendsTitle"]];
	_headerView.frame = CGRectOffset(_headerView.frame, 0.0, -10.0);
	[_headerView removeBackground];
	
	_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y - 10.0, _tableView.frame.size.width, _tableView.frame.size.height + 10);
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(6.0, 1.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"StatusBackButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"StatusBackButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(0.0, self.view.frame.size.height - 48.0, 320.0, 48.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButtonLargeActive_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButtonLargeActive_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
	
	[self _retrieveRecentClubs];
	
//	if ([[_submitParams objectForKey:@"club_id"] intValue] != 0 || [[_submitParams objectForKey:@"recipients"] length] > 0) {
//		_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y + kOrthodoxTableCellHeight, _tableView.frame.size.width, _tableView.frame.size.height - kOrthodoxTableCellHeight);
//		
//		_selectedRecipientViewCell = [[HONClubViewCell alloc] initAsCellType:HONClubViewCellTypeBlank];
//		_selectedRecipientViewCell.frame = CGRectMake(0.0, kNavHeaderHeight - 10.0, 320.0, kOrthodoxTableCellHeight);
//		[_selectedRecipientViewCell setSize:_selectedRecipientViewCell.frame.size];
//		[_selectedRecipientViewCell toggleSelected:YES];
//		[_selectedRecipientViewCell hideTimeStat];
//		_selectedRecipientViewCell.hidden = YES;
//		[self.view addSubview:_selectedRecipientViewCell];
//		
//		UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		selectedButton.frame = CGRectMake(0.0, 0.0, 320.0, kOrthodoxTableCellHeight);
//		[selectedButton addTarget:self action:@selector(_goSelectToggle) forControlEvents:UIControlEventTouchUpInside];
//		[_selectedRecipientViewCell.contentView addSubview:selectedButton];
//	}
	
	
	//[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom + 48.0, _tableView.contentInset.right)];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
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

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Submit"];
	if ([_selectedClubs count] == 0 && [_selectedUsers count] == 0 && [_selectedContacts count] == 0) {
		[[[UIAlertView alloc] initWithTitle:@"No one selected!"
									message:@"You need to select a club or friend."
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
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add to club?"
																	message:[NSString stringWithFormat:@"Are you sure you want to add %@ to the club%@ you have selected?", names, ([_selectedClubs count] != 1) ? @"s" : @""]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
														  otherButtonTitles:@"Yes", nil];
				[alertView setTag:10];
				[alertView show];
			
			} else {
				[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					HONUserClubVO *submitClubVO = (HONUserClubVO *)obj;
					
					[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
					NSLog(@"SUBMITTING:[%@]", _submitParams);
					
					[self _submitStatusUpdate];
					[self _sendClubInvites:submitClubVO];
				}];
			}
		
		} else {
			if ([_selectedUsers count] == 0 && [_selectedContacts count] == 0) {
				HONUserClubVO *submitClubVO = [[HONClubAssistant sharedInstance] userSignupClub];
				[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
				NSLog(@"SUBMITTING:[%@]", _submitParams);
				
				[self _submitStatusUpdate];
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
					
					[self _submitStatusUpdate];
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
						
						[self _submitStatusUpdate];
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
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Club"
									withUserClub:clubVO];
	
	[super clubViewCell:viewCell didSelectClub:clubVO];
	if ([_selectedClubs containsObject:viewCell.clubVO])
		[_selectedClubs removeObject:viewCell.clubVO];
	
	else
		[_selectedClubs addObject:viewCell.clubVO];
}

- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[*:*] clubViewCell:didSelectContactUser");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Contact"
									withContactUser:contactUserVO];
	
	[super clubViewCell:viewCell didSelectContactUser:contactUserVO];
	if ([_selectedContacts containsObject:viewCell.trivialUserVO])
		[_selectedContacts removeObject:viewCell.trivialUserVO];
	
	else
		[_selectedContacts addObject:viewCell.trivialUserVO];
}

- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[*:*] clubViewCell:didSelectTrivialUser");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
									withTrivialUser:trivialUserVO];
	
	[super clubViewCell:viewCell didSelectTrivialUser:trivialUserVO];
	if ([_selectedUsers containsObject:viewCell.trivialUserVO])
		[_selectedUsers removeObject:viewCell.trivialUserVO];
	
	else
		[_selectedUsers addObject:viewCell.trivialUserVO];
}


#pragma mark - TableView DataSource Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubViewCell *cell = (HONClubViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	[cell hideTimeStat];
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceSearchResults) {
		
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers) {
		if (indexPath.section == 1) {
			[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONUserClubVO *vo = (HONUserClubVO *)obj;
				NSLog(@"CELL:[%d] -=- [%d]VO", cell.clubVO.clubID, vo.clubID);
				[cell toggleSelected:(vo.clubID == cell.clubVO.clubID)];
				*stop = cell.isSelected;
			}];
			
			if ([[_submitParams objectForKey:@"club_id"] intValue] == cell.clubVO.clubID) {
				if (![_selectedClubs containsObject:cell.clubVO]) {
					[_selectedClubs addObject:cell.clubVO];
					[cell toggleSelected:YES];
				}
			}
		
		} else if (indexPath.section == 2) {
			[_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
				NSLog(@"CELL:[%d] -=- [%d]VO", cell.trivialUserVO.userID, vo.userID);
				[cell toggleSelected:(vo.userID == cell.trivialUserVO.userID)];
				*stop = cell.isSelected;
			}];
			
			if ([[_submitParams objectForKey:@"recipients"] intValue] == cell.trivialUserVO.userID) {
				if (![_selectedUsers containsObject:cell.trivialUserVO]) {
					[_selectedUsers addObject:cell.trivialUserVO];
					[cell toggleSelected:YES];
				}
			}
		}
		
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		if (indexPath.section == 1) {
			[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONUserClubVO *vo = (HONUserClubVO *)obj;
				NSLog(@"CELL:[%d] -=- [%d]VO", cell.clubVO.clubID, vo.clubID);
				[cell toggleSelected:(vo.clubID == cell.clubVO.clubID)];
				*stop = cell.isSelected;
			}];
			
			if ([[_submitParams objectForKey:@"club_id"] intValue] == cell.clubVO.clubID) {
				if (![_selectedClubs containsObject:cell.clubVO]) {
					[_selectedClubs addObject:cell.clubVO];
					[cell toggleSelected:YES];
				}
			}
			
		} else if (indexPath.section == 2) {
			[_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONTrivialUserVO *vo = (HONTrivialUserVO *)obj;
				NSLog(@"CELL:[%d] -=- [%d]VO", cell.trivialUserVO.userID, vo.userID);
				[cell toggleSelected:(vo.userID == cell.trivialUserVO.userID)];
				*stop = cell.isSelected;
			}];
			
			if ([[_submitParams objectForKey:@"recipients"] intValue] == cell.trivialUserVO.userID) {
				if (![_selectedUsers containsObject:cell.trivialUserVO]) {
					[_selectedUsers addObject:cell.trivialUserVO];
					[cell toggleSelected:YES];
				}
			}
		
		} else if (indexPath.section == 3) {
			[_selectedContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONContactUserVO *vo = (HONContactUserVO *)obj;
				NSLog(@"CELL:[%@] -=- [%@]VO", cell.contactUserVO.mobileNumber, vo.mobileNumber);
				[cell toggleSelected:([vo.mobileNumber isEqualToString:cell.contactUserVO.mobileNumber])];
				*stop = cell.isSelected;
			}];
			
			if ([[_submitParams objectForKey:@"recipients"] isEqualToString:(cell.contactUserVO.isSMSAvailable) ? cell.contactUserVO.mobileNumber : cell.contactUserVO.email]) {
				if (![_selectedContacts containsObject:cell.contactUserVO]) {
					[_selectedContacts addObject:cell.contactUserVO];
					[cell toggleSelected:YES];
				}
			}
		}
	}
	
	return (cell);
}


#pragma mark - TableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	HONClubViewCell *cell = (HONClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"[[- cell.contactUserVO.userID:[%d]", cell.contactUserVO.userID);
	NSLog(@"[[- cell.trivialUserVO.userID:[%d]", cell.trivialUserVO.userID);
	
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceSearchResults) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Search Result"];
				
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers) {
		if (indexPath.section == 0) {
			[[HONAnalyticsParams sharedInstance] trackEvent:[@"Camera Step - Access Contacts " stringByAppendingString:(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"(UNDETERMINED)" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"(AUTHORIZED)" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"(DENIED)" : @"(OTHER)"]];
			
		} else if (indexPath.section == 1) {
			NSLog(@"RECENT CLUB:[%@]", cell.clubVO.clubName);
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Club"
											   withUserClub:cell.clubVO];
			
			[cell invertSelected];
			if ([_selectedClubs containsObject:cell.clubVO])
				[_selectedClubs removeObject:cell.clubVO];
			
			else
				[_selectedClubs addObject:cell.clubVO];
			
		} else if (indexPath.section == 2) {
			NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Contact"
											withTrivialUser:cell.trivialUserVO];
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
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Club"
											   withUserClub:cell.clubVO];
			
			[cell invertSelected];
			if ([_selectedClubs containsObject:cell.clubVO])
				[_selectedClubs removeObject:cell.clubVO];
			
			else
				[_selectedClubs addObject:cell.clubVO];
			
		} else if (indexPath.section == 2) {
			NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected In-App User"
											withTrivialUser:cell.trivialUserVO];
			[cell invertSelected];
			if ([_selectedUsers containsObject:cell.trivialUserVO])
				[_selectedUsers removeObject:cell.trivialUserVO];
			
			else
				[_selectedUsers addObject:cell.trivialUserVO];
			
		} else if (indexPath.section == 3) {
			NSLog(@"DEVICE CONTACT:[%@]", cell.contactUserVO.fullName);
			
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
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Camera Step - Invite Alert %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		if (buttonIndex == 1) {
			[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONUserClubVO *submitClubVO = (HONUserClubVO *)obj;
				
				[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
				NSLog(@"SUBMITTING:[%@]", _submitParams);
				
				[self _submitStatusUpdate];
				[self _sendClubInvites:submitClubVO];
			}];
		}
	}
}

@end
