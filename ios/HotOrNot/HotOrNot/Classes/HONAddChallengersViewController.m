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
@property(nonatomic, strong) NSMutableArray *contacts;
@property(nonatomic, strong) NSMutableArray *following;
@property(nonatomic, strong) UITableView *tableView;
@end


@implementation HONAddChallengersViewController

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
- (void)_retreiveFollowing {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 11], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONAddFriendsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSLog(@"HONAddFriendsViewController AFNetworking: %@", parsedLists);
			
			_following = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				[_following addObject:vo];
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONAddFriendsViewController AFNetworking %@", [error localizedDescription]);
		
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
	
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonGreen_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonGreen_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:cancelButton];
	
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
	
	//[self _retreiveFollowing];
	
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
- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Add Friends - Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self dismissViewControllerAnimated:YES completion:nil];
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
	[inviteButton addTarget:self action:(section == 0) ? @selector(_goFollowFriends) : @selector(_goInviteAllContacts) forControlEvents:UIControlEventTouchUpInside];
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
