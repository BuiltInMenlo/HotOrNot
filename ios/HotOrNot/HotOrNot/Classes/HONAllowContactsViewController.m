//
//  HONAllowContactsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/28/2014 @ 17:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "HONAllowContactsViewController.h"
#import "HONAnalyticsParams.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONHeaderView.h"
#import "HONAllowContactViewCell.h"
#import "HONContactUserVO.h"
#import "HONUserClubVO.h"


@interface HONAllowContactsViewController () <HONAllowContactViewCellDelegate>
@property (nonatomic, strong) NSString *smsRecipients;
@property (nonatomic, strong) NSString *emailRecipients;
@property (nonatomic, strong) NSMutableArray *inAppContacts;
@property (nonatomic, strong) NSMutableArray *nonAppContacts;
@property (nonatomic, strong) NSMutableArray *clubs;
@property (nonatomic, strong) NSArray *headerTitles;
@property (nonatomic, strong) UITableView *tableView;
@end


@implementation HONAllowContactsViewController

- (id)init {
	if ((self = [super init])) {
		_headerTitles = @[@"FRIENDS",
						  @"CONTACTS",
						  @"CLUBS"];
		
//		_smsRecipients = @"";
//		_emailRecipients = @"";
		
		_inAppContacts = [NSMutableArray array];
		_nonAppContacts = [NSMutableArray array];
		_clubs = [NSMutableArray array];
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
		
		[_tableView reloadData];
	}];
}

- (void)_retrieveFeaturedClubs {
	[[HONAPICaller sharedInstance] retrieveFeaturedClubsWithCompletion:^(NSObject *result) {
		_clubs = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result) {
			HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:dict];
			[_clubs addObject:vo];
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Add friends" hasTranslucency:NO];
	[self.view addSubview:headerView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
	
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
			[[Mixpanel sharedInstance] track:@"Address Book - Granted"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
			
			
			[self _retrieveContacts];
			
			// denied permission
		} else {
			[[Mixpanel sharedInstance] track:@"Address Book - Denied"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We need your OK to access the the address book."
																message:@"Flip the switch in Settings->Privacy->Contacts to grant access."
															   delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView show];
		}
	}
	
	[self _retrieveFeaturedClubs];
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
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Allow Access - Done" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
		
		if ([HONAppDelegate switchEnabledForKey:@"firstrun_subscribe"])
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
		
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_HOME_TUTORIAL" object:nil];
	}];
}


#pragma mark - ContactViewCell Delegates
- (void)contactViewCell:(HONAllowContactViewCell *)cell user:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Allow Access - %@ Contact", (isSelected) ? @"Add" : @"Block"] properties:[[HONAnalyticsParams sharedInstance] userProperty]];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_inAppContacts count] : (section == 1) ? [_nonAppContacts count] : [_clubs count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (3);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowHeader"]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 3.0, 200.0, 24.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = [_headerTitles objectAtIndex:section];
	[imageView addSubview:label];
	
	return (imageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONAllowContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONAllowContactViewCell alloc] init];
	
//	HONTrivialUserVO *vo = (HONTrivialUserVO *)[_subscribers objectAtIndex:indexPath.row];
//	
//	cell.userVO = vo;
//	cell.delegate = self;
//	[cell toggleSelected:([HONAppDelegate isFollowingUser:vo.userID])];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (24.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}



@end
