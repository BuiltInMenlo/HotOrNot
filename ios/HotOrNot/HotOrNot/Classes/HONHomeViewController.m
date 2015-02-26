//
//  HONHomeViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <LayerKit/LayerKit.h>

#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "UIScrollView+BuiltInMenlo.h"

#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"
#import "TransitionDelegate.h"

#import "HONHomeViewController.h"
#import "HONHomeViewFlowLayout.h"
#import "HONActivityViewController.h"
#import "HONRegisterViewController.h"
#import "HONRestrictedViewController.h"
#import "HONComposeTopicViewController.h"
#import "HONStatusUpdateViewController.h"
#import "HONSettingsViewController.h"
#import "HONLoadingOverlayView.h"
#import "HONRefreshControl.h"
#import "HONHomeFeedToggleView.h"
#import "HONHomeViewCell.h"
#import "HONTableView.h"
#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"
#import "HONCommentVO.h"

@interface HONHomeViewController () <HONHomeFeedToggleViewDelegate, HONHomeViewCellDelegate, HONLoadingOverlayViewDelegate>
@property (nonatomic, assign) HONHomeFeedType feedType;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) NSMutableArray *retrievedStatusUpdates;
@property (nonatomic, strong) NSMutableArray *statusUpdates;
@property (nonatomic, strong) NSMutableDictionary *convos;
@property (nonatomic, strong) HONStatusUpdateVO *selectedStatusUpdateVO;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONHomeFeedToggleView *toggleView;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) UIView *emptyFeedView;
@property (nonatomic, strong) UIView *noNetworkView;
@property (nonatomic) int voteScore;
@property (nonatomic) int totStatusUpdates;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSTimer *overlayTimer;
@property (nonatomic) int cnt;
@property (nonatomic, strong) TransitionDelegate *transitionController;
@end

@implementation HONHomeViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeHomeTab;
		_viewStateType = HONStateMitigatorViewStateTypeHome;
		_feedType = HONHomeFeedTypeRecent;
		_voteScore = 0;
		
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
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_locationManager.delegate = nil;
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveClubPhotosAtPage:(int)page {
	__block HONUserClubVO *locationClubVO = [[HONClubAssistant sharedInstance] currentLocationClub];
//	__block int nextPage = page + 1;
	[[HONAPICaller sharedInstance] retrieveStatusUpdatesForClubByClubID:locationClubVO.clubID fromPage:MAX(1, page) completion:^(NSDictionary *result) {
		NSLog(@"TOTAL:[%d]", [[result objectForKey:@"count"] intValue]);
		
		if (page == 1)
			_totStatusUpdates = [[result objectForKey:@"count"] intValue];
		
		[_retrievedStatusUpdates addObjectsFromArray:[result objectForKey:@"results"]];
			
//		NSLog(@"ON PAGE:[%d]", page);
//		NSLog(@"RETRIEVED:[%@]", [result objectForKey:@"results"]);
		
//		if ([_retrievedStatusUpdates count] < 20)//[[result objectForKey:@"count"] intValue])
//			[self _retrieveClubPhotosAtPage:nextPage];
//		
//		else {
//			NSLog(@"FINISHED RETRIEVED:[%d]", [_retrievedStatusUpdates count]);
			
			[_retrievedStatusUpdates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
				[dict setValue:@(locationClubVO.clubID) forKey:@"club_id"];
				
				HONStatusUpdateVO *vo = [HONStatusUpdateVO statusUpdateWithDictionary:dict];
				[_statusUpdates addObject:vo];
				
//				NSError *error = nil;
//				LYRConversation *conversation = [[[HONLayerKitAssistant sharedInstance] client] newConversationWithParticipants:[NSSet setWithArray:@[NSStringFromInt(193010), NSStringFromInt(vo.userID)]] options:@{@"user_id"	: @([[HONUserAssistant sharedInstance] activeUserID])} error:&error];
//				LYRMessage *message = [[[HONLayerKitAssistant sharedInstance] client] newMessageWithParts:@[[LYRMessagePart messagePartWithMIMEType:kMIMETypeImagePNG data:UIImagePNGRepresentation([UIImage imageNamed:@"fpo_emotionIcon-SM"])], [LYRMessagePart messagePartWithMIMEType:kMIMETypeTextPlain data:[[vo.dictionary objectForKey:@"img"] dataUsingEncoding:NSUTF8StringEncoding]]] options:nil error:&error];
//				
//				NSLog(@"STATUSUPD:[%@]\n[%@]", conversation, message);
//				
//				[_convos setObject:@{@"convo"	: conversation,
//									 @"msg"		: message} forKey:NSStringFromInt(vo.statusUpdateID)];
//				
				[[HONUserAssistant sharedInstance] writeClubMemberToUserLookup:@{@"id"			: [[dict objectForKey:@"owner_member"] objectForKey:@"id"],
																				 @"username"	: [[dict objectForKey:@"owner_member"] objectForKey:@"name"],
																				 @"avatar"		: [[HONUserAssistant sharedInstance] rndAvatarURL]}];
			}];
			
			[self _didFinishDataRefresh];
//		}
	}];
}

