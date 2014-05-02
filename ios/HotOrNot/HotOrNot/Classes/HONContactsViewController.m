//
//  HONContactsViewController.
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "NSString+DataTypes.h"

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "TSTapstream.h"

#import "HONContactsViewController.h"

#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONTutorialView.h"
#import "HONSearchBarView.h"
#import "HONMessagesButtonView.h"
#import "HONTrivialUserVO.h"
#import "HONContactUserVO.h"
#import "HONUserClubVO.h"
#import "HONUserToggleViewCell.h"
#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONMessagesViewController.h"
#import "HONUserProfileViewController.h"

@interface HONContactsViewController () <EGORefreshTableHeaderDelegate, HONSearchBarViewDelegate, HONTutorialViewDelegate, HONUserToggleViewCellDelegate>
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) NSMutableArray *allContacts;
@property (nonatomic, strong) NSMutableArray *inAppContacts;
@property (nonatomic, strong) NSMutableArray *clubInviteContacts;
@property (nonatomic, strong) NSMutableArray *searchUsers;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *contactsBlockedImageView;
@property (nonatomic, strong) HONTutorialView *tutorialView;
@property (nonatomic, strong) NSString *smsRecipients;
@property (nonatomic, strong) NSString *emailRecipients;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, assign, readonly) HONContactsTableViewDataSource tableViewDataSource;
@property (nonatomic) int currentMatchStateCounter;
@property (nonatomic) int totalMatchStateCounter;

@property (nonatomic,retain) NSDictionary *segmentedContacts;
@property (nonatomic,retain) NSMutableArray *segmentedKeys;
@end


@implementation HONContactsViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedContactsTab:) name:@"SELECTED_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareContactsTab:) name:@"TARE_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshContactsTab:) name:@"REFRESH_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshContactsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFirstRun:) name:@"SHOW_FIRST_RUN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showContactsTutorial:) name:@"SHOW_CONTACTS_TUTORIAL" object:nil];
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
- (void)_retreiveUserClub {
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0)
			_userClubVO = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
		
		else
			_userClubVO = [HONUserClubVO clubWithDictionary:[[HONAppDelegate fpoClubDictionaries] lastObject]];
	}];
}

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
		
		_currentMatchStateCounter++;
		if (_currentMatchStateCounter == _totalMatchStateCounter) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[self _updateMatchedContacts];
		}
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
		
		_currentMatchStateCounter++;
		if (_currentMatchStateCounter == _totalMatchStateCounter) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[self _updateMatchedContacts];
		}
	}];
}

- (void)_inviteInAppContact:(HONTrivialUserVO *)trivialUserVO toClub:(HONUserClubVO *)userClubVO {
	TSTapstream *tracker = [TSTapstream instance];
	
	TSEvent *e = [TSEvent eventWithName:@"Invite Friends" oneTimeOnly:YES];
	[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"user_id"];
	[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"username"] forKey:@"username"];
	[e addValue:[@"" stringFromInt:userClubVO.clubID] forKey:@"club_id"];
	[e addValue:userClubVO.clubName forKey:@"club_name"];
	[e addValue:[@"" stringFromInt:trivialUserVO.userID] forKey:@"invite_id"];
	[e addValue:trivialUserVO.username forKey:@"invite_name"];
	[tracker fireEvent:e];
	
	[[HONAPICaller sharedInstance] inviteInAppUsers:[NSArray arrayWithObject:trivialUserVO] toClubWithID:userClubVO.clubID withClubOwnerID:userClubVO.ownerID completion:^(NSObject *result) {
	}];
}

- (void)_inviteNonAppContact:(HONContactUserVO *)contactUserVO toClub:(HONUserClubVO *)userClubVO {
	TSTapstream *tracker = [TSTapstream instance];
	
	TSEvent *e = [TSEvent eventWithName:@"Invite Friends" oneTimeOnly:YES];
	[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"user_id"];
	[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"username"] forKey:@"username"];
	[e addValue:[@"" stringFromInt:userClubVO.clubID] forKey:@"club_id"];
	[e addValue:userClubVO.clubName forKey:@"club_name"];
	[e addValue:contactUserVO.fullName forKey:@"invite_name"];
	[e addValue:(contactUserVO.isSMSAvailable) ? contactUserVO.mobileNumber : contactUserVO.email forKey:@"invite_contact"];
	[tracker fireEvent:e];
	
	[[HONAPICaller sharedInstance] inviteNonAppUsers:[NSArray arrayWithObject:contactUserVO] toClubWithID:userClubVO.clubID withClubOwnerID:userClubVO.ownerID completion:^(NSObject *result) {
	}];
}

