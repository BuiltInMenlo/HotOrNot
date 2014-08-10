//
//  HONUserClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "CKRefreshControl.h"
#import "JLBPopSlideTransition.h"
#import "MBProgressHUD.h"

#import "HONUserClubsViewController.h"
#import "HONClubsViewFlowLayout.h"

#import "HONCollectionView.h"
#import "HONClubCollectionViewCell.h"
#import "HONClubToggleViewCell.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONInsetOverlayView.h"
#import "HONCreateSnapButtonView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONSelfieCameraViewController.h"
#import "HONUserProfileViewController.h"
#import "HONCreateClubViewController.h"
#import "HONClubSettingsViewController.h"
#import "HONInviteContactsViewController.h"
#import "HONClubTimelineViewController.h"
#import "HONHighSchoolSearchViewController.h"
#import "HONTabBannerView.h"
#import "HONSearchBarView.h"
#import "HONUserClubVO.h"
#import "HONTrivialUserVO.h"

@interface HONUserClubsViewController () <HONClubCollectionViewCellDelegate, HONClubToggleViewCellDelegate, HONCreateClubViewControllerDelegate, HONInsetOverlayViewDelegate, HONSearchBarViewDelegate, HONSelfieCameraViewControllerDelegate, HONTabBannerViewDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) HONCollectionView *collectionView;
@property (nonatomic, strong) HONTabBannerView *tabBannerView;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONActivityHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) NSMutableDictionary *clubIDs;
@property (nonatomic, strong) NSMutableArray *dictClubs;
@property (nonatomic, strong) NSMutableDictionary *clubs;
@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) NSArray *suggestedClubs;
@property (nonatomic, strong) NSMutableArray *searchClubs;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;
@property (nonatomic, strong) HONClubCollectionViewCell *selectedCell;
@property (nonatomic, strong) HONInsetOverlayView *insetOverlayView;
@property (nonatomic) HONUserClubsViewControllerAppearedType appearedType;
@property (nonatomic) HONUserClubsDataSetType dataSetType;
@end


@implementation HONUserClubsViewController

- (id)init {
	if ((self = [super init])) {
		_appearedType = HONUserClubsViewControllerAppearedTypeClear;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedClubsTab:) name:@"SELECTED_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareClubsTab:) name:@"TARE_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
- (void)_retrieveClubsWithCompletion:(void (^)(void))completion {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	for (UICollectionView *cell in _collectionView.visibleCells)
		cell.alpha = 0.0;
	
	_dictClubs = [NSMutableArray array];
	_clubIDs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array]]
												  forKeys:[[HONClubAssistant sharedInstance] clubTypeKeys]];
	
	_suggestedClubs = nil;
	_suggestedClubs = [NSMutableArray array];
	_clubs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array]]
												forKeys:@[@"create",
														  @"suggested",
														  @"pending",
														  @"member"]];
	
	[_dictClubs addObject:[[HONClubAssistant sharedInstance] createClubDictionary]];
	[_clubs setObject:@[[HONUserClubVO clubWithDictionary:[[HONClubAssistant sharedInstance] createClubDictionary]]] forKey:@"create"];
	
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		[[HONClubAssistant sharedInstance] wipeUserClubs];
		[[HONClubAssistant sharedInstance] writeUserClubs:result];
		
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
			NSMutableArray *clubVOs = [_clubs objectForKey:([key isEqualToString:@"owned"] || [key isEqualToString:@"member"]) ? @"member" : key];
			
			
			for (NSDictionary *dict in [result objectForKey:key]) {
#if SC_ACCT_BUILD == 0
				[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
				[clubVOs addObject:[HONUserClubVO clubWithDictionary:dict]];
				[_dictClubs addObject:dict];
#else
				if ([[dict objectForKey:@"id"] intValue] != 100) {
					[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
					[clubVOs addObject:[HONUserClubVO clubWithDictionary:dict]];
					[_dictClubs addObject:dict];
				}
#endif
			}
			
			if ([key isEqualToString:@"owned"] || [key isEqualToString:@"member"]) {
				[_clubIDs setValue:clubIDs forKey:key];
				[_clubs setValue:[clubVOs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
					HONUserClubVO *club1VO = (HONUserClubVO *)obj1;
					HONUserClubVO *club2VO = (HONUserClubVO *)obj2;
					
					if ([club1VO.updatedDate timeIntervalSince1970] < [club2VO.updatedDate timeIntervalSince1970])
						return ((NSComparisonResult)NSOrderedDescending);
					
					if ([club1VO.updatedDate timeIntervalSince1970] > [club2VO.updatedDate timeIntervalSince1970])
						return ((NSComparisonResult)NSOrderedAscending);
					
					return ((NSComparisonResult)NSOrderedSame);
				}] forKey:key];
				
			} else {
				[_clubIDs setValue:clubIDs forKey:key];
				[_clubs setValue:clubVOs forKey:key];
			}
		}
		
		//		_suggestedClubs	= (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:@"Locked Club"]) ? [[NSArray arrayWithObject:[HONUserClubVO clubWithDictionary:[[HONClubAssistant sharedInstance] orthodoxThresholdClubDictionary]]] arrayByAddingObjectsFromArray:[[HONClubAssistant sharedInstance] suggestedClubs]] : [[HONClubAssistant sharedInstance] suggestedClubs];
		//
		//		for (HONUserClubVO *vo in [_suggestedClubs reverseObjectEnumerator])
		//			[_dictClubs addObject:vo.dictionary];
		//		[_clubs setObject:_suggestedClubs forKey:@"suggested"];
		
		
		_allClubs = nil;
		_allClubs = [NSMutableArray array];
		for (NSDictionary *dict in _dictClubs)
			[_allClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		[self _didFinishDataRefresh];
		
		if (completion)
			completion();
	}];
}

