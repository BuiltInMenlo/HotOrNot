//
//  HONContactsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 05/01/2014 @ 19:07 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "CKRefreshControl.h"

#import "HONViewController.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONUserToggleViewCell.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"
#import "HONSearchBarView.h"

typedef NS_OPTIONS(NSInteger, HONContactsTableViewDataSource) {
	HONContactsTableViewDataSourceEmpty			= 0 << 0,
	HONContactsTableViewDataSourceMatchedUsers	= 1 << 0,
	HONContactsTableViewDataSourceAddressBook	= 1 << 1,
	HONContactsTableViewDataSourceSearchResults	= 1 << 2,
};


@interface HONContactsViewController : HONViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	HONContactsTableViewDataSource _tableViewDataSource;
	
	NSMutableArray *_cells;
	NSMutableArray *_deviceContacts;
	NSMutableArray *_inAppContacts;
	NSMutableArray *_inAppUsers;
	NSMutableArray *_searchUsers;
	NSDictionary *_segmentedContacts;
	NSMutableArray *_segmentedKeys;
	HONUserClubVO *_userClubVO;
	
	HONTableView *_tableView;
	UIRefreshControl *_refreshControl;
	HONHeaderView *_headerView;
	HONSearchBarView *_searchBarView;
}

- (void)_promptForAddressBookAccess;

- (void)_retreiveUserClubs;
- (void)_sendEmailContacts;
- (void)_sendPhoneContacts;
- (void)_searchUsersWithUsername:(NSString *)username;
- (void)_retrieveDeviceContacts;
- (void)_submitPhoneNumberForMatching;

- (void)_updateDeviceContactsWithMatchedUsers;
-(NSDictionary *)_populateSegmentedDictionary;

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectContactUser:(HONContactUserVO *)contactUserVO;
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectTrivialUser:(HONTrivialUserVO *)trivialUserVO;
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO;
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO;
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell showProfileForTrivialUser:(HONTrivialUserVO *)trivialUserVO;

@end
