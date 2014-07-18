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
#import "HONHeaderView.h"
#import "HONTutorialView.h"
#import "HONCreateSnapButtonView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONSelfieCameraViewController.h"
#import "HONUserProfileViewController.h"
#import "HONCreateClubViewController.h"
#import "HONClubSettingsViewController.h"
#import "HONInviteContactsViewController.h"
#import "HONClubTimelineViewController.h"
#import "HONUserClubVO.h"


#import "HONTrivialUserVO.h"

@interface HONUserClubsViewController () <HONClubViewCellDelegate, HONTutorialViewDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) HONCollectionView *collectionView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONActivityHeaderButtonView *profileHeaderButtonView;

@property (nonatomic, strong) NSMutableDictionary *clubIDs;
@property (nonatomic, strong) NSMutableArray *dictClubs;
@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) HONTutorialView *tutorialView;
@property (nonatomic, strong) HONUserClubVO *selectedClub;
@property (nonatomic) BOOL hasClubMembership;
@property (nonatomic) BOOL isFromCreateClub;
@end


@implementation HONUserClubsViewController


//static NSString * const kCellIdentifier = @"cellIdentifier";

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedClubsTab:) name:@"SELECTED_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareClubsTab:) name:@"TARE_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
//	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
//	_progressHUD.mode = MBProgressHUDModeIndeterminate;
//	_progressHUD.minShowTime = kHUDTime;
//	_progressHUD.taskInProgress = YES;
	
	_dictClubs = [NSMutableArray array];
	_clubIDs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array]]
												  forKeys:[[HONClubAssistant sharedInstance] clubTypeKeys]];
	
	NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}] mutableCopy];
	[dict setValue:@"0" forKey:@"id"];
	[dict setValue:@"Create a club" forKey:@"name"];
	[dict setValue:@"AUTO_GEN" forKey:@"club_type"];
	[dict setValue:@"9999-99-99 99:99:99" forKey:@"added"];
	[dict setValue:@"9999-99-99 99:99:99" forKey:@"updated"];
	[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImagePrefix] forKey:@"img"];
	[_dictClubs addObject:[dict copy]];
	
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
			
			for (NSDictionary *dict in [result objectForKey:key]) {
//				HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:dict];
				[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
				
//				if ([vo.submissions count] > 0 || vo.clubEnrollmentType == HONClubEnrollmentTypePending) {
					[_dictClubs addObject:dict];
//				}
			}
			
			[_clubIDs setValue:clubIDs forKey:key];
		}
		
		_allClubs = nil;
		_allClubs = [NSMutableArray array];
		for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]]])
			[_allClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		[self _didFinishDataRefresh];
		
		_hasClubMembership = ([[_clubIDs objectForKey:@"member"] count] > 0);
	}];
}

- (void)_deleteClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] deleteClubWithClubID:vo.clubID completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
}

- (void)_editClub:(HONUserClubVO *)vo {
}


- (void)_joinClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] joinClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
}

- (void)_leaveClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] leaveClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[self _retrieveClubs];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_collectionView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	
	_hasClubMembership = NO;
	_isFromCreateClub = NO;
	self.view.backgroundColor = [UIColor whiteColor];
	_allClubs = [NSMutableArray array];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs"];
	[headerView addButton:[[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	_collectionView = [[HONCollectionView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) collectionViewLayout:[[HONClubsViewFlowLayout alloc] init]];
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
	
	[self _retrieveClubs];
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
	
	NSLog(@"clubsTab_total:[%d]", [HONAppDelegate totalForCounter:@"clubsTab"]);
	if ([HONAppDelegate incTotalForCounter:@"clubsTab"] == 1) {
//		[[[UIAlertView alloc] initWithTitle:@"Clubs Tip"
//									message:@"The more clubs you join the more your feed fills up!"
//								   delegate:nil
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil] show];
	}
	
	if (_isFromCreateClub) {
		_isFromCreateClub = NO;
		
		_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:@"tutorial_club"]];
		_tutorialView.delegate = self;
		
		[[HONScreenManager sharedInstance] appWindowAdoptsView:_tutorialView];
		[_tutorialView introWithCompletion:nil];
	}
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
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline - Profile"];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Create Challenge"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Refresh"];
	
	[self _retrieveClubs];
}

- (void)_goClubSettings:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Settings"
									   withUserClub:userClubVO];
		
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goShare {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Share"];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate facebookShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [HONImagingDepictor shareTemplateImageForType:HONImagingDepictorShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}

-(void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	NSLog(@"goLongPress:[%d]", lpGestureRecognizer.state);
	
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}


#pragma mark - Notifications
- (void)_selectedClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedClubsTab <|::");
}

- (void)_refreshClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshClubsTab <|::");
	[self _goRefresh];
}