- (void)_deleteClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] deleteClubWithClubID:vo.clubID completion:^(NSObject *result) {
		[self _retrieveClubsWithCompletion:nil];
	}];
}

- (void)_editClub:(HONUserClubVO *)vo {
}

- (void)_joinClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] joinClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubsWithCompletion:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
	}];
}

- (void)_leaveClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] leaveClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubsWithCompletion:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[self _retrieveClubsWithCompletion:nil];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	if (_dataSetType == HONUserClubsDataSetTypeUserClubs) {
		[_collectionView reloadData];
		[_refreshControl endRefreshing];
		
	} else {
		[_tableView reloadData];
	}
}


#pragma mark - Data Manip


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	
	self.view.backgroundColor = [UIColor whiteColor];
	_allClubs = [NSMutableArray array];
	_searchClubs = [NSMutableArray array];
	
	_dataSetType = HONUserClubsDataSetTypeUserClubs;
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_clubs", nil)]; //@"Clubs"];
	[headerView addButton:[[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, (kNavHeaderHeight + kSearchHeaderHeight), 320.0, self.view.frame.size.height - (kNavHeaderHeight + kSearchHeaderHeight))];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
//	_tableView.sectionIndexColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
//	_tableView.sectionIndexBackgroundColor = [UIColor clearColor];
//	_tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:0.40 alpha:0.33];
//	_tableView.sectionIndexMinimumDisplayRowCount = 1;
	_tableView.userInteractionEnabled = (_dataSetType == HONUserClubsDataSetTypeSearchResults);
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_collectionView = [[HONCollectionView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight + kSearchHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight + kSearchHeaderHeight)) collectionViewLayout:[[HONClubsViewFlowLayout alloc] init]];
	[_collectionView registerClass:[HONClubCollectionViewCell class] forCellWithReuseIdentifier:[HONClubCollectionViewCell cellReuseIdentifier]];
	_collectionView.backgroundColor = [UIColor whiteColor];
	[_collectionView setContentInset:UIEdgeInsetsZero];
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.alwaysBounceVertical = YES;
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	[self.view addSubview:_collectionView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_collectionView addSubview: _refreshControl];
	
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	longPressGestureRecognizer.minimumPressDuration = 0.5;
	longPressGestureRecognizer.delaysTouchesBegan = YES;
	longPressGestureRecognizer.delegate = self;
	[_collectionView addGestureRecognizer:longPressGestureRecognizer];
	
	HONSearchBarView *searchBarView = [[HONSearchBarView alloc] initAsHighSchoolSearchWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kSearchHeaderHeight)];
	searchBarView.delegate = self;
	[self.view addSubview:searchBarView];
	
	[self _retrieveClubsWithCompletion:nil];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[_collectionView setContentInset:UIEdgeInsetsMake(_collectionView.contentInset.top, _collectionView.contentInset.left, _collectionView.contentInset.bottom + 81.0, _collectionView.contentInset.right)];
	[_tableView setContentInset:UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom + 81.0, _tableView.contentInset.right)];
	_tabBannerView = [[HONTabBannerView alloc] init];
	_tabBannerView.delegate = self;
	[self.view addSubview:_tabBannerView];
}
- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	UINavigationController *navigationController = (UINavigationController *)self.presentedViewController;
	UIViewController *viewController = (UIViewController *)[navigationController.viewControllers lastObject];
	
	NSLog(@"navigationController:[%@] presentedViewController.nameOfClass:[%@]", self.navigationController, viewController.nameOfClass);
	
	if (_appearedType != HONUserClubsViewControllerAppearedTypeInviteFriends) {
		if ([viewController.nameOfClass isEqualToString:@"HONInviteContactsViewController"])
			_appearedType = (self.navigationController) ? HONUserClubsViewControllerAppearedTypeCreateClubCompleted : HONUserClubsViewControllerAppearedTypeClear;
		
		else
			_appearedType = HONUserClubsViewControllerAppearedTypeClear;
		
	} else
		_appearedType = HONUserClubsViewControllerAppearedTypeClear;
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
    
	NSLog(@"clubsTab_total:[%d]", [HONAppDelegate totalForCounter:@"clubsTab"]);
	
	if (_appearedType == HONUserClubsViewControllerAppearedTypeCreateClubCompleted) {
		[self _retrieveClubsWithCompletion:^{
			_selectedClubVO = [[HONClubAssistant sharedInstance] userSignupClub];
			
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [NSString stringWithFormat:@"I have created the Selfieclub %@! Tap to join: \nhttp://joinselfie.club/%@/%@", _selectedClubVO.clubName, [[HONAppDelegate infoForUser] objectForKey:@"username"], _selectedClubVO.clubName];
			
			[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_title", nil), _selectedClubVO.clubName]
										message:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_msg", nil)]
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		}];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[[touches anyObject] locationInView:_collectionView]];
	NSLog(@"INDEX PATH:[%d][%d]", indexPath.section, indexPath.row);
	if (indexPath != nil)
		[(HONClubCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath] applyTintThenReset:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[[touches anyObject] locationInView:_collectionView]];
	NSLog(@"INDEX PATH:[%d][%d]", indexPath.section, indexPath.row);
	if (indexPath != nil)
		[(HONClubCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath] removeTint];
}


