//
//  HONUserClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONUserClubsViewController.h"
#import "HONClubsViewFlowLayout.h"

#import "HONClubViewCell.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONInsetOverlayView.h"
#import "HONCreateSnapButtonView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONSelfieCameraViewController.h"
#import "HONUserProfileViewController.h"
#import "HONCreateClubViewController.h"
#import "HONClubSettingsViewController.h"
//#import "HONInviteContactsViewController.h"
#import "HONClubTimelineViewController.h"
#import "HONContactsSearchViewController.h"
#import "HONHighSchoolSearchViewController.h"
#import "HONTabBannerView.h"
#import "HONSearchBarView.h"
#import "HONUserClubVO.h"
#import "HONTrivialUserVO.h"
#import "HONTableView.h"

@interface HONUserClubsViewController () <HONClubViewCellDelegate, HONInsetOverlayViewDelegate, HONSelfieCameraViewControllerDelegate, HONTabBannerViewDelegate>
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONTabBannerView *tabBannerView;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONActivityHeaderButtonView *activityHeaderView;
@property (nonatomic, strong) NSMutableArray *dictClubs;
@property (nonatomic, strong) NSMutableDictionary *clubs;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;
@property (nonatomic, strong) HONInsetOverlayView *insetOverlayView;
@property (nonatomic) HONUserClubsViewControllerAppearedType appearedType;
//@property (nonatomic) HONUserClubsDataSetType dataSetType;
@end


@implementation HONUserClubsViewController

- (id)init {
	if ((self = [super init])) {
		_appearedType = HONUserClubsViewControllerAppearedTypeClear;
		_dictClubs = [NSMutableArray array];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedClubsTab:) name:@"SELECTED_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareClubsTab:) name:@"TARE_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_createdNewClub:) name:@"CREATED_NEW_CLUB" object:nil];
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
- (void)_retrieveClubs {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_tableView.alpha = 0.0;
	}];
	
	_dictClubs = [NSMutableArray array];
	_clubs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array]]
												forKeys:@[@"create",
														  @"suggested",
														  @"pending",
														  @"member"]];
		
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		[[HONClubAssistant sharedInstance] writeUserClubs:result];
		
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			NSMutableArray *clubVOs = [_clubs objectForKey:([key isEqualToString:@"owned"] || [key isEqualToString:@"member"]) ? @"member" : key];
			
			for (NSDictionary *dict in [result objectForKey:key]) {
//				if ([[dict objectForKey:@"id"] intValue] != 100) {
					[clubVOs addObject:[HONUserClubVO clubWithDictionary:dict]];
					[_dictClubs addObject:dict];
//				}
			}
			
			if ([key isEqualToString:@"owned"] || [key isEqualToString:@"member"]) {
//				[_clubs setValue:clubVOs forKey:@"member"];
				[_clubs setValue:[[clubVOs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
					HONUserClubVO *club1VO = (HONUserClubVO *)obj1;
					HONUserClubVO *club2VO = (HONUserClubVO *)obj2;
					
					if ([club1VO.updatedDate timeIntervalSince1970] < [club2VO.updatedDate timeIntervalSince1970])
						return ((NSComparisonResult)NSOrderedDescending);
					
					if ([club1VO.updatedDate timeIntervalSince1970] > [club2VO.updatedDate timeIntervalSince1970])
						return ((NSComparisonResult)NSOrderedAscending);
					
					return ((NSComparisonResult)NSOrderedSame);
				}] mutableCopy] forKey:@"member"];
				
			} else {
				[_clubs setValue:clubVOs forKey:key];
			}
		}
		
		[self _didFinishDataRefresh];
	}];
}

- (void)_deleteClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] deleteClubWithClubID:vo.clubID completion:^(NSObject *result) {
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
//			[[HONClubAssistant sharedInstance] writeUserClubs:result];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
		}];
	}];
}

- (void)_editClub:(HONUserClubVO *)vo {
}

- (void)_joinClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] joinClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			[[HONClubAssistant sharedInstance] writeUserClubs:result];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
		}];
	}];
}

- (void)_leaveClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] leaveClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
//			[[HONClubAssistant sharedInstance] writeUserClubs:result];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
		}];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Refresh"];
	[self _retrieveClubs];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	_tableView.alpha = 1.0;
	
	[_refreshControl endRefreshing];
	[_tableView reloadData];
}


