//
//  HONClubsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 05/03/2014 @ 18:38 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"


#import "HONClubsViewController.h"
#import "HONClubsTimelineViewController.h"
#import "HONUserClubsViewController.h"

#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONSelfieCameraViewController.h"

#import "HONTutorialView.h"
#import "HONHeaderView.h"
#import "HONProfileHeaderButtonView.h"
#import "HONCreateSnapButtonView.h"

#import "HONUserClubVO.h"


@interface HONClubsViewController () <HONTutorialViewDelegate>
@property (nonatomic, strong) HONClubsTimelineViewController *clubsTimelineViewController;
@property (nonatomic, strong) HONUserClubsViewController *userClubsViewController;
@property (nonatomic, assign) HONClubListType clubListType;
@property (nonatomic, strong) HONTutorialView *tutorialView;
@property (nonatomic, strong) UIButton *toggleListTypeButton;
@property (nonatomic, strong) UILabel *toggleClubsLabel;

@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) NSMutableArray *invitedClubs;

@property (nonatomic, strong) HONUserClubVO *ownClub;
@end


@implementation HONClubsViewController

- (id)init {
	if ((self = [super init])) {
		_clubListType = HONClubListTypeTimeline;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedClubsTab:) name:@"SELECTED_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareClubsTab:) name:@"TARE_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_CLUB_TAB" object:nil];
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
- (void)_retrieveClubs {
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		
		if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0) {
			_ownClub = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
			[_allClubs addObject:_ownClub];
		}
		
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"joined"]) {
			HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:dict];
			[_joinedClubs addObject:vo];
			[_allClubs addObject:vo];
		}
		
		
		// --//> *** POPULATED FPO CLUBS *** <//-- //
		for (NSDictionary *dict in [[HONClubAssistant sharedInstance] fpoJoinedClubs]) {
			HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:dict];
			[_joinedClubs addObject:vo];
			[_allClubs addObject:vo];
		} // --//> *** POPULATED FPO CLUBS *** <//-- //
		
		
		[self _retrieveClubInvites];
		
		
	}];
}

- (void)_retrieveClubInvites {
	
	// --//> *** POPULATED FPO CLUBS *** <//-- //
	for (NSDictionary *dict in [[HONClubAssistant sharedInstance] fpoInviteClubs]) {
		HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:dict];
		[_invitedClubs addObject:vo];
		[_allClubs addObject:vo];
	} // --//> *** POPULATED FPO CLUBS *** <//-- //
	
	
	[[HONAPICaller sharedInstance] retrieveClubInvitesForUserWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result) {
			HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:dict];
			[_invitedClubs addObject:vo];
			[_allClubs addObject:vo];
		}
		
		_toggleClubsLabel.text = [NSString stringWithFormat:@"My Club%@ (%d)", ([_allClubs count] == 1) ? @"" : @"s", [_allClubs count]];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_clubsTimelineViewController = [[HONClubsTimelineViewController alloc] initWithWrapperViewController:self];
	_userClubsViewController = [[HONUserClubsViewController alloc] initWithWrapperViewController:self];
	
	_allClubs = [NSMutableArray array];
	_invitedClubs = [NSMutableArray array];
	_joinedClubs = [NSMutableArray array];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs"];
	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	_toggleListTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_toggleListTypeButton.frame = CGRectMake(0.0, kNavHeaderHeight + 6.0, 320.0, 44.0);
	[_toggleListTypeButton setBackgroundImage:[UIImage imageNamed:@"toggleClubs_timeline"] forState:UIControlStateNormal];
	[_toggleListTypeButton setBackgroundImage:[UIImage imageNamed:@"toggleClubs_timeline"] forState:UIControlStateHighlighted];
	[_toggleListTypeButton addTarget:self action:@selector(_goToggleListType) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_toggleListTypeButton];
	
	UILabel *toggleNewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 12.0, 150.0, 17.0)];
	toggleNewsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	toggleNewsLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	toggleNewsLabel.backgroundColor = [UIColor clearColor];
	toggleNewsLabel.textAlignment = NSTextAlignmentCenter;
	toggleNewsLabel.text = @"News";
	[_toggleListTypeButton addSubview:toggleNewsLabel];
	
	_toggleClubsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 12.0, 150.0, 17.0)];
	_toggleClubsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	_toggleClubsLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	_toggleClubsLabel.backgroundColor = [UIColor clearColor];
	_toggleClubsLabel.textAlignment = NSTextAlignmentCenter;
	_toggleClubsLabel.text = @"My Clubs (0)";
	[_toggleListTypeButton addSubview:_toggleClubsLabel];
	
	[self _retrieveClubs];
	
	[_clubsTimelineViewController viewWillAppear:YES];
	[self.view insertSubview:_clubsTimelineViewController.view atIndex:0];
	[_clubsTimelineViewController viewDidAppear:YES];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
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
- (void)_goProfile {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Profile"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Create Challenge"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goToggleListType {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Clubs Timeline - Toggle %@ List", (_clubListType == HONClubListTypeTimeline) ? @"My Clubs" : @"News"]];
	_clubListType = (_clubListType == HONClubListTypeTimeline) ? HONClubListTypeEnrollments : HONClubListTypeTimeline;
	
	[_toggleListTypeButton setBackgroundImage:[UIImage imageNamed:(_clubListType == HONClubListTypeTimeline) ? @"toggleClubs_timeline" : @"toggleClubs_subscriptions"] forState:UIControlStateNormal];
	[_toggleListTypeButton setBackgroundImage:[UIImage imageNamed:(_clubListType == HONClubListTypeTimeline) ? @"toggleClubs_timeline" : @"toggleClubs_subscriptions"] forState:UIControlStateHighlighted];
	
	
	UIViewController *introViewController = (_clubListType == HONClubListTypeTimeline) ? _clubsTimelineViewController : _userClubsViewController;
	UIViewController *outroViewController = (_clubListType == HONClubListTypeTimeline) ? _userClubsViewController : _clubsTimelineViewController;
	
	[introViewController viewWillAppear:YES];
	[outroViewController viewWillDisappear:YES];
	
	[outroViewController.view removeFromSuperview];
	[self.view insertSubview:introViewController.view atIndex:0];
}


#pragma mark - Notifications
- (void)_selectedClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedClubsTab <|::");
	
//	if ([HONAppDelegate incTotalForCounter:@"clubs"] == 0) {
//		_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:@"tutorial_messages"]];
//		_tutorialView.delegate = self;
//
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialView];
//		[_tutorialView introWithCompletion:nil];
//	}
}

- (void)_refreshClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshClubsTab <|::");
	
	[self _retrieveClubs];
	
	if (_clubListType == HONClubListTypeTimeline)
		[_clubsTimelineViewController refresh];
	
	else
		[_userClubsViewController refresh];
}

- (void)_tareClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareClubsTab <|::");
	
	if (_clubListType == HONClubListTypeTimeline)
		[_clubsTimelineViewController tare];
	
	else
		[_userClubsViewController tare];
}


#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Close Tutorial"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewTakeAvatar:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Tutorial Take Avatar"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}

@end
