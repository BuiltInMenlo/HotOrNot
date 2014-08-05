//
//  HONContactsTabViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "NSString+DataTypes.h"

#import "KeychainItemWrapper.h"

#import "HONContactsTabViewController.h"
#import "HONActivityHeaderButtonView.h"
#import "HONUserToggleViewCell.h"
#import "HONCreateSnapButtonView.h"
#import "HONRegisterViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONUserProfileViewController.h"
#import "HONInviteClubsViewController.h"
#import "HONInsetOverlayView.h"

@interface HONContactsTabViewController () <HONInsetOverlayViewDelegate, HONUserToggleViewCellDelegate>
@property (nonatomic, strong) HONInsetOverlayView *insetOverlayView;
@end


@implementation HONContactsTabViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedContactsTab:) name:@"SELECTED_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareContactsTab:) name:@"TARE_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshContactsTab:) name:@"REFRESH_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshContactsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFirstRun:) name:@"SHOW_FIRST_RUN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSuggestionsOverlay:) name:@"SHOW_SUGGESTIONS_OVERLAY" object:nil];
	}
	
	return (self);
}


#pragma mark -
static NSString * const kSelfie = @"selfie";
static NSString * const kMMS = @"mms";
static NSString * const kSelfPic = @"self pic";
static NSString * const kPhoto = @"photo";
static NSString * const kFast = @"fast";
static NSString * const kTextFree = @"text free";
static NSString * const kQuick = @"quick";
static NSString * const kEmoticon = @"emoticon";
static NSString * const kSnap = @"snap";
static NSString * const kSelca = @"selca";
static NSString * const kSelfiesticker = @"selfiesticker";
static NSString * const kMMSFree = @"mmsfree";
static NSString * const kEmoji = @"emoji";
static NSString * const kSticker = @"sticker";
static NSString * const kCamera = @"camera";

#pragma mark -
#pragma mark - Data Calls


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	[_headerView setTitle:NSLocalizedString(@"header_friends", nil)];  //@"Friends"];
	[_headerView addButton:[[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] == 0)
		[self _goRegistration];
	
	else
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidAppear:animated];
	
#if __FORCE_SUGGEST__ == 1
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] != 0)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUGGESTIONS_OVERLAY" object:nil];
#endif
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

- (void)_showSuggestionsOverlay:(NSNotification *)notification {
	NSLog(@"::|> _showSuggestionsOverlay <|::");
	if (_insetOverlayView == nil) {
		_insetOverlayView = [[HONInsetOverlayView alloc] initAsType:HONInsetOverlayViewTypeSuggestions];
		_insetOverlayView.delegate = self;
		
		[[HONScreenManager sharedInstance] appWindowAdoptsView:_insetOverlayView];
		[_insetOverlayView introWithCompletion:nil];
	}
}

- (void)_selectedContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedContactsTab <|::");
}

- (void)_refreshContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshContactsTab <|::");
	
	if ([_cells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	[self _submitPhoneNumberForMatching];
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
		[self _retrieveDeviceContacts];
}

- (void)_tareContactsTab:(NSNotification *)notification {
	NSLog(@"::|> tareContactsTab <|::");
	
	if ([_cells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - UI Presentation
- (void)_updateDeviceContactsWithMatchedUsers {
	[super _updateDeviceContactsWithMatchedUsers];
}


#pragma mark - InsetOverlayView Delegates
- (void)insetOverlayViewDidClose:(HONInsetOverlayView *)view {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Friends Tab - Suggestions Overlay Close"];
	
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
		
		[self _submitPhoneNumberForMatching];
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
			[self _retrieveDeviceContacts];
	}];
}

- (void)insetOverlayViewDidAccessContents:(HONInsetOverlayView *)view {
	NSLog(@"[*:*] insetOverlayViewDidAccessContents:(%ld)", ABAddressBookGetAuthorizationStatus());
	
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
		
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
			[self _promptForAddressBookPermission];
		
		else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
			[self _retrieveDeviceContacts];
		
		else
			[self _promptForAddressBookAccess];
	}];
}

- (void)insetOverlayView:(HONInsetOverlayView *)view createSuggestedClub:(HONUserClubVO *)clubVO {
	NSLog(@"[*:*] insetOverlayView:createSuggestedClub:(%@ - %@)", clubVO.clubName, clubVO.blurb);
	
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
		
		[[HONAPICaller sharedInstance] createClubWithTitle:clubVO.clubName withDescription:clubVO.blurb withImagePrefix:clubVO.coverImagePrefix completion:^(NSDictionary *result) {
			[self _submitPhoneNumberForMatching];
			if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
				[self _retrieveDeviceContacts];
		}];
	}];
}

- (void)insetOverlayView:(HONInsetOverlayView *)view thresholdClub:(HONUserClubVO *)clubVO {
	NSLog(@"[*:*] insetOverlayView:createSuggestedClub:(%@ - %@)", clubVO.clubName, clubVO.blurb);
	
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
		
		if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] < [HONAppDelegate clubInvitesThreshold]) {
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_lockedClub_t", nil)
										message:[NSString stringWithFormat:NSLocalizedString(@"alert_lockedClub_m", nil), [HONAppDelegate clubInvitesThreshold], clubVO.clubName]
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
		} else {
			[[HONAPICaller sharedInstance] joinClub:clubVO withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			}];
			
//			[[HONAPICaller sharedInstance] createClubWithTitle:clubVO.clubName withDescription:clubVO.blurb withImagePrefix:clubVO.coverImagePrefix completion:^(NSDictionary *result) {
//				[self _submitPhoneNumberForMatching];
//				if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
//					[self _retrieveDeviceContacts];
//			}];
		}
	}];
}

- (void)insetOverlayViewCopyPersonalClub:(HONInsetOverlayView *)view {
	NSLog(@"[*:*] insetOverlayViewCopyPersonalClub");
	
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
		
		[self _submitPhoneNumberForMatching];
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
			[self _retrieveDeviceContacts];
	}];
	
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = [NSString stringWithFormat:@"I have created the Selfieclub %@! Tap to join: http://joinselfie.club/%@/%@", [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""], [[HONAppDelegate infoForUser] objectForKey:@"username"], [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""]];
	
//	[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Your %@ has been copied!", [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""]]
//								message:[NSString stringWithFormat:@"\nPaste this URL anywhere to have your friends join!"]											   delegate:nil
//					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//					  otherButtonTitles:nil] show];
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
	
	[viewCell toggleSelected:NO];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithContactUser:contactUserVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[[*:*]] userToggleViewCell:didSelectTrivialUser");
	[super userToggleViewCell:viewCell didSelectTrivialUser:trivialUserVO];
	
	[viewCell toggleSelected:NO];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithTrivialUser:trivialUserVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - TableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"[[- cell.contactUserVO.userID:[%d]", cell.contactUserVO.userID);
	NSLog(@"[[- cell.trivialUserVO.userID:[%d]", cell.trivialUserVO.userID);
	
	
	if (_tableViewDataSource == HONContactsTableViewDataSourceMatchedUsers || _tableViewDataSource == HONContactsTableViewDataSourceSearchResults) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithTrivialUser:cell.trivialUserVO]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:^(void) {
			[cell invertSelected];
		}];
	
	} else if (_tableViewDataSource == HONContactsTableViewDataSourceAddressBook) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithContactUser:cell.contactUserVO]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:^(void) {
			[cell invertSelected];
		}];
	}	
}

@end
