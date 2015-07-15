//
//  HONHomeViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSArray+BuiltinMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSNumber+BuiltInMenlo.h"
#import "NSString+BuiltinMenlo.h"
#import "UIScrollView+BuiltInMenlo.h"

#import "KeychainItemWrapper.h"
#import "KikAPI.h"
#import "MBProgressHUD.h"
#import "TransitionDelegate.h"

#import "HONHomeViewController.h"
#import "HONHomeViewFlowLayout.h"
#import "HONActivityViewController.h"
#import "HONRegisterViewController.h"
#import "HONRestrictedViewController.h"
#import "HONInviteViewController.h"
#import "HONPrivacyPolicyViewController.h"
#import "HONComposeTopicViewController.h"
#import "HONStatusUpdateViewController.h"
#import "HONSettingsViewController.h"
#import "HONTermsViewController.h"
#import "HONLoadingOverlayView.h"
#import "HONPaginationView.h"
#import "HONButton.h"
#import "HONScrollView.h"
#import "HONTableView.h"
#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"
#import "HONCommentVO.h"

@interface HONHomeViewController () <HONLoadingOverlayViewDelegate>
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONPaginationView *paginationView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) HONButton *composeButton;
@property (nonatomic, strong) NSMutableArray *retrievedStatusUpdates;
@property (nonatomic, strong) NSMutableArray *statusUpdates;
@property (nonatomic, strong) HONStatusUpdateVO *selectedStatusUpdateVO;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) UIView *noNetworkView;
@property (nonatomic, strong) UIButton *overlayButton;
@property (nonatomic) int voteScore;
@property (nonatomic) int totStatusUpdates;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSString *composeSubject;
@property (nonatomic, strong) TransitionDelegate *transitionController;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) UIButton *supportButton;
@property (nonatomic, strong) UIView *tintView;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) NSTimer *tintTimer;

@end

@implementation HONHomeViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeHomeTab;
		_viewStateType = HONStateMitigatorViewStateTypeHome;
		_voteScore = 0;
		
		_colors = @[[UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00],
					[UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00],
					[UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00],
					[UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_selectedHomeTab:)
													 name:@"SELECTED_HOME_TAB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_tareHomeTab:)
													 name:@"TARE_HOME_TAB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshHomeTab:)
													 name:@"REFRESH_HOME_TAB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshHomeTab:)
													 name:@"REFRESH_ALL_TABS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_showFirstRun:)
													 name:@"SHOW_FIRST_RUN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_completedFirstRun:)
													 name:@"COMPLETED_FIRST_RUN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshScore:)
													 name:@"REFRESH_SCORE" object:nil];
	}
	
	return (self);
}

-(void)dealloc {
	[super destroy];
}


#pragma mark - Data Calls
#pragma mark - Data Handling
- (void)_goReloadContents {
	if ([[HONDeviceIntrinsics sharedInstance] hasNetwork]) {
		
		_noNetworkView.hidden = YES;
		
		_retrievedStatusUpdates = [NSMutableArray array];
		_statusUpdates = [NSMutableArray array];
		
		[self _didFinishDataRefresh];
		
	} else {
		_noNetworkView.hidden = NO;
	}
}

- (void)_didFinishDataRefresh {
	[_loadingOverlayView outro];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
//	[[HONAPICaller sharedInstance] retrieveStatusUpdatesForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] fromPage:1	completion:^(NSDictionary *result) {
//		NSLog(@"TOTAL CREATED:[%d]", [[result objectForKey:@"count"] intValue]);
//		_voteScore = [[result objectForKey:@"count"] intValue];
//		[_headerView updateActivityScore:_voteScore];
//	}];
	
	
//	[[HONUserAssistant sharedInstance] retrieveActivityScoreByUserID:[[HONUserAssistant sharedInstance] activeUserID] completion:^(NSNumber *result){
//		NSLog(@"ACTIVITY:[%@]", result);
//		_voteScore = [result intValue];
//		[_headerView updateActivityScore:_voteScore];
//	}];
	
	NSLog(@"%@._didFinishDataRefresh - CLAuthorizationStatus() = [%@]", self.class, NSStringFromCLAuthorizationStatus([CLLocationManager authorizationStatus]));
}

