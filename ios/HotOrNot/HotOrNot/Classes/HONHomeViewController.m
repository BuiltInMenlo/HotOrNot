//
//  HONHomeViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "NSDate+Operations.h"
#import "NSString+DataTypes.h"
#import "NSUserDefaults+Replacements.h"

#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"

#import "HONHomeViewController.h"
#import "HONHomeViewFlowLayout.h"
#import "HONActivityViewController.h"
#import "HONRegisterViewController.h"
#import "HONComposeViewController.h"
#import "HONStatusUpdateViewController.h"
#import "HONSettingsViewController.h"
#import "HONRefreshControl.h"
#import "HONHeaderView.h"
#import "HONHomeFeedToggleView.h"
#import "HONHomeViewCell.h"
#import "HONCollectionView.h"
#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"
#import "HONCommentVO.h"

@interface HONHomeViewController () <HONHomeFeedToggleViewDelegate, HONHomeViewCellDelegate>
@property (nonatomic, assign) HONHomeFeedType feedType;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) HONCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *clubPhotos;
@property (nonatomic, strong) HONClubPhotoVO *selectedClubPhoto;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONHomeFeedToggleView *toggleView;
@property (nonatomic, strong) UIView *emptyFeedView;
@property (nonatomic) int voteScore;
@end

@implementation HONHomeViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeHomeTab;
		_viewStateType = HONStateMitigatorViewStateTypeHome;
		_feedType = HONHomeFeedTypeRecent;
		_voteScore = 0;
		
		
//		[[NSUserDefaults standardUserDefaults] replaceObject:@{} forKey:@"votes"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
		
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
	[[_collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_collectionView.dataSource = nil;
	_collectionView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveClubPhotos {
	if (_feedType == HONHomeFeedTypeRecent) {
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			[[[HONClubAssistant sharedInstance] clubTypeKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSString *key = (NSString *)obj;
				if ([key isEqualToString:@"owned"] || [key isEqualToString:@"member"]) {
					for (NSDictionary *dict in [result objectForKey:key]) {
						NSLog(@"CLUB_ID:[%d]-=-[%d] >> %@", [[dict objectForKey:@"id"] intValue], [[HONClubAssistant sharedInstance] currentLocationClub].clubID, NSStringFromBOOL([[dict objectForKey:@"id"] intValue] == [[HONClubAssistant sharedInstance] currentLocationClub].clubID));
						if ([[dict objectForKey:@"id"] intValue] == [[HONClubAssistant sharedInstance] currentLocationClub].clubID) {
							
							HONUserClubVO *clubVO = [HONUserClubVO clubWithDictionary:dict];
							[clubVO.submissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
								HONClubPhotoVO *clubPhotoVO = (HONClubPhotoVO *)obj;
								if (clubPhotoVO.parentID != 0)
									return;
								
								if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"expire_threshold"] intValue] != 0 && [NSDate elapsedSecondsSinceDate:clubPhotoVO.addedDate isUTC:YES] > [[[NSUserDefaults standardUserDefaults] objectForKey:@"expire_threshold"] intValue])
									return;
								
								__block BOOL isFlagged = NO;
								[[[HONClubAssistant sharedInstance] repliesForClubPhoto:clubPhotoVO] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
									HONCommentVO *vo = (HONCommentVO *)obj;
									if ([vo.textContent isEqualToString:@"__FLAG__"]) {
										isFlagged = YES;
										*stop = YES;
									}
								}];
								
								if (isFlagged)
									return;
								
								[_clubPhotos addObject:clubPhotoVO];
							}];
							
							break;
						}
					}
				}
			}];
			
			[self _didFinishDataRefresh];
		}];
		
	} else {
		[[HONAPICaller sharedInstance] retrieveTopClubsForUserWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			[[[HONClubAssistant sharedInstance] clubTypeKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSString *key = (NSString *)obj;
				if ([key isEqualToString:@"owned"] || [key isEqualToString:@"member"]) {
					for (NSDictionary *dict in [result objectForKey:key]) {
						NSLog(@"CLUB_ID:[%d]-=-[%d] >> %@", [[dict objectForKey:@"id"] intValue], [[HONClubAssistant sharedInstance] currentLocationClub].clubID, NSStringFromBOOL([[dict objectForKey:@"id"] intValue] == [[HONClubAssistant sharedInstance] currentLocationClub].clubID));
						if ([[dict objectForKey:@"id"] intValue] == [[HONClubAssistant sharedInstance] currentLocationClub].clubID) {
							HONUserClubVO *clubVO = [HONUserClubVO clubWithDictionary:dict];
							
							[clubVO.submissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
								HONClubPhotoVO *clubPhotoVO = (HONClubPhotoVO *)obj;
								if (clubPhotoVO.parentID != 0)
									return;
								
								if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"expire_threshold"] intValue] != 0 && [NSDate elapsedSecondsSinceDate:clubPhotoVO.addedDate isUTC:YES] > [[[NSUserDefaults standardUserDefaults] objectForKey:@"expire_threshold"] intValue])
									return;
								
								__block BOOL isFlagged = NO;
								[[[HONClubAssistant sharedInstance] repliesForClubPhoto:clubPhotoVO] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
									HONCommentVO *vo = (HONCommentVO *)obj;
									if ([vo.textContent isEqualToString:@"__FLAG__"]) {
										isFlagged = YES;
										*stop = YES;
									}
								}];
								
								if (isFlagged)
									return;
								
								[_clubPhotos addObject:clubPhotoVO];
							}];
							
							break;
						}
					}
				}
			}];
			
			[self _didFinishDataRefresh];
		}];
	}
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeHomeTabRefresh];
	
	[_collectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
		
		[UIView animateKeyframesWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			cell.alpha = 0.0;
		} completion:^(BOOL finished) {}];
	}];
	
	[self _goReloadContents];
}