#pragma mark - Navigation
- (void)_goProfile {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Profile"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Camera Step 1 hit Camera Button"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goClubSettings:(HONUserClubVO *)userClubVO {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goShare {
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate facebookShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [[HONImageBroker sharedInstance] shareTemplateImageForType:HONImageBrokerShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
		return;
	
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]];
	
	if (indexPath != nil) {
		HONClubCollectionViewCell *cell = (HONClubCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
		_selectedClubVO = cell.clubVO;
		
		if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeSuggested) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
			[alertView setTag:HONUserClubsAlertTypeGenerateSuggested];
			[alertView show];
			
		} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", nil), _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
			[alertView setTag:HONUserClubsAlertTypeInviteContacts];
			[alertView show];
			
		} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeOwner) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
																	 delegate:self
															cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
													   destructiveButtonTitle:nil
															otherButtonTitles:@"Invite friends", @"Copy club URL", nil];
			[actionSheet setTag:HONUserClubsActionSheetTypeOwner];
			[actionSheet showInView:self.view];
			
		} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeMember) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
																	 delegate:self
															cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
													   destructiveButtonTitle:nil
															otherButtonTitles:@"Invite friends", @"Copy club URL", @"Leave club", nil];
			[actionSheet setTag:HONUserClubsActionSheetTypeMember];
			[actionSheet showInView:self.view];
			
		} else if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeThreshold) {
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


#pragma mark - Notifications
- (void)_selectedClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedClubsTab <|::");
}

