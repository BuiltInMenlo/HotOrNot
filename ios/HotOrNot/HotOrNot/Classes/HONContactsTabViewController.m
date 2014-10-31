//
//  HONContactsTabViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "NSString+DataTypes.h"

#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"

#import "HONContactsTabViewController.h"
#import "HONHeaderView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONComposeButtonView.h"
#import "HONTableView.h"
#import "HONTableHeaderView.h"
#import "HONTableViewBGView.h"
#import "HONRefreshControl.h"
#import "HONClubViewCell.h"
#import "HONRegisterViewController.h"
#import "HONComposeViewController.h"
#import "HONCreateClubViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONUserProfileViewController.h"
#import "HONContactsSearchViewController.h"
#import "HONClubTimelineViewController.h"

@interface HONContactsTabViewController () <HONTableViewBGViewDelegate, HONClubViewCellDelegate>
@property (nonatomic, strong) HONActivityHeaderButtonView *activityHeaderView;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;
@property (nonatomic, strong) NSMutableArray *seenClubs;
@property (nonatomic, strong) NSMutableArray *unseenClubs;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) HONTableViewBGView *emptyClubsBGView;
@property (nonatomic, strong) HONTableViewBGView *accessContactsBGView;
@property (nonatomic) int joinedTotalClubs;
@end


@implementation HONContactsTabViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeFriendsTab;
		_viewStateType = HONStateMitigatorViewStateTypeFriends;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_selectedContactsTab:)
													 name:@"SELECTED_CONTACTS_TAB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_tareContactsTab:)
													 name:@"TARE_CONTACTS_TAB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshContactsTab:)
													 name:@"REFRESH_CONTACTS_TAB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshContactsTab:)
													 name:@"REFRESH_ALL_TABS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_showFirstRun:)
													 name:@"SHOW_FIRST_RUN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_completedFirstRun:)
													 name:@"COMPLETED_FIRST_RUN" object:nil];
	}
	
	return (self);
}

- (void)dealloc {
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[self destroy];
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


#pragma mark - Public APIs
- (void)destroy {
	[super destroy];
}

#pragma mark - Data Calls
- (void)_retrieveClubs {
	[_tableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubViewCell *cell = (HONClubViewCell *)obj;
		[UIView animateKeyframesWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			cell.alpha = 0.0;
		} completion:^(BOOL finished) {
		}];
	}];
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		[[HONClubAssistant sharedInstance] writeUserClubs:result];
		
		_joinedTotalClubs = (_joinedTotalClubs == 0) ? [[result objectForKey:@"pending"] count] : _joinedTotalClubs;
		
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			if ([key isEqualToString:@"owned"] || [key isEqualToString:@"member"]) {
				for (NSDictionary *dict in [result objectForKey:key]) {
					if ([[dict objectForKey:@"submissions"] count] == 0 && [[dict objectForKey:@"pending"] count] == 0)
						continue;
					
					HONUserClubVO *clubVO = [HONUserClubVO clubWithDictionary:dict];
					if ([clubVO.submissions count] == 0)
						continue;
					
					HONClubPhotoVO *clubPhotoVO = (HONClubPhotoVO *)[clubVO.submissions firstObject];
					
//					NSLog(@"SEEN UPDATES:[%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"seen_updates"]);
//					if ([[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSinceDate:clubPhotoVO.addedDate] >= (3600 * 12)) {
					if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"seen_updates"] objectForKey:[@"" stringFromInt:clubPhotoVO.challengeID]] intValue] == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
						[_seenClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
					
					} else {
						[_unseenClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
					}
				}
				
			} else if ([key isEqualToString:@"pending"]) {
				for (NSDictionary *dict in [result objectForKey:key]) {
					[[HONAPICaller sharedInstance] joinClub:[HONUserClubVO clubWithDictionary:dict] withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
						
						if ([[result objectForKey:@"pending"] count] == 0)
							[self _retrieveClubs];
					}];
				}
				
			} else
				continue;
		}
		
		[self _didFinishDataRefresh];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeFriendsTabRefresh];
	
	[self _goReloadTableViewContents];
}

- (void)_goReloadTableViewContents {
	[_refreshControl beginRefreshing];
	
	_seenClubs = [NSMutableArray array];
	_unseenClubs = [NSMutableArray array];
	[_tableView reloadData];
	
	[self _retrieveClubs];
}

