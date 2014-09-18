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
#import "HONTabBannerView.h"
#import "HONRegisterViewController.h"
#import "HONInsetOverlayView.h"
#import "HONSelfieCameraViewController.h"
#import "HONCreateClubViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONUserProfileViewController.h"
#import "HONInviteClubsViewController.h"
#import "HONInviteContactsViewController.h"
#import "HONContactsSearchViewController.h"
#import "HONClubTimelineViewController.h"
#import "HONPostStatusUpdateViewController.h"


@interface HONContactsTabViewController () <HONInsetOverlayViewDelegate, HONTabBannerViewDelegate, HONSelfieCameraViewControllerDelegate, HONUserToggleViewCellDelegate>
@property (nonatomic, strong) HONInsetOverlayView *insetOverlayView;
//@property (nonatomic, strong) HONTabBannerView *tabBannerView;
@property (nonatomic, strong) HONActivityHeaderButtonView *activityHeaderView;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;
@property (nonatomic, strong) HONContactUserVO *selectedContactUserVO;
@end


@implementation HONContactsTabViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedContactsTab:) name:@"SELECTED_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareContactsTab:) name:@"TARE_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshContactsTab:) name:@"REFRESH_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshContactsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFirstRun:) name:@"SHOW_FIRST_RUN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_completedFirstRun:) name:@"COMPLETED_FIRST_RUN" object:nil];
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
- (void)_generateClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] createClubWithTitle:vo.clubName withDescription:vo.blurb withImagePrefix:vo.coverImagePrefix completion:^(NSDictionary *result) {}];
}

- (void)_retrieveLocalSchoolClubs {
	[[HONAPICaller sharedInstance] retrieveLocalSchoolTypeClubsWithAreaCode:[[HONDeviceIntrinsics sharedInstance] areaCodeFromPhoneNumber] completion:^(NSDictionary *result) {
		NSMutableArray *schools = [NSMutableArray array];
		for (NSDictionary *club in [result objectForKey:@"clubs"]) {
			NSMutableDictionary *dict = [club mutableCopy];
			[dict setValue:@"HIGH_SCHOOL" forKey:@"club_type"];
			[schools addObject:dict];
		}
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"high_schools"] != nil)
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"high_schools"];
		
		[[NSUserDefaults standardUserDefaults] setObject:[schools copy] forKey:@"high_schools"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
}

#pragma mark - Data Handling

#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_activityHeaderView = [[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)];
	[_headerView setTitle:@""];  //@"Friends"];
	//[_headerView addButton:_activityHeaderView];
	//[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	
	_searchBarView.userInteractionEnabled = NO;
	
	//Go to Timeline
	//[_headerView addButton:[[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goTimeline)]];
	//[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	searchButton.frame = _searchBarView.frame;
	[searchButton addTarget:self action:@selector(_goContactsSearch) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:searchButton];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] == 0)
		[self _goRegistration];
	
	else {
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
		
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			[[HONClubAssistant sharedInstance] writeUserClubs:result];
			
			__block int cnt = 0;
			[[[HONClubAssistant sharedInstance] suggestedClubs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *fisnished) {
				HONUserClubVO *vo = (HONUserClubVO *)obj;
				[self performSelector:@selector(_generateClub:) withObject:vo afterDelay:cnt * 0.0];
				cnt++;
			}];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"high_schools"] == nil)
				[self _retrieveLocalSchoolClubs];
		}];
	}
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewWillAppear:animated];
	
//	if ([HONAppDelegate totalForCounter:@"background"] >= 3 && _tabBannerView == nil) {
//		[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom + 65.0, _tableView.contentInset.right)];
//		
//		_tabBannerView = [[HONTabBannerView alloc] init];
//		_tabBannerView.frame = CGRectOffset(_tabBannerView.frame, 0.0, _tabBannerView.frame.size.height);
//		_tabBannerView.delegate = self;
//		[self.view addSubview:_tabBannerView];
//		
//		[UIView animateWithDuration:0.250 delay:0.667
//			 usingSpringWithDamping:0.750 initialSpringVelocity:0.333
//							options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
//						 animations:^(void) {
//							 _tabBannerView.frame = CGRectOffset(_tabBannerView.frame, 0.0, -_tabBannerView.frame.size.height);
//						 } completion:^(BOOL finished) {
//						 }];
//	}
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidAppear:animated];
	
	NSLog(@"friendsTab_total:[%d]", [HONAppDelegate totalForCounter:@"friendsTab"]);
	[_activityHeaderView updateActivityBadge];

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
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPostStatusUpdateViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goContactsSearch {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONContactsSearchViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_showFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _showFirstRun <|::");
	
	[self _goRegistration];
}

