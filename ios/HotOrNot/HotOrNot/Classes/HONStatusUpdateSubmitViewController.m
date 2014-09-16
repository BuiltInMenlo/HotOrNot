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
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
		}];
	}
	
	if ([_selectedUsers count] > 0 && [_selectedContacts count] > 0) {
		[[HONAPICaller sharedInstance] inviteInAppUsers:_selectedUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID inviteNonAppContacts:_selectedContacts completion:^(NSDictionary *result) {
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
			}];
		}];
	
	} else {
		if ([_selectedUsers count] > 0) {
			[[HONAPICaller sharedInstance] inviteInAppUsers:_selectedUsers toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
				}];
			}];
		}
		
		if ([_selectedContacts count] > 0) {
			[[HONAPICaller sharedInstance] inviteNonAppUsers:_selectedContacts toClubWithID:clubVO.clubID withClubOwnerID:clubVO.ownerID completion:^(NSDictionary *result) {
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
	
	//[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom + 48.0, _tableView.contentInset.right)];
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
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Back"];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Submit"];
	
	if ([_selectedClubs count] > 0) {
		[_selectedClubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			HONUserClubVO *submitClubVO = (HONUserClubVO *)obj;
			
			[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
			NSLog(@"SUBMITTING:[%@]", _submitParams);
			
			[self _submitStatusUpdate];
			[self _sendClubInvites:submitClubVO];
		}];
	
	} else {
		NSLog(@"CLUB -=- (%@)", ([[HONClubAssistant sharedInstance] clubWithParticipants:_selectedUsers]) ? @"JOIN" : @"CREATE");
		
		__block HONUserClubVO *submitClubVO = [[HONClubAssistant sharedInstance] clubWithParticipants:_selectedUsers];
		if (submitClubVO != nil) {
			[_submitParams setObject:[@"" stringFromInt:submitClubVO.clubID] forKey:@"club_id"];
			NSLog(@"SUBMITTING:[%@]", _submitParams);
			
			[self _submitStatusUpdate];
			[self _sendClubInvites:submitClubVO];
			
		} else {
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

#pragma mark - ClubViewCell Delegates
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectClub:(HONUserClubVO *)clubVO {
	NSLog(@"[*:*] clubViewCell:didSelectClub");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Select Club"
									withUserClub:clubVO];
	
	[super clubViewCell:viewCell didSelectClub:clubVO];
	if ([_selectedClubs containsObject:viewCell.clubVO])
		[_selectedClubs removeObject:viewCell.clubVO];
	
	else
		[_selectedClubs addObject:viewCell.clubVO];
}

- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[*:*] clubViewCell:didSelectContactUser");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Select Contact"
									withContactUser:contactUserVO];
	
	[super clubViewCell:viewCell didSelectContactUser:contactUserVO];
	if ([_selectedContacts containsObject:viewCell.trivialUserVO])
		[_selectedContacts removeObject:viewCell.trivialUserVO];
	
	else
		[_selectedContacts addObject:viewCell.trivialUserVO];
}

- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[*:*] clubViewCell:didSelectTrivialUser");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Select Contact"
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
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONClubViewCell *cell = (HONClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"[[- cell.contactUserVO.userID:[%d]", cell.contactUserVO.userID);
	NSLog(@"[[- cell.trivialUserVO.userID:[%d]", cell.trivialUserVO.userID);
	
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceSearchResults) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Search Result"];
				
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers) {
		if (indexPath.section == 0) {
			[[HONAnalyticsParams sharedInstance] trackEvent:[[NSString stringWithFormat:@"Camera Step - %@ ", (indexPath.row == 0) ? @"Create Club" : @"Access Contacts"] stringByAppendingString:(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"(UNDETERMINED)" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"(AUTHORIZED)" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"(DENIED)" : @"(OTHER)"]];
			
		} else if (indexPath.section == 1) {
			NSLog(@"RECENT CLUB:[%@]", cell.clubVO.clubName);
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Select Club"
											   withUserClub:cell.clubVO];
			
			if ([_selectedClubs containsObject:cell.clubVO])
				[_selectedClubs removeObject:cell.clubVO];
			
			else
				[_selectedClubs addObject:cell.clubVO];
			
		} else if (indexPath.section == 2) {
			NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Select Contact"
											withTrivialUser:cell.trivialUserVO];
			[cell invertSelected];
			if ([_selectedUsers containsObject:cell.trivialUserVO])
				[_selectedUsers removeObject:cell.trivialUserVO];
			
			else
				[_selectedUsers addObject:cell.trivialUserVO];
		}
		
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		if (indexPath.section == 1) {
			NSLog(@"RECENT CLUB:[%@]", cell.clubVO.clubName);
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Select Club"
											   withUserClub:cell.clubVO];
			
			if ([_selectedClubs containsObject:cell.clubVO])
				[_selectedClubs removeObject:cell.clubVO];
			
			else
				[_selectedClubs addObject:cell.clubVO];
			
		} else if (indexPath.section == 2) {
			NSLog(@"IN-APP USER:[%@]", cell.trivialUserVO.username);
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Invite Contact"
											withTrivialUser:cell.trivialUserVO];
			[cell invertSelected];
			if ([_selectedUsers containsObject:cell.trivialUserVO])
				[_selectedUsers removeObject:cell.trivialUserVO];
			
			else
				[_selectedUsers addObject:cell.trivialUserVO];
			
		} else if (indexPath.section == 3) {
			NSLog(@"DEVICE CONTACT:[%@]", cell.contactUserVO.fullName);
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step Tab - Select Contact"
											withContactUser:cell.contactUserVO];
			[cell invertSelected];
			if ([_selectedContacts containsObject:cell.contactUserVO])
				[_selectedContacts removeObject:cell.contactUserVO];
			
			else
				[_selectedContacts addObject:cell.contactUserVO];
		}
	}
}
@end