- (void)_didFinishDataRefresh {
	if (_joinedTotalClubs > 0) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Joined Clubs"
										   withProperties:@{@"joins_total"	: [@"" stringFromInt:_joinedTotalClubs]}];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You have joined %d post%@", _joinedTotalClubs, (_joinedTotalClubs == 1) ? @"" : @"s"]
															message:@""
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:nil];
		[alertView setTag:2];
		[alertView show];
		
		_joinedTotalClubs = 0;
	
	} else {
		_seenClubs = [[[[_seenClubs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			HONUserClubVO *club1VO = (HONUserClubVO *)obj1;
			HONUserClubVO *club2VO = (HONUserClubVO *)obj2;
			
			if ([[HONDateTimeAlloter sharedInstance] didDate:club1VO.updatedDate occurBerforeDate:club2VO.updatedDate])
				return ((NSComparisonResult)NSOrderedAscending);
			
			if ([[HONDateTimeAlloter sharedInstance] didDate:club2VO.updatedDate occurBerforeDate:club1VO.updatedDate])
				return ((NSComparisonResult)NSOrderedDescending);
			
			return ((NSComparisonResult)NSOrderedSame);
		}] reverseObjectEnumerator] allObjects] mutableCopy];
		
		_unseenClubs = [[[[_unseenClubs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			HONUserClubVO *club1VO = (HONUserClubVO *)obj1;
			HONUserClubVO *club2VO = (HONUserClubVO *)obj2;
			
			if ([[HONDateTimeAlloter sharedInstance] didDate:club1VO.updatedDate occurBerforeDate:club2VO.updatedDate])
				return ((NSComparisonResult)NSOrderedAscending);
			
			if ([[HONDateTimeAlloter sharedInstance] didDate:club2VO.updatedDate occurBerforeDate:club1VO.updatedDate])
				return ((NSComparisonResult)NSOrderedDescending);
			
			return ((NSComparisonResult)NSOrderedSame);
		}] reverseObjectEnumerator] allObjects] mutableCopy];
		
		_accessContactsBGView.hidden = (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized);
		_emptyClubsBGView.hidden = ([_seenClubs count] > 0 || [_unseenClubs count] > 0);
		_emptyClubsBGView.hidden = (!_accessContactsBGView.hidden) ? YES : _emptyClubsBGView.hidden;
		
		if (!_emptyClubsBGView.hidden || !_accessContactsBGView.hidden) {
			_accessContactsBGView.frame = CGRectMake(_accessContactsBGView.frame.origin.x, _tableView.contentSize.height + 5.0, _accessContactsBGView.frame.size.width, _accessContactsBGView.frame.size.height);
			_emptyClubsBGView.frame = _accessContactsBGView.frame;
			[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, kOrthodoxTableCellHeight + kTabSize.height, _tableView.contentInset.right)];
		}
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
	
	[_tableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubViewCell *cell = (HONClubViewCell *)obj;
		[UIView animateKeyframesWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			cell.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	}];
	
//	if (_progressHUD != nil) {
//		[_progressHUD hide:YES];
//		_progressHUD = nil;
//	}
	
	NSLog(@"%@._didFinishDataRefresh - ABAddressBookGetAuthorizationStatus() = [%@]", self.class, (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"NotDetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"StatusDenied" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"Authorized" : @"UNKNOWN");
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	_seenClubs = [NSMutableArray array];
	_unseenClubs = [NSMutableArray array];
		
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight))];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _tableView.frame.size.width, _tableView.frame.size.height)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
//	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
//	lpGestureRecognizer.minimumPressDuration = 0.5;
//	lpGestureRecognizer.delegate = self;
//	[_tableView addGestureRecognizer:lpGestureRecognizer];
	
	_accessContactsBGView = [[HONTableViewBGView alloc] initAsType:HONTableViewBGViewTypeAccessContacts withCaption:NSLocalizedString(@"access_contacts", @"Access your contacts.\nFind friends") usingTarget:self action:@selector(_goTableBGSelected:)];
	_accessContactsBGView.viewType = HONTableViewBGViewTypeAccessContacts;
	[_tableView addSubview:_accessContactsBGView];
	
	_emptyClubsBGView = [[HONTableViewBGView alloc] initAsType:HONTableViewBGViewTypeCreateStatusUpdate withCaption:NSLocalizedString(@"empty_contacts", @"No results found.\nCompose") usingTarget:self action:@selector(_goTableBGSelected:)];
	_accessContactsBGView.viewType = HONTableViewBGViewTypeCreateStatusUpdate;
	[_tableView addSubview:_emptyClubsBGView];
	
	
	_headerView = [[HONHeaderView alloc] initWithTitleUsingCartoGothic:@""];
	[self.view addSubview:_headerView];
	
	self.view.hidden = YES;
	
	HONComposeButtonView *composeButtonView = [[HONComposeButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)];
	[composeButtonView setFrame:CGRectOffset(composeButtonView.frame, 272.0, 0.0)];
	
	[_headerView setTitle:NSLocalizedString(@"header_friends", @"Friends")];
	_activityHeaderView = [[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)];
	[_headerView addButton:composeButtonView];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] == 0)
		[self _goRegistration];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] != 0) {
		self.view.hidden = NO;
		
		if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
			[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
			[[UIApplication sharedApplication] registerForRemoteNotifications];
		
		} else
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
	}
	
	[[HONStateMitigator sharedInstance] resetTotalCounterForType:_totalType withValue:([[HONStateMitigator sharedInstance] totalCounterForType:_totalType] - 1)];
	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);

	
