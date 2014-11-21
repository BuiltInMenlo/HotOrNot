//
//  HONHomeViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "NSString+DataTypes.h"

#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"

#import "HONHomeViewController.h"
#import "HONHomeViewFlowLayout.h"
#import "HONActivityViewController.h"
#import "HONRegisterViewController.h"
#import "HONComposeViewController.h"
#import "HONStatusUpdateViewController.h"
#import "HONRefreshControl.h"
#import "HONHeaderView.h"
#import "HONHomeViewCell.h"
#import "HONCollectionView.h"
#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"

@interface HONHomeViewController () <HONHomeViewCellDelegate>
@property (nonatomic, strong) HONCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *clubPhotos;
@property (nonatomic, strong) HONClubPhotoVO *selectedClubPhoto;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) UIButton *activityButton;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation HONHomeViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeHomeTab;
		_viewStateType = HONStateMitigatorViewStateTypeHome;
		
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
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			if ([key isEqualToString:@"owned"] || [key isEqualToString:@"member"]) {
				for (NSDictionary *dict in [result objectForKey:key]) {
					HONUserClubVO *clubVO = [HONUserClubVO clubWithDictionary:dict];
					
//					NSLog(@"CLUB_ID:[%d]-(%@)-[%d]", clubVO.clubID, [@"" stringFromBOOL:(clubVO.clubID == [[HONClubAssistant sharedInstance] orthodoxMemberClub].clubID)], [HONUserClubVO clubWithDictionary:[[HONClubAssistant sharedInstance] orthodoxClubMemberDictionary]].clubID);
					if (clubVO.clubID == [[HONClubAssistant sharedInstance] orthodoxMemberClub].clubID) {
						[clubVO.submissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
							HONClubPhotoVO *clubPhotoVO = (HONClubPhotoVO *)obj;
							if ([clubPhotoVO.addedDate timeIntervalSinceNow] >= (3600 * 24))
								return;
							
							[_clubPhotos addObject:clubPhotoVO];
						}];
					}
				}
			
			} else
				continue;
		}
		
		NSLog(@"test**#* WITHIN RANGE:[%@]", [@"" stringFromBOOL:[[HONGeoLocator sharedInstance] isWithinOrthodoxClub]]);
		NSLog(@"test**#* MEMBER OF:[%d] =-= (%@)", [[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue], [@"" stringFromBOOL:[[HONClubAssistant sharedInstance] isMemberOfClubWithClubID:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue] includePending:YES]]);
		if ([[HONGeoLocator sharedInstance] isWithinOrthodoxClub] && ![[HONClubAssistant sharedInstance] isMemberOfClubWithClubID:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue] includePending:YES]) {
			[[HONAPICaller sharedInstance] joinClub:[HONUserClubVO clubWithDictionary:[[HONClubAssistant sharedInstance] orthodoxMemberClubDictionary]] withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
				
				if ((BOOL)[[result objectForKey:@"result"] intValue]) {
					[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
						[[HONClubAssistant sharedInstance] writeUserClubs:result];
						[self _didFinishDataRefresh];
					}];
				}
			}];
			
		} else {
			[[HONClubAssistant sharedInstance] writeUserClubs:result];
			[self _didFinishDataRefresh];
		}
		
	}];
}

- (void)_retrieveActivityItems {
	[[HONAPICaller sharedInstance] retrieveActivityTotalForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSString *result) {
		NSLog(@"ACTIVITY:[%@]", result);
		[_activityButton setTitle:[@"" stringFromInt:[result intValue]] forState:UIControlStateNormal];
		[_activityButton setTitle:[@"" stringFromInt:[result intValue]] forState:UIControlStateHighlighted];
	}];
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
	
	_clubPhotos = [NSMutableArray array];
	[_collectionView reloadData];
	
	[self _retrieveClubPhotos];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	_clubPhotos = [[[[_clubPhotos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		HONClubPhotoVO *vo1 = (HONClubPhotoVO *)obj1;
		HONClubPhotoVO *vo2 = (HONClubPhotoVO *)obj2;
		
		if ([vo1.addedDate didDateAlreadyOccur:vo2.addedDate])
			return ((NSComparisonResult)NSOrderedAscending);
		
		if ([vo2.addedDate didDateAlreadyOccur:vo1.addedDate])
			return ((NSComparisonResult)NSOrderedDescending);
		
		return ((NSComparisonResult)NSOrderedSame);
	}] reverseObjectEnumerator] allObjects] mutableCopy];
	
	_emptyLabel.hidden = ([_clubPhotos count] > 0);
	
	[_collectionView reloadData];
	[_refreshControl endRefreshing];
	
	NSLog(@"%@._didFinishDataRefresh - CLAuthorizationStatus() = [%@]", self.class, [@"" stringFromCLAuthorizationStatus:[CLLocationManager authorizationStatus]]);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.hidden = YES;
	
	_clubPhotos = [NSMutableArray array];
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[self.view addSubview:_headerView];
	
	_activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_activityButton.frame = CGRectMake(10.0, 0.0, 44.0, 44.0);
	[_activityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_activityButton setTitleColor:[[HONColorAuthority sharedInstance] honGreyTextColor] forState:UIControlStateHighlighted];
	_activityButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	[_activityButton setTitle:@"0" forState:UIControlStateNormal];
	[_activityButton setTitle:@"0" forState:UIControlStateHighlighted];
	[_activityButton addTarget:self action:@selector(_goActivity) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:_activityButton];
	
	
	_collectionView = [[HONCollectionView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) collectionViewLayout:[[HONHomeViewFlowLayout alloc] init]];
	[_collectionView registerClass:[HONHomeViewCell class] forCellWithReuseIdentifier:[HONHomeViewCell cellReuseIdentifier]];
	[_collectionView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)];
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.alwaysBounceVertical = YES;
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	[self.view addSubview:_collectionView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_collectionView addSubview: _refreshControl];
	
	_emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 18.0, 300, (_collectionView.frame.size.height - 22.0) * 0.5)];
	_emptyLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20];
	_emptyLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	_emptyLabel.backgroundColor = [UIColor clearColor];
	_emptyLabel.textAlignment = NSTextAlignmentCenter;
	_emptyLabel.text = NSLocalizedString(@"no_results", @"");
	_emptyLabel.hidden = YES;
	[_collectionView addSubview:_emptyLabel];
	
	UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	composeButton.frame = CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0);
	[composeButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[composeButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	[composeButton addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:composeButton];
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
		[self _goReloadContents];
		
	} else {
		[self _goRegistration];
	}
	
	[self _retrieveActivityItems];
	[[HONStateMitigator sharedInstance] resetTotalCounterForType:_totalType withValue:([[HONStateMitigator sharedInstance] totalCounterForType:_totalType] - 1)];
	//	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}


#pragma mark - Navigation
- (void)_goRegistration {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {
	}];
}

