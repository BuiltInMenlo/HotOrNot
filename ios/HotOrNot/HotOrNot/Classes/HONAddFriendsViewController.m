//
//  HONAddFriendsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "MBProgressHUD.h"
#import "TSTapstream.h"

#import "HONAddFriendsViewController.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONHeaderView.h"
#import "HONTutorialView.h"
#import "HONMessagesButtonView.h"
#import "HONTrivialUserVO.h"
#import "HONContactUserVO.h"
#import "HONInAppContactViewCell.h"
#import "HONNonAppContactViewCell.h"
#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONMessagesViewController.h"
#import "HONUserProfileViewController.h"

@interface HONAddFriendsViewController () <HONAddContactViewCellDelegate, HONInviteUserViewCellDelegate, HONTutorialViewDelegate>
@property (nonatomic, strong) NSMutableArray *nonAppContacts;
@property (nonatomic, strong) NSMutableArray *inAppContacts;
@property (nonatomic, strong) NSMutableArray *selectedNonAppContacts;
@property (nonatomic, strong) NSMutableArray *selectedInAppContacts;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONTutorialView *tutorialView;
@property (nonatomic, strong) NSString *smsRecipients;
@property (nonatomic, strong) NSString *emailRecipients;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) int inviteTypeCounter;
@property (nonatomic) int inviteTypeTotal;
@end


@implementation HONAddFriendsViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedHomeTab:) name:@"SELECTED_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareHomeTab:) name:@"TARE_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_HOME_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshHomeTab:) name:@"REFRESH_ALL_TABS" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showInvite:) name:@"SHOW_INVITE" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSuggestedFollowing:) name:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFirstRun:) name:@"SHOW_FIRST_RUN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showHomeTutorial:) name:@"SHOW_HOME_TUTORIAL" object:nil];
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

- (void)_followUsers {
	NSString *userIDs = @"";
	for (HONTrivialUserVO *vo in _selectedInAppContacts)
		userIDs = [userIDs stringByAppendingFormat:@"%d|", vo.userID];
	
	[[HONAPICaller sharedInstance] followUsersByUserIDWithDelimitedList:[userIDs substringToIndex:[userIDs length] - 1] completion:^(NSObject *result){
		[HONAppDelegate writeFollowingList:(NSArray *)result];
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		if ([_selectedNonAppContacts count] == 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
			
			[self dismissViewControllerAnimated:YES completion:^(void){
			}];
		}
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
			
			[[HONAPICaller sharedInstance] sendEmailInvitesFromDelimitedList:[addresses substringToIndex:[addresses length] - 1] completion:^(NSObject *result){
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
			
			[[HONAPICaller sharedInstance] sendSMSInvitesFromDelimitedList:[phoneNumbers substringToIndex:[phoneNumbers length] - 1] completion:^(NSObject *result){
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
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_smsRecipients = @"";
	_emailRecipients = @"";
	_inAppContacts = [NSMutableArray array];
	_selectedNonAppContacts = [NSMutableArray array];
	_selectedInAppContacts = [NSMutableArray array];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Friends"];
	[self.view addSubview:headerView];
	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
//	[headerView addButton:[[HONMessagesButtonView alloc] initWithTarget:self action:@selector(_goMessages)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	
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
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
		[self _goRegistration];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRegistration {
	[[Mixpanel sharedInstance] track:@"Register User"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[Mixpanel sharedInstance] track:@"Start First Run"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {}];
}

- (void)_goProfile {
	[[Mixpanel sharedInstance] track:@"Friends - Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goMessages {
	[[Mixpanel sharedInstance] track:@"Friends - Messages" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController pushViewController:[[HONMessagesViewController alloc] init] animated:YES];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Friends - Create Volley"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - Notifications
- (void)_showFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _showFirstRun <|::");
	
	[self _goRegistration];
}

- (void)_showHomeTutorial:(NSNotification *)notification {
	NSLog(@"::|> _showHomeTutorial <|::");
	
//	if ([HONAppDelegate incTotalForCounter:@"friends"] == 0) {
//		_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:@"tutorial_home"]];
//		_tutorialView.delegate = self;
//		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialView];
//		[_tutorialView introWithCompletion:nil];
//	}
}

- (void)_selectedHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedHomeTab <|::");
	
//	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	
	if (_tutorialView != nil) {
		[_tutorialView outroWithCompletion:^(BOOL finished) {
			[_tutorialView removeFromSuperview];
			_tutorialView = nil;
		}];
	}
	
	[self _retrieveContacts];
}

- (void)_refreshHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshHomeTab <|::");
	
	if (_tableView.contentOffset.y < 150.0)
		[_tableView setContentOffset:CGPointZero animated:YES];
	
	[self _retrieveContacts];
}

- (void)_tareHomeTab:(NSNotification *)notification {
	NSLog(@"::|> tareHomeTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
	
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[_tableView setContentOffset:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) animated:NO];
}


#pragma mark - UI Presentation
- (void)_checkInviteComplete {
	if (_inviteTypeCounter == _inviteTypeTotal) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	}
}


#pragma mark - TutorialViewController Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[[Mixpanel sharedInstance] track:@"Verify - Close Tutorial" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewTakeAvatar:(HONTutorialView *)tutorialView {
	[[Mixpanel sharedInstance] track:@"Verify - Tutorial Take Avatar" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}


#pragma mark - InviteUserViewCell Delegates
- (void)inviteUserViewCell:(HONInviteUserViewCell *)cell user:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected {
	if (isSelected){
		[[Mixpanel sharedInstance] track:@"Friends - Select In App Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"contact", nil]];
		
		[_selectedInAppContacts addObject:userVO];
		
	} else {
		[[Mixpanel sharedInstance] track:@"Friends - Deselect In App Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"contact", nil]];
		
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


#pragma mark - AddContactCell Delegates
- (void)addContactViewCell:(HONAddContactViewCell *)cell user:(HONContactUserVO *)userVO toggleSelected:(BOOL)isSelected {
	if (isSelected) {
		[[Mixpanel sharedInstance] track:@"Friends - Select Non App Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%@ - %@", userVO.fullName, (userVO.isSMSAvailable) ? userVO.mobileNumber : userVO.email], @"contact", nil]];
		
		[_selectedNonAppContacts addObject:userVO];
	} else {
		[[Mixpanel sharedInstance] track:@"Friends - Deselect Non App Contact"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
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
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	label.textColor = [[HONColorAuthority sharedInstance] honGreenTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"Friends on Selfieclub" : @"Invite contacts";
	[headerImageView addSubview:label];
	
	return (headerImageView);
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
		
		for (HONTrivialUserVO *vo in [HONAppDelegate followingListWithRefresh:NO]) {
			if (cell.userVO.userID == vo.userID) {
				[cell toggleSelected:YES];
				break;
			}
		}
		
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		return (cell);
		
	} else {
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
	
	
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
}

@end
