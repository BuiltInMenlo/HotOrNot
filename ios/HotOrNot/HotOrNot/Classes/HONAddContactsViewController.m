//
//  HONAddContactsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/27/13 @ 12:52 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import <AddressBook/AddressBook.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONAddContactsViewController.h"
#import "HONHeaderView.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"
#import "HONRecentOpponentViewCell.h"
#import "HONAddContactViewCell.h"


@interface HONAddContactsViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, HONRecentOpponentViewCellDelegate, HONAddContactViewCellDelegate>
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
@end


@implementation HONAddContactsViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Add Contacts - Open"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
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
- (void)_sendSMSContacts {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 11], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[_smsRecipients substringToIndex:[_smsRecipients length] - 1], @"phone",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
																   sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [serverList objectForKey:@"id"], @"id",
															   [serverList objectForKey:@"username"], @"username",
															   [serverList objectForKey:@"avatar_url"], @"avatar_url",
															   @"", @"points",
															   @"", @"votes",
															   @"", @"pokes",
															   @"", @"pics",
															   @"", @"fb_id", nil]];
				[_inAppContacts addObject:vo];
			}
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_sendEmailContacts {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[_emailRecipients substringToIndex:[_emailRecipients length] - 1], @"emailList",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailContacts
				  );
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIEmailContacts parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]
																   sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
			
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [serverList objectForKey:@"id"], @"id",
															   [serverList objectForKey:@"username"], @"username",
															   [serverList objectForKey:@"avatar_url"], @"avatar_url",
															   @"", @"points",
															   @"", @"votes",
															   @"", @"pokes",
															   @"", @"pics",
															   @"", @"fb_id", nil]];
				[_inAppContacts addObject:vo];
			}
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


- (void)_sendFriendRequests {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	NSString *userIDs = @"";
	for (HONUserVO *vo in _selectedInAppContacts)
		userIDs = [userIDs stringByAppendingFormat:@"%d|", vo.userID];
	
	NSLog(@"SELECTED FRIENDS:[%@]", [userIDs substringToIndex:[userIDs length] - 1]);
		
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[userIDs substringToIndex:[userIDs length] - 1], @"target",
							@"1", @"auto", nil];

	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriends);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIAddFriends parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			[HONAppDelegate writeFriendsList:result];
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_VERIFY" object:nil];
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[self dismissViewControllerAnimated:YES completion:^(void){
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_POPULAR_USERS" object:nil];
			}];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
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
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.taskInProgress = YES;
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
			
			_inviteTypeCounter++;
			[self _checkInviteComplete];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
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
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n[%@]", [[self class] description], [HONAppDelegate apiServerPath], kAPIEmailInvites, params);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIEmailInvites parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			_inviteTypeCounter++;
			[self _checkInviteComplete];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


#pragma mark - Device Functions
- (void)_retrieveContacts {
	_nonAppContacts = [NSMutableArray array];
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
			phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0);
			
			/*
			NSString *phoneNumber = @"";
			for(CFIndex j=0; j<phoneCount; j++) {
				NSString *mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneProperties, j);
				
				NSLog(@"PHONE:(%ld)[%@]", j, (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j));
				NSLog(@"PHONE:[%@]", (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0));
				phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0);
				
				if ([mobileLabel isEqualToString:(NSString *) kABPersonPhoneMobileLabel]) {
					phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
					break;
					
				} else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
					phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
					break;
				
				} else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
					phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
					break;
				
				} else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]) {
					phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
					break;
				}
			}
			 */
		}
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
			HONContactUserVO *vo = [HONContactUserVO contactWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																			fName, @"f_name",
																			lName, @"l_name",
																			phoneNumber, @"phone",
																			email, @"email", nil]];
			
			[_nonAppContacts addObject:vo];
			
			
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
		[self _sendSMSContacts];
	}
	
	if ([_emailRecipients length] > 0) {
		NSLog(@"EMAIL CONTACTS:[%@]", [_emailRecipients substringToIndex:[_emailRecipients length] - 1]);
		[self _sendEmailContacts];
	}
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [HONAppDelegate honOrthodoxGreenColor];
	
	_smsRecipients = @"";
	_emailRecipients = @"";
	_inAppContacts = [NSMutableArray array];
	_selectedNonAppContacts = [NSMutableArray array];
	_selectedInAppContacts = [NSMutableArray array];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Find Friends"];
	[self.view addSubview:headerView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(250.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight + 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 65.0)) style:UITableViewStylePlain];
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
	//[selectToggleButton addTarget:self action:@selector(_goSelectAllToggle) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:selectToggleButton];
	
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
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Add Contacts - Back"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Add Contacts - Done"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ([_selectedInAppContacts count] > 0)
		[self _sendFriendRequests];
	
	else if ([_selectedNonAppContacts count] > 0)
		[self _sendInvites];
	
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
															message:@"Your home feed will be empty until you add friends. (you can always add them later if you wish)"
														   delegate:self
												  cancelButtonTitle:@"Yes"
												  otherButtonTitles:@"No", nil];
		[alertView setTag:0];
		[alertView show];
	}
}

