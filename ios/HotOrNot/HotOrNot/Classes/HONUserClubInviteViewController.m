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
#import "HONHeaderView.h"
#import "HONAnalyticsParams.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONInviteClubUserViewCell.h"
#import "HONUserProfileViewController.h"




@interface HONUserClubInviteViewController () <EGORefreshTableHeaderDelegate, HONInviteClubUserViewCellDelegate>
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *smsRecipients;
@property (nonatomic, strong) NSString *emailRecipients;
@property (nonatomic, strong) NSMutableArray *inAppContacts;
@property (nonatomic, strong) NSMutableArray *nonAppContacts;
@property (nonatomic, strong) NSMutableDictionary *invitedUsers;
@property (nonatomic, strong) NSMutableDictionary *blockedUsers;
@property (nonatomic) BOOL isModal;
@end


@implementation HONUserClubInviteViewController


- (id)initAsModal:(BOOL)isModal {
	if ((self = [super init])) {
		_isModal = isModal;
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
																		  @"img_url"	: ([dict objectForKey:@"avatar_url"] != nil) ? [dict objectForKey:@"avatar_url"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:@"avatars"]] stringByAppendingString:kSnapLargeSuffix]}];
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
	[[HONAPICaller sharedInstance] sendDelimitedPhoneContacts:[_smsRecipients substringToIndex:[_smsRecipients length] - 1] completion:^(NSObject *result){
		for (NSDictionary *dict in (NSArray *)result) {
			HONTrivialUserVO *vo = [HONTrivialUserVO userWithDictionary:@{@"id"			: [dict objectForKey:@"id"],
																		  @"username"	: [dict objectForKey:@"username"],
																		  @"img_url"	: ([dict objectForKey:@"avatar_url"] != nil) ? [dict objectForKey:@"avatar_url"] : [[NSString stringWithFormat:@"%@/defaultAvatar", [HONAppDelegate s3BucketForType:@"avatars"]] stringByAppendingString:kSnapLargeSuffix]}];
			
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
	
	_inAppContacts = [NSMutableArray array];
	_invitedUsers = [NSMutableDictionary dictionary];
	_blockedUsers = [NSMutableDictionary dictionary];
	
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Invite Friends"];
	[self.view addSubview:headerView];
	
	if (_isModal) {
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[closeButton setBackgroundImage:[UIImage imageNamed:@"xButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"xButton_Active"] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
		[headerView addButton:closeButton];
		
	} else {
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(15.0, 0.0, 64.0, 44.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addButton:backButton];
	}
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
	
	[self _retrieveContacts];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSLog(@"SELF:[%@]\nSELF.NC:[%@]", self, self.navigationController);
	NSLog(@"[self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]](%d)", [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]]);
	NSLog(@"self.navigationController.presentingViewController.presentedViewController:[%@]", self.navigationController.presentingViewController.presentedViewController);
	NSLog(@"self.presentingViewController.presentedViewController:[%@]", self.presentingViewController.presentedViewController);
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
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Club Invite - Refresh" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
}


#pragma mark - InviteClubUserViewCell Delegates
- (void)avatarViewCell:(HONBaseAvatarViewCell *)viewCell showProfileForUser:(HONTrivialUserVO *)vo {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Invite - Profile"
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																							  toTrivalUser:vo]];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
}

- (void)inviteClubUserViewCell:(HONInviteClubUserViewCell *)viewCell toggleBlock:(BOOL)isSelected forUser:(HONTrivialUserVO *)vo {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Club Invite - Block User %@elected", (isSelected) ? @"S" : @"Des"]
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																							  toTrivalUser:vo]];
	
	if (isSelected) {
		
	
	} else {
		
		
	}
}

- (void)inviteClubUserViewCell:(HONInviteClubUserViewCell *)viewCell toggleInvite:(BOOL)isSelected forUser:(HONTrivialUserVO *)vo {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Club Invite - Invite User %@elected", (isSelected) ? @"S" : @"Des"]
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																							  toTrivalUser:vo]];
	
	if (isSelected) {
		
		
	} else {
		
		
	}
	
}

- (void)inviteClubUserViewCell:(HONInviteClubUserViewCell *)viewCell clearSelectionForUser:(HONTrivialUserVO *)vo {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Invite - User Clear Selection"
									 withProperties:[[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
																							  toTrivalUser:vo]];
	
	
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
	
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBackground"]];
	headerImageView.userInteractionEnabled = YES;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 6.0, 310.0, 20.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	label.textColor = [[HONColorAuthority sharedInstance] honGreenTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"Friends on Selfieclub" : @"Invite contacts";
	[headerImageView addSubview:label];
	
	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 || indexPath.section == 1) {
		HONInviteClubUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			HONTrivialUserVO *vo = (indexPath.section == 0) ? [_inAppContacts objectAtIndex:indexPath.row] : [HONTrivialUserVO userWithDictionary:@{@"id"		: @"0",
																																					@"username"	: ((HONContactUserVO *)[_nonAppContacts objectAtIndex:indexPath.row]).fullName,
																																					@"img_url"	: [[HONAppDelegate s3BucketForType:@"avatars"] stringByAppendingString:@"/defaultAvatar"],
																																					@"altID"	: (((HONContactUserVO *)[_nonAppContacts objectAtIndex:indexPath.row]).isSMSAvailable) ? ((HONContactUserVO *)[_nonAppContacts objectAtIndex:indexPath.row]).mobileNumber : ((HONContactUserVO *)[_nonAppContacts objectAtIndex:indexPath.row]).email}];
			cell = [[HONInviteClubUserViewCell alloc] init];
			cell.userVO = vo;
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
	
//	if (indexPath.section == 0) {
//		HONInviteClubUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
//		
//		if (cell == nil) {
//			cell = [[HONInviteClubUserViewCell alloc] init];
//			cell.userVO = (HONTrivialUserVO *)[_inAppContacts objectAtIndex:indexPath.row];
//		}
//		
//		for (HONTrivialUserVO *vo in [HONAppDelegate followingListWithRefresh:NO]) {
//			if (cell.userVO.userID == vo.userID) {
//				[cell toggleSelected:YES];
//				break;
//			}
//		}
//
//		cell.delegate = self;
//		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
//		return (cell);
//		
//	} else if (indexPath.section == 1) {
//		HONInviteClubUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
//		
//		if (cell == nil) {
//			cell = [[HONInviteClubUserViewCell alloc] init];
//			cell.userVO = (HONTrivialUserVO *)[_nonAppContacts objectAtIndex:indexPath.row];
//		}
//		
//		cell.delegate = self;
//		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//		return (cell);
		
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
	return ((indexPath.section == 0 || indexPath.section == 1) ? kOrthodoxTableCellHeight : ([_inAppContacts count] + [_nonAppContacts count] > 5 + ((int)([[HONDeviceTraits sharedInstance] isPhoneType5s]) * 2)) ? 50.0: 0.0);
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

@end