- (void)_refreshClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshClubsTab <|::");
	[self _retrieveClubsWithCompletion:nil];
}

- (void)_tareClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareClubsTab <|::");
	
	if (_collectionView.contentOffset.y > 0)
		[_collectionView setContentOffset:CGPointZero animated:YES];
}


#pragma mark - CreateClubViewController Delegates
- (void)createClubViewController:(HONCreateClubViewController *)viewController didCreateClub:(HONUserClubVO *)clubV0 {
	_selectedClubVO = clubV0;
}


#pragma mark - TabBannerView Delegates
- (void)tabBannerView:(HONTabBannerView *)bannerView joinAreaCodeClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:joinAreaCodeClub:[%@]", clubVO.clubName);
	
	_selectedClubVO = clubVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
														message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
	[alertView setTag:HONUserClubsAlertTypeGenerateSuggested];
	[alertView show];
}

- (void)tabBannerView:(HONTabBannerView *)bannerView joinFamilyClub:(HONUserClubVO *)clubVO {
	NSLog(@"[[*:*]] tabBannerView:joinFamilyClub:[%@]", clubVO.clubName);
	
	_selectedClubVO = clubVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
														message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
	[alertView setTag:HONUserClubsAlertTypeGenerateSuggested];
	[alertView show];
}

- (void)tabBannerViewInviteContacts:(HONTabBannerView *)bannerView {
	NSLog(@"[[*:*]] tabBannerViewInviteContacts");
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] userSignupClub] viewControllerPushed:NO]];
	[navigationController setNavigationBarHidden:YES];
	
	[self presentViewController:navigationController animated:YES completion:^(void) {
	}];
}


#pragma mark - ClubViewCell Delegates


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

