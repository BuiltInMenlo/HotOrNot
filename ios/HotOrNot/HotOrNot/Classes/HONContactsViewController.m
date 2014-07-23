//
//  HONContactsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 05/01/2014 @ 19:07 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "MBProgressHUD.h"
#import "KeychainItemWrapper.h"
#import "TSTapstream.h"

#import "HONContactsViewController.h"
#import "HONUserProfileViewController.h"
#import "HONInviteClubsViewController.h"
#import "HONCreateSnapButtonView.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONSearchBarView.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"

@interface HONContactsViewController () <HONSearchBarViewDelegate, HONUserToggleViewCellDelegate>
@property (nonatomic, strong) NSString *smsRecipients;
@property (nonatomic, strong) NSString *emailRecipients;
@property (nonatomic, strong) NSMutableArray *clubInviteContacts;
@property (nonatomic, strong) NSMutableArray *matchedUserIDs;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIImageView *noAccessImageView;
@property (nonatomic) int currentMatchStateCounter;
@property (nonatomic) int totalMatchStateCounter;

@property (nonatomic, strong) UITableViewController *refreshControlTableViewController;
@end


@implementation HONContactsViewController

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls
- (void)_retreiveUserClubs {
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		_userClubVO = [HONUserClubVO clubWithDictionary:([[result objectForKey:@"owned"] count] > 0) ? [[result objectForKey:@"owned"] objectAtIndex:0] : nil];
	}];
}

- (void)_sendEmailContacts {
	[[HONAPICaller sharedInstance] submitDelimitedEmailContacts:[_emailRecipients substringToIndex:[_emailRecipients length] - 1] completion:^(NSArray *result) {
		for (NSDictionary *dict in result) {
			HONTrivialUserVO *vo = [HONTrivialUserVO userWithDictionary:@{@"id"			: [dict objectForKey:@"id"],
																		  @"username"	: [dict objectForKey:@"username"],
																		  @"img_url"	: ([dict objectForKey:@"avatar_url"] != nil) ? [dict objectForKey:@"avatar_url"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront]] stringByAppendingString:kSnapLargeSuffix]}];
			
			
			if (![_matchedUserIDs containsObject:vo.phoneNumber]) {
				[_matchedUserIDs addObject:vo.phoneNumber];
				[_inAppContacts addObject:vo];
			}
		}
		
		_currentMatchStateCounter++;
		if (_currentMatchStateCounter == _totalMatchStateCounter)
			[self _didFinishDataRefresh];
	}];
}

- (void)_sendPhoneContacts {
	[[HONAPICaller sharedInstance] submitDelimitedPhoneContacts:[_smsRecipients substringToIndex:[_smsRecipients length] - 1] completion:^(NSArray *result) {
		for (NSDictionary *dict in result) {
			HONTrivialUserVO *vo = [HONTrivialUserVO userWithDictionary:@{@"id"			: [dict objectForKey:@"id"],
																		  @"username"	: [dict objectForKey:@"username"],
																		  @"img_url"	: ([dict objectForKey:@"avatar_url"] != nil) ? [dict objectForKey:@"avatar_url"] : [NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront]],
																		  @"alt_id"		: [HONAppDelegate normalizedPhoneNumber:[dict objectForKey:@"phone"]]}];
			
			if (![_matchedUserIDs containsObject:vo.altID]) {
				[_matchedUserIDs addObject:vo.altID];
				[_inAppContacts addObject:vo];
			}
		}
		
		_currentMatchStateCounter++;
		if (_currentMatchStateCounter == _totalMatchStateCounter)
			[self _didFinishDataRefresh];
	}];
}

- (void)_submitPhoneNumberForMatching {
	_tableViewDataSource = HONContactsTableViewDataSourceMatchedUsers;
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_inAppUsers = [NSMutableArray array];
	HONTrivialUserVO *vo = [HONTrivialUserVO userWithDictionary:@{@"id"				: @"-1",
																  @"username"		: @"¡",
																  @"img_url"		: @"",
																  @"is_verified"	: @"N",
																  @"abuse_ct"		: @"0"}];
	[_inAppUsers addObject:vo];;
	[[HONAPICaller sharedInstance] submitPhoneNumberForUserMatching:[HONAppDelegate phoneNumber] completion:^(NSArray *result) {
		NSLog(@"(NSArray *result[%@]", (NSArray *)result);
		if ([(NSArray *)result count] > 1) {
			for (NSDictionary *dict in [NSArray arrayWithArray:[result sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]]) {
				[_inAppUsers addObject:[HONTrivialUserVO userWithDictionary:@{@"id"			: [dict objectForKey:@"id"],
																			  @"username"	: [dict objectForKey:@"username"],
																			  @"img_url"	: ([dict objectForKey:@"avatar_url"] != nil) ? [dict objectForKey:@"avatar_url"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront]] stringByAppendingString:kSnapLargeSuffix]}]];
			}
		}
		
		[self _didFinishDataRefresh];
		
//		UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactsOverlay"]];
//		overlayImageView.frame = CGRectOffset(overlayImageView.frame, 3.0, 0.0);
//		[_tableView addSubview:overlayImageView];
//		
//		[self _cycleOverlay:overlayImageView];
	}];
}

