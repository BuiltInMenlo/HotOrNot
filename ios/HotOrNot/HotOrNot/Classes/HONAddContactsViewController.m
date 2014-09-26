//
//  HONAddContactsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/27/13 @ 12:52 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import <AddressBook/AddressBook.h>

#import "MBProgressHUD.h"
#import "TSTapstream.h"
#import "UIImageView+AFNetworking.h"

#import "HONAddContactsViewController.h"
#import "HONMessagesViewController.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONMessagesButtonView.h"
#import "HONTrivialUserVO.h"
#import "HONContactUserVO.h"
#import "HONFollowContactViewCell.h"
#import "HONInviteContactViewCell.h"
//#import "HONUserProfileViewController.h"


@interface HONAddContactsViewController ()<HONFollowContactViewCellDelegate, HONInviteContactViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *nonAppContacts;
@property (nonatomic, strong) NSMutableArray *inAppContacts;
@property (nonatomic, strong) NSMutableArray *selectedNonAppContacts;
@property (nonatomic, strong) NSMutableArray *selectedInAppContacts;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *smsRecipients;
@property (nonatomic, strong) NSString *emailRecipients;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) int inviteTypeCounter;
@property (nonatomic) int inviteTypeTotal;
@property (nonatomic) BOOL isFirstRun;
@property (nonatomic) BOOL hasUpdated;
@end


