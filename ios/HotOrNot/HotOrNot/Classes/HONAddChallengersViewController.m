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
#import "HONAppDelegate.h"
#import "HONFollowFriendViewCell.h"
#import "HONAddContactViewCell.h"


@interface HONAddChallengersViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *following;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSMutableArray *selectedFollowing;
@property (nonatomic, strong) NSMutableArray *followingCells;
@property (nonatomic, strong) NSMutableArray *contactCells;
@property (nonatomic, strong) NSMutableArray *cellArray;
@end

@implementation HONAddChallengersViewController
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		_cellArray = [[NSMutableArray alloc] init];
		
		
		_selectedContacts = [NSMutableArray array];
		_selectedFollowing = [NSMutableArray array];
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithFollowersSelected:(NSArray *)followers contactsSelected:(NSArray *)contacts {
	if ((self = [super init])) {
		_selectedFollowing = [followers mutableCopy];
		_selectedContacts = [contacts mutableCopy];
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ADD_FOLLOW_FRIEND" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DROP_FOLLOW_FRIEND" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ADD_CONTACT_INVITE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DROP_CONTACT_INVITE" object:nil];
}

- (BOOL)shouldAutorotate {
	return (NO);
}

- (void)_registerNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_addFollowFriend:) name:@"ADD_FOLLOW_FRIEND" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_addContactInvite:) name:@"ADD_CONTACT_INVITE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dropFollowFriend:) name:@"DROP_FOLLOW_FRIEND" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dropContactInvite:) name:@"DROP_CONTACT_INVITE" object:nil];
}


#pragma mark - Data Calls
- (void)_retreiveFollowing {
	_following = [NSMutableArray array];
	_followingCells = [NSMutableArray array];

	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 4], @"action", // 11 on Users.php actual following // 4 on Search is past challengers
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-]  HONAddChallengersViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
																					 sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			VolleyJSONLog(@"AFNetworking [-]  HONAddChallengersViewController: %@", parsedUsers);
			
			
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				[_following addObject:vo];
				
				if ([_following count] >= 3)
					break;
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-]  HONAddChallengersViewController %@", [error localizedDescription]);
		
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
	
	//_cellDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], @"followers", [NSMutableArray array], @"contacts", nil];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
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
	
	ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
	
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
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goFollowFriends {
	[[Mixpanel sharedInstance] track:@"Add Challengers - Select All Following"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	NSLog(@"[_selectedFollowing count] :: [_following count] :: [%d][%d]", [_selectedFollowing count], [_following count]);
	BOOL isDeselecting = ([_selectedFollowing count] >= [_following count]);
	
	for (HONFollowFriendViewCell *cell in _followingCells)
		[cell toggleSelected:!isDeselecting];
	
	_selectedFollowing = [_following mutableCopy];
	[self.delegate addChallengers:self selectFollowing:[_selectedFollowing copy] forAppending:!isDeselecting];
}

- (void)_goAllContacts {
	[[Mixpanel sharedInstance] track:@"Add Challengers - Select All Contacts"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"[_selectedContacts count] :: [_contacts count] :: [%d][%d]", [_selectedContacts count], [_contacts count]);
	BOOL isDeselecting = ([_selectedFollowing count] >= [_following count]);
	
	for (HONAddContactViewCell *cell in _contactCells)
		[cell toggleSelected:!isDeselecting];
	
	_selectedContacts = [_contacts mutableCopy];
	[self.delegate addChallengers:self selectFollowing:[_selectedContacts copy] forAppending:!isDeselecting];
}


#pragma mark - Notifications
- (void)_addFollowFriend:(NSNotification *)notification {
	HONUserVO *vo = (HONUserVO *)[notification object];
	[_selectedFollowing addObject:vo];
	
	[[Mixpanel sharedInstance] track:@"Add Challengers - Select Following"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"friend", nil]];
	
	[self.delegate addChallengers:self selectFollowing:[NSArray arrayWithObject:vo] forAppending:YES];
}

- (void)_addContactInvite:(NSNotification *)notification {
	HONContactUserVO *vo = (HONContactUserVO *)[notification object];
	[_selectedContacts addObject:vo];
	
	[[Mixpanel sharedInstance] track:@"Add Challengers - Select Contact"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email], @"contact", nil]];
	
	[self.delegate addChallengers:self selectFollowing:[NSArray arrayWithObject:vo] forAppending:YES];
}

- (void)_dropFollowFriend:(NSNotification *)notification {
	HONUserVO *vo = (HONUserVO *)[notification object];
	[_selectedFollowing removeObject:vo];
	
	[[Mixpanel sharedInstance] track:@"Add Challengers - Deselect Following"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"friend", nil]];
	
	[self.delegate addChallengers:self selectFollowing:[NSArray arrayWithObject:vo] forAppending:NO];
}

- (void)_dropContactInvite:(NSNotification *)notification {
	HONContactUserVO *vo = (HONContactUserVO *)[notification object];
	[_selectedContacts removeObject:vo];
	
	[[Mixpanel sharedInstance] track:@"Add Challengers - Deselect Contact"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email], @"contact", nil]];
	
	[self.delegate addChallengers:self selectContacts:[NSArray arrayWithObject:vo] forAppending:NO];
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
	label.text = (section == 0) ? @"Friends on Volley" : @"Invite Friends from Contacts";
	[headerImageView addSubview:label];
	
	UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	inviteButton.frame = CGRectMake(254.0, 3.0, 54.0, 24.0);
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteAll_nonActive"] forState:UIControlStateNormal];
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteAll_Active"] forState:UIControlStateHighlighted];
	[inviteButton addTarget:self action:(section == 0) ? @selector(_goFollowFriends) : @selector(_goAllContacts) forControlEvents:UIControlEventTouchUpInside];
	inviteButton.hidden = ((section == 0 && [_following count] == 0) || (section == 1 && [_contacts count] == 0));
	[headerImageView addSubview:inviteButton];
	
	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONFollowFriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONFollowFriendViewCell alloc] init];
			cell.userVO = (HONUserVO *)[_following objectAtIndex:indexPath.row];
			
			for (HONUserVO *vo in _selectedFollowing) {
				if (vo.userID == cell.userVO.userID) {
					[cell toggleSelected:YES];
					break;
				}
			}
			 //NSDictionary *followCellsDict = [NSDictionary dictionaryWithObject:cellArray forKey:@"followers"];
		}
		
		[_followingCells addObject:cell];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
		
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
