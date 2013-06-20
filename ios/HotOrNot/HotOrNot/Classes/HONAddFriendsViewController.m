//
//  HONAddFriendsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONAddFriendsViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"
#import "HONFollowFriendViewCell.h"
#import "HONAddContactViewCell.h"

@interface HONAddFriendsViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) NSMutableArray *contacts;
@property(nonatomic, strong) NSMutableArray *following;
@property(nonatomic, strong) NSMutableArray *selectedContacts;
@property(nonatomic, strong) NSMutableArray *selectedFollowing;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSString *smsRecipients;
@end

@implementation HONAddFriendsViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Add Friends - Open"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_addFollowFriend:) name:@"ADD_FOLLOW_FRIEND" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dropFollowFriend:) name:@"DROP_FOLLOW_FRIEND" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_addContactInvite:) name:@"ADD_CONTACT_INVITE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dropContactInvite:) name:@"DROP_CONTACT_INVITE" object:nil];
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
- (void)_retreiveFollowing {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 4], @"action", // 11 on Users.php actual following // 4 on Search is past challengers
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-]  HONAddFriendsViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
																					 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			VolleyJSONLog(@"AFNetworking [-]  HONAddFriendsViewController: %@", parsedUsers);
			
			_following = [NSMutableArray array];
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				[_following addObject:vo];
				
				if ([_following count] >= kFollowingUsersDisplayTotal)
					break;
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-]  HONAddFriendsViewController %@", [error localizedDescription]);
		
	}];
}

- (void)_sendContactsSMS {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 12], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							_smsRecipients, @"sms_recipients",
							nil];
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-]  HONAddFriendsViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSDictionary *sendResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-]  HONAddFriendsViewController: %@", sendResult);
			
			[self _goDone];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-]  HONAddFriendsViewController %@", [error localizedDescription]);
	}];
}


#pragma mark - Device Functions
- (void)_retrieveContacts {
	_contacts = [NSMutableArray array];
	
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	
	for (int i=0; i<nPeople; i++) {
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		
		NSString *fName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		NSString *lName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
		
		if ([fName length] == 0 || [lName length] == 0)
			continue;
		
		ABMultiValueRef phoneProperties = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		CFIndex phoneCount = ABMultiValueGetCount(phoneProperties);
		
		NSString *phoneNumber = @"";
		for(CFIndex j=0; j<phoneCount; j++) {
			NSString *mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneProperties, j);
			if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
				phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
				
			} else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
				phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
				break ;
			}
		}
		CFRelease(phoneProperties);
		
		
		NSString *email = @"";
		ABMultiValueRef emailProperties = ABRecordCopyValue(ref, kABPersonEmailProperty);
		CFIndex emailCount = ABMultiValueGetCount(emailProperties);
		
		if (emailCount > 0) {
			for (CFIndex j=0; j<emailCount; j++) {
				email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailProperties, j);
			}
		}
		CFRelease(emailProperties);
		
		if ([phoneNumber length] > 0 || [email length] > 0) {
			[_contacts addObject:[HONContactUserVO contactWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																									fName, @"f_name",
																									lName, @"l_name",
																									phoneNumber, @"phone",
																									email, @"email", nil]]];
		}
	}
	
	[_tableView reloadData];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [HONAppDelegate honGreenColor];
	
	_selectedContacts = [NSMutableArray array];
	_selectedFollowing = [NSMutableArray array];
	
//	UIImageView *promoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 35.0, 320.0, 94.0)];
//	[promoteImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate promoteInviteImageForType:1]] placeholderImage:nil];
//	[self.view addSubview:promoteImageView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Find friends"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 0.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButtonArrow_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButtonArrow_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight + 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 45.0)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	UIButton *selectToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectToggleButton.frame = CGRectMake(0.0, kNavBarHeaderHeight, 320.0, 50.0);
	[selectToggleButton setBackgroundImage:[UIImage imageNamed:@"singleTab_nonActive"] forState:UIControlStateNormal];
	[selectToggleButton setBackgroundImage:[UIImage imageNamed:@"singleTab_Active"] forState:UIControlStateHighlighted];
	[selectToggleButton addTarget:self action:@selector(_goSelectAllToggle) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:selectToggleButton];
	
	[self _retreiveFollowing];
	
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
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Contacts Permissions"
															message:@"We need your OK to access the the address book."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Add Friends - Done"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Add Friends - Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}

//- (void)_goFollowFriends {
//	[[Mixpanel sharedInstance] track:@"Add Friends - Follow All"
//								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
//}
//
//- (void)_goInviteAllContacts {
//	[[Mixpanel sharedInstance] track:@"Add Friends - Invite All"
//								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
//	
//	_smsRecipients = @"";
//	for (HONContactUserVO *contactUserVO in _contacts) {
//		if (contactUserVO.isSMSAvailable)
//			[_smsRecipients stringByAppendingString:[NSString stringWithFormat:@"%@|", contactUserVO.mobileNumber]];
//	}
//	
//	_smsRecipients = [_smsRecipients substringToIndex:[_smsRecipients length] - 1];
//	[self _sendContactsSMS];
//}

