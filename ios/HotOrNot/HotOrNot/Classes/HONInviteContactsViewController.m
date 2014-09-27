//
//  HONInviteContactsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:05 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AddressBook/AddressBook.h>

#import "NSString+DataTypes.h"

#import "MBProgressHUD.h"

#import "HONInviteContactsViewController.h"
#import "HONUserProfileViewController.h"
#import "HONUserToggleViewCell.h"

@interface HONInviteContactsViewController ()
@property (nonatomic, strong) NSMutableArray *selectedNonAppContacts;
@property (nonatomic, strong) NSMutableArray *selectedInAppContacts;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic) BOOL isPushed;
@end


@implementation HONInviteContactsViewController

- (id)initAsViewControllerPushed:(BOOL)isPushed {
	NSLog(@"%@ - initAsViewControllerPushed:[%@]", [self description], [@"" stringFromBOOL:isPushed]);
	if ((self = [super init])) {
		
		_isPushed = isPushed;
		
		NSDictionary *preClub = [[HONClubAssistant sharedInstance] fetchPreClub];
		if (preClub != nil) {
			NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
			[dict setValue:[preClub objectForKey:@"name"] forKey:@"name"];
			[dict setValue:[preClub objectForKey:@"description"] forKey:@"description"];
			[dict setValue:[preClub objectForKey:@"img"] forKey:@"img"];
			_userClubVO = nil;
			_clubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
		
		} else {
			_userClubVO = nil;
			_clubVO = nil;
		}
		
		NSLog(@"INVITECLUB - _userClubVO:[%@]", _userClubVO.dictionary);
		NSLog(@"INVITECLUB - _clubVO:[%@]", _clubVO.dictionary);
	}
	
	return (self);
}

- (id)initWithClub:(HONUserClubVO *)userClub viewControllerPushed:(BOOL)isPushed {
	NSLog(@"%@ - initWithClub:[%d] viewControllerPushed:[%@]", [self description], userClub.clubID, [@"" stringFromBOOL:isPushed]);
	if ((self = [super init])) {
		_userClubVO = userClub;
		_clubVO = userClub;
		_isPushed = isPushed;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_sendClubInvites {
	NSLog(@"_sendClubInvites:[%d - %@] -=- (%d)=-=(%d)", _clubVO.clubID, _clubVO.clubName, [_selectedInAppContacts count], [_selectedNonAppContacts count]);
	
	if ([_selectedInAppContacts count] > 0)
		[self _sendInAppUserInvites];
	
	if ([_selectedNonAppContacts count] > 0)
		[self _sendNonAppUserInvites];
}

- (void)_sendInAppUserInvites {
	[[HONAPICaller sharedInstance] inviteInAppUsers:[_selectedInAppContacts copy] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
		for (HONTrivialUserVO *vo in _selectedInAppContacts)
			[[HONContactsAssistant sharedInstance] writeTrivialUser:vo toInvitedClub:_clubVO];
		
		[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_TOTAL_UPDATED" object:nil];
		}];
	}];
}