#pragma mark - Data Manip


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	
	_activityHeaderView = [[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)];
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_clubs", @"Clubs")];
//	[headerView addButton:_activityHeaderView];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight)];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
//	@property(nonatomic) BOOL cancelsTouchesInView;	   // default is YES. causes touchesCancelled:withEvent: to be sent to the view for all touches recognized as part of this gesture immediately before the action method is called
//	@property(nonatomic) BOOL delaysTouchesBegan;		 // default is NO.  causes all touch events to be delivered to the target view only after this gesture has failed recognition. set to YES to prevent views from processing any touches that may be recognized as part of this gesture
//	@property(nonatomic) BOOL delaysTouchesEnded;		 // default is YES. causes touchesEnded events to be delivered to the target view only after this gesture has failed recognition. this ensures that a touch that is part of the gesture can be cancelled if the gesture is recognized
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	longPressGestureRecognizer.minimumPressDuration = 0.5;
	longPressGestureRecognizer.cancelsTouchesInView = NO;
	longPressGestureRecognizer.delaysTouchesBegan = NO;
	longPressGestureRecognizer.delaysTouchesEnded = NO;
	longPressGestureRecognizer.delegate = self;
	[_tableView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	if ([_dictClubs count] == 0)
		[self _retrieveClubs];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	UINavigationController *navigationController = (UINavigationController *)self.presentedViewController;
	UIViewController *viewController = (UIViewController *)[navigationController.viewControllers lastObject];
	NSLog(@"navigationController:[%@] presentedViewController.nameOfClass:[%@]", self.navigationController, viewController.nameOfClass);
	
//	if ([HONAppDelegate totalForCounter:@"background"] >= 3 && _tabBannerView == nil) {
//		[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom + 65.0, _tableView.contentInset.right)];
//		
//		_tabBannerView = [[HONTabBannerView alloc] init];
//		_tabBannerView.delegate = self;
//		[self.view addSubview:_tabBannerView];
//	}
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	NSLog(@"clubsTab_total:[%d]", [HONAppDelegate totalForCounter:@"clubsTab"]);
	[_activityHeaderView updateActivityBadge];
	
	if (_appearedType == HONUserClubsViewControllerAppearedTypeCreateClubCompleted) {
		[self _retrieveClubs];
		_appearedType = HONUserClubsViewControllerAppearedTypeClear;
		[[HONClubAssistant sharedInstance] copyClubToClipBoard:_selectedClubVO withAlert:YES];
	}
}


#pragma mark - Navigation
- (void)_goProfile {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Activity"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Create Status Update"];
	
	HONSelfieCameraViewController *selfieCameraViewController = [[HONSelfieCameraViewController alloc] initAsNewChallenge];
	selfieCameraViewController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selfieCameraViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goClubSettings:(HONUserClubVO *)userClubVO {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateClub {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goContactsSearch {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - User Search"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONContactsSearchViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	NSLog(@"gestureRecognizer.state:[%@]", (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"Began" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"Canceled" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"Ended" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"Failed" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"Possible" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"Recognized" : @"UNKNOWN");
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
	
	NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:_tableView]];
	
	if (indexPath != nil) {
		HONClubViewCell *cell = (HONClubViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
		_selectedClubVO = cell.clubVO;
		
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
			if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeCreate) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Long Pressed Create Club Row"
												   withUserClub:_selectedClubVO];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
														  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
				[alertView setTag:HONUserClubsAlertTypeGenerateSuggested];
				[alertView show];
				
			} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeSuggested) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Long Pressed Suggested Club Row"
												   withUserClub:_selectedClubVO];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
														  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
				[alertView setTag:HONUserClubsAlertTypeGenerateSuggested];
				[alertView show];
				
			} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Long Pressed Invite Club Row"
												   withUserClub:_selectedClubVO];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
														  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
				[alertView setTag:HONUserClubsAlertTypeInviteContacts];
				[alertView show];
				
			} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeOwner) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Long Pressed Member Club Row"
												   withUserClub:_selectedClubVO];
				
				UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
																		 delegate:self
																cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
														   destructiveButtonTitle:nil
																otherButtonTitles:NSLocalizedString(@"alert_invite", @"Invite friends"), NSLocalizedString(@"copy_url", @"Copy Club URL"), nil];
				[actionSheet setTag:HONUserClubsActionSheetTypeOwner];
				[actionSheet showInView:self.view];
				
			} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeMember) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Long Pressed Member Club Row"
												   withUserClub:_selectedClubVO];
				
				UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
																		 delegate:self
																cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
														   destructiveButtonTitle:nil
																otherButtonTitles:NSLocalizedString(@"alert_invite", @"Invite friends"), NSLocalizedString(@"copy_url", @"Copy club URL"), nil];
				[actionSheet setTag:HONUserClubsActionSheetTypeMember];
				[actionSheet showInView:self.view];
				
			} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeThreshold) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Long Pressed Locked Club Row"
												   withUserClub:_selectedClubVO];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Would you like to unlock & purchase the 26MGMT club for $.99?"