- (void)_retriveOwnedPhotosAtPage:(int)page {
	__block HONUserClubVO *locationClubVO = [[HONClubAssistant sharedInstance] currentLocationClub];
//	__block int nextPage = page + 1;
	
	[[HONAPICaller sharedInstance] retrieveStatusUpdatesForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] fromPage:MAX(1, page) completion:^(NSDictionary *result) {
		NSLog(@"TOTAL:[%d]", [[result objectForKey:@"count"] intValue]);
		if (page == 1)
			_totStatusUpdates = [[result objectForKey:@"count"] intValue];
		
		[_retrievedStatusUpdates addObjectsFromArray:[result objectForKey:@"results"]];
		
//		NSLog(@"ON PAGE:[%d]", page);
//		NSLog(@"RETRIEVED:[%d]", [_retrievedStatusUpdates count]);
		
//		if ([_retrievedStatusUpdates count] < [[result objectForKey:@"count"] intValue])
//			[self _retrieveClubPhotosAtPage:nextPage];
//		
//		else {
//			NSLog(@"FINISHED RETRIEVED:[%d]", [_retrievedStatusUpdates count]);
			
			[_retrievedStatusUpdates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
				if ([[[dict objectForKey:@"text"] lowercaseString] isEqualToString:@"#__verifyme__"]) {
					_totStatusUpdates--;
					return;
				}
				
//				NSLog(@"STATUSUPD:[%@]", dict);
				
				[dict setValue:@(locationClubVO.clubID) forKey:@"club_id"];
				
				HONStatusUpdateVO *vo = [HONStatusUpdateVO statusUpdateWithDictionary:dict];
				[_statusUpdates addObject:vo];
				
//				NSError *error = nil;
//				LYRConversation *conversation = [[[HONLayerKitAssistant sharedInstance] client] newConversationWithParticipants:[NSSet setWithArray:@[NSStringFromInt(193010), NSStringFromInt(vo.userID)]] options:@{@"user_id"	: @([[HONUserAssistant sharedInstance] activeUserID])} error:&error];
//				LYRMessage *message = [[[HONLayerKitAssistant sharedInstance] client] newMessageWithParts:@[[LYRMessagePart messagePartWithMIMEType:kMIMETypeImagePNG data:UIImagePNGRepresentation([UIImage imageNamed:@"fpo_emotionIcon-SM"])], [LYRMessagePart messagePartWithMIMEType:kMIMETypeTextPlain data:[[vo.dictionary objectForKey:@"img"] dataUsingEncoding:NSUTF8StringEncoding]]] options:nil error:&error];
//				
//				NSLog(@"STATUSUPD:[%@]\n[%@]", conversation, message);
//				
//				[_convos setObject:@{@"convo"	: conversation,
//									 @"msg"		: message} forKey:NSStringFromInt(vo.statusUpdateID)];
				
			}];
			
			[self _didFinishDataRefresh];
//		}
	}];
}

- (void)_flagStatusUpdate {
	NSDictionary *dict = @{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
						   @"img_url"		: [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL],
						   @"club_id"		: @(_selectedStatusUpdateVO.clubID),
						   @"subject"		: @"__FLAG__",
						   @"challenge_id"	: @(_selectedStatusUpdateVO.statusUpdateID)};
	
	[[HONAPICaller sharedInstance] submitStatusUpdateWithDictionary:dict completion:^(NSDictionary *result) {
		if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", @"Upload fail");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
			_progressHUD = nil;
			
		} else {
			[self _goReloadContents];
		}
	}];
}

