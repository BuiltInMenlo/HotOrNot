//
//  HONContactsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 05/01/2014 @ 19:07 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "MBProgressHUD.h"
#import "TSTapstream.h"

#import "HONContactsViewController.h"
#import "HONUserProfileViewController.h"
#import "HONUserToggleViewCell.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONSearchBarView.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"

@interface HONContactsViewController () <EGORefreshTableHeaderDelegate, HONSearchBarViewDelegate, HONUserToggleViewCellDelegate>
@property (nonatomic, strong) NSString *smsRecipients;
@property (nonatomic, strong) NSString *emailRecipients;
@property (nonatomic, strong) NSMutableArray *clubInviteContacts;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) int currentMatchStateCounter;
@property (nonatomic) int totalMatchStateCounter;
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
- (void)_retreiveUserClub {
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		_userClubVO = nil;//[HONUserClubVO clubWithDictionary:([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0) ? [[((NSDictionary *)result) objectForKey:@"owned"] objectAtIndex:0] : nil];
		
	}];
}

- (void)_sendEmailContacts {
	[[HONAPICaller sharedInstance] sendDelimitedEmailContacts:[_emailRecipients substringToIndex:[_emailRecipients length] - 1] completion:^(NSObject *result){
		for (NSDictionary *dict in (NSArray *)result) {
			HONTrivialUserVO *vo = [HONTrivialUserVO userWithDictionary:@{@"id"			: [dict objectForKey:@"id"],
																		  @"username"	: [dict objectForKey:@"username"],
																		  @"img_url"	: ([dict objectForKey:@"avatar_url"] != nil) ? [dict objectForKey:@"avatar_url"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront]] stringByAppendingString:kSnapLargeSuffix]}];
			BOOL isFound = NO;
			for (HONTrivialUserVO *searchVO in _inAppContacts) {
				if (searchVO.userID == vo.userID) {
					isFound = YES;
					break;
				}
			}
			
			if (!isFound)
				[_inAppContacts addObject:vo];
		}
		
		_currentMatchStateCounter++;
		if (_currentMatchStateCounter == _totalMatchStateCounter) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[self _updateMatchedContacts];
		}
	}];
}

- (void)_sendPhoneContacts {
	[[HONAPICaller sharedInstance] sendDelimitedPhoneContacts:[_smsRecipients substringToIndex:[_smsRecipients length] - 1] completion:^(NSObject *result){
		for (NSDictionary *dict in (NSArray *)result) {
			HONTrivialUserVO *vo = [HONTrivialUserVO userWithDictionary:@{@"id"			: [dict objectForKey:@"id"],
																		  @"username"	: [dict objectForKey:@"username"],
																		  @"img_url"	: ([dict objectForKey:@"avatar_url"] != nil) ? [dict objectForKey:@"avatar_url"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront]] stringByAppendingString:kSnapLargeSuffix]}];
			
			BOOL isFound = NO;
			for (HONTrivialUserVO *searchVO in _inAppContacts) {
				if (searchVO.userID == vo.userID) {
					isFound = YES;
					break;
				}
			}
			
			if (!isFound)
				[_inAppContacts addObject:vo];
		}
		
		_currentMatchStateCounter++;
		if (_currentMatchStateCounter == _totalMatchStateCounter) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[self _updateMatchedContacts];
		}
	}];
}

- (void)_inviteInAppContact:(HONTrivialUserVO *)trivialUserVO toClub:(HONUserClubVO *)userClubVO {
	TSTapstream *tracker = [TSTapstream instance];
	
	TSEvent *e = [TSEvent eventWithName:@"Invite Friends" oneTimeOnly:YES];
	[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"user_id"];
	[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"username"] forKey:@"username"];
	[e addValue:[@"" stringFromInt:userClubVO.clubID] forKey:@"club_id"];
	[e addValue:userClubVO.clubName forKey:@"club_name"];
	[e addValue:[@"" stringFromInt:trivialUserVO.userID] forKey:@"invite_id"];
	[e addValue:trivialUserVO.username forKey:@"invite_name"];
	[tracker fireEvent:e];
	
	[[HONAPICaller sharedInstance] inviteInAppUsers:[NSArray arrayWithObject:trivialUserVO] toClubWithID:userClubVO.clubID withClubOwnerID:userClubVO.ownerID completion:^(NSObject *result) {
	}];
}

