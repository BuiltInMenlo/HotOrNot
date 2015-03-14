//
//  HONHomeViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <LayerKit/LayerKit.h>

#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSNumber+BuiltInMenlo.h"
#import "NSString+BuiltinMenlo.h"
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
#import "HONPaginationView.h"
#import "HONScrollView.h"
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
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONPaginationView *paginationView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *cursorImageView;
@property (nonatomic, strong) UIButton *composeButton;
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
@property (nonatomic, strong) NSString *composeSubject;
@property (nonatomic, strong) UIButton *submitButton;
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
	
//	_locationManager.delegate = nil;
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


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeHomeTabRefresh];
	
	_isLoading = YES;
//	_locationManager.delegate = self;
//	if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
//		[_locationManager startUpdatingLocation];
	
//	else
		[self _goReloadContents];
}

- (void)_goReloadContents {
	if ([[HONDeviceIntrinsics sharedInstance] hasNetwork]) {
//		_locationManager.delegate = nil;
		
		_noNetworkView.hidden = YES;
		[_toggleView toggleEnabled:NO];
		
		_retrievedStatusUpdates = [NSMutableArray array];
		_statusUpdates = [NSMutableArray array];
		[_tableView reloadData];
		
		[self _didFinishDataRefresh];
		
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
	[_headerView addSettingsButtonWithTarget:self action:@selector(_goSettings)];
	[self.view addSubview:_headerView];
	
	_toggleView = [[HONHomeFeedToggleView alloc] initWithTypes:@[@(HONHomeFeedTypeRecent), @(HONHomeFeedTypeTop)]];
	_toggleView.delegate = self;
	[_toggleView toggleEnabled:NO];
	//[_headerView addSubview:_toggleView];
	
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight)];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 4.0, _scrollView.frame.size.height);
	_scrollView.alwaysBounceHorizontal = YES;
	_scrollView.pagingEnabled = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	UIImageView *tutorial1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_01"]];
	tutorial1ImageView.frame = CGRectTranslateY(tutorial1ImageView.frame, kNavHeaderHeight - 24.0);
	[_scrollView addSubview:tutorial1ImageView];
	
	UILabel *tutorial1Label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, _scrollView.frame.size.height - 107.0, 280.0, 30.0)];
	tutorial1Label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20.0];
	tutorial1Label.textColor = [UIColor blackColor];
	tutorial1Label.backgroundColor = [UIColor clearColor];
	tutorial1Label.textAlignment = NSTextAlignmentCenter;
	tutorial1Label.text = @"hide from SMS & more";
	[_scrollView addSubview:tutorial1Label];
	
	UIImageView *tutorial2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_02"]];
	tutorial2ImageView.frame = CGRectOffset(tutorial2ImageView.frame, _scrollView.frame.size.width, kNavHeaderHeight - 24.0);
	[_scrollView addSubview:tutorial2ImageView];
	
	UILabel *tutorial2Label = [[UILabel alloc] initWithFrame:CGRectMake(340.0, _scrollView.frame.size.height - 107.0, 280.0, 30.0)];
	tutorial2Label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20.0];
	tutorial2Label.textColor = [UIColor blackColor];
	tutorial2Label.backgroundColor = [UIColor clearColor];
	tutorial2Label.textAlignment = NSTextAlignmentCenter;
	tutorial2Label.text = @"use DOOD chat links";
	[_scrollView addSubview:tutorial2Label];
	
	UIImageView *tutorial3ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_03"]];
	tutorial3ImageView.frame = CGRectOffset(tutorial3ImageView.frame, _scrollView.frame.size.width * 2.0, kNavHeaderHeight - 24.0);
	[_scrollView addSubview:tutorial3ImageView];
	
	UILabel *tutorial3Label = [[UILabel alloc] initWithFrame:CGRectMake(660.0, _scrollView.frame.size.height - 107.0, 280.0, 30.0)];
	tutorial3Label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20.0];
	tutorial3Label.textColor = [UIColor blackColor];
	tutorial3Label.backgroundColor = [UIColor clearColor];
	tutorial3Label.textAlignment = NSTextAlignmentCenter;
	tutorial3Label.text = @"no history or usernames";
	[_scrollView addSubview:tutorial3Label];
	
	_paginationView = [[HONPaginationView alloc] initAtPosition:CGPointMake(160.0, self.view.frame.size.height - 43.0) withTotalPages:4 usingDiameter:4.0 andPadding:5.0];
	[_paginationView updateToPage:0];
	[self.view addSubview:_paginationView];
	
	_isLoading = YES;
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) style:UITableViewStylePlain];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.alwaysBounceVertical = YES;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.scrollsToTop = NO;
//	[self.view addSubview:_tableView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	_noNetworkView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 233.0, 320.0, 90.0)];
	_noNetworkView.hidden = YES;
	[_noNetworkView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noNetworkBG"]]];
	[_scrollView addSubview:_noNetworkView];
	
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
	//[_scrollView addSubview:_emptyFeedView];
	
	_composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_composeButton.frame = CGRectMake(105.0, self.view.frame.size.height, 111.0, 111.0);
	[_composeButton setBackgroundImage:[UIImage imageNamed:@"composeButton_nonActive"] forState:UIControlStateNormal];
	[_composeButton setBackgroundImage:[UIImage imageNamed:@"composeButton_Active"] forState:UIControlStateHighlighted];
	[_composeButton addTarget:self action:@selector(_goTextField) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_composeButton];
	
	_cursorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1020.0, 151.0, 1.0, 34.0)];
	_cursorImageView.animationImages = @[[UIImage imageNamed:@"composeCursor-02"],
										 [UIImage imageNamed:@"composeCursor-01"]];
	_cursorImageView.animationDuration = 1.0;
	_cursorImageView.animationRepeatCount = 0;
	[_scrollView addSubview:_cursorImageView];
	
	_textField = [[UITextField alloc] initWithFrame:CGRectMake(1035.0, 153.0, 220.0, 26.0)];
	[_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_textField setReturnKeyType:UIReturnKeyDone];
	[_textField setTextColor:[UIColor blackColor]];
	[_textField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_textField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20];
	_textField.keyboardType = UIKeyboardTypeAlphabet;
	_textField.placeholder = @"what are you doing?";
	_textField.delegate = self;
	[_scrollView addSubview:_textField];
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
		
		
		
