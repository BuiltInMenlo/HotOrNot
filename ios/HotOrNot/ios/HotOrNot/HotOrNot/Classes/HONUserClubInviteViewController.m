//
//  HONUserClubInviteViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:05 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AddressBook/AddressBook.h>

#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

#import "HONUserClubInviteViewController.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONDeviceIntrinsics.h"
#import "HONFontAllocator.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONTrivialUserVO.h"
#import "HONContactUserVO.h"
#import "HONUserClubVO.h"
#import "HONInAppContactViewCell.h"
#import "HONNonAppContactViewCell.h"
#import "HONUserProfileViewController.h"

@interface HONUserClubInviteViewController () <EGORefreshTableHeaderDelegate, HONInAppContactViewCellDelegate, HONNonAppContactViewCellDelegate>
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) NSMutableArray *inAppContacts;
@property (nonatomic, strong) NSMutableArray *nonAppContacts;
@property (nonatomic, strong) NSMutableArray *selectedNonAppContacts;
@property (nonatomic, strong) NSMutableArray *selectedInAppContacts;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *contactsBlockedImageView;
@property (nonatomic, strong) NSString *smsRecipients;
@property (nonatomic, strong) NSString *emailRecipients;
@end


@implementation HONUserClubInviteViewController

- (id)initWithClub:(HONUserClubVO *)userClub {
	if ((self = [super init])) {
		_userClubVO = userClub;
		
		if (_userClubVO == nil) {
			_userClubVO = [HONUserClubVO clubWithDictionary:@{@"id"				: @"32",
															  @"name"			: @"snap_club",
															  @"added"			: @"2014-04-06 21:20:02",
															  @"description"	: @"",
															  @"img"			: @"",
															  @"members"		: @[],
															  @"total_members"	: @"0",
															  @"owner"			: @{@"id"		: @"131249",
																					@"username"	: @"snap",
																					@"avatar"	: @"https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png",
																					@"age"		: @"2001-04-06 00:00:00"},
															  @"pending"		: @[],
															  @"blocked"		: @[]}];
		}
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
			
			if (!isFound && [_inAppContacts count] < 4)
				[_inAppContacts addObject:vo];
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
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
			
			if (!isFound && [_inAppContacts count] < 4)
				[_inAppContacts addObject:vo];
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}


- (void)_sendClubInvites {
	HONUserClubInviteType userClubInviteType = (HONUserClubInviteTypeInApp * (int)([_selectedInAppContacts count] > 0)) + (HONUserClubInviteTypeNonApp * (int)([_selectedNonAppContacts count] > 0));
	
	if (userClubInviteType == HONUserClubInviteTypeNone) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Friends Selected!"
															 message:@"Create your club w/o inviting anyone?"
															delegate:self
												   cancelButtonTitle:@"No"
												   otherButtonTitles:@"Yes", nil];
		[alertView setTag:0];
		[alertView show];
	
	} else if (userClubInviteType == HONUserClubInviteTypeInApp)
		[self _sendInAppUserInvites];
	
	else if (userClubInviteType == HONUserClubInviteTypeNonApp)
		[self _sendNonAppUserInvites];
	
	else
		[self _sendCombinedUserInvites];
}

- (void)_sendCombinedUserInvites {
	[[HONAPICaller sharedInstance] inviteInAppUsers:[_selectedInAppContacts copy] toClubWithID:_userClubVO.clubID withClubOwnerID:_userClubVO.ownerID inviteNonAppContacts:[_selectedNonAppContacts copy] completion:^(NSObject *result) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}];
}

- (void)_sendInAppUserInvites {
	[[HONAPICaller sharedInstance] inviteInAppUsers:[_selectedInAppContacts copy] toClubWithID:_userClubVO.clubID withClubOwnerID:_userClubVO.ownerID completion:^(NSObject *result) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}];
}


