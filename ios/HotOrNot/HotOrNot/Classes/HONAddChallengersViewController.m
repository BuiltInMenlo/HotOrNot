//
//  HONAddChallengersViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13 @ 20:22 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

#import "HONAddChallengersViewController.h"
#import "HONHeaderView.h"
#import "HONRecentOpponentViewCell.h"
#import "HONFriendViewCell.h"
#import "HONAddContactViewCell.h"


@interface HONAddChallengersViewController () <UITableViewDataSource, UITableViewDelegate, HONRecentOpponentViewCellDelegate, HONFriendViewCellDelegate, HONAddContactViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *recents;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectedRecents;
@property (nonatomic, strong) NSMutableArray *selectedFriends;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSMutableArray *recentOpponentCells;
@property (nonatomic, strong) NSMutableArray *friendCells;
@property (nonatomic, strong) NSMutableArray *contactCells;
@property (nonatomic, strong) NSMutableArray *cellArray;
@end

@implementation HONAddChallengersViewController
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		_cellArray = [[NSMutableArray alloc] init];
		
		_selectedRecents = [NSMutableArray array];
		_selectedFriends = [NSMutableArray array];
		_selectedContacts = [NSMutableArray array];
	}
	
	return (self);
}

- (id)initRecentsSelected:(NSArray *)followers friendsSelected:(NSArray *)friends contactsSelected:(NSArray *)contacts {
	if ((self = [super init])) {
		_selectedRecents = [followers mutableCopy];
		_selectedFriends = [friends mutableCopy];
		_selectedContacts = [contacts mutableCopy];
		
		NSMutableArray *dropVO = [NSMutableArray array];
		for (HONUserVO *vo in _selectedRecents) {
			for (HONUserVO *friendVO in [HONAppDelegate friendsList]) {
				if (vo.userID == friendVO.userID) {
					[dropVO addObject:vo];
					[_selectedFriends addObject:vo];
				}
			}
		}
		
		[_selectedRecents removeObjectsInArray:dropVO];
		dropVO = nil;
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
	_recents = [NSMutableArray array];
	_recentOpponentCells = [NSMutableArray array];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 4], @"action", // 11 on Users.php actual following // 4 on Search is past challengers
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
//			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
//																					sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			NSArray *parsedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], parsedUsers);
			
			
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				[_recents addObject:vo];
				
				if ([_recents count] >= kRecentOpponentsDisplayTotal)
					break;
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, [error localizedDescription]);
	}];
}


- (void)_sendInvites {
	NSMutableArray *emails = [NSMutableArray array];
	NSMutableArray *numbers = [NSMutableArray array];
	for (HONContactUserVO *vo in _selectedContacts) {
		if (vo.isSMSAvailable)
			[numbers addObject:vo];
		
		else
			[emails addObject:vo];
	}
		
	if ([numbers count] > 0)
		[self _sendSMSInvites:[numbers copy]];
	
	if ([emails count] > 0)
		[self _sendEmailInvites:[emails copy]];
}

- (void)_sendSMSInvites:(NSArray *)numbers {
	NSString *phoneNumbers = @"";
	for (HONContactUserVO *vo in numbers) {
		if (vo.isSMSAvailable)
			phoneNumbers = [phoneNumbers stringByAppendingFormat:@"%@|", vo.mobileNumber];
	}
	
	NSLog(@"SELECTED CONTACTS:[%@]", [phoneNumbers substringToIndex:[phoneNumbers length] - 1]);
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[phoneNumbers substringToIndex:[phoneNumbers length] - 1], @"numbers", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPISMSInvites);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPISMSInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_sendEmailInvites:(NSArray *)addresses {
	NSString *emails = @"";
	for (HONContactUserVO *vo in addresses) {
		emails = [emails stringByAppendingFormat:@"%@|", vo.email];
	}
	
	NSLog(@"SELECTED CONTACTS:[%@]", [emails substringToIndex:[emails length] - 1]);
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[emails substringToIndex:[emails length] - 1], @"addresses", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailInvites);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIEmailInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}



#pragma mark - Device Functions
- (void)_retrieveContacts {
	_contacts = [NSMutableArray array];
	_contactCells = [NSMutableArray array];
	
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	
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
		if (phoneCount > 0) {
			NSLog(@"\nPHONE:[%@]", (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0));
			phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0);
		}
		/*
		NSString *phoneNumber = @"";
		for(CFIndex j=0; j<phoneCount; j++) {
			NSString *mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneProperties, j);
			if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
				phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
				break;
				
			} else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
				phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
				break;
				
			} else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
				phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
				break;
			}
		}
		*/
		CFRelease(phoneProperties);
		
		
		NSString *email = @"";
		ABMultiValueRef emailProperties = ABRecordCopyValue(ref, kABPersonEmailProperty);
		CFIndex emailCount = ABMultiValueGetCount(emailProperties);
		
		if (emailCount > 0) {
			email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailProperties, 0);