- (void)_retrieveStatusUpdate {
	NSError *error = nil;
	LYRQuery *convoQuery = [LYRQuery queryWithClass:[LYRConversation class]];
	convoQuery.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:[_selectedStatusUpdateVO.dictionary objectForKey:@"img"]];
	LYRConversation *conversation = [[[[HONLayerKitAssistant sharedInstance] client] executeQuery:convoQuery error:&error] firstObject];
	
//	if (++_cnt < 5)
//		[self _sendInviteDMConversation];
	
	NSLog(@"CONVO: -=- (%@) -=- [%@]\n%@", [_selectedStatusUpdateVO.dictionary objectForKey:@"img"], conversation.identifier, conversation);
	
	if (conversation == nil) {
		dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 3.33 * NSEC_PER_SEC);
		dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
			[self _retrieveStatusUpdate];
		});
		
	} else {
		[_loadingOverlayView outro];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedStatusUpdateVO forClub:[[HONClubAssistant sharedInstance] currentLocationClub]]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:^(void) {
		}];
	}
}

- (void)_sendInviteDMConversation {
	NSError *error = nil;
	//LYRConversation *conversation = [[[HONLayerKitAssistant sharedInstance] client] newConversationWithParticipants:[NSSet setWithArray:@[NSStringFromInt(_statusUpdateVO.userID)]] options:@{@"user_id"	: @([[HONUserAssistant sharedInstance] activeUserID])} error:&error];
	LYRConversation *conversation = [[[HONLayerKitAssistant sharedInstance] client] newConversationWithParticipants:[NSSet setWithArray:@[NSStringFromInt(193010)]] options:@{@"user_id"	: @([[HONUserAssistant sharedInstance] activeUserID])} error:&error];
	LYRMessage *message = [[[HONLayerKitAssistant sharedInstance] client] newMessageWithParts:@[[LYRMessagePart messagePartWithMIMEType:kMIMETypeImagePNG data:UIImagePNGRepresentation([UIImage imageNamed:@"fpo_emotionIcon-SM"])], [LYRMessagePart messagePartWithMIMEType:kMIMETypeTextPlain data:[[_selectedStatusUpdateVO.dictionary objectForKey:@"img"] dataUsingEncoding:NSUTF8StringEncoding]]] options:nil error:&error];
	
	NSLog(@"MESSAGE RESULT -=- CREATOR:[%@]%@", error, message.identifierSuffix);
	BOOL success = [[HONLayerKitAssistant sharedInstance] sendMessage:message toConversation:conversation];
	NSLog(@"MESSAGE SENT -=- CREATOR:[%@]", NSStringFromBOOL(success));
	
//	[[HONAPICaller sharedInstance] retrieveRepliesForStatusUpdateByStatusUpdateID:_statusUpdateVO.statusUpdateID fromPage:1 completion:^(NSDictionary *result) {
//		[[result objectForKey:@"results"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//			NSDictionary *dict = (NSDictionary *)obj;
//
//			NSError *error = nil;
//			LYRConversation *conversationRequest = [[[HONLayerKitAssistant sharedInstance] client] newConversationWithParticipants:[NSSet setWithArray:@[NSStringFromInt([[[dict objectForKey:@"owner_member"] objectForKey:@"id"] intValue])]] options:@{@"user_id"	: @([[HONUserAssistant sharedInstance] activeUserID])} error:&error];
//			LYRMessage *messageRequest = [[[HONLayerKitAssistant sharedInstance] client] newMessageWithParts:@[[LYRMessagePart messagePartWithMIMEType:kMIMETypeImagePNG data:UIImagePNGRepresentation([UIImage imageNamed:@"fpo_emotionIcon-SM"])], [LYRMessagePart messagePartWithMIMEType:kMIMETypeTextPlain data:[[_statusUpdateVO.dictionary objectForKey:@"img"] dataUsingEncoding:NSUTF8StringEncoding]]] options:nil error:&error];
//
//			NSLog(@"MESSAGE RESULT:(%d) -=- [%@]%@", idx, error, messageRequest.identifierSuffix);
//			BOOL success2 = [[HONLayerKitAssistant sharedInstance] sendMessage:messageRequest toConversation:conversationRequest];
//			NSLog(@"MESSAGE SENT:(%d) -=- [%@]", idx, NSStringFromBOOL(success2));
//		}];
//	}];
}