//		_locationManager = [[CLLocationManager alloc] init];
//		_locationManager.delegate = self;
//		_locationManager.distanceFilter = 1000;
//		if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
//			[_locationManager requestWhenInUseAuthorization];
//		[_locationManager startUpdatingLocation];
		
		[[HONAPICaller sharedInstance] retrieveLocationFromIPAddressWithCompletion:^(NSDictionary *result) {
			[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[result objectForKey:@"location"]];
			
			[[HONDeviceIntrinsics sharedInstance] updateGeoLocale:@{@"city"		: [result objectForKey:@"city"],
																	@"state"	: [result objectForKey:@"state"],
																	@"region"	: [result objectForKeyedSubscript:@"region"]}];
			
			[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[[CLLocation alloc] initWithLatitude:[[result objectForKey:@"lat"] floatValue] longitude:[[result objectForKey:@"lon"] floatValue]]];
			
//			HONUserClubVO *globalClubVO = [[HONClubAssistant sharedInstance] globalClub];
//			if ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:globalClubVO.location] < globalClubVO.joinRadius) {
////				[_locationManager stopUpdatingLocation];
//				
//				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRestrictedViewController alloc] init]];
//				[navigationController setNavigationBarHidden:YES];
//				[self presentViewController:navigationController animated:NO completion:^(void) {
//				}];
//				
//			} else {
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
//			}
		}];
		
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
	
	if (![_cursorImageView isAnimating])
		[_cursorImageView startAnimating];
}