- (void)_completedFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _completedFirstRun <|::");
	
	NSLog(@"%@._completedFirstRun - ABAddressBookGetAuthorizationStatus() = [%@]", self.class, (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"NotDetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"Denied" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"Authorized" : @"UNKNOWN");
	[self _submitPhoneNumberForMatching];
	
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
		[super _retrieveDeviceContacts];
	
	else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
		[super _promptForAddressBookPermission];
		
	} else
		[super _promptForAddressBookAccess];
	
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"intro_modal"] isEqualToString:@"YES"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"intro_modal"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		NSLog(@"INTRO MODAL TO BE DISPLAYED ON FIRST RUN -> (YES)");
	}
	[self _goCreateChallenge];
}

- (void)_selectedContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedContactsTab <|::");
	[_activityHeaderView updateActivityBadge];
}

- (void)_refreshContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshContactsTab <|::");
	
	_headerRows = [NSMutableArray array];
	_headerRows = [NSMutableArray arrayWithObjects:[HONTrivialUserVO userWithDictionary:@{@"id"			: @"-1",
																						  @"alt_id"		: @"-1",
																						  @"username"	: @"",
																						  @"img_url"	: @""}], [HONTrivialUserVO userWithDictionary:@{@"id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																																						@"alt_id"		: [[HONDeviceIntrinsics sharedInstance] phoneNumber],
																																						@"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],																																							@"img_url"		: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]}], nil];
	
	
	[_activityHeaderView updateActivityBadge];
	
	[self _submitPhoneNumberForMatching];
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
		_tableViewDataSource = HONContactsTableViewDataSourceAddressBook;
		[self _retrieveDeviceContacts];
		
	} else
		_tableViewDataSource = HONContactsTableViewDataSourceMatchedUsers;
	
//	if ([_cells count] > 0)
//		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
//	[self _submitPhoneNumberForMatching];
//	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
//		[super _retrieveDeviceContacts];
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


#pragma mark - InsetOverlay Delegates
- (void)insetOverlayViewDidClose:(HONInsetOverlayView *)view {
	NSLog(@"[*:*] insetOverlayViewDidClose");
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Friends Tab - Review Overlay Close"];
	
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
	}];
}

- (void)insetOverlayViewDidReview:(HONInsetOverlayView *)view {
	NSLog(@"[*:*] insetOverlayViewDidReview");
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Friends Tab - Review Overlay Acknowledge"];
	
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]];
	}];
}

- (void)insetOverlayViewDidInvite:(HONInsetOverlayView *)view {
	NSLog(@"[*:*] insetOverlayViewDidInvite");
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Friends Tab - Invite Overlay Acknowledge"];
	
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}];
}


#pragma mark - SelfieCameraViewController Delegates
- (void)selfieCameraViewControllerDidDismissByInviteOverlay:(HONSelfieCameraViewController *)viewController {
	NSLog(@"[*:*] selfieCameraViewControllerDidDismissByInviteOverlay");
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - TabBannerView Delegates
//- (void)tabBannerView:(HONTabBannerView *)bannerView joinAreaCodeClub:(HONUserClubVO *)clubVO {
//	NSLog(@"[[*:*]] tabBannerView:joinAreaCodeClub:[%@]", clubVO.clubName);
//	
//	_selectedClubVO = clubVO;
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
//}
//
//- (void)tabBannerView:(HONTabBannerView *)bannerView joinFamilyClub:(HONUserClubVO *)clubVO {
//	NSLog(@"[[*:*]] tabBannerView:joinFamilyClub:[%d - %@]", clubVO.clubID, clubVO.clubName);
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
//}
//
//- (void)tabBannerView:(HONTabBannerView *)bannerView joinSchoolClub:(HONUserClubVO *)clubVO {
//	NSLog(@"[[*:*]] tabBannerView:joinSchoolClub:[%d - %@]", clubVO.clubID, clubVO.clubName);
//		
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];