//			for (CFIndex j=0; j<emailCount; j++)
//				email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailProperties, j);
		}
		CFRelease(emailProperties);
		
		if ([email length] == 0)
			email = @"";
		
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
	
	self.view.backgroundColor = [HONAppDelegate honOrthodoxGreenColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Select friends"];
	[self.view addSubview:headerView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kNavBarHeaderHeight) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	[self _retreiveFollowing];
	
	_friendCells = [NSMutableArray array];
	
	ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
	
	// first time asking for access
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
		ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
			[self _retrieveContacts];
		});
		
		// already granted access
	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
		[[Mixpanel sharedInstance] track:@"Address Book - Granted"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[self _retrieveContacts];
		
		// denied permission
	} else {
		[[Mixpanel sharedInstance] track:@"Address Book - Denied"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
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
	[[Mixpanel sharedInstance] track:@"Add Challengers - Done"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ([_selectedContacts count] > 0)
		[self _sendInvites];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goFollowFriends {
	[[Mixpanel sharedInstance] track:@"Add Challengers - Select All Following"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	NSLog(@"[_selectedRecents count] :: [_following count] :: [%d][%d]", [_selectedRecents count], [_recents count]);
	BOOL isDeselecting = ([_selectedRecents count] >= [_recents count]);
	
	for (HONRecentOpponentViewCell *cell in _recentOpponentCells)
		[cell toggleSelected:!isDeselecting];
	
	_selectedRecents = [_recents mutableCopy];
	[self.delegate addChallengers:self selectFollowing:[_selectedRecents copy] forAppending:!isDeselecting];
}

- (void)_goAllContacts {
	[[Mixpanel sharedInstance] track:@"Add Challengers - Select All Contacts"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"[_selectedContacts count] :: [_contacts count] :: [%d][%d]", [_selectedContacts count], [_contacts count]);
	BOOL isDeselecting = ([_selectedContacts count] >= [_contacts count]);
	
	for (HONAddContactViewCell *cell in _contactCells)
		[cell toggleSelected:!isDeselecting];
	
	_selectedContacts = [_contacts mutableCopy];
	[self.delegate addChallengers:self selectFollowing:[_selectedContacts copy] forAppending:!isDeselecting];
}


#pragma mark - Notifications


#pragma mark - RecentOpponentCell Delegates
- (void)recentOpponentViewCell:(HONRecentOpponentViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected {
	if (isSelected) {
		[[Mixpanel sharedInstance] track:@"Add Challengers - Select Recent"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"opponent", nil]];
		[_selectedRecents addObject:userVO];
		
	} else {
		[[Mixpanel sharedInstance] track:@"Add Challengers - Deselect Recent"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"opponent", nil]];
		[_selectedRecents removeObject:userVO];
	}
	
	[self.delegate addChallengers:self selectFollowing:[NSArray arrayWithObject:userVO] forAppending:isSelected];
}


#pragma mark - FriendCell Delegates
- (void)friendViewCell:(HONFriendViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected {
	if (isSelected) {
		[[Mixpanel sharedInstance] track:@"Add Challengers - Select Friend"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"friend", nil]];
		[_selectedFriends addObject:userVO];
	} else {
		[[Mixpanel sharedInstance] track:@"Add Challengers - Deselect Friend"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"friend", nil]];
		[_selectedFriends removeObject:userVO];
	}
}

#pragma mark - AddContactCell Delegates
- (void)addContactViewCell:(HONAddContactViewCell *)cell user:(HONContactUserVO *)userVO toggleSelected:(BOOL)isSelected {
	if (isSelected) {
		[[Mixpanel sharedInstance] track:@"Add Challengers - Select Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%@ - %@", userVO.fullName, (userVO.isSMSAvailable) ? userVO.mobileNumber : userVO.email], @"contact", nil]];
		[_selectedContacts addObject:userVO];
		
	} else {
		[[Mixpanel sharedInstance] track:@"Add Challengers - Deselect Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%@ - %@", userVO.fullName, (userVO.isSMSAvailable) ? userVO.mobileNumber : userVO.email], @"contact", nil]];
		[_selectedContacts removeObject:userVO];
	}
	
	[self.delegate addChallengers:self selectContacts:[NSArray arrayWithObject:userVO] forAppending:isSelected];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return ([_recents count]);
	
//	else if (section == 1)
//		return ([[HONAppDelegate friendsList] count]);
	
	else
		return ([_contacts count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBackground"]];
	headerImageView.userInteractionEnabled = YES;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 6.0, 310.0, 20.0)];
	label.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
	label.textColor = [HONAppDelegate honGreenTextColor];
	label.backgroundColor = [UIColor clearColor];
	[headerImageView addSubview:label];
	
	if (section == 0)
		label.text = @"Most Recent";
	
//	else if (section == 1)
//		label.text = @"Friends";
	
	else
		label.text = @"Invite Friends";
		
	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONRecentOpponentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONRecentOpponentViewCell alloc] init];
			cell.userVO = (HONUserVO *)[_recents objectAtIndex:indexPath.row];
			
			for (HONUserVO *vo in _selectedRecents) {
				if (vo.userID == cell.userVO.userID) {
					[cell toggleSelected:YES];
					break;
				}
			}
		}
		
		[_recentOpponentCells addObject:cell];
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
		
//	} else if (indexPath.section == 1) {
//		HONFriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
//		
//		if (cell == nil) {
//			cell = [[HONFriendViewCell alloc] init];
//			cell.userVO = (HONUserVO *)[[HONAppDelegate friendsList] objectAtIndex:indexPath.row];
//			
//			for (HONUserVO *vo in _selectedFriends) {
//				if (vo.userID == cell.userVO.userID) {
//					[cell toggleSelected:YES];
//					break;
//				}
//			}
//		}
//		
//		[_friendCells addObject:cell];
//		cell.delegate = self;
//		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//		return (cell);
		
	} else {
		HONAddContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONAddContactViewCell alloc] init];
			cell.userVO = (HONContactUserVO *)[_contacts objectAtIndex:indexPath.row];
			
			for (HONContactUserVO *vo in _selectedContacts) {
				if ([vo.fullName isEqualToString:cell.userVO.fullName]) {
					[cell toggleSelected:YES];
					break;
				}
			}
		}
		
		[_contactCells addObject:cell];
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
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


@end
