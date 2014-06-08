//
//  HONContactsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 05/01/2014 @ 19:07 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "EGORefreshTableHeaderView.h"

#import "HONHeaderView.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"

typedef NS_ENUM(NSInteger, HONContactsTableViewDataSource) {
	HONContactsTableViewDataSourceMatchedUsers = 0,
	HONContactsTableViewDataSourceAddressBook,
	HONContactsTableViewDataSourceSearchResults
};

@interface HONContactsViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	HONContactsTableViewDataSource _tableViewDataSource;
	
	NSMutableArray *_deviceContacts;
	NSMutableArray *_inAppContacts;
	NSMutableArray *_inAppUsers;
	NSDictionary *_segmentedContacts;
	NSMutableArray *_segmentedKeys;
	NSMutableArray *_searchUsers;
	HONUserClubVO *_userClubVO;
	
	EGORefreshTableHeaderView *_refreshTableHeaderView;
	UITableView *_tableView;
	HONHeaderView *_headerView;
}

- (void)_promptForAddressBookAccess;

- (void)_retreiveUserClubs;
- (void)_sendEmailContacts;
- (void)_sendPhoneContacts;
- (void)_inviteInAppContact:(HONTrivialUserVO *)trivialUserVO toClub:(HONUserClubVO *)userClubVO;
- (void)_inviteNonAppContact:(HONContactUserVO *)contactUserVO toClub:(HONUserClubVO *)userClubVO;
- (void)_searchUsersWithUsername:(NSString *)username;
- (void)_retrieveDeviceContacts;

- (void)_updateDeviceContactsWithMatchedUsers;
-(NSDictionary *)_populateSegmentedDictionary;
@end