#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeHomeTabRefresh];
	
	_isLoading = YES;
	_locationManager.delegate = self;
	if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
		[_locationManager startUpdatingLocation];
	
	else
		[self _goReloadContents];
}

- (void)_goReloadContents {
	if ([[HONDeviceIntrinsics sharedInstance] hasNetwork]) {
		_locationManager.delegate = nil;
		
		_noNetworkView.hidden = YES;
		[_toggleView toggleEnabled:NO];
		
		_retrievedStatusUpdates = [NSMutableArray array];
		_statusUpdates = [NSMutableArray array];
		[_tableView reloadData];
		
		[_tableView setContentOffset:CGPointMake(0.0, -95.0) animated:YES];
		if (![_refreshControl isRefreshing])
			[_refreshControl beginRefreshing];
		
		if (_feedType == HONHomeFeedTypeOwned)
			[self _retriveOwnedPhotosAtPage:1];
		
		else
			[self _retrieveClubPhotosAtPage:1];
	
	} else {
		_noNetworkView.hidden = NO;
	}
}

- (void)_didFinishDataRefresh {
	
	_isLoading = NO;
	
	[self _orphanSubmitOverlay];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	if (_feedType == HONHomeFeedTypeTop) {
		_statusUpdates = [[_statusUpdates sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			HONStatusUpdateVO *vo1 = (HONStatusUpdateVO *)obj1;
			HONStatusUpdateVO *vo2 = (HONStatusUpdateVO *)obj2;
			
			if (vo1.score < vo2.score) {
				NSLog(@"vo1.score:[%d / %d] < vo2.score:[%d / %d]", vo1.score, vo1.statusUpdateID, vo2.score, vo2.statusUpdateID);
				return ((NSComparisonResult)NSOrderedDescending);
			}
			
			if (vo1.score > vo2.score) {
				NSLog(@"vo1.score:[%d / %d] > vo2.score:[%d / %d]", vo1.score, vo1.statusUpdateID, vo2.score, vo2.statusUpdateID);
				return ((NSComparisonResult)NSOrderedAscending);
			}
			
			NSLog(@"vo1.score:[%d / %d] = vo2.score:[%d / %d]", vo1.score, vo1.statusUpdateID, vo2.score, vo2.statusUpdateID);
			return ((NSComparisonResult)NSOrderedSame);
		}] mutableCopy];
	}
	
	_emptyFeedView.hidden = ([_statusUpdates count] > 0);
	[_refreshControl endRefreshing];
	
	[_toggleView toggleEnabled:YES];
	[[HONUserAssistant sharedInstance] retrieveActivityScoreByUserID:[[HONUserAssistant sharedInstance] activeUserID] completion:^(NSNumber *result){
		NSLog(@"ACTIVITY:[%@]", result);
		_voteScore = [result intValue];
		[_headerView updateActivityScore:_voteScore];
	}];
	