- (void)_inviteNonAppContact:(HONContactUserVO *)contactUserVO toClub:(HONUserClubVO *)userClubVO {
	TSTapstream *tracker = [TSTapstream instance];
	
	TSEvent *e = [TSEvent eventWithName:@"Invite Friends" oneTimeOnly:YES];
	[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"user_id"];
	[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"username"] forKey:@"username"];
	[e addValue:[@"" stringFromInt:userClubVO.clubID] forKey:@"club_id"];
	[e addValue:userClubVO.clubName forKey:@"club_name"];
	[e addValue:contactUserVO.fullName forKey:@"invite_name"];
	[e addValue:(contactUserVO.isSMSAvailable) ? contactUserVO.mobileNumber : contactUserVO.email forKey:@"invite_contact"];
	[tracker fireEvent:e];
	
	[[HONAPICaller sharedInstance] inviteNonAppUsers:[NSArray arrayWithObject:contactUserVO] toClubWithID:userClubVO.clubID withClubOwnerID:userClubVO.ownerID completion:^(NSObject *result) {
	}];
}

- (void)_searchUsersWithUsername:(NSString *)username {
	_tableViewDataSource = HONContactsTableViewDataSourceSearchResults;
	_searchUsers = [NSMutableArray array];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] searchForUsersByUsername:username completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result) {
			[_searchUsers addObject:[HONTrivialUserVO userWithDictionary:@{@"id"		: [dict objectForKey:@"id"],
																		   @"username"	: [dict objectForKey:@"username"],
																		   @"img_url"	: [dict objectForKey:@"avatar_url"]}]];
		}
		
		if (_progressHUD != nil) {
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
		}
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
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
		
		if ([fName length] == 0)
			continue;
		
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
																			 @"l_name"	: lName,
																			 @"phone"	: phoneNumber,
																			 @"email"	: email,
																			 @"image"	: (imageData != nil) ? imageData : UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"])}];
			[unsortedContacts addObject:vo.dictionary];
			
			if (vo.isSMSAvailable)
				_smsRecipients = [_smsRecipients stringByAppendingFormat:@"%@|", vo.mobileNumber];
			
			else
				_emailRecipients = [_emailRecipients stringByAppendingFormat:@"%@|", vo.email];
		}
	}
	
	if ([_smsRecipients length] > 0 || [_emailRecipients length] > 0) {
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
	
	_allContacts = [NSMutableArray array];
	for (NSDictionary *dict in [NSArray arrayWithArray:[unsortedContacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"l_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]])
		[_allContacts addObject:[HONContactUserVO contactWithDictionary:dict]];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	_segmentedContacts = [self _populateSegmentedDictionary];
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
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"" hasBackground:YES];
	[self.view addSubview:_headerView];
	
	HONSearchBarView *searchBarView = [[HONSearchBarView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kSearchHeaderHeight)];
	searchBarView.delegate = self;
	[self.view addSubview:searchBarView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight + kSearchHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + kSearchHeaderHeight)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	UIButton *contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	contactsButton.frame = CGRectMake(103.0, 0.0, 44.0, 44.0);
	[contactsButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_nonActive"] forState:UIControlStateNormal];
	[contactsButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_Active"] forState:UIControlStateHighlighted];
	[contactsButton addTarget:self action:(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @selector(_promptForAddressBookPermission) : @selector(_promptForAddressBookAccess) forControlEvents:UIControlEventTouchUpInside];
	contactsButton.hidden = (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized);
	[_tableView addSubview:contactsButton];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] != nil) {
		[self _retreiveUserClub];
		
		if (ABAddressBookRequestAccessWithCompletion) {
			ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
			NSLog(@"ABAddressBookGetAuthorizationStatus() = [%ld]", ABAddressBookGetAuthorizationStatus());
			
			// first time asking for access
			if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
				ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
					//[self _promptForAddressBookPermission];
				});
				
			// already granted access
			} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Address Book - Granted"];
				[self _retrieveDeviceContacts];
				
			// denied permission
			} else {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Address Book - Denied"];
			}
		}
	}
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
	[[[UIAlertView alloc] initWithTitle:@"We need your OK to access the the address book."
								message:@"Flip the switch in Settings->Privacy->Contacts to grant access."
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_promptForAddressBookPermission {
	[[[UIAlertView alloc] initWithTitle:@"Allow Access to your contacts?"
								message:nil
							   delegate:nil
					  cancelButtonTitle:@"No"
					  otherButtonTitles:@"Yes", nil] show];
	
	[self _retrieveDeviceContacts];
}


#pragma mark - SearchBarHeader Delegates
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView {
	_tableViewDataSource = HONContactsTableViewDataSourceSearchResults;
	
	_searchUsers = [NSMutableArray array];
	[_tableView reloadData];
}

- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Search Users Cancel"];
	_tableViewDataSource = HONContactsTableViewDataSourceAddressBook;
	[_tableView reloadData];
}

- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Search Users Submit"
									 withProperties:@{@"query"	: searchQuery}];
	
	[self _searchUsersWithUsername:searchQuery];
}