//	_panGestureRecognizer.delaysTouchesBegan = NO;
//	_panGestureRecognizer.enabled = YES;
}


#pragma mark - Navigation
- (void)_goRegistration {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:^(void) {
		self.view.hidden = NO;
	}];
}

- (void)_goProfile {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Activity"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Create Status Update"
									 withProperties:@{@"src"	: @"header"}];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initAsNewStatusUpdate]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	NSLog(@"gestureRecognizer.state:[%@]", (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"Began" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"Canceled" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"Ended" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"Failed" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"Possible" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"Recognized" : @"UNKNOWN");
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
	
	NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:_tableView]];
	
	if (indexPath != nil) {
		HONClubViewCell *cell = (HONClubViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
		
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//			NSLog(@"STATUS UPDATE:[%@]", cell.statusUpdateVO.subjectNames);
			HONClubTimelineViewController *clubTimelineViewController = [[HONClubTimelineViewController alloc] initWithClub:cell.clubVO atPhotoIndex:0];
			//clubTimelineViewController.view.frame = CGRectMake(0.0, 0.0, clubTimelineViewController.view.frame.size.width, clubTimelineViewController.view.frame.size.height + 20.0); //CGRectOffset(clubTimelineViewController.view.frame, 0.0, 20.0);
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:clubTimelineViewController];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:NO completion:nil];
			
//			[self.navigationController pushViewController:clubTimelineViewController animated:NO];
			[self.view addSubview:clubTimelineViewController.view];
//			[self performSelector:@selector(_goFinishLongPress) withObject:nil afterDelay:0.25];
		
		} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
			[[self.view.subviews lastObject] removeFromSuperview];
		}
	}
}

- (void)_goSelectClub:(HONUserClubVO *)clubVO {
	if (!_isPushing) {
		_isPushing = YES;
		
		[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"Friends Tab - %@", ([clubVO.submissions count] > 0) ? @"Club Timeline" : @"Create Status Update"]
											 withUserClub:clubVO];
		
		if ([clubVO.submissions count] > 0) {
			HONClubTimelineViewController *clubTimelineViewController = [[HONClubTimelineViewController alloc] initWithClub:clubVO atPhotoIndex:0];
			[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:clubVO atPhotoIndex:0] animated:[[HONAnimationOverseer sharedInstance] isAnimationEnabledForViewControllerPushSegue:clubTimelineViewController]];
		
		} else {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:clubVO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:[[HONAnimationOverseer sharedInstance] isAnimationEnabledForViewControllerModalSegue:navigationController.presentingViewController] completion:nil];
		}
	}
}

- (void)_goTableBGSelected:(id)sender {
	NSLog(@"[:|:] _goTableBGSelected:");
	
	UIButton *button = (UIButton *)sender;
	if (button.tag == HONTableViewBGViewTypeAccessContacts) {
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
			[self _promptForAddressBookPermission];
		
		else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
			[self _promptForAddressBookAccess];
		
	} else if (button.tag == HONTableViewBGViewTypeCreateStatusUpdate) {
		[self _goCreateChallenge];
	}
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	HONClubViewCell *cell = (HONClubViewCell *)[_tableView cellForRowAtIndexPath:[_tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:_tableView]]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Club Row Swipe"
										 withUserClub:cell.clubVO];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -1500) {
		[self _goSelectClub:cell.clubVO];
	}
}


#pragma mark - Notifications
- (void)_showFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _showFirstRun <|::");
	
	[self _goRegistration];
}