//	[_tableView setContentOffset:CGPointZero animated:NO];
	[_tableView reloadData];
	
	NSLog(@"%@._didFinishDataRefresh - CLAuthorizationStatus() = [%@]", self.class, NSStringFromCLAuthorizationStatus([CLLocationManager authorizationStatus]));
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_transitionController = [[TransitionDelegate alloc] init];
	
	_cnt = 0;
	_convos = [NSMutableDictionary dictionary];
	self.view.hidden = ([[[[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil] objectForKey:CFBridgingRelease(kSecAttrAccount)] length] == 0);
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[_headerView addActivityButtonWithTarget:self action:@selector(_goActivity)];
	[self.view addSubview:_headerView];
	
	_toggleView = [[HONHomeFeedToggleView alloc] initWithTypes:@[@(HONHomeFeedTypeRecent), @(HONHomeFeedTypeTop)]];
	_toggleView.delegate = self;
	[_toggleView toggleEnabled:NO];
	[_headerView addSubview:_toggleView];
	
	_isLoading = YES;
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) style:UITableViewStylePlain];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.alwaysBounceVertical = YES;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.scrollsToTop = NO;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	composeButton.frame = CGRectMake(123.0, self.view.frame.size.height - 99.0, 74.0, 74.0);
	[composeButton setBackgroundImage:[UIImage imageNamed:@"composeButton_nonActive"] forState:UIControlStateNormal];
	[composeButton setBackgroundImage:[UIImage imageNamed:@"composeButton_Active"] forState:UIControlStateHighlighted];
	[composeButton addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:composeButton];
	
	UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	settingsButton.frame = CGRectMake(self.view.frame.size.width - 36.0, self.view.frame.size.height - 44.0, 44.0, 44.0);
	[settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_nonActive"] forState:UIControlStateNormal];
	[settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_Active"] forState:UIControlStateHighlighted];
	[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:settingsButton];
	
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
	
	_emptyFeedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 120.0, 320.0, 280.0)];
	_emptyFeedView.hidden = YES;
	[_emptyFeedView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyFeedBG"]]];
	[self.view addSubview:_emptyFeedView];

	UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 260.0, 220.0, 20.0)];
	emptyLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16.0];
	emptyLabel.textColor = [[HONColorAuthority sharedInstance] honGreenTextColor];
	emptyLabel.backgroundColor = [UIColor clearColor];
	emptyLabel.textAlignment = NSTextAlignmentCenter;
	emptyLabel.text = NSLocalizedString(@"no_results", @"");
	[_emptyFeedView addSubview:emptyLabel];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
	
	if (!self.view.hidden && ![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	longPressGestureRecognizer.minimumPressDuration = 0.5;
	longPressGestureRecognizer.delegate = self;
	longPressGestureRecognizer.delaysTouchesBegan = YES;
	longPressGestureRecognizer.cancelsTouchesInView = NO;
	longPressGestureRecognizer.delaysTouchesBegan = NO;
	longPressGestureRecognizer.delaysTouchesEnded = NO;
	[self.tableView addGestureRecognizer:longPressGestureRecognizer];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] != 0) {
		[[HONLayerKitAssistant sharedInstance] writePushToken:nil];
		
		if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
			[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
			[[UIApplication sharedApplication] registerForRemoteNotifications];
			
		} else
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
		
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.distanceFilter = 1000;
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
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewWillAppear:animated];
	
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
	[[HONAPICaller sharedInstance] createClubWithTitle:NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])
									   withDescription:@""
									   withImagePrefix:[[HONClubAssistant sharedInstance] defaultCoverImageURL]
											atLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation]
											completion:^(NSDictionary *result) {
												NSDictionary *dict = [result mutableCopy];
												
												[dict setValue:@(0.0) forKey:@"distance"];
												[dict setValue:@([[[NSUserDefaults standardUserDefaults] objectForKey:@"join_radius"] floatValue]) forKey:@"radius"];
												[dict setValue:@{@"lat"	: @([[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude),
																 @"lon"	: @([[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude)} forKey:@"coords"];
												
												HONUserClubVO *clubVO = [HONUserClubVO clubWithDictionary:dict];
												NSLog(@"CREATED CLUB:[%@]", NSStringFromNSDictionary(clubVO.dictionary));
											}];
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
	
	[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%d DOOD point%@", _voteScore, (_voteScore != 1) ? @"s" : @""]
								message:@"Each image and comment vote gives you a single point."
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
					  otherButtonTitles:nil] show];
}

- (void)_goCompose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Create Status Update"
	//									 withProperties:@{@"src"	: @"header"}];
	
//	HONComposeTopicViewController *composeTopicViewController = [[HONComposeTopicViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] currentLocationClub]];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeTopicViewController];
//	[navigationController setNavigationBarHidden:YES];
//	navigationController.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
//	[navigationController setTransitioningDelegate:_transitionController];
//	navigationController.modalPresentationStyle = UIModalPresentationCustom;
//	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//	[self presentViewController:navigationController animated:YES completion:nil];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Deep Link", @"Open", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
}