- (void)_inviteInAppContact:(HONTrivialUserVO *)trivialUserVO toClub:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] inviteInAppUsers:[NSArray arrayWithObject:trivialUserVO] toClubWithID:userClubVO.clubID withClubOwnerID:userClubVO.ownerID completion:^(NSObject *result) {
	}];
}

- (void)_inviteNonAppContact:(HONContactUserVO *)contactUserVO toClub:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] inviteNonAppUsers:[NSArray arrayWithObject:contactUserVO] toClubWithID:userClubVO.clubID withClubOwnerID:userClubVO.ownerID completion:^(NSObject *result) {
	}];
}

- (void)_searchUsersWithUsername:(NSString *)username {
	_tableViewDataSource = HONContactsTableViewDataSourceSearchResults;
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_searchUsers = [NSMutableArray array];
	[[HONAPICaller sharedInstance] searchForUsersByUsername:username completion:^(NSArray *result) {
		for (NSDictionary *dict in result) {
			if([[dict objectForKey:@"id"] intValue] != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]){
				[_searchUsers addObject:[HONTrivialUserVO userWithDictionary:@{@"id"		: [dict objectForKey:@"id"],
																			   @"username"	: [dict objectForKey:@"username"],
																			   @"img_url"	: [dict objectForKey:@"avatar_url"]}]];
			}
		}
		
			if ([_searchUsers count] == 0) {
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
				
			} else {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		
			[self _didFinishDataRefresh];
	}];
}


