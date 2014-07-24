//
//  HONContactsTabViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "NSString+DataTypes.h"

#import "KeychainItemWrapper.h"
#import "PCCandyStoreSearchController.h"
#import "PicoManager.h"

#import "HONContactsTabViewController.h"
#import "HONActivityHeaderButtonView.h"
#import "HONUserToggleViewCell.h"
#import "HONCreateSnapButtonView.h"
#import "HONRegisterViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONUserProfileViewController.h"
#import "HONInviteClubsViewController.h"

@interface HONContactsTabViewController () <HONUserToggleViewCellDelegate>
@end


@implementation HONContactsTabViewController

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


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	[_headerView setTitle:@"Friends"];
	[_headerView addButton:[[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
	NSString *passedRegistration = [keychain objectForKey:CFBridgingRelease(kSecAttrAccount)];
	
//	[[[UIAlertView alloc] initWithTitle:@"Passed 1st Run"
//								message:passedRegistration
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
//	
	if ([passedRegistration length] == 0)
		[self _goRegistration];
	
	
	PicoManager *picoManager = [PicoManager sharedManager];
	[picoManager registerStoreWithAppId:@"1df5644d9e94"
								 apiKey:@"8Xzg4rCwWpwHfNCPLBvV"];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"picocandy"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"picocandy"];
	
	NSLog(@"PICOCANDY:[%@]", [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:@"free"]);
	
	NSMutableArray *stickers = [NSMutableArray array];
	PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
	for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:@"free"]) {
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
			NSLog(@"///// fetchStickerPackInfo:[%d][%@] /////", success, contentGroup);
			
			[contentGroup.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				PCContent *content = (PCContent *)obj;
				NSLog(@"content.image:[%@][%@][%@] (%@)", content.medium_image, content.medium_image, content.large_image, content.name);
				
				[stickers addObject:@{@"id"		: content.content_id,
									  @"name"	: content.name,
									  @"price"	: @"0",
									  @"img"	: content.large_image}];
				
				[[NSUserDefaults standardUserDefaults] setObject:[stickers copy] forKey:@"picocandy"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}];
		}];
	}
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
	
	if ([HONAppDelegate totalForCounter:@"friendsTab"] == 0 && ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
//		[[[UIAlertView alloc] initWithTitle:@"Friends Tip"
//									message:@"Allow access to your Contact List for even more friends!"
//								   delegate:nil
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil] show];
	}
	
	NSLog(@"ABAddressBookGetAuthorizationStatus() = [%@]", (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"kABAuthorizationStatusNotDetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"kABAuthorizationStatusDenied" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"kABAuthorizationStatusAuthorized" : @"OTHER");
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
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {}];
}

- (void)_goProfile {
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goCreateChallenge {
	
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
}

- (void)_selectedContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedContactsTab <|::");
}

- (void)_refreshContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshContactsTab <|::");
	
	if (_tableView.contentOffset.y < 150.0)
		[_tableView setContentOffset:CGPointZero animated:YES];
	
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
		[self _retrieveDeviceContacts];
	
	else
		[self _submitPhoneNumberForMatching];
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
- (void)_updateDeviceContactsWithMatchedUsers {
	[super _updateDeviceContactsWithMatchedUsers];
}


#pragma mark - UserToggleViewCell Delegates
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell showProfileForTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[[*:*]] userToggleViewCell:showProfileForTrivialUser");
	
	[super userToggleViewCell:viewCell showProfileForTrivialUser:trivialUserVO];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:trivialUserVO.userID] animated:YES];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[[*:*]] userToggleViewCell:didSelectContactUser");
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Friend Row Tap"];
	[super userToggleViewCell:viewCell didSelectContactUser:contactUserVO];
	
	if (contactUserVO.contactType == HONContactTypeUnmatched)
		[self _inviteNonAppContact:contactUserVO toClub:_userClubVO];
	
	else
		[self _inviteInAppContact:[HONTrivialUserVO userFromContactVO:contactUserVO] toClub:_userClubVO];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithContactUser:contactUserVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[[*:*]] userToggleViewCell:didSelectTrivialUser");
	[super userToggleViewCell:viewCell didSelectTrivialUser:trivialUserVO];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithTrivialUser:trivialUserVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
	
	[self _inviteInAppContact:trivialUserVO toClub:_userClubVO];
	
}


#pragma mark - TableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"[[ cell.contactUserVO.userID:[%d]", cell.contactUserVO.userID);
	NSLog(@"[[- cell.trivialUserVO.userID:[%d]", cell.trivialUserVO.userID);
	
	if (_tableViewDataSource != HONContactsTableViewDataSourceMatchedUsers || cell.trivialUserVO.userID > 0) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithContactUser:cell.contactUserVO]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

@end