- (void)_searchUsersWithUsername:(NSString *)username {
	_tableViewDataSource = HONContactsTableViewDataSourceSearchResults;
	_searchUsers = [NSMutableArray array];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] searchForUsersByUsername:username completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result) {
			[_searchUsers addObject:[HONTrivialUserVO userWithDictionary:@{@"id"		: [dict objectForKey:@"id"],
																		   @"username"	: [dict objectForKey:@"username"],
																		   @"img_url"	: [dict objectForKey:@"avatar_url"]}]];
		}
		
		if (_progressHUD != nil) {
			if ([_searchUsers count] == 0) {
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
				
			} else {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}


#pragma mark - Device Functions
- (void)_retrieveContacts {
	_tableViewDataSource = HONContactsTableViewDataSourceAddressBook;
	NSMutableArray *unsortedContacts = [NSMutableArray array];
	
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
		
		
		NSData *imageData = nil;
		if (ABPersonHasImageData(ref))
			imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
		
		
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
																			 @"email"	: email,
																			 @"image"	: (imageData != nil) ? imageData : UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"])}];
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
	
	_currentMatchStateCounter = 0;
	_totalMatchStateCounter = (int)([_smsRecipients length] > 0) + (int)([_emailRecipients length] > 0);
	
	if ([_smsRecipients length] > 0) {
		NSLog(@"SMS CONTACTS:[%@]", [_smsRecipients substringToIndex:[_smsRecipients length] - 1]);
		[self _sendPhoneContacts];
	}
	
	if ([_emailRecipients length] > 0) {
		NSLog(@"EMAIL CONTACTS:[%@]", [_emailRecipients substringToIndex:[_emailRecipients length] - 1]);
		[self _sendEmailContacts];
	}
	
	_allContacts = [NSMutableArray array];
	for (NSDictionary *dict in [NSArray arrayWithArray:[unsortedContacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"l_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]])
		[_allContacts addObject:[HONContactUserVO contactWithDictionary:dict]];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	_segmentedContacts = [self _populateSegmentedDictionary];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	//	[[HONAPICaller sharedInstance] followUserWithUserID:2394 completion:nil]; //
	//	[[HONAPICaller sharedInstance] followUserWithUserID:11822 completion:nil];
	//	[[HONAPICaller sharedInstance] followUserWithUserID:9419 completion:nil];
	
	//	[[HONAPICaller sharedInstance] stopFollowingUserWithUserID:2394 completion:nil];
	//	[[HONAPICaller sharedInstance] followUserWithUserID:86493 completion:nil];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_smsRecipients = @"";
	_emailRecipients = @"";
	_inAppContacts = [NSMutableArray array];
	_clubInviteContacts = [NSMutableArray array];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Friends"];
	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	HONSearchBarView *searchBarView = [[HONSearchBarView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kSearchHeaderHeight)];
	searchBarView.delegate = self;
	[self.view addSubview:searchBarView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight + kSearchHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + kSearchHeaderHeight)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_contactsBlockedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
	_contactsBlockedImageView.frame = _tableView.frame;
	_contactsBlockedImageView.hidden = YES;
	[_tableView addSubview:_contactsBlockedImageView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
		[self _goRegistration];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] != nil) {
		[self _retreiveUserClub];
		
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
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Address Book - Granted"];
				[self _retrieveContacts];
				
				// denied permission
			} else {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Address Book - Denied"];
				
				_contactsBlockedImageView.hidden = NO;
				[self _promptForAddressBookAccess];
			}
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRegistration {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Register User"];
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Start First Run"];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {}];
}

- (void)_goProfile {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Profile"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goMessages {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Messages"];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Create Volley"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - Notifications
- (void)_showFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _showFirstRun <|::");
	
	[self _goRegistration];
}

- (void)_showContactsTutorial:(NSNotification *)notification {
	NSLog(@"::|> _showContactsTutorial <|::");
	
//	if ([HONAppDelegate incTotalForCounter:@"contacts"] == 0) {
//		_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:@"tutorial_contacts"]];
//		_tutorialView.delegate = self;
//
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialView];
//		[_tutorialView introWithCompletion:nil];
//	}
}

- (void)_selectedContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedContactsTab <|::");
	
	//	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	
	if (_tutorialView != nil) {
		[_tutorialView outroWithCompletion:^(BOOL finished) {
			[_tutorialView removeFromSuperview];
			_tutorialView = nil;
		}];
	}
	
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
		[self _promptForAddressBookAccess];
	
	else
		[self _retrieveContacts];
}

- (void)_refreshContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshContactsTab <|::");
	
	if (_tableView.contentOffset.y < 150.0)
		[_tableView setContentOffset:CGPointZero animated:YES];
	
//	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
//		[self _promptForAddressBookAccess];
//	
//	else
		[self _retrieveContacts];
}