- (void)_registerPushNotifications {
	NSLog(@"%@._registerPushNotifications", self.class);
	
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
		//if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
			[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
			[[UIApplication sharedApplication] registerForRemoteNotifications];
		//}
		
	} else {
//		if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone)
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
	}
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	// blue
	self.view.backgroundColor = [UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00];
	
	
	_transitionController = [[TransitionDelegate alloc] init];
	
	_noNetworkView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 233.0, 320.0, 90.0)];
	_noNetworkView.hidden = YES;
	[_noNetworkView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noNetworkBG"]]];
	[self.view addSubview:_noNetworkView];
	
	UILabel *noNetworkLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 85.0, 220.0, 20.0)];
	noNetworkLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16.0];
	noNetworkLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	noNetworkLabel.backgroundColor = [UIColor clearColor];
	noNetworkLabel.textAlignment = NSTextAlignmentCenter;
	noNetworkLabel.text = NSLocalizedString(@"no_network", @"");
	[_noNetworkView addSubview:noNetworkLabel];
	
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectFromSize(self.view.frame.size)];
	_scrollView.backgroundColor = [UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00];
	_scrollView.backgroundColor = [UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 4.0, _scrollView.frame.size.height);
	_scrollView.contentInset = UIEdgeInsetsZero;
	_scrollView.alwaysBounceHorizontal = YES;
	_scrollView.pagingEnabled = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	
	[self performSelector:@selector(_startTint) withObject:nil afterDelay:3.0];
	
	_tintView = [[UIView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width * 3.0, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
	_tintView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	_tintView.alpha = 0.0;
	[_scrollView addSubview:_tintView];
	
	NSLog(@"*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~\nSCREEN BOUNDS:[%@](%.02f) // VIEW FRAME:[%@] BOUNDS:[%@]\n*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~", NSStringFromCGSize([UIScreen mainScreen].bounds.size),[UIScreen mainScreen].scale, NSStringFromCGSize(self.view.frame.size), NSStringFromCGSize(self.view.bounds.size));
	
	UIImageView *tutorial1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_01"]];
	[_scrollView addSubview:tutorial1ImageView];
	
	UIImageView *tutorial2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_02"]];
	tutorial2ImageView.frame = CGRectOffset(tutorial2ImageView.frame, _scrollView.frame.size.width, 0.0);
	[_scrollView addSubview:tutorial2ImageView];
	
	UIImageView *tutorial3ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_03"]];
	tutorial3ImageView.frame = CGRectOffset(tutorial3ImageView.frame, _scrollView.frame.size.width * 2.0, 0.0);
	[_scrollView addSubview:tutorial3ImageView];
	
	UIImageView *tutorial4ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_04"]];
	tutorial4ImageView.frame = CGRectOffset(tutorial4ImageView.frame, _scrollView.frame.size.width * 3.0, 0.0);
	[_scrollView addSubview:tutorial4ImageView];
	
//	[[[NSUserDefaults standardUserDefaults] objectForKey:@"channels"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		int channelID = [obj intValue];
//		
//		UIButton *linkButton = [HONButton buttonWithType:UIButtonTypeCustom];
//		linkButton.frame = CGRectMake((_scrollView.frame.size.width * 3.0) + 50.0, 310.0 + (idx * 25.0), self.view.frame.size.width - 100.0, 18.0);
//		[linkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//		[linkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//		linkButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
//		[linkButton setTitle:[NSString stringWithFormat:@"/%d", channelID] forState:UIControlStateNormal];
//		[linkButton setTitle:[NSString stringWithFormat:@"/%d", channelID] forState:UIControlStateHighlighted];
//		[linkButton addTarget:self action:@selector(_goDeeplink) forControlEvents:UIControlEventTouchUpInside];
//		[_scrollView addSubview:linkButton];
//	}];
	
	_supportButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_supportButton.frame = CGRectMake((_scrollView.frame.size.width * 3.0), 410.0 * (([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kScreenMult.height : 1.0), self.view.frame.size.width, 99.0);
	[_supportButton setBackgroundImage:[UIImage imageNamed:@"randomButton_nonActive"] forState:UIControlStateNormal];
	[_supportButton setBackgroundImage:[UIImage imageNamed:@"randomButton_Active"] forState:UIControlStateHighlighted];
	[_supportButton addTarget:self action:@selector(_goRandom) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_supportButton];
	
	_overlayButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_overlayButton.frame = CGRectMake(_scrollView.frame.size.width * 3.0, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
	[_overlayButton addTarget:self action:@selector(_goCancelCompose) forControlEvents:UIControlEventTouchUpInside];
	_overlayButton.hidden = YES;
	[_scrollView addSubview:_overlayButton];
	
	_textField = [[UITextField alloc] initWithFrame:CGRectMake((_scrollView.frame.size.width * 3.0) + ((_scrollView.frame.size.width - 300.0) * 0.5), 302.0 * (([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kScreenMult.height : 1.0), 300.0, 36.0)];
	[_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_textField setReturnKeyType:UIReturnKeyDone];
	[_textField setTextColor:[UIColor whiteColor]];
	[_textField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_textField.font = [[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:25];
	_textField.keyboardType = UIKeyboardTypeAlphabet;
	_textField.textAlignment = NSTextAlignmentCenter;
	_textField.text = @"What is on your mind?";
	_textField.delegate = self;
	[_scrollView addSubview:_textField];
	
	_composeButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_composeButton.frame = CGRectMake(0.0, _scrollView.frame.size.height, _scrollView.frame.size.width, 76.0);
	[_composeButton setBackgroundImage:[UIImage imageNamed:@"composeButton_nonActive"] forState:UIControlStateNormal];
	[_composeButton setBackgroundImage:[UIImage imageNamed:@"composeButton_Active"] forState:UIControlStateHighlighted];
	//[_composeButton addTarget:self action:@selector(_goTextField) forControlEvents:UIControlEventTouchUpInside];
	[_composeButton addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	_composeButton.alpha = 1.0;
	[self.view addSubview:_composeButton];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
//	[_headerView addPrivacyButtonWithTarget:self action:@selector(_goPrivacy)];
//	[_headerView addInviteButtonWithTarget:self action:@selector(_goInvite)];
	[self.view addSubview:_headerView];
	
	HONButton *linkButton = [HONButton buttonWithType:UIButtonTypeCustom];
	linkButton.frame = CGRectMake(6.0, 23.0, 52.0, 46.0);
	[linkButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_nonActive"] forState:UIControlStateNormal];
	[linkButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_Active"] forState:UIControlStateHighlighted];
	[linkButton addTarget:self action:@selector(_goPrivacy) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:linkButton];
	
	_paginationView = [[HONPaginationView alloc] initAtPosition:CGPointMake(_scrollView.frame.size.width * 0.5, self.view.frame.size.height - 40.0) withTotalPages:4 usingDiameter:7.0 andPadding:10.0];
	[_paginationView updateToPage:0];
	[self.view addSubview:_paginationView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
	
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	longPressGestureRecognizer.minimumPressDuration = 0.5;
	longPressGestureRecognizer.delegate = self;
	longPressGestureRecognizer.delaysTouchesBegan = YES;
	longPressGestureRecognizer.cancelsTouchesInView = NO;
	longPressGestureRecognizer.delaysTouchesBegan = NO;
	longPressGestureRecognizer.delaysTouchesEnded = NO;
	[self.view addGestureRecognizer:longPressGestureRecognizer];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] != 0) {
//		[[HONAPICaller sharedInstance] retrieveLocationFromIPAddressWithCompletion:^(NSDictionary *result) {
//			[[HONDeviceIntrinsics sharedInstance] updateGeoLocale:@{@"city"		: [result objectForKey:@"city"],
//																	@"state"	: [result objectForKey:@"state"],
//																	@"region"	: [result objectForKeyedSubscript:@"region"]}];
//			
//			[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[[CLLocation alloc] initWithLatitude:[[result objectForKey:@"lat"] floatValue] longitude:[[result objectForKey:@"lon"] floatValue]]];
//
//			[[HONClubAssistant sharedInstance] joinGlobalClubWithCompletion:^(HONUserClubVO *clubVO) {
//				[[HONClubAssistant sharedInstance] writeHomeLocationClub:clubVO];
//				
//				HONUserClubVO *homeClubVO = [[HONClubAssistant sharedInstance] homeLocationClub];
//				HONUserClubVO *locationClubVO = [[HONClubAssistant sharedInstance] currentLocationClub];
//				NSLog(@"HOME CLUB:[%d - %@] CURRENT_CLUB:[%d - %@] RADIUS CLUB:[%d - %@]", homeClubVO.clubID, homeClubVO.clubName, locationClubVO.clubID, locationClubVO.clubName, clubVO.clubID, clubVO.clubName);
//				if (locationClubVO.clubID == 0 || (clubVO.clubID != locationClubVO.clubID && clubVO.clubID != homeClubVO.clubID)) {
//					[[HONClubAssistant sharedInstance] writeCurrentLocationClub:clubVO];
//				}
//				
//				[self _goReloadContents];
//			}];
//		}];
		
	} else {
		[self _goRegistration];
	}
	
	[[HONStateMitigator sharedInstance] resetTotalCounterForType:_totalType withValue:([[HONStateMitigator sharedInstance] totalCounterForType:_totalType] - 1)];
//	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
//	[[HONAPICaller sharedInstance] retrieveStatusUpdatesForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] fromPage:1	completion:^(NSDictionary *result) {
//		NSLog(@"TOTAL CREATED:[%d]", [[result objectForKey:@"count"] intValue]);
//		_voteScore = [[result objectForKey:@"count"] intValue];
//		[_headerView updateActivityScore:_voteScore];
//	}];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"terms"] length] == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Terms of service"
															message:@"You agree to the following terms."
														   delegate:self
												  cancelButtonTitle:@"View Terms"
												  otherButtonTitles:@"Agree", NSLocalizedString(@"alert_cancel", @"Cancel"), nil];
		[alertView setTag:HONHomeAlertViewTypeTermsAgreement];
		[alertView show];
	}
	
	[[[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil] setObject:NSStringFromBOOL(YES) forKey:CFBridgingRelease(kSecAttrAccount)];
}


#pragma mark - Navigation
- (void)_goRegistration {
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:^(void) {
//	}];
	
//	NSLog(@"_checkUsername -- ID:[%d]", [[HONUserAssistant sharedInstance] activeUserID]);
//	NSLog(@"_checkUsername -- USERNAME:[%@]", [[HONUserAssistant sharedInstance] activeUsername]);
//	NSLog(@"_checkUsername -- PHONE:[%@]", [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
//	
//	NSLog(@"\n\n******** USER/PHONE API CHECK **********\n");
//	[[HONAPICaller sharedInstance] checkForAvailableUsername:[[HONUserAssistant sharedInstance] activeUsername] completion:^(NSDictionary *result) {
//		NSLog(@"RESULT:[%@]", result);
//		
//		if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
//		} else {
//			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//				[[HONAPICaller sharedInstance] checkForAvailablePhone:[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]] completion:^(NSDictionary *result) {
//					if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue])
//						NSLog(@"\n\n!¡!¡!¡ FAILED API NAME/PHONE CHECK !¡!¡!¡");
//					
//					else
//						NSLog(@"\n\n******** PASSED API NAME/PHONE CHECK **********");
//				}];
//			});
//			
//			NSLog(@"_finalizeUser -- ID:[%d]", [[HONUserAssistant sharedInstance] activeUserID]);
//			NSLog(@"_finalizeUser -- USERNAME_TXT:[%@] -=- PREV:[%@]", [[HONUserAssistant sharedInstance] activeUsername], [[HONUserAssistant sharedInstance] activeUsername]);
//			NSLog(@"_finalizeUser -- PHONE_TXT:[%@] -=- PREV[%@]", [NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]], [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
//			
//			NSLog(@"\n\n******** FINALIZE W/ API **********");
//			[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
//																		@"username"		: [[HONUserAssistant sharedInstance] activeUsername],
//																		@"phone"		: [[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]] stringByAppendingString:@"@selfieclub.com"]} completion:^(NSDictionary *result) {
//																			
//																			
//																			NSLog(@"~*~*~*~*~*~* FINALIZE UPDATE !¡!¡!¡!¡!¡!¡!¡!\n%@", result);
//																			int responseCode = [[result objectForKey:@"result"] intValue];
//																			if (result != nil && responseCode == 0) {
//																				[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
//																				[[HONDeviceIntrinsics sharedInstance] writePhoneNumber:[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]]];
//																				
//																				[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - joiniOS"];
//																				[_loadingOverlayView outro];
//																				KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
//																				
//
//																				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//																					[[HONAPICaller sharedInstance] updateUsernameForUser:[[HONUserAssistant sharedInstance] activeUsername] completion:^(NSDictionary *result) {
//																						NSLog(@"~*~*~*~*~*~* USERAME UPDATE !¡!¡!¡!¡!¡!¡!¡!");
//																						
//																						if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
//																							[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
//																						
//																						[[HONAPICaller sharedInstance] updateAvatarWithImagePrefix:[[HONUserAssistant sharedInstance] rndAvatarURL] completion:^(NSDictionary *result) {
//																							NSLog(@"~*~*~*~*~*~* AVATAR UPDATE !¡!¡!¡!¡!¡!¡!¡!");
//																							
//																							if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
//																								[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
//																							
//																							[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSDictionary *result) {
//																								NSLog(@"~*~*~*~*~*~* PHONE UPDATE !¡!¡!¡!¡!¡!¡!¡!\n");
//																								
//																								if (!((BOOL)[[result objectForKey:@"result"] intValue]))
//																									NSLog(@"!¡!¡!¡!¡!¡!¡!¡ PHONE UPDATE FAILED !¡!¡!¡!¡!¡!¡!¡!");
//																							}];
//																						}];
//																					}];
//																				});
//																				
//																				[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETED_FIRST_RUN" object:nil];
//																				
//																			} else {
//																				[_loadingOverlayView outro];
//																				
//																				if (_progressHUD == nil)
//																					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//																				[_progressHUD setYOffset:-80.0];
//																				_progressHUD.minShowTime = kProgressHUDErrorDuration;
//																				_progressHUD.mode = MBProgressHUDModeCustomView;
//																				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
//																				_progressHUD.labelText = NSLocalizedString((responseCode == 1) ? @"hud_usernameTaken" : (responseCode == 2) ? @"phone_taken" : (responseCode == 3) ? @"user_phone" : @"hud_loadError", nil);
//																				[_progressHUD show:NO];
//																				[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration + 0.75];
//																				_progressHUD = nil;
//																			}
//																		}]; // finalize
//		}
//	}];
}

- (void)_goActivity {
	[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%d DOOD point%@", _voteScore, (_voteScore != 1) ? @"s" : @""]
								message:@"Each image and comment vote gives you a single point."
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
					  otherButtonTitles:nil] show];
}

- (void)_goTextField {
	if (![_textField isFirstResponder])
		[_textField becomeFirstResponder];
}

- (void)_goCompose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Create Status Update"
	//									 withProperties:@{@"src"	: @"header"}];
	
	_loadingView = [[UIView alloc] initWithFrame:self.view.frame];
	_loadingView.backgroundColor = [UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00];
	[self.view addSubview:_loadingView];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicatorView.center = CGPointMake(_loadingView.bounds.size.width * 0.5, (_loadingView.bounds.size.height + 20.0) * 0.5);
	[activityIndicatorView startAnimating];
	[_loadingView addSubview:activityIndicatorView];

	//[_loadingView addSubview:animationImageView];
	
	int challenge_id = ([[NSUserDefaults standardUserDefaults] hasObjectForKey:@"challenge_id"]) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"challenge_id"] intValue] : 0;
	
	NSString *statusUpdateAffix = @"/";
	NSLog(@"(*)(*)(*)(*)(*)(*) TOPIC:[%@] // PREFIXED:[%@] -=- IS NUMERIC:[%@]", _textField.text, NSStringFromBOOL([_textField.text isPrefixedByString:statusUpdateAffix]), NSStringFromInt(challenge_id));
	
	int statusUpdateID = ([_textField.text isPrefixedByString:statusUpdateAffix]) ? [[_textField.text substringFromIndex:[statusUpdateAffix length]] intValue] : 0;
	if (statusUpdateID > 0) {
//		[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - joinPopup"]];
		
		if ([_textField isFirstResponder])
			[_textField resignFirstResponder];
		
		
//		_loadingOverlayView = [[HONLoadingOverlayView alloc] initWithCaption:@"Finding Popup Link…"];
//		_loadingOverlayView.delegate = self;
		
		[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:statusUpdateID completion:^(NSDictionary *result) {
			if (![[result objectForKey:@"detail"] isEqualToString:@"Not found"]) {
				_selectedStatusUpdateVO = [HONStatusUpdateVO statusUpdateWithDictionary:result];
				_selectedStatusUpdateVO.comment = NSStringFromBOOL(NO);
				
				[[NSUserDefaults standardUserDefaults] setObject:NSStringFromInt(statusUpdateID) forKey:@"challenge_id"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				HONStatusUpdateViewController *statusUpdateViewController = [[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedStatusUpdateVO forClub:[[HONClubAssistant sharedInstance] currentLocationClub]];
				[self.navigationController pushViewController:statusUpdateViewController animated:YES];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					[_loadingView removeFromSuperview];
					//[_tintTimer invalidate];
					//_tintTimer = nil;
					
					[_loadingOverlayView outro];
					_textField.text = @"What is on your mind?";
				});
				
			} else {
				[_loadingView removeFromSuperview];
				//[_tintTimer invalidate];
				//_tintTimer = nil;
				
//				[_loadingOverlayView outro];
				_textField.text = @"";
				
				if (![_textField isFirstResponder])
					[_textField becomeFirstResponder];
			}
		}];
		
	} else {
		[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - createPopup"]];
		
		if ([_textField isFirstResponder])
			[_textField resignFirstResponder];
		
		NSError *error;
		NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[@""] options:0 error:&error]
													 encoding:NSUTF8StringEncoding];
		
		NSDictionary *submitParams = @{@"user_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
									   @"img_url"		: @"",
									   @"club_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
									   @"challenge_id"	: @(0),
									   @"topic_id"		: @(0),
									   @"subject"		: _textField.text,
									   @"subjects"		: jsonString};
		NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", submitParams);
		
		
		NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", submitParams);
//		[[HONAPICaller sharedInstance] submitStatusUpdateWithDictionary:submitParams completion:^(NSDictionary *result) {
//			if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
//				if (_progressHUD == nil)
//					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//				_progressHUD.minShowTime = kProgressHUDMinDuration;
//				_progressHUD.mode = MBProgressHUDModeCustomView;
//				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
//				_progressHUD.labelText = @"Error!";
//				[_progressHUD show:NO];
//				[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
//				_progressHUD = nil;
//				
//			} else {
//			} // api result
		
		_selectedStatusUpdateVO = nil;//[HONStatusUpdateVO statusUpdateWithDictionary:result];
//			_selectedStatusUpdateVO.comment = NSStringFromBOOL(YES);
//			
//			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//			pasteboard.string = [NSString stringWithFormat:@"http://popup.vlly.im/%d/", _selectedStatusUpdateVO.statusUpdateID];
//			
//			if ([_textField isFirstResponder])
//				[_textField resignFirstResponder];
//			
			HONStatusUpdateViewController *statusUpdateViewController = [[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedStatusUpdateVO forClub:[[HONClubAssistant sharedInstance] currentLocationClub]];
			[self.navigationController pushViewController:statusUpdateViewController animated:YES];
//
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				[_loadingView removeFromSuperview];
				//[_tintTimer invalidate];
				//_tintTimer = nil;
				
				[_loadingOverlayView outro];
				_textField.text = @"What is on your mind?";
			});
//		}]; // api submit
	}
}

- (void)_goRandom {
	_loadingView = [[UIView alloc] initWithFrame:self.view.frame];
	_loadingView.backgroundColor = [UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00];
	[self.view addSubview:_loadingView];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicatorView.center = CGPointMake(_loadingView.bounds.size.width * 0.5, (_loadingView.bounds.size.height + 20.0) * 0.5);
	[activityIndicatorView startAnimating];
	[_loadingView addSubview:activityIndicatorView];
	
	HONStatusUpdateViewController *statusUpdateViewController = [[HONStatusUpdateViewController alloc] initWithChannelName:@"4c07fbc6-35a5-4d5c-87b1-1ccd5146893f_1436743103"];
	[self.navigationController pushViewController:statusUpdateViewController animated:YES];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[_loadingView removeFromSuperview];
		//[_tintTimer invalidate];
		//_tintTimer = nil;
		
		[_loadingOverlayView outro];
		_textField.text = @"What is on your mind?";
	});
}

- (void)_goCancelCompose {
	[_textField resignFirstResponder];
}

- (void)_goDeeplink {
	_textField.text = [NSString stringWithFormat:@"/%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"challenge_id"] intValue]];
	[self _goCompose];
}

- (void)_goSupport {
	_textField.text = @"/22222";
	[self _goCompose];
}

- (void)_goPrivacy {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPrivacyPolicyViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goInvite {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareApp"];
	
//	[UIPasteboard generalPasteboard].string = @"Join my Popup! (expires in 10 mins) http://popup.vlly.im";
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Popup link has been copied to your clipboard!"
//														message:@"http://popup.vlly.im\nShare now for people to join."
//													   delegate:self
//											  cancelButtonTitle:NSLocalizedString(@"alert_cancel", @"Cancel")
//											  otherButtonTitles:@"Copy to Clipboard", @"Share on SMS", nil];//@"Share Kik", @"Share Line", @"Share Kakao", nil];
//	[alertView setTag:HONHomeAlertViewTypeInvite];
//	[alertView show];
	
	[self.navigationController pushViewController:[[HONInviteViewController alloc] init] animated:YES];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
//	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
//		return;
//	
//		if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//		}
//	}
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
//	HONHomeViewCell *cell = (HONHomeViewCell *)[_collectionView cellForItemAtIndexPath:[_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]]];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -1500) {
	}
}



#pragma mark - Notifications
- (void)_showFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _showFirstRun <|::");
	
	[self _goRegistration];
}

- (void)_completedFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _completedFirstRun <|::");
	
	[[HONAPICaller sharedInstance] retrieveLocationFromIPAddressWithCompletion:^(NSDictionary *result) {
		[[HONDeviceIntrinsics sharedInstance] updateGeoLocale:@{@"city"		: [result objectForKey:@"city"],
																@"state"	: [result objectForKey:@"state"],
																@"region"	: [result objectForKeyedSubscript:@"region"]}];
		
		[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[[CLLocation alloc] initWithLatitude:[[result objectForKey:@"lat"] floatValue] longitude:[[result objectForKey:@"lon"] floatValue]]];
		
//		HONUserClubVO *globalClubVO = [[HONClubAssistant sharedInstance] globalClub];
//		if ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:globalClubVO.location] < globalClubVO.joinRadius) {
//			[_locationManager stopUpdatingLocation];
//			
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRestrictedViewController alloc] init]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:NO completion:^(void) {
//			}];
//			
//		} else {
			[[HONClubAssistant sharedInstance] joinGlobalClubWithCompletion:^(HONUserClubVO *clubVO) {
				[[HONClubAssistant sharedInstance] writeHomeLocationClub:clubVO];
				
				HONUserClubVO *homeClubVO = [[HONClubAssistant sharedInstance] homeLocationClub];
				HONUserClubVO *locationClubVO = [[HONClubAssistant sharedInstance] currentLocationClub];
				NSLog(@"HOME CLUB:[%d - %@] CURRENT_CLUB:[%d - %@] RADIUS CLUB:[%d - %@]", homeClubVO.clubID, homeClubVO.clubName, locationClubVO.clubID, locationClubVO.clubName, clubVO.clubID, clubVO.clubName);
				if (locationClubVO.clubID == 0 || (clubVO.clubID != locationClubVO.clubID && clubVO.clubID != homeClubVO.clubID)) {
					[[HONClubAssistant sharedInstance] writeCurrentLocationClub:clubVO];
				}
				
				[self _goReloadContents];
			}];
//		}
	}];
	
	NSLog(@"%@._completedFirstRun - CLAuthorizationStatus = [%@]", self.class, NSStringFromCLAuthorizationStatus([CLLocationManager authorizationStatus]));
}