#pragma mark - Device Functions
- (void)_retrieveDeviceContacts {
	_tableViewDataSource = HONContactsTableViewDataSourceAddressBook;
	NSMutableArray *unsortedContacts = [NSMutableArray array];
	
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = MIN(100, ABAddressBookGetPersonCount(addressBook));
	
	for (int i=0; i<nPeople; i++) {
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		
		NSString *fName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		NSString *lName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
		
//		if ([fName length] == 0)
//			continue;
		
		if ([lName length] == 0)
			lName = @"";
		
		
		NSData *imageData = nil;
		if (ABPersonHasImageData(ref))
			imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
		
		
		ABMultiValueRef phoneProperties = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		CFIndex phoneCount = ABMultiValueGetCount(phoneProperties);
		
		NSString *phoneNumber = @"";
		if (phoneCount > 0)
			phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0);
		
		CFRelease(phoneProperties);
		
		
		NSString *email = @"";
		ABMultiValueRef emailProperties = ABRecordCopyValue(ref, kABPersonEmailProperty);
		CFIndex emailCount = ABMultiValueGetCount(emailProperties);
		
		if (emailCount > 0)
			email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailProperties, 0);
		
		CFRelease(emailProperties);
		
		if ([email length] == 0)
			email = @"";
		
		if ([phoneNumber length] > 0 || [email length] > 0) {
			HONContactUserVO *vo = [HONContactUserVO contactWithDictionary:@{@"f_name"	: fName,
																			 @"l_name"		: lName,
																			 @"phone"		: phoneNumber,
																			 @"email"		: email,
																			 @"image"		: (imageData != nil) ? imageData : UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"])}];
			[unsortedContacts addObject:vo.dictionary];
			
			
			if (vo.isSMSAvailable)
				_smsRecipients = [_smsRecipients stringByAppendingFormat:@"%@|", vo.mobileNumber];
			
			else
				_emailRecipients = [_emailRecipients stringByAppendingFormat:@"%@|", vo.email];
			
			_emailRecipients = @"";
		}
	}
	
	_deviceContacts = [NSMutableArray array];
	for (NSDictionary *dict in [NSArray arrayWithArray:[unsortedContacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"l_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]])
		[_deviceContacts addObject:[HONContactUserVO contactWithDictionary:dict]];
	
	[self _didFinishDataRefresh];
	
	
	
	if ([_smsRecipients length] > 0 || [_emailRecipients length] > 0) {
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.taskInProgress = YES;
	}
	
	_currentMatchStateCounter = 0;
	_totalMatchStateCounter = (int)([_smsRecipients length] > 0) + (int)([_emailRecipients length] > 0);
	
	if ([_smsRecipients length] > 0) {
		NSLog(@"SMS CONTACTS:[%@]", [_smsRecipients substringToIndex:[_smsRecipients length] - 1]);
		[self _sendPhoneContacts];
	}
	
	if ([_emailRecipients length] > 0) {
		NSLog(@"EMAIL CONTACTS:[%@]", [_emailRecipients substringToIndex:[_emailRecipients length] - 1]);
		[self _sendEmailContacts];
	}
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[self _retreiveUserClubs];
	
	[_matchedUserIDs removeAllObjects];
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
		[self _retrieveDeviceContacts];
	
	else
		[self _submitPhoneNumberForMatching];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	if (_tableViewDataSource != HONContactsTableViewDataSourceSearchResults) {
		[self _updateDeviceContactsWithMatchedUsers];
		_segmentedContacts = [self _populateSegmentedDictionary];
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}



#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_smsRecipients = @"";
	_emailRecipients = @"";
	_inAppContacts = [NSMutableArray array];
	_clubInviteContacts = [NSMutableArray array];
	_matchedUserIDs = [NSMutableArray array];
	
	self.edgesForExtendedLayout = UIRectEdgeNone;

	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, (kNavHeaderHeight + kSearchHeaderHeight), 320.0, self.view.frame.size.height - (kNavHeaderHeight + kSearchHeaderHeight)) style:UITableViewStylePlain];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.sectionIndexColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	_tableView.sectionIndexBackgroundColor = [UIColor clearColor];
	_tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:0.40 alpha:0.33];
	_tableView.sectionIndexMinimumDisplayRowCount = 1;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"" hasBackground:YES];
	[self.view addSubview:_headerView];
	
	HONSearchBarView *searchBarView = [[HONSearchBarView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kSearchHeaderHeight)];
	searchBarView.delegate = self;
	[self.view addSubview:searchBarView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
	NSString *passedRegistration = [keychain objectForKey:CFBridgingRelease(kSecAttrAccount)];
	
	if ([passedRegistration length] != 0) {
		[self _retreiveUserClubs];
		
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
			[self _retrieveDeviceContacts];
		
		else
			[self _submitPhoneNumberForMatching];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation


#pragma mark - UI Presentation
- (void)_promptForAddressBookAccess {
	[[[UIAlertView alloc] initWithTitle:@"We need your OK to access the address book."
								message:@"Flip the switch in Settings -> Privacy -> Contacts -> Selfieclub to grant access."
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_promptForAddressBookPermission {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Allow Access to your contacts?"
														message:nil
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:0];
	[alertView show];
}


#pragma mark - SearchBarHeader Delegates
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView {
	_tableViewDataSource = HONContactsTableViewDataSourceSearchResults;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_searchUsers = [NSMutableArray array];
	[_tableView reloadData];
}

- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Search Users Cancel"];
	_tableViewDataSource = HONContactsTableViewDataSourceAddressBook;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self _retreiveUserClubs];
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
		[self _retrieveDeviceContacts];
	
	else
		[self _submitPhoneNumberForMatching];
}

- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Search Users Submit"
									 withProperties:@{@"query"	: searchQuery}];
	
	[self _searchUsersWithUsername:searchQuery];
}