- (void)_tareContactsTab:(NSNotification *)notification {
	NSLog(@"::|> tareContactsTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
	
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[_tableView setContentOffset:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) animated:NO];
}


#pragma mark - UI Presentation
- (void)_updateMatchedContacts {
	_inAppContacts = [NSMutableArray array];
	for (HONTrivialUserVO *trivialUserVO in _inAppContacts) {
		for (HONContactUserVO *contactUserVO in _allContacts) {
			if ([trivialUserVO.username isEqualToString:contactUserVO.fullName]) {
				break;
			}
		}
	}
	
	[_tableView reloadData];
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}

- (void)_promptForAddressBookAccess {
	[[[UIAlertView alloc] initWithTitle:@"We need your OK to access the the address book."
								message:@"Flip the switch in Settings->Privacy->Contacts to grant access."
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Tutorial Close"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewTakeAvatar:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Tutorial Take Avatar"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}


#pragma mark - SearchBarHeader Delegates
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView {
	_tableViewDataSource = HONContactsTableViewDataSourceSearchResults;
	
	_searchUsers = [NSMutableArray array];
	[_tableView reloadData];
}

- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Search Users Cancel"];
	_tableViewDataSource = HONContactsTableViewDataSourceAddressBook;
	[_tableView reloadData];
}

- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Search Users Submit"
									 withProperties:@{@"query"	: searchQuery}];
	
	[self _searchUsersWithUsername:searchQuery];
}


#pragma mark - UserToggleViewCell Delegates
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell showProfileForTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Show Profile" withTrivialUser:trivialUserVO];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:trivialUserVO.userID] animated:YES];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectContactUser:(HONContactUserVO *)contactUserVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Deselect Invite Non-App Contact"
									withContactUser:contactUserVO];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Deselect Invite In-App Contact"
									withTrivialUser:trivialUserVO];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Select Invite Non-App Contact"
									withContactUser:contactUserVO];
	
	if (_userClubVO != nil)
		[self _inviteNonAppContact:contactUserVO toClub:_userClubVO];
	
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Haven't Created A Club!"
															message:@"You need to create your own club before inviting anyone."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Select Invite In-App Contact"
									withTrivialUser:trivialUserVO];
	
	if (_userClubVO != nil)
		[self _inviteInAppContact:trivialUserVO toClub:_userClubVO];
	
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Haven't Created A Club!"
															message:@"You need to create your own club before inviting anyone."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
//	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
//		[self _promptForAddressBookAccess];
//	
//	else
		[self _retrieveContacts];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [_segmentedKeys count] : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [[_segmentedContacts valueForKey:[_segmentedKeys objectAtIndex:section]] count] : [_searchUsers count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:(_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [_segmentedKeys objectAtIndex:section] : @"SEARCH RESULTS"]);
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] : nil);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		HONUserToggleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		if (cell == nil)
			cell = [[HONUserToggleViewCell alloc] init];
		
		HONContactUserVO *contactUserVO = (HONContactUserVO *)[[_segmentedContacts valueForKey:[_segmentedKeys objectAtIndex:[indexPath section]]] objectAtIndex:indexPath.row];
		cell.contactUserVO = contactUserVO;
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
		return (cell);
		
	} else {
		HONUserToggleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONUserToggleViewCell alloc] init];
			cell.trivialUserVO = (HONTrivialUserVO *)[_searchUsers objectAtIndex:indexPath.row];
		}

		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) ? 0.0 : kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		return ((cell.trivialUserVO != nil) ? indexPath : nil);
		
	} else
		return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		HONTrivialUserVO *vo = cell.trivialUserVO;
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Select Contact Row"
										withTrivialUser:vo];
		
		[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
	
	} else {
		HONTrivialUserVO *vo = [_searchUsers objectAtIndex:indexPath.row];
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Contacts - Select Search Row"
										withTrivialUser:vo];
		
		[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
	}
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


#pragma mark - Data Manip
-(NSDictionary *)_populateSegmentedDictionary {
	_segmentedKeys = [[NSMutableArray alloc] init];
	[_segmentedKeys removeAllObjects];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	for (HONContactUserVO *vo in _allContacts) {
		
		NSString *charKey = [vo.lastName substringToIndex:1];
		if (![_segmentedKeys containsObject:charKey]) {
			[_segmentedKeys addObject:charKey];
			
			NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
			[dict setValue:newSegment forKey:charKey];
		
		} else {
			NSMutableArray *prevSegment = (NSMutableArray *)[dict valueForKey:charKey];
			[prevSegment addObject:vo];
			[dict setValue:prevSegment forKey:charKey];
		}
	}
	
	return (dict);
}

@end