- (void)_sendNonAppUserInvites {
	[[HONAPICaller sharedInstance] inviteNonAppUsers:[_selectedNonAppContacts copy] toClubWithID:_userClubVO.clubID withClubOwnerID:_userClubVO.ownerID completion:^(NSObject *result) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}];
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
	_selectedInAppContacts = [NSMutableArray array];
	_selectedNonAppContacts = [NSMutableArray array];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:NO];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
	
	_contactsBlockedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
	_contactsBlockedImageView.frame = _tableView.frame;
	_contactsBlockedImageView.hidden = YES;
	[_tableView addSubview:_contactsBlockedImageView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Invite Friends"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
	
	
	BOOL hasPermission = ([[HONDeviceIntrinsics sharedInstance] hasAdressBookPermission]);
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:[NSString stringWithFormat:@"Address Book Access - %@", (hasPermission) ? @"Granted" : @"Unknown / Denied"]];
	if (hasPermission)
		[self _retrieveContacts];
	
	else
		[[HONDeviceIntrinsics sharedInstance] promptForAddressBookAccess];
	
	
	_contactsBlockedImageView.hidden = !hasPermission;
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
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Club Invite - Back" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goClose {
	[[Mixpanel sharedInstance] track:@"Club Invite - Close" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Club Invite - Done" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self _sendClubInvites];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Club Invite - Refresh" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	if ([_smsRecipients length] > 0)
		[self _sendPhoneContacts];
	
	if ([_emailRecipients length] > 0)
		[self _sendEmailContacts];
}



#pragma mark - InAppContactViewCell Delegates
- (void)avatarViewCell:(HONBaseAvatarViewCell *)viewCell showProfileForUser:(HONTrivialUserVO *)vo {
	[[Mixpanel sharedInstance] track:@"Club Invite - Show User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"contact", nil]];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
}

- (void)inAppContactViewCell:(HONInAppContactViewCell *)viewCell addUser:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Club Invite - Invite User %@elected", (isSelected) ? @"S" : @"Des"]
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																							  toTrivalUser:userVO]];
	
	if (isSelected) {
		[_selectedInAppContacts addObject:userVO];
	
	} else {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONTrivialUserVO *vo in _selectedInAppContacts) {
			if (vo.userID == userVO.userID) {
				[removeVOs addObject:vo];
			}
		}
		
		[_selectedInAppContacts removeObjectsInArray:removeVOs];
		removeVOs = nil;
	}
}


#pragma mark - NonAppContactViewCell Delegates
- (void)nonAppContactViewCell:(HONNonAppContactViewCell *)viewCell contactUser:(HONContactUserVO *)userVO toggleSelected:(BOOL)isSelected {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Club Invite - Invite Contact %@elected", (isSelected) ? @"S" : @"Des"]
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																							  toContactUser:userVO]];
	
	if (isSelected) {
		[_selectedNonAppContacts addObject:userVO];
		
	} else {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONContactUserVO *vo in _selectedNonAppContacts) {
			if (userVO.isSMSAvailable) {
				if ([vo.mobileNumber isEqualToString:userVO.mobileNumber]) {
					[removeVOs addObject:vo];
				}
				
			} else {
				if ([vo.email isEqualToString:userVO.email]) {
					[removeVOs addObject:vo];
				}
			}
		}
		
		[_selectedNonAppContacts removeObjectsInArray:removeVOs];
		removeVOs = nil;
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_inAppContacts count] : (section == 1 ) ? [_nonAppContacts count] : 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (3);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 2)
		return (nil);
	
	return ([[HONTableHeaderView alloc] initWithTitle:(section == 0) ? @"FRIENDS" : @"CONTACTS"]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONInAppContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONInAppContactViewCell alloc] init];
			cell.userVO = (HONTrivialUserVO *)[_inAppContacts objectAtIndex:indexPath.row];
		}
		
		for (HONTrivialUserVO *vo in _selectedInAppContacts) {
			if (cell.userVO.userID == vo.userID) {
				[cell toggleSelected:YES];
				break;
			}
		}
		
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		return (cell);
		
	} else if (indexPath.section == 1) {
		HONNonAppContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONNonAppContactViewCell alloc] init];
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
		
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[UITableViewCell alloc] init];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 0 || indexPath.section == 1) ? kOrthodoxTableCellHeight : 0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((section == 0 || section == 1) ? kOrthodoxTableHeaderHeight : 0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 0) ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONTrivialUserVO *vo = [_inAppContacts objectAtIndex:indexPath.row];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Invite - Show User Profile"
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																							  toTrivalUser:vo]];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//	NSLog(@"**_[scrollViewDidScroll]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//	NSLog(@"**_[scrollViewDidEndDragging]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	//	NSLog(@"**_[scrollViewDidEndScrollingAnimation]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_tableView setContentOffset:CGPointZero animated:NO];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Club Invite - No Users Selected %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"] properties:[[HONAnalyticsParams sharedInstance] userProperty]];
		
		if (buttonIndex == 1)
			[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