- (void)_selectedHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedHomeTab <|::");
	
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:_totalType];
	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
	
	[self _goReloadContents];
}

- (void)_refreshHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshHomeTab <|::");
	
//	[[HONLayerKitAssistant sharedInstance] authenticateUserWithUserID:[[HONUserAssistant sharedInstance] activeUserID] withCompletion:^(BOOL success, NSError *error) {
//		NSLog(@"AUTH RESULT:%@ -=- %@", NSStringFromBOOL(success), error);
//	}];
	[self _goReloadContents];
}

- (void)_tareHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _tareHomeTab <|::");
}

- (void)_refreshScore:(NSNotification *)notification {
	NSLog(@"::|> _refreshScore:[%d] <|::", ((HONStatusUpdateVO *)[notification object]).statusUpdateID);
}

- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	UITextField *textField = (UITextField *)[notification object];
	
	if ([textField.text length] == 0)
		[textField resignFirstResponder];
}


#pragma mark - UI Presentation
- (void)_startTint {
//	_tintTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
//												  target:self
//												selector:@selector(_changeTint)
//												userInfo:nil repeats:YES];
}

- (void)_changeTint {
//	NSArray *colors = @[[UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00],
//						[UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00],
//						[UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00],
//						[UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00]];
//	
//	UIColor *color = [colors randomElement];
//	[UIView animateWithDuration:0.3333 animations:^(void) {
//		[[HONViewDispensor sharedInstance] tintView:_scrollView withColor:color];
//	} completion:nil];
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		[[HONViewDispensor sharedInstance] tintView:_scrollView withColor:[UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00]];
	} completion:nil];
}