- (void)insetOverlayViewDidAccessContents:(HONInsetOverlayView *)view {
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
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:nil viewControllerPushed:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - SearchBarHeader Delegates
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView {
	_dataSetType = HONUserClubsDataSetTypeSearchResults;
	
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
	_tableView.userInteractionEnabled = YES;
	
	_searchClubs = [NSMutableArray array];
	[_tableView reloadData];
	
	
	//	[UIView animateWithDuration:0.33 animations:^(void) {
	//		_collectionView.alpha = 0.0;
	//
	//	} completion:^(BOOL finished) {
	_collectionView.hidden = YES;
	//	}];
	
}

- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView {
	_dataSetType = HONUserClubsDataSetTypeUserClubs;
	
	_tableView.userInteractionEnabled = NO;
	
	_collectionView.hidden = NO;
	//	[UIView animateWithDuration:0.33 animations:^(void) {
	//		_collectionView.alpha = 1.0;
	//
	//	} completion:^(BOOL finished) {
	//	}];
}

- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery {
	_searchClubs = [NSMutableArray array];
	[[HONAPICaller sharedInstance] searchForClubsByClubName:searchQuery completion:^(NSDictionary *result) {
		if ([[result objectForKey:@"clubs"] count] > 0) {
			[[result objectForKey:@"clubs"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:(NSDictionary *)obj];
				if ([vo.clubName rangeOfString:searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound)
					[_searchClubs addObject:vo];
			}];
		}
		
		if ([_searchClubs count] > 0) {
			_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			
		} else {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
		
		
		[self _didFinishDataRefresh];
	}];
}


#pragma mark - CollectionViewDataSource Delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return (1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return ([_dictClubs count]);//(section == 0) ? 1 + [[_clubs objectForKey:@"suggested"] count] + [[_clubs objectForKey:@"pending"] count] : [[_clubs objectForKey:@"member"] count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	HONClubCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HONClubCollectionViewCell cellReuseIdentifier]
																				forIndexPath:indexPath];
	[cell resetSubviews];
	cell.alpha = 1.0;
	
	//	NSLog(@"INDEXPATH:[%d][%d]", indexPath.section, indexPath.row);
	//	HONUserClubVO *vo;
	//	if (indexPath.section == 0) {
	//		vo = [[_clubs objectForKey:@"create"] objectAtIndex:0];
	//
	//		if (indexPath.row >= 1 && indexPath.row <= [[_clubs objectForKey:@"suggested"] count])
	//			vo = [[_clubs objectForKey:@"suggested"] objectAtIndex:indexPath.row - 1];
	//
	//		else if (indexPath.row > [[_clubs objectForKey:@"suggested"] count])
	//			vo = [[_clubs objectForKey:@"pending"] objectAtIndex:indexPath.row - (1 + [[_clubs objectForKey:@"suggested"] count])];
	//
	//	} else if (indexPath.section == 1)
	//		vo = [[_clubs objectForKey:@"member"] objectAtIndex:indexPath.row];
	
	
	//	HONUserClubVO *vo;
	//	if (indexPath.row == 0)
	//		vo = [[_clubs objectForKey:@"create"] objectAtIndex:0];
	//
	//	else if (indexPath.row >= 1 && indexPath.row <= [[_clubs objectForKey:@"suggested"] count])
	//		vo = [[_clubs objectForKey:@"suggested"] objectAtIndex:indexPath.row - 1];
	//
	//	else if (indexPath.row >= [[_clubs objectForKey:@"suggested"] count] && indexPath.row <= ([[_clubs objectForKey:@"suggested"] count] + [[_clubs objectForKey:@"pending"] count]))
	//		vo = [[_clubs objectForKey:@"pending"] objectAtIndex:indexPath.row - (1 + [[_clubs objectForKey:@"suggested"] count])];
	//
	//	else
	//		vo = [[_clubs objectForKey:@"member"] objectAtIndex:indexPath.row - (1 + [[_clubs objectForKey:@"suggested"] count] + [[_clubs objectForKey:@"pending"] count])];
	//
	
	cell.clubVO = [HONUserClubVO clubWithDictionary:[_dictClubs objectAtIndex:indexPath.row]];//vo;
	cell.delegate = self;
	
	return (cell);
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	HONUserClubVO *vo =  ((HONClubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).clubVO;
	NSLog(@"vo.clubEnrollmentType:[%d]", vo.clubEnrollmentType);
	_selectedClubVO = vo;
	
	HONClubCollectionViewCell *cell = (HONClubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell applyTintThenReset:YES];
	
	if (vo.clubEnrollmentType == HONClubEnrollmentTypeOwner || vo.clubEnrollmentType == HONClubEnrollmentTypeMember) {
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
		HONCreateClubViewController *createClubViewController = [[HONCreateClubViewController alloc] init];
		createClubViewController.delegate = self;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:createClubViewController];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
		
	} else if (vo.clubEnrollmentType == HONClubEnrollmentTypeSuggested) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
		[alertView setTag:HONUserClubsAlertTypeGenerateSuggested];
		[alertView show];
		
	} else if (vo.clubEnrollmentType == HONClubEnrollmentTypePending) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
		[alertView setTag:HONUserClubsAlertTypeJoin];
		[alertView show];
		
	} else if (vo.clubEnrollmentType == HONClubEnrollmentTypeThreshold) {
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
		
		
		
#if SC_ACCT_BUILD == 1
	} else if (vo.clubEnrollmentType == HONClubEnrollmentTypeUnknown) {
		if ([vo.submissions count] == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithClub:_selectedClubVO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
			
		} else
			[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:vo atPhotoIndex:0] animated:YES];
#endif
	}
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	HONClubCollectionViewCell *viewCell = (HONClubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	[viewCell resetSubviews];
}