//																	message:@""
//																   delegate:nil
//														  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
//														  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
//				[alertView setTag:HONUserClubsAlertTypeJoin];
//				[alertView show];
				
				if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] < [HONAppDelegate clubInvitesThreshold]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_lockedClub_t", nil)
																		message:[NSString stringWithFormat:NSLocalizedString(@"alert_lockedClub_m", nil), [HONAppDelegate clubInvitesThreshold], _selectedClubVO.clubName] //@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
																	   delegate:self
															  cancelButtonTitle:NSLocalizedString(@"alert_invite", nil)
															  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
					[alertView setTag:HONUserClubsAlertTypeInviteContacts];
					[alertView show];
					
				} else {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																		message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName] //@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
																	   delegate:self
															  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
															  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
					[alertView setTag:HONUserClubsAlertTypeJoin];
					[alertView show];
				}
			}
		}
	}
}


#pragma mark - Notifications
- (void)_selectedClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedClubsTab <|::");
	[_activityHeaderView updateActivityBadge];
}

- (void)_refreshClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshClubsTab <|::");
	[_activityHeaderView updateActivityBadge];
	[self _retrieveClubs];
}

- (void)_tareClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareClubsTab <|::");
	
	if (_tableView.contentOffset.y > 0)
		[_tableView setContentOffset:CGPointZero animated:YES];
}

- (void)_createdNewClub:(NSNotification *)notification {
	NSLog(@"::|> _createdNewClub <|::");
	_selectedClubVO = (HONUserClubVO *)[notification object];
	NSLog(@"%@", ((HONUserClubVO *)[notification object]).dictionary);
	
	_appearedType = HONUserClubsViewControllerAppearedTypeCreateClubCompleted;
}


#pragma mark - SelfieCameraViewController Delegates
- (void)selfieCameraViewControllerDidDismissByInviteOverlay:(HONSelfieCameraViewController *)viewController {
	NSLog(@"[*:*] selfieCameraViewControllerDidDismissByInviteOverlay");
	_appearedType = HONUserClubsViewControllerAppearedTypeSelfieCameraCanceled;
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] userSignupClub] viewControllerPushed:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - TabBannerView Delegates
- (void)tabBannerView:(HONTabBannerView *)bannerView joinAreaCodeClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:joinAreaCodeClub:[%@]", clubVO.clubName);
	
	_selectedClubVO = clubVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)tabBannerView:(HONTabBannerView *)bannerView joinFamilyClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:joinFamilyClub:[%@]", clubVO.clubName);
	
	_selectedClubVO = clubVO;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)tabBannerView:(HONTabBannerView *)bannerView createBaeClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:createBaeClub:[%d - %@]", clubVO.clubID, clubVO.clubName);
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)tabBannerView:(HONTabBannerView *)bannerView joinSchoolClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:joinSchoolClub:[%d - %@]", clubVO.clubID, clubVO.clubName);
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:clubVO.clubName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)tabBannerViewInviteContacts:(HONTabBannerView *)bannerView {
	NSLog(@"[[*:*]] tabBannerViewInviteContacts");
	
	_appearedType = HONUserClubsViewControllerAppearedTypeInviteFriends;
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] userSignupClub] viewControllerPushed:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	
//	[self presentViewController:navigationController animated:YES completion:^(void) {
//	}];
}


#pragma mark - InsetOverlayView Delegates
- (void)insetOverlayViewDidClose:(HONInsetOverlayView *)view {
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
	}];
}

- (void)insetOverlayViewDidReview:(HONInsetOverlayView *)view {
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
	}];
}

- (void)insetOverlayViewDidAskForSuggestions:(HONInsetOverlayView *)view {
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
	}];
}

- (void)insetOverlayViewDidUnlock:(HONInsetOverlayView *)view {
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
	}];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:nil viewControllerPushed:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - ClubViewCell Delegates