#pragma mark - UserToggleViewCell Delegates
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell showProfileForTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:trivialUserVO.userID] animated:YES];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectContactUser:(HONContactUserVO *)contactUserVO {
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	if (_userClubVO != nil)
		[self _inviteNonAppContact:contactUserVO toClub:_userClubVO];
	
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Haven't Created A Club!"
															message:@"You need to create your own club before inviting anyone."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	if (_userClubVO != nil)
		[self _inviteInAppContact:trivialUserVO toClub:_userClubVO];
	
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Haven't Created A Club!"
															message:@"You need to create your own club before inviting anyone."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
		[self _promptForAddressBookAccess];
	
	else
		[self _retrieveDeviceContacts];
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [_segmentedKeys count] : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [[_segmentedContacts valueForKey:[_segmentedKeys objectAtIndex:section]] count] : [_searchUsers count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:(_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [_segmentedKeys objectAtIndex:section] : @"SEARCH RESULTS"]);
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] : nil);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		HONUserToggleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		if (cell == nil)
			cell = [[HONUserToggleViewCell alloc] init];
		
		HONContactUserVO *contactUserVO = (HONContactUserVO *)[[_segmentedContacts valueForKey:[_segmentedKeys objectAtIndex:[indexPath section]]] objectAtIndex:indexPath.row];
		cell.contactUserVO = contactUserVO;
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
		
	} else {
		HONUserToggleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONUserToggleViewCell alloc] init];
			cell.trivialUserVO = (HONTrivialUserVO *)[_searchUsers objectAtIndex:indexPath.row];
		}
		
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? 0.0 : kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		return ((cell.trivialUserVO != nil) ? indexPath : nil);
		
	} else
		return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		HONTrivialUserVO *vo = cell.trivialUserVO;
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Select Contact Row"
										withTrivialUser:vo];
		
		[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
		
	} else {
		HONTrivialUserVO *vo = [_searchUsers objectAtIndex:indexPath.row];
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Select Search Row"
										withTrivialUser:vo];
		
		[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
	}
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[_tableView setContentOffset:CGPointZero animated:NO];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 0) {
			if (ABAddressBookRequestAccessWithCompletion) {
				ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
				NSLog(@"ABAddressBookGetAuthorizationStatus() = [%ld]", ABAddressBookGetAuthorizationStatus());
				
				// first time asking for access
				if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
						[self _retrieveDeviceContacts];
					});
					
					// already granted access
				} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
					[[HONAnalyticsParams sharedInstance] trackEvent:@"Address Book - Granted"];
					[self _retrieveDeviceContacts];
					
					// denied permission
				} else {
					[[HONAnalyticsParams sharedInstance] trackEvent:@"Address Book - Denied"];
				}
			}
		}
	}
}


#pragma mark - Data Manip
-(NSDictionary *)_populateSegmentedDictionary {
	_segmentedKeys = [[NSMutableArray alloc] init];
	[_segmentedKeys removeAllObjects];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	for (HONContactUserVO *vo in _allContacts) {
		
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
	}
	
	return (dict);
}

- (void)_updateMatchedContacts {
	_inAppContacts = [NSMutableArray array];
	for (HONTrivialUserVO *trivialUserVO in _inAppContacts) {
		for (HONContactUserVO *contactUserVO in _allContacts) {
			if ([trivialUserVO.username isEqualToString:contactUserVO.fullName]) {
				break;
			}
		}
	}
	
	[_tableView reloadData];
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}

@end