#pragma mark - ClubToggleViewCelll Delegates
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] clubToggleViewCell:selectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	_selectedClubVO = userClubVO;
	if ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:userClubVO.clubName]) {
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

- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] clubToggleViewCell:deselectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_searchClubs count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:@"SEARCH RESULTS"]);
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return (nil);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return (0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubToggleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubToggleViewCell alloc] init];
	
	[cell toggleIndicator:NO];
	[cell hideChevron];
	
	cell.userClubVO = (HONUserClubVO *)[_searchClubs objectAtIndex:indexPath.row];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
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
	
	//	HONClubToggleViewCell *cell = (HONClubToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	//	[cell toggleSelected:YES];
	
	_selectedClubVO = (HONUserClubVO *)[_searchClubs objectAtIndex:indexPath.row];
	if (_selectedClubVO.clubEnrollmentType == HONClubEnrollmentTypeMember) {
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


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == HONUserClubsActionSheetTypeSuggested) {
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (buttonIndex == 1) {
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [NSString stringWithFormat:@"I have created the Selfieclub %@! Tap to join: \nhttp://joinselfie.club/%@/%@", _selectedClubVO.clubName, [[HONAppDelegate infoForUser] objectForKey:@"username"], _selectedClubVO.clubName];
			
			[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_title", nil), _selectedClubVO.clubName]
										message:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_msg", nil)]
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		}
		
	} else if (actionSheet.tag == HONUserClubsActionSheetTypePending) {
	} else if (actionSheet.tag == HONUserClubsActionSheetTypeOwner) {
		if (buttonIndex == 0) {
			_appearedType = HONUserClubsViewControllerAppearedTypeInviteFriends;
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (buttonIndex == 1) {
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [NSString stringWithFormat:@"I have created the Selfieclub %@! Tap to join: \nhttp://joinselfie.club/%@/%@", _selectedClubVO.clubName, [[HONAppDelegate infoForUser] objectForKey:@"username"], _selectedClubVO.clubName];
			
			[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_title", nil), _selectedClubVO.clubName]
										message:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_msg", nil)]
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
		} else if (actionSheet.tag == HONUserClubsActionSheetTypeMember) {
			if (buttonIndex == 0) {
				_appearedType = HONUserClubsViewControllerAppearedTypeInviteFriends;
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				
			} else if (buttonIndex == 1) {
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"I have created the Selfieclub %@! Tap to join: \nhttp://joinselfie.club/%@/%@", _selectedClubVO.clubName, [[HONAppDelegate infoForUser] objectForKey:@"username"], _selectedClubVO.clubName];
				
				[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_title", nil), _selectedClubVO.clubName]
											message:[NSString stringWithFormat:NSLocalizedString(@"popup_clubcopied_msg", nil)]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
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
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONUserClubsAlertTypeGenerateSuggested) {
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] createClubWithTitle:_selectedClubVO.clubName withDescription:_selectedClubVO.blurb withImagePrefix:_selectedClubVO.coverImagePrefix completion:^(NSDictionary *result) {
				[[HONClubAssistant sharedInstance] addClub:result forKey:@"owned"];
				[self _retrieveClubsWithCompletion:nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:nil];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:[NSString stringWithFormat:@"Want to invite friends to %@?", _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
														  otherButtonTitles:@"Not Now", nil];
				[alertView setTag:HONUserClubsAlertTypeInviteContacts];
				[alertView show];
			}];
		}
		
	} else if (alertView.tag == HONUserClubsAlertTypeJoin) {
		if (buttonIndex == 0) {
			[self _joinClub:_selectedClubVO];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:@"Want to invite friends to %@?", _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
													  otherButtonTitles:@"Not Now", nil];
			[alertView setTag:HONUserClubsAlertTypeInviteContacts];
			[alertView show];
		}
		
	} else if (alertView.tag == HONUserClubsAlertTypeLeave) {
		if (buttonIndex == 0) {
			[self _leaveClub:_selectedClubVO];
		}
		
	} else if (alertView.tag == HONUserClubsAlertTypeInviteContacts) {
		if (buttonIndex == 0) {
			_appearedType = HONUserClubsViewControllerAppearedTypeInviteFriends;
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == HONUserClubsAlertTypeSubmitPhoto) {
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithClub:_selectedClubVO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	}
}


@end