- (void)_completedFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _completedFirstRun <|::");
	
	NSLog(@"%@._completedFirstRun - ABAddressBookGetAuthorizationStatus() = [%@]", self.class, (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"NotDetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"Denied" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"Authorized" : @"UNKNOWN");
	
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
		[self _promptForAddressBookPermission];
	
	else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
		[self _promptForAddressBookAccess];
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)_selectedContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedContactsTab <|::");
	
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:_totalType];
	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
	
	[self _goReloadTableViewContents];
	
	if ([notification.object isEqualToString:@"Y"] && [_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)_refreshContactsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshContactsTab <|::");
	
	[self _goReloadTableViewContents];
	
	if ([notification.object isEqualToString:@"Y"] && [_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)_tareContactsTab:(NSNotification *)notification {
	NSLog(@"::|> tareContactsTab <|::");
	
	if ([_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - UI Presentation
- (void)_promptForAddressBookAccess {
	[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ok_access", @"We need your OK to access the address book.")
								message:NSLocalizedString(@"grant_access", @"Flip the switch in Settings -> Privacy -> Contacts -> Selfieclub to grant access.")
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
					  otherButtonTitles:nil] show];
}

- (void)_promptForAddressBookPermission {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"allow_access", @"Allow Access to contacts?")
														message:nil
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
	[alertView setTag:0];
	[alertView show];
}


#pragma mark - TableViewBGView Delegates
- (void)tableViewBGViewDidSelect:(HONTableViewBGView *)bgView {
	NSLog(@"[*:*] tableViewBGViewDidSelect [*:*]");
	
	if (bgView.viewType == HONTableViewBGViewTypeAccessContacts) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Access Contacts"
										 withProperties:@{@"access"	: (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"undetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"authorized" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"denied" : @"other"}];
		
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
			[self _promptForAddressBookPermission];
		
		else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
			[self _promptForAddressBookAccess];
	
	} else if (bgView.viewType == HONTableViewBGViewTypeCreateStatusUpdate) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Create Status Update"
										 withProperties:@{@"src"	: @"text"}];
		[self _goCreateChallenge];
	}
}


#pragma mark - ClubViewCell Delegates
- (void)clubViewCell:(HONClubViewCell *)viewCell didSelectClub:(HONUserClubVO *)clubVO {
	NSLog(@"[*:*] clubViewCell:didSelectClub");
	
	[self _goSelectClub:clubVO];
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_unseenClubs count] : [_seenClubs count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubViewCell alloc] initAsCellType:HONClubViewCellTypeBlank];
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		HONUserClubVO *vo = (HONUserClubVO *)[_unseenClubs objectAtIndex:indexPath.row];
		cell.clubVO = vo;
		
	} else  {
		HONUserClubVO *vo = (HONUserClubVO *)[_seenClubs objectAtIndex:indexPath.row];
		cell.clubVO = vo;
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	cell.delegate = self;
	
	if (!tableView.decelerating)
		[cell toggleImageLoading:YES];
	
	return (cell);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:(section == 0) ? @"Recent" : @"Seen"]);
}



#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONClubViewCell *cell = (HONClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"-[- cell.clubVO.clubID:[%d]", cell.clubVO.clubID);
	
	if (indexPath.section == 0) {
		HONUserClubVO *vo = (HONUserClubVO *)[_unseenClubs objectAtIndex:indexPath.row];
		NSLog(@"UNSEEN CLUB:[%@]", vo.clubName);
		[self _goSelectClub:cell.clubVO];
		
	} else {
		HONUserClubVO *vo = (HONUserClubVO *)[_seenClubs objectAtIndex:indexPath.row];
		NSLog(@"SEEN CLUB:[%@]", vo.clubName);
		[self _goSelectClub:cell.clubVO];
	}
	
	[cell toggleOnWithReset:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubViewCell *cell = (HONClubViewCell *)obj;
		[cell toggleImageLoading:YES];
	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		NSLog(@"CONTACTS:[%d]", buttonIndex);
		if (buttonIndex == 1) {
			if (ABAddressBookRequestAccessWithCompletion) {
				ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
				NSLog(@"ABAddressBookGetAuthorizationStatus() = [%@]", (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"kABAuthorizationStatusNotDetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"kABAuthorizationStatusDenied" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"kABAuthorizationStatusAuthorized" : @"OTHER");
				
				if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
					});
					
				} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
					});
					
				} else {
				}
				
				[self _goReloadTableViewContents];
			}
		}
		
	} else if (alertView.tag == 1) {
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] createClubWithTitle:_selectedClubVO.clubName withDescription:_selectedClubVO.blurb withImagePrefix:_selectedClubVO.coverImagePrefix completion:^(NSDictionary *result) {
				[[HONClubAssistant sharedInstance] addClub:result forKey:@"owned"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:nil];
			}];
		}
	
	}  else if (alertView.tag == 2) {
		[self _goReloadTableViewContents];
	}
}

@end