- (void)_tareClubsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareClubsTab <|::");
	
	if (_collectionView.contentOffset.y > 0) {
		_collectionView.pagingEnabled = NO;
		[_collectionView setContentOffset:CGPointZero animated:YES];
	}
}


#pragma mark - ClubViewCell Delegates
- (void)clubViewCell:(HONClubCollectionViewCell *)cell deleteClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Delete Club"
									   withUserClub:userClubVO];
	[self _leaveClub:userClubVO];
}

- (void)clubViewCell:(HONClubCollectionViewCell *)cell editClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Edit Club"
									   withUserClub:userClubVO];
	
	[self.navigationController pushViewController:[[HONClubSettingsViewController alloc] initWithClub:userClubVO] animated:YES];
}

- (void)clubViewCell:(HONClubCollectionViewCell *)cell joinClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Join Club"
									   withUserClub:userClubVO];
	
	_selectedClub = userClubVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
														message:[NSString stringWithFormat:@"Would you like to join the %@ Selfieclub?", _selectedClub.clubName]
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:@"Cancel", nil];
	
	[alertView setTag:0];
	[alertView show];
}

- (void)clubViewCell:(HONClubCollectionViewCell *)cell quitClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Quit Club"
									   withUserClub:userClubVO];
	[self _leaveClub:userClubVO];
}

- (void)clubViewCellCreateClub:(HONClubCollectionViewCell *)cell {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Create Club"];
	
//	for (int i=0; i<[_allClubs count]; i++) {
//		HONClubCollectionViewCell *cell = (HONClubCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//		[cell removeOverlay];
//	}
	
	_isFromCreateClub = YES;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Tutorial Close"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewInvite:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Tutorial Invite"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:nil viewControllerPushed:NO]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}];
}

- (void)tutorialViewSkip:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Tutorial Skip"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}


#pragma mark - CollectionViewDataSource Delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return (1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return ([_allClubs count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	HONClubCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HONClubCollectionViewCell cellReuseIdentifier]
																				forIndexPath:indexPath];
//	[cell resetSubviews];
	
	HONUserClubVO *vo = [_allClubs objectAtIndex:indexPath.row];
	cell.clubVO = vo;
	cell.delegate = self;
	
//	if (_hasClubMembership)
//		[cell removeOverlay];
	
    return (cell);
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//	HONUserClubVO *vo =  ((HONClubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).clubVO;
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	HONUserClubVO *vo =  ((HONClubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).clubVO;
	
	if (vo.clubEnrollmentType != HONClubEnrollmentTypeUnknown) {
		NSLog(@"/// SHOW CLUB TIMELINE:(%@ - %@)", [vo.dictionary objectForKey:@"id"], [vo.dictionary objectForKey:@""]);
		
		NSLog(@"vo.clubEnrollmentType:[%d]", vo.clubEnrollmentType);
		
		if (vo.clubEnrollmentType == HONClubEnrollmentTypeOwner || vo.clubEnrollmentType == HONClubEnrollmentTypeMember) {
			//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
			_selectedClub = vo;
			if ([vo.submissions count] == 0) {
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"This club does not have any status updates yet!"
																	 message:@"Would you like to create one?"
																	delegate:self
														   cancelButtonTitle:@"No"
														   otherButtonTitles:@"Yes", nil];
				[alertView setTag: 2];
				[alertView show];
			}
			else
				[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:vo] animated:YES];

		} else if (vo.clubEnrollmentType == HONClubEnrollmentTypeAutoGen) {
			if (vo.clubID == 0) {
				_isFromCreateClub = YES;
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
			
			} else {
				[[HONAPICaller sharedInstance] createClubWithTitle:vo.clubName withDescription:vo.blurb withImagePrefix:vo.coverImagePrefix completion:^(NSObject *result) {
					[self _retrieveClubs];
				}];
			}
			
		} else if (vo.clubEnrollmentType == HONClubEnrollmentTypePending) {
			_selectedClub = vo;
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:@"Would you like to join the %@ Selfieclub?", _selectedClub.clubName]
															   delegate:self
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:@"Cancel", nil];
			
			[alertView setTag:0];
			[alertView show];
		}
	
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs - Settings " stringByAppendingString:(buttonIndex == 0) ? @"Quit" : @"Cancel"]
										   withUserClub:_selectedClub];
		
		if (buttonIndex == 0)
			[self _leaveClub:_selectedClub];
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs - Invite Friends " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"]
										   withUserClub:_selectedClub];		
		
		if (buttonIndex == 0) {
			[self _joinClub:_selectedClub];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:@"Want to invite friends to %@?", _selectedClub.clubName]
															   delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"Not Now", nil];
			
			[alertView setTag:1];
			[alertView show];
		}
	
	} else if (alertView.tag == 1) {
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClub viewControllerPushed:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	} else if (alertView.tag ==2) {
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithClub:_selectedClub]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	}
}


@end
