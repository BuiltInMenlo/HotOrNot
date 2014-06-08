//
//  HONContactsTabViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "NSString+DataTypes.h"

#import "HONContactsTabViewController.h"

#import "HONTutorialView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONRegisterViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONUserProfileViewController.h"

@interface HONContactsTabViewController () <HONTutorialViewDelegate>
@property (nonatomic, strong) HONTutorialView *tutorialView;
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
	
//	[[HONAPICaller sharedInstance] followUserWithUserID:2394 completion:nil]; //
//	[[HONAPICaller sharedInstance] followUserWithUserID:11822 completion:nil];
//	[[HONAPICaller sharedInstance] followUserWithUserID:9419 completion:nil];

//	[[HONAPICaller sharedInstance] stopFollowingUserWithUserID:2394 completion:nil];
//	[[HONAPICaller sharedInstance] followUserWithUserID:86493 completion:nil];
	
	[_headerView setTitle:@"Friends"];
	[_headerView addButton:[[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	
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
	
	if ([HONAppDelegate totalForCounter:@"friendsTab"] == 0 && ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
		[[[UIAlertView alloc] initWithTitle:@"Friends Tip"
									message:@"Allow access to your Contact List for even more friends!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
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
	
//	if ([HONAppDelegate incTotalForCounter:@"friendsTab"] == 0) {
//		_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:@"tutorial_contacts"]];
//		_tutorialView.delegate = self;
//
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialView];
//		[_tutorialView introWithCompletion:nil];
//	}
}

- (void)_selectedContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedContactsTab <|::");
	
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	
	if (_tutorialView != nil) {
		[_tutorialView outroWithCompletion:^(BOOL finished) {
			[_tutorialView removeFromSuperview];
			_tutorialView = nil;
		}];
	}
}

- (void)_refreshContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshContactsTab <|::");
	
	if (_tableView.contentOffset.y < 150.0)
		[_tableView setContentOffset:CGPointZero animated:YES];
	
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
		[super _retrieveDeviceContacts];
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
	_inAppContacts = [NSMutableArray array];
	for (HONTrivialUserVO *trivialUserVO in _inAppContacts) {
		for (HONContactUserVO *contactUserVO in _deviceContacts) {
			if ([trivialUserVO.username isEqualToString:contactUserVO.fullName]) {
				break;
			}
		}
	}
	
	[_tableView reloadData];
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
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


@end