- (void)_goSettings {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - more_button"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
	
	NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:_tableView]];
	
	if (indexPath != nil) {
		HONHomeViewCell *cell = (HONHomeViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
		_selectedStatusUpdateVO = cell.statusUpdateVO;
		
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
			NSLog(@"STATUS UPDATE:[%@]", cell.statusUpdateVO.dictionary);
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
																message:NSLocalizedString(@"alert_flag_m", nil)
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
			[alertView setTag:0];
			[alertView show];
			
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
	self.view.hidden = NO;
	
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
	
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
}

- (void)_selectedHomeTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedHomeTab <|::");
	
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:_totalType];
	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
	
	if ([[notification object] isEqualToString:@"Y"] && [_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

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
	
	if ([_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)_refreshScore:(NSNotification *)notification {
	NSLog(@"::|> _refreshScore:[%d] <|::", ((HONStatusUpdateVO *)[notification object]).statusUpdateID);
	
//	HONStatusUpdateVO *vo = (HONStatusUpdateVO *)[notification object];
//	[_collectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
//		
//		if (cell.statusUpdateVO.statusUpdateID == vo.statusUpdateID) {
//			[cell refeshScore];
//			*stop = YES;
//		}
//	}];
}


#pragma mark - UI Presentation
- (void)_orphanSubmitOverlay {
	NSLog(@"::|> _orphanSubmitOverlay <|::");
	
	if ([_overlayTimer isValid])
		[_overlayTimer invalidate];
	
	if (_overlayTimer != nil);
	_overlayTimer = nil;
	
	if (_overlayView != nil) {
		[UIView animateKeyframesWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			_overlayView.alpha = 0.0;
			
		} completion:^(BOOL finished) {
			[_overlayView removeFromSuperview];
			_overlayView = nil;
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}];
	}
}

#pragma mark - HomeFeedToggleView Delegates
- (void)homeFeedToggleView:(HONHomeFeedToggleView *)toggleView didSelectFeedType:(HONHomeFeedType)feedType {
	NSLog(@"[*:*] homeFeedToggleView:didSelectFeedType:[%@])", (feedType == HONHomeFeedTypeRecent) ? @"Recent" : (feedType == HONHomeFeedTypeTop) ? @"Top" : (feedType == HONHomeFeedTypeOwned) ? @"Owned" : @"UNKNOWN");
	
	_feedType = feedType;
	[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"HOME - %@", (_feedType == HONHomeFeedTypeRecent) ? @"new_toggle" : @"top_toggle"]];
	
	[toggleView toggleEnabled:NO];
	[_tableView setContentOffset:CGPointMake(0.0, -95.0) animated:YES];
	[self _goReloadContents];
}

#pragma mark - HomeViewCell Delegates
- (void)homeViewCell:(HONHomeViewCell *)viewCell didSelectStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO {
	NSLog(@"[*:*] homeViewCell:didSelectdidSelectdidSelectStatusUpdate:[%d])", statusUpdateVO.statusUpdateID);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - row_select"];
	
	_selectedStatusUpdateVO = statusUpdateVO;
	
	
//	NSError *error = nil;
//	LYRQuery *convoQuery = [LYRQuery queryWithClass:[LYRConversation class]];
//	convoQuery.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:[_selectedStatusUpdateVO.dictionary objectForKey:@"img"]];
//	LYRConversation *conversation = [[[[HONLayerKitAssistant sharedInstance] client] executeQuery:convoQuery error:&error] firstObject];
//	
//	NSLog(@"CONVO: -=- (%@) -=- [%@]\n%@", [_selectedStatusUpdateVO.dictionary objectForKey:@"img"], conversation.identifier, conversation);
//	
//	if (conversation == nil) {
//		_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
//		_loadingOverlayView.delegate = self;
//		
//		
//		NSDictionary *dict = [_convos objectForKey:NSStringFromInt(_selectedStatusUpdateVO.statusUpdateID)];
//		LYRConversation *convo = [dict objectForKey:@"convo"];
//		LYRMessage *message = [dict objectForKey:@"msg"];
//		
//		NSLog(@"STORED CONVO:[%@]\nSTORED MSG:[%@]", convo, message);
//		
//		BOOL success = [[HONLayerKitAssistant sharedInstance] sendMessage:message toConversation:convo];
//		
//		[self _retrieveStatusUpdate];
//	} else {
//		[self.navigationController pushViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedStatusUpdateVO forClub:[[HONClubAssistant sharedInstance] currentLocationClub]] animated:NO];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedStatusUpdateVO forClub:[[HONClubAssistant sharedInstance] currentLocationClub]]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:^(void) {
		}];
//	}
}


#pragma mark - LoadingOverlayView Delegates
- (void)loadingOverlayViewDidIntro:(HONLoadingOverlayView *)loadingOverlayView {
	
}

- (void)loadingOverlayViewDidOutro:(HONLoadingOverlayView *)loadingOverlayView {
	
}