- (void)_goReloadContents {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	[_toggleView toggleEnabled:NO];
	_clubPhotos = [NSMutableArray array];
	[_collectionView reloadData];
	
	[self _retrieveClubPhotos];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
//	_clubPhotos = [[[[_clubPhotos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//		HONClubPhotoVO *vo1 = (HONClubPhotoVO *)obj1;
//		HONClubPhotoVO *vo2 = (HONClubPhotoVO *)obj2;
//		
//		if ([vo1.addedDate didDateAlreadyOccur:vo2.addedDate])
//			return ((NSComparisonResult)NSOrderedAscending);
//		
//		if ([vo2.addedDate didDateAlreadyOccur:vo1.addedDate])
//			return ((NSComparisonResult)NSOrderedDescending);
//		
//		return ((NSComparisonResult)NSOrderedSame);
//	}] reverseObjectEnumerator] allObjects] mutableCopy];
	
	_emptyFeedView.hidden = ([_clubPhotos count] > 0);
	
	[_collectionView reloadData];
	[_refreshControl endRefreshing];
	
	[_headerView refreshActivity];
	[_toggleView toggleEnabled:YES];
	
	[[HONAPICaller sharedInstance] retrieveActivityTotalForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSNumber *result) {
		NSLog(@"ACTIVITY:[%@]", result);
		_voteScore = [result intValue];
	}];
	
	NSLog(@"%@._didFinishDataRefresh - CLAuthorizationStatus() = [%@]", self.class, [@"" stringFromCLAuthorizationStatus:[CLLocationManager authorizationStatus]]);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.view.hidden = YES;
	
	[[HONAPICaller sharedInstance] retrieveActivityTotalForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSNumber *result) {
		NSLog(@"ACTIVITY:[%@]", result);
		_voteScore = [result intValue];
	}];

	_clubPhotos = [NSMutableArray array];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[_headerView addActivityButtonWithTarget:self action:@selector(_goActivity)];
	[_headerView refreshActivity];
	[self.view addSubview:_headerView];
	
	_toggleView = [[HONHomeFeedToggleView alloc] initWithTypes:@[@(HONHomeFeedTypeRecent), @(HONHomeFeedTypeTop)]];
	_toggleView.delegate = self;
	[_headerView addSubview:_toggleView];
	
	
	_collectionView = [[HONCollectionView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, ((kHomeCollectionViewCellSize.width + kHomeCollectionViewCellSpacing.width) * 3.0), self.view.frame.size.height - kNavHeaderHeight) collectionViewLayout:[[HONHomeViewFlowLayout alloc] init]];
	[_collectionView registerClass:[HONHomeViewCell class] forCellWithReuseIdentifier:[HONHomeViewCell cellReuseIdentifier]];
	[_collectionView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)];
	_collectionView.backgroundColor = [UIColor clearColor];
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.alwaysBounceVertical = YES;
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	[self.view addSubview:_collectionView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_collectionView addSubview: _refreshControl];
	
	UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	composeButton.frame = CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0);
	[composeButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[composeButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	[composeButton addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:composeButton];
	
	UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	settingsButton.frame = CGRectMake(self.view.frame.size.width - 44.0, self.view.frame.size.height - 43.0, 44.0, 44.0);
	[settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_nonActive"] forState:UIControlStateNormal];
	[settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_Active"] forState:UIControlStateHighlighted];
	[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:settingsButton];
	
	_emptyFeedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 233.0, 320.0, 90.0)];
	_emptyFeedView.hidden = YES;
	[_emptyFeedView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyFeedBG"]]];
	[self.view addSubview:_emptyFeedView];

	UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 85.0, 220.0, 20.0)];
	emptyLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16.0];
	emptyLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	emptyLabel.backgroundColor = [UIColor clearColor];
	emptyLabel.textAlignment = NSTextAlignmentCenter;
	emptyLabel.text = NSLocalizedString(@"no_results", @"");
	[_emptyFeedView addSubview:emptyLabel];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.5;
	lpGestureRecognizer.delegate = self;
	lpGestureRecognizer.delaysTouchesBegan = YES;
	[self.collectionView addGestureRecognizer:lpGestureRecognizer];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] != 0) {
		self.view.hidden = NO;
		
		if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
			[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
			[[UIApplication sharedApplication] registerForRemoteNotifications];
			
		} else
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
		
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.distanceFilter = 10000;
		if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
			[_locationManager requestWhenInUseAuthorization];
		[_locationManager startUpdatingLocation];
		
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - enter"];
		
	} else {
		[self _goRegistration];
	}
	
	[[HONStateMitigator sharedInstance] resetTotalCounterForType:_totalType withValue:([[HONStateMitigator sharedInstance] totalCounterForType:_totalType] - 1)];