- (void)_goSelectAllToggle {
	if ([_selectedNonAppContacts count] == [_nonAppContacts count] && [_selectedInAppContacts count] == [_inAppContacts count]) {
		[[Mixpanel sharedInstance] track:@"Add Contacts - Deselect All"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		for (int i=0; i<[_inAppContacts count]; i++) {
			HONRecentOpponentViewCell *cell = (HONRecentOpponentViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			[cell toggleSelected:NO];
		}
		
		for (int i=0; i<[_nonAppContacts count]; i++) {
			HONAddContactViewCell *cell = (HONAddContactViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
			[cell toggleSelected:NO];
		}
		
		[_selectedNonAppContacts removeAllObjects];
		[_selectedInAppContacts removeAllObjects];
		
	} else {
		[[Mixpanel sharedInstance] track:@"Add Contacts - Select All"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		for (int i=0; i<[_inAppContacts count]; i++) {
			HONRecentOpponentViewCell *cell = (HONRecentOpponentViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			[cell toggleSelected:YES];
		}
		
		for (int i=0; i<[_nonAppContacts count]; i++) {
			HONAddContactViewCell *cell = (HONAddContactViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
			[cell toggleSelected:YES];
		}
		
		_selectedNonAppContacts = [NSMutableArray arrayWithArray:_nonAppContacts];
		_selectedInAppContacts = [NSMutableArray arrayWithArray:_inAppContacts];
	}
}


#pragma mark - Notifications


#pragma mark - UI Presentation
- (void)_checkInviteComplete {
	if (_inviteTypeCounter == _inviteTypeTotal) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_VERIFY" object:nil];
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[self dismissViewControllerAnimated:YES completion:^(void){
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_POPULAR_USERS" object:nil];
		}];
	}
}


#pragma mark - RecentOpponentViewCell Delegates
- (void)recentOpponentViewCell:(HONRecentOpponentViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected {
	if (isSelected){
		[[Mixpanel sharedInstance] track:@"Add Contacts - Select In App Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"contact", nil]];
		
		[_selectedInAppContacts addObject:userVO];
	
	} else {
		[[Mixpanel sharedInstance] track:@"Add Contacts - Deselect In App Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"contact", nil]];
		
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONUserVO *vo in _selectedInAppContacts) {
			for (HONUserVO *dropVO in _inAppContacts) {
				if (vo.userID == dropVO.userID) {
					[removeVOs addObject:vo];
				}
			}
		}
		
		[_selectedInAppContacts removeObjectsInArray:removeVOs];
		removeVOs = nil;
	}
}


#pragma mark - AddContactCell Delegates
- (void)addContactViewCell:(HONAddContactViewCell *)cell user:(HONContactUserVO *)userVO toggleSelected:(BOOL)isSelected {
	if (isSelected) {
		[[Mixpanel sharedInstance] track:@"Add Contacts - Select Non App Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%@ - %@", userVO.fullName, (userVO.isSMSAvailable) ? userVO.mobileNumber : userVO.email], @"contact", nil]];
		
		[_selectedNonAppContacts addObject:userVO];
	} else {
		[[Mixpanel sharedInstance] track:@"Add Contacts - Deselect Non App Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%@ - %@", userVO.fullName, (userVO.isSMSAvailable) ? userVO.mobileNumber : userVO.email], @"contact", nil]];
		
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
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBackground"]];
	headerImageView.userInteractionEnabled = YES;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 6.0, 310.0, 20.0)];
	label.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
	label.textColor = [HONAppDelegate honGreenTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"Follow friends who Volley" : @"Invite friends to Volley";
	[headerImageView addSubview:label];
	
	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONRecentOpponentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONRecentOpponentViewCell alloc] init];
			cell.userVO = (HONUserVO *)[_inAppContacts objectAtIndex:indexPath.row];
		}
		
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
		
	} else {
		HONAddContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONAddContactViewCell alloc] init];
			cell.userVO = (HONContactUserVO *)[_nonAppContacts objectAtIndex:indexPath.row];
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
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Add Contacts - Confirm Done"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_VERIFY" object:nil];
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[self dismissViewControllerAnimated:YES completion:^(void){
					//[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_POPULAR_USERS" object:nil];
				}];
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Add Contacts - Cancel Done"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				break;
		}
	}
}


@end
