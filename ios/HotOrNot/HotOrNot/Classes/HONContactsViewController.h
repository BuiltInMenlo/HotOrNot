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
	HONContactsTableViewDataSourceAddressBook,
	HONContactsTableViewDataSourceSearchResults
};

@interface HONContactsViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	HONContactsTableViewDataSource _tableViewDataSource;
	
	NSMutableArray *_allContacts;
	NSMutableArray *_inAppContacts;
	NSDictionary *_segmentedContacts;
	NSMutableArray *_segmentedKeys;
	NSMutableArray *_searchUsers;
	HONUserClubVO *_userClubVO;
	
	EGORefreshTableHeaderView *_refreshTableHeaderView;
	UITableView *_tableView;
	HONHeaderView *_headerView;
}

- (void)_promptForAddressBookAccess;

- (void)_retreiveUserClub;
- (void)_sendEmailContacts;
- (void)_sendPhoneContacts;
- (void)_inviteInAppContact:(HONTrivialUserVO *)trivialUserVO toClub:(HONUserClubVO *)userClubVO;
- (void)_inviteNonAppContact:(HONContactUserVO *)contactUserVO toClub:(HONUserClubVO *)userClubVO;
- (void)_searchUsersWithUsername:(NSString *)username;
- (void)_retrieveDeviceContacts;

- (void)_updateMatchedContacts;
-(NSDictionary *)_populateSegmentedDictionary;
@end