//	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}


#pragma mark - Navigation
- (void)_goRegistration {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {
	}];
}

- (void)_goActivity {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Home Tab - Activity"];
	
	[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%d Yunder point%@", _voteScore, (_voteScore != 1) ? @"s" : @""]
								message:@"Each image and comment vote gives you a single point."
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
					  otherButtonTitles:nil] show];
	
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONActivityViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:^(void) {
//	}];
}

- (void)_goCompose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Create Status Update"
	//									 withProperties:@{@"src"	: @"header"}];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] clubWithClubID:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue]]]];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] currentLocationClub]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goSettings {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - more_button"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	NSLog(@"gestureRecognizer.state:[%@]", (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"Began" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"Canceled" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"Ended" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"Failed" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"Possible" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"Recognized" : @"UNKNOWN");
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
	
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]];
	
	if (indexPath != nil) {
		HONHomeViewCell *cell = (HONHomeViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
		
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
			NSLog(@"STATUS UPDATE:[%@]", cell.clubPhotoVO.dictionary);
//			HONClubTimelineViewController *clubTimelineViewController = [[HONClubTimelineViewController alloc] initWithClub:cell.clubVO atPhotoIndex:0];
//			[self.view addSubview:clubTimelineViewController.view];
			
		} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		}
	}
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
//	HONHomeViewCell *cell = (HONHomeViewCell *)[_collectionView cellForItemAtIndexPath:[_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]]];
	
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Home Tab - Status Update SWIPE"
//											 withClubPhoto:cell.clubPhotoVO];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -1500) {
	}
}



#pragma mark - Notifications
- (void)_showFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _showFirstRun <|::");
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - enter_fr"];
	[self _goRegistration];
}

- (void)_completedFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _completedFirstRun <|::");
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - enter"];
	
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
		[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
		[[UIApplication sharedApplication] registerForRemoteNotifications];
		
	} else
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.distanceFilter = 100;
	
	if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
		[_locationManager requestWhenInUseAuthorization];
	[_locationManager startUpdatingLocation];
	
	NSLog(@"%@._completedFirstRun - CLAuthorizationStatus = [%@]", self.class, NSStringFromCLAuthorizationStatus([CLLocationManager authorizationStatus]));
	
	[self _goReloadContents];
	self.view.hidden = NO;
}

- (void)_selectedHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedHomeTab <|::");
	
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:_totalType];
	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
	
	if ([[notification object] isEqualToString:@"Y"] && [_collectionView.visibleCells count] > 0)
		[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];

	[self _goReloadContents];
}

- (void)_refreshHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshHomeTab <|::");
	
	[self _goReloadContents];
}

- (void)_tareHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _tareHomeTab <|::");
	
	if ([_collectionView.visibleCells count] > 0)
		[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)_refreshScore:(NSNotification *)notification {
	NSLog(@"::|> _refreshScore:[%d] <|::", ((HONClubPhotoVO *)[notification object]).challengeID);
	
	HONClubPhotoVO *vo = (HONClubPhotoVO *)[notification object];
	[_collectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
		
		if (cell.clubPhotoVO.challengeID == vo.challengeID) {
			[cell refeshScore];
			*stop = YES;
		}
	}];
}