#pragma mark - Navigation
- (void)_goRegistration {
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:^(void) {
//	}];
	
	NSLog(@"_checkUsername -- ID:[%d]", [[HONUserAssistant sharedInstance] activeUserID]);
	NSLog(@"_checkUsername -- USERNAME:[%@]", [[HONUserAssistant sharedInstance] activeUsername]);
	NSLog(@"_checkUsername -- PHONE:[%@]", [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
	
	NSLog(@"\n\n******** USER/PHONE API CHECK **********\n");
	[[HONAPICaller sharedInstance] checkForAvailableUsername:[[HONUserAssistant sharedInstance] activeUsername] completion:^(NSDictionary *result) {
		NSLog(@"RESULT:[%@]", result);
		
		if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
		} else {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[HONAPICaller sharedInstance] checkForAvailablePhone:[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]] completion:^(NSDictionary *result) {
					if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue])
						NSLog(@"\n\n!¡!¡!¡ FAILED API NAME/PHONE CHECK !¡!¡!¡");
					
					else
						NSLog(@"\n\n******** PASSED API NAME/PHONE CHECK **********");
				}];
			});
			
			NSLog(@"_finalizeUser -- ID:[%d]", [[HONUserAssistant sharedInstance] activeUserID]);
			NSLog(@"_finalizeUser -- USERNAME_TXT:[%@] -=- PREV:[%@]", [[HONUserAssistant sharedInstance] activeUsername], [[HONUserAssistant sharedInstance] activeUsername]);
			NSLog(@"_finalizeUser -- PHONE_TXT:[%@] -=- PREV[%@]", [NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]], [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
			
			NSLog(@"\n\n******** FINALIZE W/ API **********");
			[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
																		@"username"		: [[HONUserAssistant sharedInstance] activeUsername],
																		@"phone"		: [[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]] stringByAppendingString:@"@selfieclub.com"]} completion:^(NSDictionary *result) {
																			
																			
																			NSLog(@"~*~*~*~*~*~* FINALIZE UPDATE !¡!¡!¡!¡!¡!¡!¡!\n%@", result);
																			int responseCode = [[result objectForKey:@"result"] intValue];
																			if (result != nil && responseCode == 0) {
																				[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
																				[[HONDeviceIntrinsics sharedInstance] writePhoneNumber:[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]]];
																				
																				[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - complete"];
																				[_loadingOverlayView outro];
//																				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
																					KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
																					[keychain setObject:NSStringFromBOOL(YES) forKey:CFBridgingRelease(kSecAttrAccount)];
																					
																					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
																						[[HONAPICaller sharedInstance] updateUsernameForUser:[[HONUserAssistant sharedInstance] activeUsername] completion:^(NSDictionary *result) {
																							NSLog(@"~*~*~*~*~*~* USERAME UPDATE !¡!¡!¡!¡!¡!¡!¡!");
																							
																							if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
																								[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
																							
																							[[HONAPICaller sharedInstance] updateAvatarWithImagePrefix:[[HONUserAssistant sharedInstance] rndAvatarURL] completion:^(NSDictionary *result) {
																								NSLog(@"~*~*~*~*~*~* AVATAR UPDATE !¡!¡!¡!¡!¡!¡!¡!");
																								
																								if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
																									[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
																								
																								[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSDictionary *result) {
																									NSLog(@"~*~*~*~*~*~* PHONE UPDATE !¡!¡!¡!¡!¡!¡!¡!\n");
																									
																									if (!((BOOL)[[result objectForKey:@"result"] intValue]))
																										NSLog(@"!¡!¡!¡!¡!¡!¡!¡ PHONE UPDATE FAILED !¡!¡!¡!¡!¡!¡!¡!");
																								}];
																							}];
																						}];
																					});
																					
																					[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETED_FIRST_RUN" object:nil];
//																				}];
																				
																			} else {
																				[_loadingOverlayView outro];
																				
																				if (_progressHUD == nil)
																					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
																				[_progressHUD setYOffset:-80.0];
																				_progressHUD.minShowTime = kProgressHUDErrorDuration;
																				_progressHUD.mode = MBProgressHUDModeCustomView;
																				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
																				_progressHUD.labelText = NSLocalizedString((responseCode == 1) ? @"hud_usernameTaken" : (responseCode == 2) ? @"phone_taken" : (responseCode == 3) ? @"user_phone" : @"hud_loadError", nil);
																				[_progressHUD show:NO];
																				[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration + 0.75];
																				_progressHUD = nil;
																			}
																		}]; // finalize
		}
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