#pragma mark - LoadingOverlayView Delegates
- (void)loadingOverlayViewDidIntro:(HONLoadingOverlayView *)loadingOverlayView {
}

- (void)loadingOverlayViewDidOutro:(HONLoadingOverlayView *)loadingOverlayView {
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	textField.text = @"";
	_overlayButton.hidden = NO;
	//textField.text = @"//269759";
	
	[UIView animateWithDuration:0.333
					 animations:^(void) {
						 _tintView.alpha = 1.0;
						 _supportButton.alpha = 0.0;
						 //_scrollView.frame = CGRectTranslateY(_scrollView.frame, -58.0);
						 _composeButton.frame = CGRectOffsetY(_composeButton.frame, -216.0);
						 
					 } completion:^(BOOL finished) {
//						 [_composeButton removeTarget:self action:@selector(_goTextField) forControlEvents:UIControlEventTouchUpInside];
//						 [_composeButton addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
					 }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField.text length] > 0)
		[self _goCompose];
	
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSet]].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] <= 200 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	
	textField.text = ([textField.text length] == 0) ? @"What is on your mind?" : textField.text;
	[UIView animateWithDuration:0.333
					 animations:^(void) {
						 _tintView.alpha = 0.0;
						 _supportButton.alpha = 1.0;
						 _composeButton.frame = CGRectOffsetY(_composeButton.frame, 216.0);
						 //_scrollView.frame = CGRectTranslateY(_scrollView.frame, 0.0);
					 } completion:^(BOOL finished) {
						 _overlayButton.hidden = YES;
						// [_composeButton removeTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
						// [_composeButton addTarget:self action:@selector(_goTextField) forControlEvents:UIControlEventTouchUpInside];
					 }];
}