#pragma mark - UserToggleViewCell Delegates
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell showProfileForTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[*:*] userToggleViewCell:showProfileForTrivialUser");
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[*:*] userToggleViewCell:didDeselectContactUser");
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[*:*] userToggleViewCell:didDeselectTrivialUser");
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[*:*] userToggleViewCell:didSelectContactUser");
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[*:*] userToggleViewCell:didSelectTrivialUser");
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceSearchResults) ? 1 : [_segmentedKeys count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceSearchResults) ? [_searchUsers count] : [[_segmentedContacts valueForKey:[_segmentedKeys objectAtIndex:section]] count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:(_tableViewDataSource == HONContactsTableViewDataSourceSearchResults) ? @"SEARCH RESULTS" : [_segmentedKeys objectAtIndex:section]]);
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceSearchResults) ? nil : [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceSearchResults) ? 0 : [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONUserToggleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONUserToggleViewCell alloc] init];
	
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		cell.contactUserVO = (HONContactUserVO *)[[_segmentedContacts valueForKey:[_segmentedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
				
	} else {
		if (_tableViewDataSource == HONContactsTableViewDataSourceSearchResults)
			cell.trivialUserVO = (HONTrivialUserVO *)[_searchUsers objectAtIndex:indexPath.row];
			
		else {
			HONTrivialUserVO *vo = (HONTrivialUserVO *)[[_segmentedContacts valueForKey:[_segmentedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
			
			if (vo.userID == -1) {
				[cell toggleIndicator:NO];
				cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactsAllowBG"]];
				
			} else {
				cell.trivialUserVO = (HONTrivialUserVO *)[[_segmentedContacts valueForKey:[_segmentedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
			}
		}
	}
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers && section == 0) ? 0.0 : kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"-[- cell.contactUserVO.userID:[%d]", cell.contactUserVO.userID);
	NSLog(@"-[- cell.trivialUserVO.userID:[%d]", cell.trivialUserVO.userID);
	
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers && (indexPath.section == 0 && indexPath.row == 0)) {
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
			[self _promptForAddressBookPermission];
		
		else
			[self _promptForAddressBookAccess];
	
	} else {
		[cell invertSelected];
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		NSLog(@"CONTACTS:[%d]", buttonIndex);
		if (buttonIndex == 1) {
			if (ABAddressBookRequestAccessWithCompletion) {
				ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
				NSLog(@"ABAddressBookGetAuthorizationStatus() = [%@]", (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"kABAuthorizationStatusNotDetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"kABAuthorizationStatusDenied" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"kABAuthorizationStatusAuthorized" : @"OTHER");
				
				if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
						[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Address Book Granted"];
						
						[_inAppUsers removeAllObjects];
						[self _retrieveDeviceContacts];
					});
				
				} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
						[_inAppUsers removeAllObjects];
						[self _retrieveDeviceContacts];
					});
				
				} else
					[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Address Book Unknown / Denied "];
			}
		}
	}
}


#pragma mark - Data Manip
-(NSDictionary *)_populateSegmentedDictionary {
	_segmentedKeys = [[NSMutableArray alloc] init];
	[_segmentedKeys removeAllObjects];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers) {
		for (HONTrivialUserVO *vo in _inAppUsers) {
			if ([vo.username length] > 0) {
				NSString *charKey = [[vo.username substringToIndex:1] lowercaseString];
				if (![_segmentedKeys containsObject:charKey]) {
					[_segmentedKeys addObject:charKey];
					
					NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
					[dict setValue:newSegment forKey:charKey];
					
				} else {
					NSMutableArray *prevSegment = (NSMutableArray *)[dict valueForKey:charKey];
					[prevSegment addObject:vo];
					[dict setValue:prevSegment forKey:charKey];
				}
			}
		}
		
//		for (NSString *key in dict) {
//			for (HONTrivialUserVO *vo in [dict objectForKey:key])
//				NSLog(@"_segmentedKeys[%@] = [%@]", key, vo.username);
//		}

	} else {
		for (HONContactUserVO *vo in _deviceContacts) {
			if (vo.contactType == HONContactTypeUnmatched) {
				if ([vo.lastName length] > 0) {
					NSString *charKey = [vo.lastName substringToIndex:1];
					if (![_segmentedKeys containsObject:charKey]) {
						[_segmentedKeys addObject:charKey];
						
						NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
						[dict setValue:newSegment forKey:charKey];
						
					} else {
						NSMutableArray *prevSegment = (NSMutableArray *)[dict valueForKey:charKey];
						[prevSegment addObject:vo];
						[dict setValue:prevSegment forKey:charKey];
					}
				}
			
			} else {
				NSString *charKey = [vo.username substringToIndex:1];
				if (![_segmentedKeys containsObject:charKey]) {
					[_segmentedKeys addObject:charKey];
					
					NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
					[dict setValue:newSegment forKey:charKey];
					
				} else {
					NSMutableArray *prevSegment = (NSMutableArray *)[dict valueForKey:charKey];
					[prevSegment addObject:vo];
					[dict setValue:prevSegment forKey:charKey];
				}
			}
		}
		
//		for (NSString *key in dict) {
//			for (HONContactUserVO *vo in [dict objectForKey:key])
//				NSLog(@"_segmentedKeys[%@] = [%@]", key, vo.mobileNumber);
//		}
	}
	
	return (dict);
}

- (void)_updateDeviceContactsWithMatchedUsers {
	for (HONTrivialUserVO *inAppContactVO in _inAppContacts) {
		for (HONContactUserVO *deviceContactVO in _deviceContacts) {
			if ([deviceContactVO.mobileNumber isEqualToString:inAppContactVO.altID]) {
				deviceContactVO.contactType = HONContactTypeMatched;
				deviceContactVO.userID = inAppContactVO.userID;
				deviceContactVO.username = inAppContactVO.username;
				deviceContactVO.avatarPrefix = inAppContactVO.avatarPrefix;
			}
		}
	}
}


- (void)_cycleOverlay:(UIView *)overlayView {
	[UIView animateWithDuration:0.33 animations:^(void) {
		overlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.33 animations:^(void) {
			overlayView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[self _cycleOverlay:overlayView];
		}];
	}];
}

@end