- (void)_goActivity {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Home Tab - Activity"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONActivityViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {
	}];
}

- (void)_goCompose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Create Status Update"
	//									 withProperties:@{@"src"	: @"header"}];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] clubWithClubID:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue]]]];
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
	HONHomeViewCell *cell = (HONHomeViewCell *)[_collectionView cellForItemAtIndexPath:[_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Home Tab - Status Update SWIPE"
											 withClubPhoto:cell.clubPhotoVO];
	
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
	
	NSLog(@"%@._completedFirstRun - CLAuthorizationStatus = [%@]", self.class, [@"" stringFromCLAuthorizationStatus:[CLLocationManager authorizationStatus]]);
	
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


#pragma mark - HomeViewCellDelegates
- (void)homeViewCell:(HONHomeViewCell *)viewCell didSelectClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] homeViewCell:didSelectdidSelectClubPhoto:[%@])", clubPhotoVO.dictionary);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Home Tab - Seleted Photo"
											  withClubPhoto:clubPhotoVO];
	
	_selectedClubPhoto = clubPhotoVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedClubPhoto]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:[[HONAnimationOverseer sharedInstance] isSegueAnimationEnabledForModalViewController:navigationController.presentingViewController] completion:^(void) {
	}];
}


#pragma mark - LocationManager Delegates
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"**_[%@ locationManager:didFailWithError:(%@)]_**", self.class, error.description);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"**_[%@ locationManager:didChangeAuthorizationStatus:(%@)]_**", self.class, [@"" stringFromCLAuthorizationStatus:status]);// (status == kCLAuthorizationStatusAuthorized) ? @"Authorized" : (status == kCLAuthorizationStatusAuthorizedAlways) ? @"AuthorizedAlways" : (status == kCLAuthorizationStatusAuthorizedWhenInUse) ? @"AuthorizedWhenInUse" : (status == kCLAuthorizationStatusDenied) ? @"Denied" : (status == kCLAuthorizationStatusRestricted) ? @"Restricted" : (status == kCLAuthorizationStatusNotDetermined) ? @"NotDetermined" : @"UNKNOWN");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	NSLog(@"**_[%@ locationManager:didUpdateLocations:(%@)]_**", self.class, locations);
	[_locationManager stopUpdatingLocation];
	
	[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[locations firstObject]];
	
	NSLog(@"WITHIN RANGE:[%@]", [@"" stringFromBOOL:[[HONGeoLocator sharedInstance] isWithinOrthodoxClub]]);
	NSLog(@"MEMBER OF:[%d] =-= (%@)", [[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue], [@"" stringFromBOOL:[[HONClubAssistant sharedInstance] isMemberOfClubWithClubID:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue] includePending:YES]]);
	if ([[HONGeoLocator sharedInstance] isWithinOrthodoxClub] && ![[HONClubAssistant sharedInstance] isMemberOfClubWithClubID:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue] includePending:YES]) {
		[[HONAPICaller sharedInstance] joinClub:[HONUserClubVO clubWithDictionary:[[HONClubAssistant sharedInstance] orthodoxMemberClubDictionary]] withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			
			if ((BOOL)[[result objectForKey:@"result"] intValue]) {
				[self _goReloadContents];
			}
		}];
	}
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
	[cell setSize:CGSizeMake(107.0, 107.0)];
	
	HONClubPhotoVO *vo = (HONClubPhotoVO *)[_clubPhotos objectAtIndex:indexPath.row];
	cell.clubPhotoVO = vo;
	cell.delegate = self;
	
	if (!collectionView.decelerating)
		[cell toggleImageLoading:YES];
	
	return (cell);
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//	HONClubPhotoVO *vo =  ((HONHomeViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).clubPhotoVO;
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[_] collectionView:didSelectItemAtIndexPath:%@)", [@"" stringFromIndexPath:indexPath]);
	
	HONHomeViewCell *viewCell = (HONHomeViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Home Tab - Selected Photo"
//										  withClubPhoto:viewCell.clubPhotoVO];
	
	_selectedClubPhoto = viewCell.clubPhotoVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedClubPhoto]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {
	}];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125 delay:(0.125 * (indexPath.row / 3)) options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	HONHomeViewCell *viewCell = (HONHomeViewCell *)cell;
	[viewCell toggleImageLoading:NO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[[_collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
		[cell toggleImageLoading:YES];
	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}


@end