- (void)_onTextEditingDidEnd:(id)sender {
	//	NSLog(@"[*:*] _onTextEditingDidEnd:[%@]", _commentTextField.text);
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"[*:*] scrollViewDidScroll:[%@]", NSStringFromCGPoint(scrollView.contentOffset));
	
	if (scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width) {
		if ([_textField isFirstResponder])
			[_textField resignFirstResponder];
		
		if (_composeButton.frame.origin.y == scrollView.frame.size.height - _composeButton.frame.size.height) {
			[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
				_composeButton.alpha = 0.0;
				_composeButton.frame = CGRectTranslateY(_composeButton.frame, scrollView.frame.size.height);
			} completion:^(BOOL finished) {
			}];
		}
		
		if (_paginationView.frame.origin.y == (self.view.frame.size.height - 40.0) - (_composeButton.frame.size.height + 7.0)) {
			[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
				_paginationView.frame = CGRectTranslateY(_paginationView.frame, self.view.frame.size.height - 40.0);
			} completion:^(BOOL finished) {
			}];
		}
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//	UIColor *color = [_colors objectAtIndex:(int)(scrollView.contentOffset.x / scrollView.frame.size.width)];
//	[UIView animateWithDuration:0.333 animations:^(void) {
//		[[HONViewDispensor sharedInstance] tintView:scrollView withColor:color];
//	} completion:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	NSLog(@"[*:*] scrollViewDidEndDecelerating:[%@]", NSStringFromCGPoint(scrollView.contentOffset));
//	[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"HOME - swipe_%d", (int)(scrollView.contentOffset.x / scrollView.frame.size.width)]];
	
	[_paginationView updateToPage:scrollView.contentOffset.x / scrollView.frame.size.width];
	if (scrollView.contentOffset.x >= _scrollView.contentSize.width - _scrollView.frame.size.width) {
		[self _registerPushNotifications];
		
		
//		if (!_isLoading) {
//			_isLoading = YES;
//			[self _changeTint];
//		}
		
		if (_composeButton.frame.origin.y == scrollView.frame.size.height) {
			[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
				_composeButton.alpha = 1.0;
				_composeButton.frame = CGRectTranslateY(_composeButton.frame, scrollView.frame.size.height - _composeButton.frame.size.height);
			} completion:^(BOOL finished) {
			}];
		}
		
		if (_paginationView.frame.origin.y == self.view.frame.size.height - 40.0) {
			[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
				_paginationView.frame = CGRectTranslateY(_paginationView.frame, (self.view.frame.size.height - 40.0) - (_composeButton.frame.size.height + 7.0));
			} completion:^(BOOL finished) {
			}];
		}
		
	} else if (scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width) {
		if ([_textField isFirstResponder])
			[_textField resignFirstResponder];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//	NSLog(@"[*:*] scrollViewDidEndScrollingAnimation:[%@]", NSStringFromCGPoint(scrollView.contentOffset));
	
	[_paginationView updateToPage:scrollView.contentOffset.x / scrollView.frame.size.width];
	if (scrollView.contentOffset.x >= _scrollView.contentSize.width - _scrollView.frame.size.width) {
		[self _registerPushNotifications];
		
		if (_composeButton.frame.origin.y == scrollView.frame.size.height) {
			[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
				_composeButton.alpha = 1.0;
				_composeButton.frame = CGRectTranslateY(_composeButton.frame, scrollView.frame.size.height - _composeButton.frame.size.height);
				
			} completion:^(BOOL finished) {
//				if (![_textField isFirstResponder])
//					[_textField becomeFirstResponder];
			}];
		}
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"terms"] length] == 0) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Terms of service"
																message:@"You agree to the following terms."
															   delegate:self
													  cancelButtonTitle:@"View Terms"
													  otherButtonTitles:@"Agree", NSLocalizedString(@"alert_cancel", @"Cancel"), nil];
			[alertView setTag:HONHomeAlertViewTypeTermsAgreement];
			[alertView show];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"[*:*] alertView:[%ld] clickedButtonAtIndex:[%ld]", (long)alertView.tag, (long)buttonIndex);
	
	if (alertView.tag == HONHomeAlertViewTypeFlag) {
	} else if (alertView.tag == HONHomeAlertViewTypeCompose) {
		if (buttonIndex == 1) {
			
		}
		
	} else if (alertView.tag == HONHomeAlertViewTypeJoin) {
		_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
		_loadingOverlayView.delegate = self;
		
		[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:[_textField.text intValue] completion:^(NSDictionary *result) {
			[_loadingOverlayView outro];
			
			if (![[result objectForKey:@"detail"] isEqualToString:@"Not found"]) {
				if ([_textField isFirstResponder])
					[_textField resignFirstResponder];
				
				HONStatusUpdateVO *vo = [HONStatusUpdateVO statusUpdateWithDictionary:result];
				[self.navigationController pushViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:vo forClub:[[HONClubAssistant sharedInstance] currentLocationClub]] animated:YES];
				
			} else {
				_textField.text = @"";
				
				if (![_textField isFirstResponder])
					[_textField becomeFirstResponder];
			}
		}];
		
	} else if (alertView.tag == HONHomeAlertViewTypeShare) {
	} else if (alertView.tag == HONHomeAlertViewTypeInvite) {
		if (buttonIndex == 1) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareClipboard"];
			
			[[[UIAlertView alloc] initWithTitle:@"Paste anywhere to share!"
										message:@""
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
		} else if (buttonIndex == 2) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareSMS"];
			
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [UIPasteboard generalPasteboard].string;
				messageComposeViewController.messageComposeDelegate = self;
				
				[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Error"
											message:@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else if (buttonIndex == 3) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareKik"];
			
			NSString *typeName = @"";
			NSString *urlSchema = @"";
			
			typeName = @"Kik";
			urlSchema = @"kik://";
			
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchema]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			} else {
				KikMessage *message = [KikMessage articleMessageWithTitle:@"[LIVE NOW]"
																	 text:@"Walkie talkie style video chat."
															   contentURL:[NSString stringWithFormat:@"http://popup.rocks/deep.php?id=%d", _selectedStatusUpdateVO.statusUpdateID]
															   previewURL:@"http://popup.rocks/images/my_icon.png"];
				[[KikClient sharedInstance] sendKikMessage:message];
			}
			
		} else if (buttonIndex == 4) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareLine"];
			
			NSString *typeName = @"Line";
			NSString *urlSchema = @"line://";
			
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchema]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlSchema]];
			}
			
		} else if (buttonIndex == 5) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareKakao"];
			
			NSString *typeName = @"";
			NSString *urlSchema = @"";
			
			typeName = @"Kakao";
			urlSchema = @"kakaolink://";
			
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchema]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlSchema]];
			}
		}
	
	} else if (alertView.tag == HONHomeAlertViewTypeTermsAgreement) {
		if (buttonIndex == 1) {
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"terms"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		
		} else if (buttonIndex == 0) {
			[self _goPrivacy];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"[*:*] alertView:[%d] didDismissWithButtonIndex:[%d]", (int)alertView.tag, (int)buttonIndex);
	
	if (alertView.tag == HONHomeAlertViewTypeFlag) {
		if (buttonIndex == 1) {
		}
	
	} else if (alertView.tag == HONHomeAlertViewTypeCompose) {
	} else if (alertView.tag == HONHomeAlertViewTypeJoin) {
		
	} else if (alertView.tag == HONHomeAlertViewTypeShare) {
		if (buttonIndex == 1) {
			[[HONSocialCoordinator sharedInstance] presentActionSheetForSharingWithMetaData:@{@"deeplink"	: [NSString stringWithFormat:@"dood://%d", _selectedStatusUpdateVO.statusUpdateID]}];
		}
		
	} else if (alertView.tag == HONHomeAlertViewTypeShowTerms) {
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONTermsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:^(void) {
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"terms"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}];
		}
	}
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissViewControllerAnimated:NO completion:^(void) {
	}];
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
}


@end