#pragma mark - LocationManager Delegates
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"**_[%@ locationManager:didFailWithError:(%@)]_**", self.class, error.description);
	
	[[HONAPICaller sharedInstance] retrieveLocationFromIPAddressWithCompletion:^(NSDictionary *result) {
		[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[result objectForKey:@"location"]];
		
		[[HONDeviceIntrinsics sharedInstance] updateGeoLocale:@{@"city"		: [result objectForKey:@"city"],
																@"state"	: [result objectForKey:@"state"]}];
		
		HONUserClubVO *globalClubVO = [[HONClubAssistant sharedInstance] globalClub];
		if ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:globalClubVO.location] < globalClubVO.joinRadius) {
			[_locationManager stopUpdatingLocation];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:^(void) {
			}];
			
		} else {
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
		}
	}];}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"**_[%@ locationManager:didChangeAuthorizationStatus:(%@)]_**", self.class, NSStringFromCLAuthorizationStatus(status));
	NSLog(@"LOCATION:[%@]", NSStringFromCLLocation([[HONDeviceIntrinsics sharedInstance] deviceLocation]));
	
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	if (status == kCLAuthorizationStatusNotDetermined) {
		[_locationManager startUpdatingLocation];
		
	} else if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - location_accept"];
//		[_locationManager startUpdatingLocation];
	
	} else if (status == kCLAuthorizationStatusDenied) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - location_cancel"];
		[[HONAPICaller sharedInstance] retrieveLocationFromIPAddressWithCompletion:^(NSDictionary *result) {
			[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[result objectForKey:@"location"]];
			
			[[HONDeviceIntrinsics sharedInstance] updateGeoLocale:@{@"city"		: [result objectForKey:@"city"],
																	@"state"	: [result objectForKey:@"state"]}];
			
			HONUserClubVO *globalClubVO = [[HONClubAssistant sharedInstance] globalClub];
			if ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:globalClubVO.location] < globalClubVO.joinRadius) {
				[_locationManager stopUpdatingLocation];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:NO completion:^(void) {
				}];
				
			} else {
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
			}
		}];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	NSLog(@"**_[%@ locationManager:didUpdateLocations:(%@)]_**", self.class, locations);
	[_locationManager stopUpdatingLocation];
	_locationManager.delegate = nil;
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - location_AF"];
	[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[locations firstObject]];
	
	HONUserClubVO *globalClubVO = [[HONClubAssistant sharedInstance] globalClub];
	if ([[HONDeviceIntrinsics sharedInstance] hasNetwork]) {
		if ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:globalClubVO.location] < globalClubVO.joinRadius) {
			[_locationManager stopUpdatingLocation];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:^(void) {
			}];
			
		} else {
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
		}
	
	} else {
		_noNetworkView.hidden = NO;
		_statusUpdates = [NSMutableArray array];
		[_refreshControl endRefreshing];
		[_tableView reloadData];
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_statusUpdates count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"[_] tableView:cellForRowAtIndexPath:%@)", NSStringFromNSIndexPath(indexPath));
	
	HONHomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	if (cell == nil)
		cell = [[HONHomeViewCell alloc] init];
	
	[cell setIndexPath:indexPath];
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
//	cell.alpha = 0.0;
	
	HONStatusUpdateVO *vo = (HONStatusUpdateVO *)[_statusUpdates objectAtIndex:indexPath.row];
	cell.statusUpdateVO = vo;
	cell.delegate = self;

	if (!tableView.decelerating)
		[cell toggleImageLoading:YES];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (84.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[_] tableView:didSelectRowAtIndexPath:[%@]", NSStringFromNSIndexPath(indexPath));
	
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONHomeViewCell *cell = (HONHomeViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	_selectedStatusUpdateVO = cell.statusUpdateVO;
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - row_select"];
	
//	NSError *error = nil;
//	LYRQuery *convoQuery = [LYRQuery queryWithClass:[LYRConversation class]];
//	convoQuery.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:[cell.statusUpdateVO.dictionary objectForKey:@"img"]];
//	LYRConversation *conversation = [[[[HONLayerKitAssistant sharedInstance] client] executeQuery:convoQuery error:&error] firstObject];
//	
//	NSLog(@"CONVO: -=- (%@) -=- [%@]\n%@", [cell.statusUpdateVO.dictionary objectForKey:@"img"], conversation.identifier, conversation);
//	
//	if (conversation == nil) {
//		_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
//		_loadingOverlayView.delegate = self;
//		
//		NSDictionary *dict = [_convos objectForKey:NSStringFromInt(_selectedStatusUpdateVO.statusUpdateID)];
//		LYRConversation *convo = [dict objectForKey:@"convo"];
//		LYRMessage *message = [dict objectForKey:@"msg"];
//		
//		NSLog(@"STORED CONVO:[%@]\nSTORED MSG:[%@]", convo, message);
//		
//		BOOL success = [[HONLayerKitAssistant sharedInstance] sendMessage:message toConversation:convo];
//		
//		[self _retrieveStatusUpdate];
//		
//	} else {
//		[self.navigationController pushViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedStatusUpdateVO forClub:[[HONClubAssistant sharedInstance] currentLocationClub]] animated:NO];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedStatusUpdateVO forClub:[[HONClubAssistant sharedInstance] currentLocationClub]]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:^(void) {
		}];
