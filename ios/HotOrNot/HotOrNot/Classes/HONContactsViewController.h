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
#import "HONClubViewCell.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"
#import "HONSearchBarView.h"
#import "HONTableHeaderView.h"
#import "HONTableViewBGView.h"

typedef NS_OPTIONS(NSInteger, HONContactsTableViewDataSource) {
	HONContactsTableViewDataSourceEmpty			= 0 << 0,
	HONContactsTableViewDataSourceMatchedUsers	= 1 << 0,
	HONContactsTableViewDataSourceAddressBook	= 1 << 1
};

typedef NS_OPTIONS(NSUInteger, HONContactsSendType) {
	HONContactsSendTypeNone		= 0 << 0,
	HONContactsSendTypePhone	= 1 << 0,
	HONContactsSendTypeEmail	= 1 << 1,
	HONContactsSendTypeSMS		= 1 << 2
};

@interface HONContactsViewController : HONViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	HONContactsTableViewDataSource _tableViewDataSource;
	HONContactsSendType _contactsSendType;
	
	NSMutableArray *_headRows;
	NSMutableArray *_recentClubs;
	NSMutableArray *_allDeviceContacts;
	NSMutableArray *_shownDeviceContacts;
	NSMutableArray *_omittedDeviceContacts;
	NSMutableArray *_inAppUsers;
	NSMutableArray *_searchUsers;
	NSMutableArray *_matchedUserIDs;
	HONUserClubVO *_userClubVO;
	
	HONTableView *_tableView;
	UIRefreshControl *_refreshControl;
	HONHeaderView *_headerView;
	HONSearchBarView *_searchBarView;
	
	HONTableViewBGView *_emptyContactsBGView;
	HONTableViewBGView *_accessContactsBGView;
	
	int _joinedTotalClubs;
}

- (void)_goDataRefresh:(CKRefreshControl *)sender;
- (void)_didFinishDataRefresh;

- (void)_promptForAddressBookAccess;
- (void)_promptForAddressBookPermission;

- (void)_submitPhoneNumberForMatching;
- (void)_retrieveRecentClubs;
- (void)_retrieveDeviceContacts;
- (void)_sendEmailContacts;
- (void)_sendPhoneContacts;

- (void)_goCreateChallenge;
- (void)_goTableBGSelected:(id)sender;

- (void)tableViewBGViewDidSelect:(HONTableViewBGView *)bgView;

- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectClub:(HONUserClubVO *)clubVO;
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO;
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO;

@end