- (void)_sendNonAppUserInvites {
	[[HONAPICaller sharedInstance] inviteNonAppUsers:[_selectedNonAppContacts copy] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
		for (HONContactUserVO *vo in _selectedNonAppContacts)
			[[HONContactsAssistant sharedInstance] writeContactUser:vo toInvitedClub:_clubVO];
		
		[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_TOTAL_UPDATED" object:nil];
		}];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_selectedInAppContacts = [NSMutableArray array];
	_selectedNonAppContacts = [NSMutableArray array];
	
	[_tableView setContentInset:UIEdgeInsetsZero];
	[_headerView setTitle:NSLocalizedString(@"invite_club", @"Invite to Club")];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(6.0, 1.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"StatusBackButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"StatusBackButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	backButton.hidden = !isPushed;
	[_headerView addButton:backButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:doneButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goClose {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goDone {
	NSLog(@"******* DISMISSING ******");
	
	if (_isPushed) {
		NSLog(@"******* FROM CREATE CLUB ******");
		if ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:_clubVO.clubName]) {
			NSLog(@"******* EXISTING (%d, %d) ******", [_selectedInAppContacts count], [_selectedNonAppContacts count]);
			
		} else {
			NSLog(@"******* CREATE ******");
			[[HONAPICaller sharedInstance] createClubWithTitle:_clubVO.clubName withDescription:_clubVO.blurb withImagePrefix:_clubVO.coverImagePrefix completion:^(NSDictionary *result) {
				_clubVO = [HONUserClubVO clubWithDictionary:result];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CREATED_NEW_CLUB" object:_clubVO];
				
				if (([_selectedInAppContacts count] > 0 || [_selectedNonAppContacts count] > 0))
					[self _sendClubInvites];
				
				[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
				}];
			}];
		}
	
	} else {
		if (_userClubVO == nil || _clubVO == nil) {
			NSLog(@"******* NO CLUB ******");
			[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {}];
		
		} else {
			NSLog(@"******* HAS CLUB ******");
			if ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:_clubVO.clubName]) {
				NSLog(@"******* EXISTING (%d, %d) ******", [_selectedInAppContacts count], [_selectedNonAppContacts count]);
				if (([_selectedInAppContacts count] == 0 && [_selectedNonAppContacts count] == 0)) {
					NSLog(@"******* NON SELECTED ******");
					[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {}];
//					[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noclubs_t", nil)
//												message:[NSString stringWithFormat:NSLocalizedString(@"alert_noclubs_m", nil), _clubVO.clubName]
//											   delegate:nil
//									  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//									  otherButtonTitles:nil] show];
				} else {
					NSLog(@"******* SEND INVITES ******");
					[self _sendClubInvites];
					[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {}];
				}
			
			} else {
				NSLog(@"******* CREATE ******");
				[[HONAPICaller sharedInstance] createClubWithTitle:_clubVO.clubName withDescription:_clubVO.blurb withImagePrefix:_clubVO.coverImagePrefix completion:^(NSDictionary *result) {
					_clubVO = [HONUserClubVO clubWithDictionary:result];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"CREATED_NEW_CLUB" object:_clubVO];
					
					if (([_selectedInAppContacts count] > 0 || [_selectedNonAppContacts count] > 0))
						[self _sendClubInvites];
					
					[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary * result) {
						[[HONClubAssistant sharedInstance] writeUserClubs:result];	
						[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {}];
					}];
				}];
			}
		}
	}
}


#pragma mark - UserToggleViewCell Delegates
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[[*:*]] userToggleViewCell:didSelectContactUser");
	[super clubViewCell:viewCell didSelectContactUser:contactUserVO];
	
	if (![_selectedNonAppContacts containsObject:contactUserVO])
		[_selectedNonAppContacts addObject:contactUserVO];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[[*:*]] userToggleViewCell:didSelectTrivialUser");
	
	[super clubViewCell:viewCell didSelectTrivialUser:trivialUserVO];
	
	if (![_selectedInAppContacts containsObject:trivialUserVO])
		[_selectedInAppContacts addObject:trivialUserVO];
}


#pragma mark - TableView DataSources


#pragma mark - TableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"CELL.ISSELECTED:[%d]", cell.isSelected);
	NSLog(@"CELL.CONTACT:[%@]", cell.contactUserVO.dictionary);
	NSLog(@"CELL.TRIVIAL:[%@]", cell.trivialUserVO.dictionary);
	
	NSLog(@"::PRE:: IN-APP:[%@]", _selectedInAppContacts);
	NSLog(@"::PRE:: NON-APP:[%@]", _selectedNonAppContacts);
	
	if (cell.trivialUserVO == nil) {
		if (cell.isSelected) {
			if (![_selectedNonAppContacts containsObject:cell.contactUserVO])
				[_selectedNonAppContacts addObject:cell.contactUserVO];
		
		} else {
			if ([_selectedNonAppContacts containsObject:cell.contactUserVO])
				[_selectedNonAppContacts removeObject:cell.contactUserVO];
		}
	
	} else {
		if (cell.isSelected) {
			if (![_selectedInAppContacts containsObject:cell.trivialUserVO])
				[_selectedInAppContacts addObject:cell.trivialUserVO];
			
		} else {
			if ([_selectedInAppContacts containsObject:cell.trivialUserVO])
				[_selectedInAppContacts removeObject:cell.trivialUserVO];
		}
	}
		
	NSLog(@"::POST:: IN-APP:[%@]", _selectedInAppContacts);
	NSLog(@"::POST:: NON-APP:[%@]", _selectedNonAppContacts);
}

@end