//	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//	cell.alpha = 0.0;
//	[UIView animateKeyframesWithDuration:0.125 delay:(0.0625 * MIN(indexPath.row, 6)) options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
//		cell.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	HONHomeViewCell *viewCell = (HONHomeViewCell *)cell;
	[viewCell toggleImageLoading:NO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
		[cell toggleImageLoading:YES];
	}];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"OFFSET:[%@]\nSIZE:[%@]\nBOTTOM:[%@]", NSStringFromCGPoint(_tableView.contentOffset), NSStringFromCGSize(_tableView.contentSize), NSStringFromBOOL([_tableView isAtBottom]));
	
	if (scrollView.contentSize.height > scrollView.frame.size.height && [scrollView isAtContentBottom] && [_statusUpdates count] < _totStatusUpdates && !_isLoading) {
		_isLoading = YES;
		
		if (_overlayView == nil) {
			_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
			_overlayView.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.33];
			_overlayView.alpha = 0.0;
			[self.view addSubview:_overlayView];
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:_overlayView animated:YES];
			_progressHUD.labelText = @"";
			_progressHUD.mode = MBProgressHUDModeIndeterminate;
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.taskInProgress = YES;
			
			[UIView animateKeyframesWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
				_overlayView.alpha = 1.0;
				
			} completion:^(BOOL finished) {
				_overlayTimer = [NSTimer timerWithTimeInterval:[HONAPICaller timeoutInterval] target:self
													  selector:@selector(_orphanSubmitOverlay)
													  userInfo:nil repeats:NO];
				
				if (_feedType == HONHomeFeedTypeOwned)
					[self _retriveOwnedPhotosAtPage:(int)([_statusUpdates count] / 10)];
				
				else
					[self _retrieveClubPhotosAtPage:(int)([_statusUpdates count] / 10)];
			}];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		if (buttonIndex == 0) {
			_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
			_loadingOverlayView.delegate = self;
			
			NSString *channelName = [NSString stringWithFormat:@"%d_%d", [[HONUserAssistant sharedInstance] activeUserID], [NSDate elapsedUTCSecondsSinceUnixEpoch]];
			PNChannel *channel = [PNChannel channelWithName:channelName shouldObservePresence:YES];
			[PubNub subscribeOnChannel:channel];
			
			NSError *error;
			NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[channelName] options:0 error:&error]
														 encoding:NSUTF8StringEncoding];
			
			NSDictionary *submitParams = @{@"user_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
										   @"img_url"		: channelName,
										   @"club_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
										   @"challenge_id"	: @(0),
										   @"topic_id"		: @(0),
										   @"subject"		: channelName,
										   @"subjects"		: jsonString};
			NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", submitParams);
			
			
			NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", submitParams);
			[[HONAPICaller sharedInstance] submitStatusUpdateWithDictionary:submitParams completion:^(NSDictionary *result) {
				if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
					if (_progressHUD == nil)
						_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
					_progressHUD.minShowTime = kProgressHUDMinDuration;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
					_progressHUD.labelText = @"Error!";
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
					_progressHUD = nil;
					
				} else {
				} // api result
				
				[_loadingOverlayView outro];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
				
				[[[UIAlertView alloc] initWithTitle:nil
											message:[NSString stringWithFormat:@"Your Derp URL is derpch.at/%d", [[result objectForKey:@"id"] intValue]]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			}]; // api submit
		
		} else if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeTopicViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] currentLocationClub]]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
			[self _flagStatusUpdate];
		}
	}
}


@end