- (void)clubViewCell:(HONClubViewCell *)viewCell selectedClub:(HONUserClubVO *)clubVO {
	NSLog(@"[*|*] clubToggleViewCell:selectedClub(%d - %@)", clubVO.clubID, clubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Clubs Tab - Selected %@ Club Row", ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubVO.clubName]) ? @"Member" : @"Invite"]
									   withUserClub:clubVO];
	
	_selectedClubVO = clubVO;
	if ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubVO.clubName]) {
		if ([_selectedClubVO.submissions count] == 0) {
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_status", @"This club does not have any status updates yet!")
																 message:NSLocalizedString(@"alert_create", @"Would you like to create one?")
																delegate:self
													   cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
													   otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
			[alertView setTag:HONUserClubsAlertTypeSubmitPhoto];
			[alertView show];
			
		} else
			[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:_selectedClubVO atPhotoIndex:0] animated:YES];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
		[alertView setTag:HONUserClubsAlertTypeJoin];
		[alertView show];
	}
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	NSArray *visibleCells = [_tableView visibleCells];
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubViewCell *cell = (HONClubViewCell *)obj;
		[cell toggleImageLoading:YES];
	}];
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (3);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? 1 : (section == 1) ? [[_clubs objectForKey:@"pending"] count] : [[_clubs objectForKey:@"member"] count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubViewCell alloc] init];
	
	if (indexPath.section == 0) {
		[cell hideChevron];
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"createClub"]];
		
	} else if (indexPath.section == 1) {
		cell.clubVO = (HONUserClubVO *)[[_clubs objectForKey:@"pending"] objectAtIndex:indexPath.row];
		cell.delegate = self;
		
	} else {
		cell.clubVO = (HONUserClubVO *)[[_clubs objectForKey:@"member"] objectAtIndex:indexPath.row];
		cell.delegate = self;
	}
	
	if (indexPath.section > 0) {
		if (!tableView.decelerating)
			[cell toggleImageLoading:YES];
	}
	
	
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setSelectionStyle:(indexPath.section == 0) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray];
	
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125 delay:indexPath.row * 0.1 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (75.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONClubViewCell *cell = (HONClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	HONUserClubVO *vo = cell.clubVO;
	
	NSLog(@"vo.clubEnrollmentType:[%d]", vo.clubEnrollmentType);
	_selectedClubVO = vo;
	
	if (indexPath.section == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Selected Create Club Row"];
		
		cell.backgroundView.alpha = 0.5;
		[UIView animateWithDuration:0.33 animations:^(void) {
			cell.backgroundView.alpha = 1.0;
		}];
		[self _goCreateClub];
	}
	
	
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeOwner || vo.clubEnrollmentType == HONClubEnrollmentTypeMember) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Selected Member Club Row"
										   withUserClub:vo];
		
		NSLog(@"/// SHOW CLUB TIMELINE:(%@ - %@)", [vo.dictionary objectForKey:@"id"], [vo.dictionary objectForKey:@""]);
		
		if ([vo.submissions count] == 0) {
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_status", @"This club does not have any status updates yet!")
																 message:NSLocalizedString(@"alert_create", @"Would you like to create one?")
																delegate:self
													   cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
													   otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
			[alertView setTag:HONUserClubsAlertTypeSubmitPhoto];
			[alertView show];
			
		} else
			[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:vo atPhotoIndex:0] animated:YES];
		
	} else if (vo.clubEnrollmentType == HONClubEnrollmentTypeCreate) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Selected Create Club Row"];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
		
	} else if (vo.clubEnrollmentType == HONClubEnrollmentTypeSuggested) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Selected Suggested Club Row"
										   withUserClub:vo];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
		[alertView setTag:HONUserClubsAlertTypeGenerateSuggested];
		[alertView show];
		
	} else if (vo.clubEnrollmentType == HONClubEnrollmentTypePending) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Selected Invite Club Row"
										   withUserClub:vo];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
		[alertView setTag:HONUserClubsAlertTypeJoin];
		[alertView show];
		
	} else if (vo.clubEnrollmentType == HONClubEnrollmentTypeThreshold) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Tab - Selected Locked Club Row"
										   withUserClub:vo];
		
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Would you like to unlock & purchase the 26MGMT club for $.99?"
//															message:@""
//														   delegate:nil
//												  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
//												  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
//		[alertView setTag:HONUserClubsAlertTypeJoin];
//		[alertView show];
		
		if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] < [HONAppDelegate clubInvitesThreshold]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_lockedClub_t", nil)
																message:[NSString stringWithFormat:NSLocalizedString(@"alert_lockedClub_m", @"Would you like to join the %@ Selfieclub?"), [HONAppDelegate clubInvitesThreshold], _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_invite", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
			[alertView setTag:HONUserClubsAlertTypeInviteContacts];
			[alertView show];
			
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
			[alertView setTag:HONUserClubsAlertTypeJoin];
			[alertView show];
		}
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubViewCell *viewCell = (HONClubViewCell *)cell;
	[viewCell toggleImageLoading:NO];
}