- (void)_goSelectAllToggle {
	if ([_selectedContacts count] == [_contacts count] && [_selectedFollowing count] == [_following count]) {
		[[Mixpanel sharedInstance] track:@"Add Friends - Deselect All"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		for (int i=0; i<[_following count]; i++) {
			HONFollowFriendViewCell *cell = (HONFollowFriendViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			[cell toggleSelected:NO];
		}
		
		for (int i=0; i<[_contacts count]; i++) {
			HONAddContactViewCell *cell = (HONAddContactViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
			[cell toggleSelected:NO];
		}
		
		[_selectedContacts removeAllObjects];
		[_selectedFollowing removeAllObjects];
		
	} else {
		[[Mixpanel sharedInstance] track:@"Add Friends - Select All"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		for (int i=0; i<[_following count]; i++) {
			HONFollowFriendViewCell *cell = (HONFollowFriendViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			[cell toggleSelected:YES];
		}
		
		for (int i=0; i<[_contacts count]; i++) {
			HONAddContactViewCell *cell = (HONAddContactViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
			[cell toggleSelected:YES];
		}
		
		_selectedContacts = [NSMutableArray arrayWithArray:_contacts];
		_selectedFollowing = [NSMutableArray arrayWithArray:_following];
	}
}


#pragma mark - Notifications
- (void)_addFollowFriend:(NSNotification *)notification {
	HONUserVO *vo = (HONUserVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Add Friends - Select Following"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"friend", nil]];
	
	[_selectedFollowing addObject:vo];
}

- (void)_addContactInvite:(NSNotification *)notification {
	HONContactUserVO *vo = (HONContactUserVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Add Friends - Select Contact"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email], @"contact", nil]];
	
	[_selectedContacts addObject:vo];
	//_smsRecipients = vo.mobileNumber;
	//[self _sendContactsSMS];
}

- (void)_dropFollowFriend:(NSNotification *)notification {
	HONUserVO *vo = (HONUserVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Add Friends - Deselect Following"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"friend", nil]];
	
	NSMutableArray *removeVOs = [NSMutableArray array];
	for (HONUserVO *vo in _selectedFollowing) {
		for (HONUserVO *dropVO in _following) {
			if (vo.userID == dropVO.userID) {
				[removeVOs addObject:vo];
			}
		}
	}
	
	[_selectedFollowing removeObjectsInArray:removeVOs];
	removeVOs = nil;
}

- (void)_dropContactInvite:(NSNotification *)notification {
	HONContactUserVO *vo = (HONContactUserVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Add Friends - Deselect Contact"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email], @"contact", nil]];
	
	NSMutableArray *removeVOs = [NSMutableArray array];
	for (HONContactUserVO *vo in _selectedContacts) {
		for (HONContactUserVO *dropVO in _contacts) {
			if ([vo.mobileNumber isEqualToString:dropVO.mobileNumber]) {
				[removeVOs addObject:vo];
			}
		}
	}
	
	[_selectedContacts removeObjectsInArray:removeVOs];
	removeVOs = nil;
	
	//_smsRecipients = vo.mobileNumber;
	//[self _sendContactsSMS];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_following count] : [_contacts count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBackground"]];
	headerImageView.userInteractionEnabled = YES;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 310.0, 29.0)];
	label.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:15];
	label.textColor = [HONAppDelegate honBlueTxtColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"Follow friends who Volley" : @"Invite friends to Volley";
	[headerImageView addSubview:label];
	
//	UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	inviteButton.frame = CGRectMake(254.0, 3.0, 54.0, 24.0);
//	[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteAll_nonActive"] forState:UIControlStateNormal];
//	[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteAll_Active"] forState:UIControlStateHighlighted];
//	[inviteButton addTarget:self action:(section == 0) ? @selector(_goFollowFriends) : @selector(_goInviteAllContacts) forControlEvents:UIControlEventTouchUpInside];
//	inviteButton.hidden = ((section == 0 && [_following count] == 0) || (section == 1 && [_contacts count] == 0));
//	[headerImageView addSubview:inviteButton];
	
	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		HONFollowFriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
		if (cell == nil) {
			cell = [[HONFollowFriendViewCell alloc] init];
			cell.userVO = (HONUserVO *)[_following objectAtIndex:indexPath.row];
		}
			
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
			
	} else {
		HONAddContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
		if (cell == nil) {
				cell = [[HONAddContactViewCell alloc] init];
				cell.userVO = (HONContactUserVO *)[_contacts objectAtIndex:indexPath.row];
			}
			
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
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

@end