#pragma mark - HomeFeedToggleView Delegates
- (void)homeFeedToggleView:(HONHomeFeedToggleView *)toggleView didSelectFeedType:(HONHomeFeedType)feedType {
	NSLog(@"[*:*] homeFeedToggleView:didSelectFeedType:[%@])", (feedType == HONHomeFeedTypeRecent) ? @"Recent" : (feedType == HONHomeFeedTypeTop) ? @"Top" : (feedType == HONHomeFeedTypeOwned) ? @"Owned" : @"UNKNOWN");
	
	_feedType = feedType;
	[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"HOME - %@", (_feedType == HONHomeFeedTypeRecent) ? @"new" : @"top"]];
	
	[self _goReloadContents];
}

#pragma mark - HomeViewCell Delegates
- (void)homeViewCell:(HONHomeViewCell *)viewCell didSelectClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] homeViewCell:didSelectdidSelectClubPhoto:[%d])", clubPhotoVO.challengeID);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - select_post"];
	
	_selectedClubPhoto = clubPhotoVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedClubPhoto forClub:[[HONClubAssistant sharedInstance] currentLocationClub]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:[[HONAnimationOverseer sharedInstance] isSegueAnimationEnabledForModalViewController:navigationController.presentingViewController] completion:^(void) {
	}];
}


#pragma mark - LocationManager Delegates
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"**_[%@ locationManager:didFailWithError:(%@)]_**", self.class, error.description);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"**_[%@ locationManager:didChangeAuthorizationStatus:(%@)]_**", self.class, [@"" stringFromCLAuthorizationStatus:status]);
	NSLog(@"LOCATION:[%@]", NSStringFromCLLocation([[HONDeviceIntrinsics sharedInstance] deviceLocation]));
	
	if (status == kCLAuthorizationStatusNotDetermined) {
		[_locationManager startUpdatingLocation];
		
	} else if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - location_accept"];
		[_locationManager startUpdatingLocation];
	
	} else if (status == kCLAuthorizationStatusDenied) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - location_cancel"];
		[[HONAPICaller sharedInstance] retrieveLocationFromIPAddressWithCompletion:^(CLLocation *result) {
			[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:result];
			[[HONClubAssistant sharedInstance] locationClubWithCompletion:^(HONUserClubVO *clubVO) {
				[self _goReloadContents];
			}];
		}];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	NSLog(@"**_[%@ locationManager:didUpdateLocations:(%@)]_**", self.class, locations);
	[_locationManager stopUpdatingLocation];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - location_AF"];
	[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[locations firstObject]];
	
	[[HONClubAssistant sharedInstance] locationClubWithCompletion:^(HONUserClubVO *clubVO) {
		[self _goReloadContents];
	}];
}


#pragma mark - CollectionView DataSources
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	[collectionView.collectionViewLayout invalidateLayout];
	return (1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return ([_clubPhotos count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"[_] collectionView:cellForItemAtIndexPath:%@)", [@"" stringFromIndexPath:indexPath]);
	
	HONHomeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HONHomeViewCell cellReuseIdentifier]
																	  forIndexPath:indexPath];
	
	[cell setIndexPath:indexPath];
	[cell setSize:kHomeCollectionViewCellSize];
	
	HONClubPhotoVO *vo = (HONClubPhotoVO *)[_clubPhotos objectAtIndex:indexPath.row];
	cell.clubPhotoVO = vo;
	cell.delegate = self;
	
//	if (!collectionView.decelerating)
//		[cell toggleImageLoading:YES];
	
	return (cell);
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[_] collectionView:didSelectItemAtIndexPath:%@)", [@"" stringFromIndexPath:indexPath]);
	HONHomeViewCell *cell = (HONHomeViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - select_post"];
	
	_selectedClubPhoto = cell.clubPhotoVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedClubPhoto forClub:[[HONClubAssistant sharedInstance] currentLocationClub]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {
	}];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 1.0;
//	[UIView animateKeyframesWithDuration:0.125 delay:(0.125 * (indexPath.row / 3)) options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
//		cell.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//	HONHomeViewCell *viewCell = (HONHomeViewCell *)cell;
//	[viewCell toggleImageLoading:NO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	[[_collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
//		[cell toggleImageLoading:YES];
//	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}


@end