@implementation HONAddContactsViewController

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (id)initAsFirstRun:(BOOL)isFirstRun {
	if ((self = [self init])) {
		_isFirstRun = isFirstRun;
		_hasUpdated = NO;
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
- (void)_sendEmailContacts {
	[[HONAPICaller sharedInstance] submitDelimitedEmailContacts:[_emailRecipients substringToIndex:[_emailRecipients length] - 1] completion:^(NSArray *result) {
		for (NSDictionary *dict in result) {
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
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[_tableView reloadData];
	}];
}

- (void)_sendPhoneContacts {
	[[HONAPICaller sharedInstance] submitDelimitedPhoneContacts:[_smsRecipients substringToIndex:[_smsRecipients length] - 1] completion:^(NSArray *result) {
		for (NSDictionary *dict in result) {
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
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[_tableView reloadData];
	}];
}

- (void)_followUsers {
	NSString *userIDs = @"";
	for (HONTrivialUserVO *vo in _selectedInAppContacts)
		userIDs = [userIDs stringByAppendingFormat:@"%d|", vo.userID];
	
//	[[HONAPICaller sharedInstance] followUsersByUserIDWithDelimitedList:[userIDs substringToIndex:[userIDs length] - 1] completion:^(NSArray *result) {
//		[HONAppDelegate writeFollowingList:result];
//		
//		if (_progressHUD != nil) {
//			[_progressHUD hide:YES];
//			_progressHUD = nil;
//		}
//		
//		if ([_selectedNonAppContacts count] == 0) {
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
//			
//			[self dismissViewControllerAnimated:YES completion:^(void){
//			}];
//		}
//	}];
}

- (void)_sendInvites {
	NSMutableArray *emails = [NSMutableArray array];
	NSMutableArray *numbers = [NSMutableArray array];
	for (HONContactUserVO *vo in _selectedNonAppContacts) {
		if (vo.isSMSAvailable)
			[numbers addObject:vo];
		
		else
			[emails addObject:vo];
	}
	
	_inviteTypeCounter = 0;
	_inviteTypeTotal = ((int)[numbers count] > 0) + ((int)[emails count] > 0);
	
	if (_inviteTypeTotal > 0) {
		TSTapstream *tracker = [TSTapstream instance];
		
		TSEvent *e = [TSEvent eventWithName:@"Invite Friends" oneTimeOnly:YES];
		[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
		[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"username"] forKey:@"username"];
		[tracker fireEvent:e];
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.taskInProgress = YES;
		
		if ([emails count] > 0) {
			NSString *addresses = @"";
			for (HONContactUserVO *vo in emails)
				addresses = [addresses stringByAppendingFormat:@"%@|", vo.email];
			
			[[HONAPICaller sharedInstance] sendEmailInvitesWithDelimitedList:[addresses substringToIndex:[addresses length] - 1] completion:^(NSObject *result) {
				_inviteTypeCounter++;
				[self _checkInviteComplete];
			}];
		}
		
		if ([numbers count] > 0) {
			NSString *phoneNumbers = @"";
			for (HONContactUserVO *vo in numbers) {
				if (vo.isSMSAvailable)
					phoneNumbers = [phoneNumbers stringByAppendingFormat:@"%@|", vo.mobileNumber];
			}
			
			[[HONAPICaller sharedInstance] sendSMSInvitesWithDelimitedList:[phoneNumbers substringToIndex:[phoneNumbers length] - 1] completion:^(NSObject *result) {
				_inviteTypeCounter++;
				[self _checkInviteComplete];
			}];
		}
	}
}


#pragma mark - Device Functions
- (void)_retrieveContacts {
	NSMutableArray *unsortedContacts = [NSMutableArray array];
	_nonAppContacts = [NSMutableArray array];
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
																			 @"email"	: email}];
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
	
	if ([_smsRecipients length] > 0) {
		NSLog(@"SMS CONTACTS:[%@]", [_smsRecipients substringToIndex:[_smsRecipients length] - 1]);
		[self _sendPhoneContacts];
	}
	
	if ([_emailRecipients length] > 0) {
		NSLog(@"EMAIL CONTACTS:[%@]", [_emailRecipients substringToIndex:[_emailRecipients length] - 1]);
		[self _sendEmailContacts];
	}
	
	NSArray *sortedContacts = [NSArray arrayWithArray:[unsortedContacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"f_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
	for (NSDictionary *dict in sortedContacts) {
		HONContactUserVO *vo = [HONContactUserVO contactWithDictionary:dict];
		[_nonAppContacts addObject:vo];
	}
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	_smsRecipients = @"";
	_emailRecipients = @"";
	_inAppContacts = [NSMutableArray array];
	_selectedNonAppContacts = [NSMutableArray array];
	_selectedInAppContacts = [NSMutableArray array];
	
//	UIButton *inviteAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	inviteAllButton.frame = CGRectMake(10.0, 0.0, 64.0, 44.0);
//	[inviteAllButton setBackgroundImage:[UIImage imageNamed:@"inviteAllButton_nonActive"] forState:UIControlStateNormal];
//	[inviteAllButton setBackgroundImage:[UIImage imageNamed:@"inviteAllButton_Active"] forState:UIControlStateHighlighted];
//	[inviteAllButton addTarget:self action:@selector(_goSelectAllToggle) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle: @"Friends"]; //NSLocalizedString(@"header_friends", nil)];  @"Friends"];
	[self.view addSubview:headerView];
	[headerView addButton:closeButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 76.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 76.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	if (ABAddressBookRequestAccessWithCompletion) {
		ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
		NSLog(@"ABAddressBookGetAuthorizationStatus() = [%ld]", ABAddressBookGetAuthorizationStatus());
		
		// first time asking for access
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
			ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
				[self _retrieveContacts];
			});
			
			// already granted access
		} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
			
			
			[self _retrieveContacts];
			
			// denied permission
		} else {
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We need your OK to access the the address book."
																message:nil
															   delegate:nil
													  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
													  otherButtonTitles:nil];
			[alertView show];
		}
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goClose {
	
	if ([_selectedInAppContacts count] > 0)
		[self _followUsers];
	
	if ([_selectedNonAppContacts count] > 0)
		[self _sendInvites];
	
	if ([_selectedInAppContacts count] == 0 && [_selectedNonAppContacts count] == 0) {
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}

- (void)_goSelectAllToggle {
	if ([_selectedNonAppContacts count] == [_nonAppContacts count] && [_selectedInAppContacts count] == [_inAppContacts count]) {
		
		for (int i=0; i<[_inAppContacts count]; i++) {
			HONFollowContactViewCell *cell = (HONFollowContactViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			[cell toggleSelected:NO];
		}
		
		for (int i=0; i<[_nonAppContacts count]; i++) {
			HONInviteContactViewCell *cell = (HONInviteContactViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
			[cell toggleSelected:NO];
		}
		
		[_selectedNonAppContacts removeAllObjects];
		[_selectedInAppContacts removeAllObjects];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"are_you_sure", nil) //@"Are you sure?"
															message:@"Are you sure you wish to select all of your contacts?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:1];
		[alertView show];
	}
}


#pragma mark - UI Presentation
- (void)_checkInviteComplete {
	if (_inviteTypeCounter == _inviteTypeTotal) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
		[self dismissViewControllerAnimated:YES completion:^(void){
		}];
	}
}


#pragma mark - FollowContactViewCell Delegates
- (void)followContactUserViewCell:(HONFollowContactViewCell *)viewCell followUser:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected {

	
	_hasUpdated = YES;
	if (isSelected)
		[_selectedInAppContacts addObject:userVO];
	
	else {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONTrivialUserVO *vo in _selectedInAppContacts) {
			for (HONTrivialUserVO *dropVO in _inAppContacts) {
				if (vo.userID == dropVO.userID) {
					[removeVOs addObject:vo];
				}
			}
		}
		
		[_selectedInAppContacts removeObjectsInArray:removeVOs];
		removeVOs = nil;
	}
}


#pragma mark - InviteContactCell Delegates
- (void)inviteContactViewCell:(HONInviteContactViewCell *)viewCell inviteUser:(HONContactUserVO *)userVO toggleSelected:(BOOL)isSelected {
	
	
	if (isSelected)
		[_selectedNonAppContacts addObject:userVO];
	
	else {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONContactUserVO *vo in _selectedNonAppContacts) {
			for (HONContactUserVO *dropVO in _nonAppContacts) {
				if ([vo.mobileNumber isEqualToString:dropVO.mobileNumber]) {
					[removeVOs addObject:vo];
				}
			}
		}
		
		[_selectedNonAppContacts removeObjectsInArray:removeVOs];
		removeVOs = nil;
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_inAppContacts count] : [_nonAppContacts count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:(section == 0) ? @"FRIENDS" : @"CONTACTS"]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONFollowContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONFollowContactViewCell alloc] init];
			cell.userVO = (HONTrivialUserVO *)[_inAppContacts objectAtIndex:indexPath.row];
		}
		
		for (HONTrivialUserVO *vo in _selectedInAppContacts) {
			if (cell.userVO.userID == vo.userID) {
				[cell toggleSelected:YES];
				break;
			}
		}
		
