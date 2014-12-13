//
//  HONContactsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 05/01/2014 @ 19:07 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "NSMutableDictionary+Replacements.h"
#import "HONViewController.h"
#import "HONRefreshControl.h"
#import "HONTableView.h"
#import "HONClubViewCell.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"
#import "HONSearchBarView.h"
#import "HONTableHeaderView.h"
#import "HONLineButtonView.h"

typedef NS_OPTIONS(NSInteger, HONContactsTableViewDataSource) {
	HONContactsTableViewDataSourceEmpty			= (0UL << 0),
	HONContactsTableViewDataSourceMatchedUsers	= (1UL << 0),
	HONContactsTableViewDataSourceAddressBook	= (1UL << 1)
};

typedef NS_OPTIONS(NSUInteger, HONContactsSendType) {
	HONContactsSendTypeNone		= (0UL << 0),
	HONContactsSendTypePhone	= (1UL << 0),
	HONContactsSendTypeEmail	= (1UL << 1),
	HONContactsSendTypeSMS		= (1UL << 2)
};

@interface HONContactsViewController : HONViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	HONContactsTableViewDataSource _tableViewDataSource;
	HONContactsSendType _contactsSendType;
	
	NSMutableArray *_headRows;
	NSMutableArray *_clubs;
	NSMutableArray *_allDeviceContacts;
	NSMutableArray *_shownDeviceContacts;
	NSMutableArray *_omittedDeviceContacts;
	NSMutableArray *_inAppUsers;
	NSMutableArray *_searchUsers;
	NSMutableArray *_matchedUserIDs;
	HONUserClubVO *_userClubVO;
	
	HONTableView *_tableView;
	UIRefreshControl *_refreshControl;
	HONSearchBarView *_searchBarView;
	
	HONLineButtonView *_emptyContactsBGView;
	HONLineButtonView *_accessContactsBGView;
	
	int _joinedTotalClubs;
}

- (void)_retrieveClubs;
- (void)_goDataRefresh:(HONRefreshControl *)sender;
- (void)_goReloadTableViewContents;
- (void)_didFinishDataRefresh;

- (void)_promptForAddressBookAccess;
- (void)_promptForAddressBookPermission;

- (void)_submitPhoneNumberForMatching;
- (void)_retrieveDeviceContacts;
- (void)_sendEmailContacts;
- (void)_sendPhoneContacts;

- (void)_goCreateChallenge;
- (void)_goTableBGSelected:(id)sender;

- (void)lineButtonViewDidSelect:(HONLineButtonView *)lineButtonView;

- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectClub:(HONUserClubVO *)clubVO;
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO;
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO;

@end