//	_selectedClubVO = clubVO;
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//														message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
//													   delegate:self
//											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//											  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
//	[alertView setTag:2];
//	[alertView show];
//}
//
//- (void)tabBannerView:(HONTabBannerView *)bannerView createBaeClub:(HONUserClubVO *)clubVO {
//	NSLog(@"[[*:*]] tabBannerView:createBaeClub:[%d - %@]", clubVO.clubID, clubVO.clubName);
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
//}
//
//- (void)tabBannerViewInviteContacts:(HONTabBannerView *)bannerView {
//	NSLog(@"[[*:*]] tabBannerViewInviteContacts");
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] userSignupClub] viewControllerPushed:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:^(void) {
//	}];
//}


#pragma mark - UserToggleViewCell Delegates
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[[*:*]] userToggleViewCell:didSelectContactUser");
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Friends Tab - Invite Friend"
									withContactUser:contactUserVO];
	
	[super userToggleViewCell:viewCell didSelectContactUser:contactUserVO];
	
	_selectedContactUserVO = contactUserVO;
	
	NSString *emojis = @"";
	for (NSString *emoji in [[NSUserDefaults standardUserDefaults] objectForKey:@"last_emojis"])
		emojis = [emojis stringByAppendingString:emoji];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Want to send %@ you status update?", _selectedContactUserVO.fullName]
														message:emojis
														delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
	[alertView setTag:3];
	[alertView show];
}

- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[[*:*]] userToggleViewCell:didDeselectContactUser");
	[super userToggleViewCell:viewCell didDeselectContactUser:contactUserVO];
	
	[viewCell toggleSelected:NO];
}


#pragma mark - TableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	HONUserToggleViewCell *cell = (HONUserToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"[[- cell.clubVO:[%@]", cell.clubVO);
	
	if (cell.clubVO != nil) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Main View - Row Tap %@ Status", (cell.clubVO.clubID == [[HONClubAssistant sharedInstance] userSignupClub].clubID) ? @"My" : @"Member"]
										   withUserClub:cell.clubVO];
		
		
		if ([cell.clubVO.submissions count] != 0) {
			[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:cell.clubVO atPhotoIndex:0] animated:YES];
		}
		
	} else {
		if (indexPath.section == 0 && indexPath.row == 0) {
			[self _promptForAddressBookPermission];
			
		} else if (indexPath.section == 0 && indexPath.row == 1) {
			[self _goCreateChallenge];
			
		} else if (indexPath.section == 2) {
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Main View - Row Tap Non-Member Invite"
											withContactUser:cell.contactUserVO];
			
			_selectedContactUserVO = cell.contactUserVO;
			
			NSString *emojis = @"";
			for (NSString *emoji in [[NSUserDefaults standardUserDefaults] objectForKey:@"last_emojis"])
				emojis = [emojis stringByAppendingString:emoji];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Want to send %@ you status update?", _selectedContactUserVO.fullName]
																message:emojis
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
			[alertView setTag:3];
			[alertView show];
			
			[cell toggleOnWithReset:YES];
			
		} else if ( indexPath.section == 1) {
			[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:cell.clubVO atPhotoIndex:0] animated:YES];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1) {
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] createClubWithTitle:_selectedClubVO.clubName withDescription:_selectedClubVO.blurb withImagePrefix:_selectedClubVO.coverImagePrefix completion:^(NSDictionary *result) {
				[[HONClubAssistant sharedInstance] addClub:result forKey:@"owned"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:nil];
			}];
		}
	
	} else if (alertView.tag == 2) {
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] joinClub:_selectedClubVO withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
				[[HONClubAssistant sharedInstance] addClub:result forKey:@"member"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:nil];
			}];
		}
	
	} else if (alertView.tag == 3) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Main View - Non-Member Invite Alert Prompt %@", (buttonIndex == 0) ? @"Yes" : @"No"]
																   withContactUser:_selectedContactUserVO];
		
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] inviteNonAppUsers:@[_selectedContactUserVO] toClubWithID:[[HONClubAssistant sharedInstance] userSignupClub].clubID withClubOwnerID:[[HONClubAssistant sharedInstance] userSignupClub].ownerID completion:^(NSDictionary *result) {
				[[HONContactsAssistant sharedInstance] writeContactUser:_selectedContactUserVO toInvitedClub:[[HONClubAssistant sharedInstance] userSignupClub]];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_TOTAL_UPDATED" object:nil];
			}];
			
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithContactUser:_selectedContactUserVO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:^(void) {
//			}];
		}
	}
}

@end