//		for (HONTrivialUserVO *vo in [HONAppDelegate followingListWithRefresh:NO]) {
//			if (cell.userVO.userID == vo.userID) {
//				[cell toggleSelected:YES];
//				break;
//			}
//		}
		
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		return (cell);
		
	} else {
		HONInviteContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONInviteContactViewCell alloc] init];
			cell.userVO = (HONContactUserVO *)[_nonAppContacts objectAtIndex:indexPath.row];
		}
		
		for (HONContactUserVO *vo in _selectedNonAppContacts) {
			if ([cell.userVO.fullName isEqualToString:vo.fullName]) {
				[cell toggleSelected:YES];
				break;
			}
		}
		
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 0) ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONTrivialUserVO *vo = [_inAppContacts objectAtIndex:indexPath.row];
		
//	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1) {
		 
		if (buttonIndex == 0) {
			for (int i=0; i<[_inAppContacts count]; i++) {
				HONFollowContactViewCell *cell = (HONFollowContactViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
				[cell toggleSelected:YES];
			}
			
			for (int i=0; i<[_nonAppContacts count]; i++) {
				HONInviteContactViewCell *cell = (HONInviteContactViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
				[cell toggleSelected:YES];
			}
			
			_selectedNonAppContacts = [NSMutableArray arrayWithArray:_nonAppContacts];
			_selectedInAppContacts = [NSMutableArray arrayWithArray:_inAppContacts];
		}
		
		if ([_selectedInAppContacts count] > 0)
			[self _followUsers];
		
		if ([_selectedNonAppContacts count] > 0)
			[self _sendInvites];
		
		if ([_selectedInAppContacts count] == 0 && [_selectedNonAppContacts count] == 0) {
			[self dismissViewControllerAnimated:YES completion:^(void) {
			}];
		}
	}
}


@end