- (void)_goTextField {
	if (![_textField isFirstResponder])
		[_textField becomeFirstResponder];
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
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation"
														message:_textField.text
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
											  otherButtonTitles:@"Create Chat", nil];
	[alertView setTag:1];
	[alertView show];
	
//	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select the type of DOOD you want to create:"
//															 delegate:self
//													cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
//											   destructiveButtonTitle:nil
//													otherButtonTitles:@"Deep link (only people with the link can see)", @"Open (people on DOOD can see)", nil];
//	[actionSheet setTag:0];
//	[actionSheet showInView:self.view];
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
	
	self.view.hidden = NO;
	
//	_locationManager = [[CLLocationManager alloc] init];
//	_locationManager.delegate = self;
//	_locationManager.distanceFilter = 100;
//	
//	if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
//		[_locationManager requestWhenInUseAuthorization];
//	[_locationManager startUpdatingLocation];
	
	[[HONAPICaller sharedInstance] retrieveLocationFromIPAddressWithCompletion:^(NSDictionary *result) {
		[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[result objectForKey:@"location"]];
		
		[[HONDeviceIntrinsics sharedInstance] updateGeoLocale:@{@"city"		: [result objectForKey:@"city"],
																@"state"	: [result objectForKey:@"state"]}];
		
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

- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	UITextField *textField = (UITextField *)[notification object];
	
	if ([textField.text length] == 0)
		[textField resignFirstResponder];
}


#pragma mark - UI Presentation
- (void)_orphanSubmitOverlay {
	NSLog(@"::|> _orphanSubmitOverlay <|::");
	
	if ([_overlayTimer isValid])
		[_overlayTimer invalidate];
	
	if (_overlayTimer != nil);
	_overlayTimer = nil;
	
	if (_overlayView != nil) {
		[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
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
		
//		HONUserClubVO *globalClubVO = [[HONClubAssistant sharedInstance] globalClub];
//		if ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:globalClubVO.location] < globalClubVO.joinRadius) {
////			[_locationManager stopUpdatingLocation];
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
}

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
			
//			HONUserClubVO *globalClubVO = [[HONClubAssistant sharedInstance] globalClub];
//			if ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:globalClubVO.location] < globalClubVO.joinRadius) {
////				[_locationManager stopUpdatingLocation];
//				
//				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRestrictedViewController alloc] init]];
//				[navigationController setNavigationBarHidden:YES];
//				[self presentViewController:navigationController animated:NO completion:^(void) {
//				}];
//				
//			} else {
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
//			}
		}];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	NSLog(@"**_[%@ locationManager:didUpdateLocations:(%@)]_**", self.class, locations);
//	[_locationManager stopUpdatingLocation];
//	_locationManager.delegate = nil;
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - location_AF"];
	[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[locations firstObject]];
	
//	HONUserClubVO *globalClubVO = [[HONClubAssistant sharedInstance] globalClub];
	if ([[HONDeviceIntrinsics sharedInstance] hasNetwork]) {
//		if ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:globalClubVO.location] < globalClubVO.joinRadius) {
////			[_locationManager stopUpdatingLocation];
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
	
	[cell hideChevron];
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


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	if ([_cursorImageView isAnimating])
		[_cursorImageView stopAnimating];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, self.view.frame.size.height, 320.0, 44.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"composeTextButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"composeTextButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
	_submitButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	[_submitButton setTitle:@"Start Chat" forState:UIControlStateNormal];
	[_submitButton setTitle:@"Start Chat" forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_submitButton];
	
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _submitButton.frame = CGRectOffsetY(_submitButton.frame, -(216.0 + 44.0));
					 } completion:^(BOOL finished) {
					 }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
//	[_conversation sendTypingIndicator:LYRTypingDidFinish];
	if ([textField.text length] > 0)
		[self _goCompose];
	
	else {
		if (![_cursorImageView isAnimating])
			[_cursorImageView startAnimating];
	}
	
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
	
	[_submitButton removeFromSuperview];
	[_submitButton removeTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	_submitButton = nil;
}

- (void)_onTextEditingDidEnd:(id)sender {
	//	NSLog(@"[*:*] _onTextEditingDidEnd:[%@]", _commentTextField.text);
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.x < 960) {
		if ([_textField isFirstResponder])
			[_textField resignFirstResponder];
		
		[UIView animateWithDuration:0.25 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			_composeButton.alpha = 0.0;
			_composeButton.frame = CGRectTranslateY(_composeButton.frame, self.view.frame.size.height);
		} completion:^(BOOL finished) {
		}];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
//		[cell toggleImageLoading:YES];
//	}];
	
	[_paginationView updateToPage:scrollView.contentOffset.x / scrollView.frame.size.width];
	
	if (scrollView.contentOffset.x == 960) {
		if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
			[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
			[[UIApplication sharedApplication] registerForRemoteNotifications];
			
		} else
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
		
		if (![_cursorImageView isAnimating])
			[_cursorImageView startAnimating];
		
		_composeButton.alpha = 0.0;
		_composeButton.frame = CGRectTranslateY(_composeButton.frame, self.view.frame.size.height);
		[UIView animateWithDuration:0.25 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
			_composeButton.alpha = 1.0;
			_composeButton.frame = CGRectTranslateY(_composeButton.frame, self.view.frame.size.height - 176.0);
			
		} completion:^(BOOL finished) {
			if (![_textField isFirstResponder])
				[_textField becomeFirstResponder];
		}];
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
			[self _flagStatusUpdate];
		}
	
	} else if (alertView.tag == 1) {
		if (buttonIndex == 1) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"HOME - compose"];
			
			_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
			_loadingOverlayView.delegate = self;
			
			NSError *error;
			NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[@""] options:0 error:&error]
														 encoding:NSUTF8StringEncoding];
			
			NSDictionary *submitParams = @{@"user_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
										   @"img_url"		: @"",
										   @"club_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
										   @"challenge_id"	: @(0),
										   @"topic_id"		: @(0),
										   @"subject"		: [_textField.text stringByAppendingString:@"|"],
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
				
				_selectedStatusUpdateVO = [HONStatusUpdateVO statusUpdateWithDictionary:result];
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"doodch.at/%d/", _selectedStatusUpdateVO.statusUpdateID];
				
				_textField.text = @"";
				if ([_textField isFirstResponder])
					[_textField resignFirstResponder];
				
				[self.navigationController pushViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:_selectedStatusUpdateVO forClub:[[HONClubAssistant sharedInstance] currentLocationClub]] animated:YES];
				[_loadingOverlayView outro];
			}]; // api submit
		}
	
	} else if (alertView.tag == 2) {
		if (buttonIndex == 1) {
			[[HONSocialCoordinator sharedInstance] presentActionSheetForSharingWithMetaData:@{@"deeplink"	: [NSString stringWithFormat:@"dood://%d", _selectedStatusUpdateVO.statusUpdateID]}];
		}
	}
}


@end