#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == HONUserClubsActionSheetTypeSuggested) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Suggested Club Action Sheet " stringByAppendingString:(buttonIndex == 0) ? @"Invite" : (buttonIndex == 1) ? @"Copy" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
		if (buttonIndex == 0) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (buttonIndex == 1) {
			[[HONClubAssistant sharedInstance] copyClubToClipBoard:_selectedClubVO withAlert:YES];
		}
		
	} else if (actionSheet.tag == HONUserClubsActionSheetTypePending) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Invited Club Action Sheet " stringByAppendingString:(buttonIndex == 0) ? @"Invite" : (buttonIndex == 1) ? @"Copy" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
	} else if (actionSheet.tag == HONUserClubsActionSheetTypeOwner) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Member Club Action Sheet " stringByAppendingString:(buttonIndex == 0) ? @"Invite" : (buttonIndex == 1) ? @"Copy" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
		if (buttonIndex == 0) {
			_appearedType = HONUserClubsViewControllerAppearedTypeInviteFriends;
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (buttonIndex == 1) {
			[[HONClubAssistant sharedInstance] copyClubToClipBoard:_selectedClubVO withAlert:YES];
		}
		
	} else if (actionSheet.tag == HONUserClubsActionSheetTypeMember) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Member Club Action Sheet " stringByAppendingString:(buttonIndex == 0) ? @"Invite" : (buttonIndex == 1) ? @"Copy" : (buttonIndex == 1) ? @"Leave" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
		if (buttonIndex == 0) {
			_appearedType = HONUserClubsViewControllerAppearedTypeInviteFriends;
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (buttonIndex == 1) {
			[[HONClubAssistant sharedInstance] copyClubToClipBoard:_selectedClubVO withAlert:YES];
				
		} else if (buttonIndex == 2) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Leave %@", _selectedClubVO.clubName]
																message:[NSString stringWithFormat:@"Are you sure you want to leave %@?", _selectedClubVO.clubName]
																delegate:self
														cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
														otherButtonTitles:nil];
			[alertView setTag:HONUserClubsAlertTypeLeave];
			[alertView show];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONUserClubsAlertTypeGenerateSuggested) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Suggested Club Alert " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] createClubWithTitle:_selectedClubVO.clubName withDescription:_selectedClubVO.blurb withImagePrefix:_selectedClubVO.coverImagePrefix completion:^(NSDictionary *result) {
				[[HONClubAssistant sharedInstance] addClub:result forKey:@"owned"];
				[self _retrieveClubs];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:[NSString stringWithFormat: NSLocalizedString(@"want_invite", nil), _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
														  otherButtonTitles:@"Not Now", nil];
				[alertView setTag:HONUserClubsAlertTypeInviteContacts];
				[alertView show];
			}];
		}
		
	} else if (alertView.tag == HONUserClubsAlertTypeJoin) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Join Club Alert " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
		if (buttonIndex == 0) {
			[self _joinClub:_selectedClubVO];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat: NSLocalizedString(@"want_invite", nil), _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
													  otherButtonTitles:@"Not Now", nil];
			[alertView setTag:HONUserClubsAlertTypeInviteContacts];
			[alertView show];
		}
		
	} else if (alertView.tag == HONUserClubsAlertTypeLeave) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Leave Club Alert " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
		if (buttonIndex == 0) {
			[self _leaveClub:_selectedClubVO];
		}
		
	} else if (alertView.tag == HONUserClubsAlertTypeInviteContacts) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Invite Club Alert " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
		if (buttonIndex == 0) {
			_appearedType = HONUserClubsViewControllerAppearedTypeInviteFriends;
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == HONUserClubsAlertTypeSubmitPhoto) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs Tab - Submit Status Update Alert " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"]
										   withUserClub:_selectedClubVO];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithClub:_selectedClubVO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	}
}


@end
