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
#import "HONHighSchoolSearchViewController.h"
#import "HONSearchBarView.h"
#import "HONUserClubVO.h"
#import "HONTrivialUserVO.h"

@interface HONUserClubsViewController () <HONClubCollectionViewCellDelegate, HONTutorialViewDelegate, HONSearchBarViewDelegate>
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
@property (nonatomic) BOOL didCloseCreateClub;
@end


@implementation HONUserClubsViewController


//static NSString * const kCellIdentifier = @"cellIdentifier";

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedClubsTab:) name:@"SELECTED_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareClubsTab:) name:@"TARE_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_CLUBS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_closedCreateClub:) name:@"CLOSED_CREATE_CLUB" object:nil];
		_didCloseCreateClub = NO;
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
	
	dict = [[[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}] mutableCopy];
	[dict setValue:@"0" forKey:@"id"];
	[dict setValue:@"Find High School" forKey:@"name"];
	[dict setValue:@"HIGH_SCHOOL" forKey:@"club_type"];
	[dict setValue:@"9999-99-99 99:99:99" forKey:@"added"];
	[dict setValue:@"9999-99-99 99:99:99" forKey:@"updated"];
	[dict setValue:[[HONClubAssistant sharedInstance] defaultCoverImagePrefix] forKey:@"img"];
	[_dictClubs addObject:[dict copy]];
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		[[HONClubAssistant sharedInstance] writeUserClubs:result];
		
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
			
			for (NSDictionary *dict in [result objectForKey:key]) {
				[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
					[_dictClubs addObject:dict];
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
	[[HONClubAssistant sharedInstance] wipeUserClubs];
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


#pragma mark - Data Manip


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
	
	HONSearchBarView *searchBarView = [[HONSearchBarView alloc] initAsHighSchoolSearchWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kSearchHeaderHeight)];
	searchBarView.delegate = self;
	[self.view addSubview:searchBarView];
	
	[self _retrieveClubs];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
	lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	NSLog(@"clubsTab_total:[%d]", [HONAppDelegate totalForCounter:@"clubsTab"]);
	if (_isFromCreateClub && !_didCloseCreateClub) {
		_isFromCreateClub = NO;
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Your %@ has been copied!", [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@"'s Club"]]
                                    message:[NSString stringWithFormat:@"http://joinselfie.club/%@/%@\n\nPaste your URL anywhere to share!", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@"'s Club"]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
	}
	
	_didCloseCreateClub = NO;
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
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Camera Step 1 hit Camera Button"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	
	[self _retrieveClubs];
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
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [HONImagingDepictor shareTemplateImageForType:HONImagingDepictorShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}

//-(void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
//	NSLog(@"goLongPress:[%d]", lpGestureRecognizer.state);
//	
//	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
//		
//		
//	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
//	}
//}

-(void)_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
	
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        HONClubCollectionViewCell* cell = (HONClubCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        // do stuff with the cell
		_selectedClub = cell.clubVO;
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""//[NSString stringWithFormat:[_tabInfo objectForKey:@"nay_format"], _challengeVO.creatorVO.username]
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Invite Friends", @"Copy my club URL", nil];
		[actionSheet setTag:0];
		[actionSheet showInView:self.view];
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

- (void)_closedCreateClub: (NSNotification *)notification {
	_didCloseCreateClub = YES;
}


#pragma mark - ClubViewCell Delegates
- (void)clubViewCell:(HONClubCollectionViewCell *)cell deleteClub:(HONUserClubVO *)userClubVO {
	[self _leaveClub:userClubVO];
}

- (void)clubViewCell:(HONClubCollectionViewCell *)cell editClub:(HONUserClubVO *)userClubVO {

	
	[self.navigationController pushViewController:[[HONClubSettingsViewController alloc] initWithClub:userClubVO] animated:YES];
}

- (void)clubViewCell:(HONClubCollectionViewCell *)cell joinClub:(HONUserClubVO *)userClubVO {

	
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

	[self _leaveClub:userClubVO];
}

- (void)clubViewCellCreateClub:(HONClubCollectionViewCell *)cell {
	
//	for (int i=0; i<[_allClubs count]; i++) {
//		HONClubCollectionViewCell *cell = (HONClubCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//		[cell removeOverlay];
//	}
	
	_isFromCreateClub = YES;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)clubViewCellHighSchoolClub:(HONClubCollectionViewCell *)cell {
//    [[[UIAlertView alloc] initWithTitle:@""
//                                message:[NSString stringWithFormat:@"No High Schools Found"]
//                               delegate:nil
//                      cancelButtonTitle:@"Ok"
//                      otherButtonTitles: nil] show];
    [self.navigationController pushViewController:[[HONHighSchoolSearchViewController alloc] init] animated:YES];
}


#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewInvite:(HONTutorialView *)tutorialView {
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:nil viewControllerPushed:NO]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}];
}

- (void)tutorialViewSkip:(HONTutorialView *)tutorialView {
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}


#pragma mark - SearchBarHeader Delegates
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView {
}

- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView {
}

- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery {
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
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
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
				[self.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:vo atPhotoIndex:0] animated:YES];

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
			
		} else if (vo.clubEnrollmentType == HONClubEnrollmentTypeHighSchool) {
			[self.navigationController pushViewController:[[HONHighSchoolSearchViewController alloc] init] animated:YES];
//            [[[UIAlertView alloc] initWithTitle:@""
//                                        message:[NSString stringWithFormat:@"No High Schools Found"]
//                                       delegate:nil
//                              cancelButtonTitle:@"Ok"
//                              otherButtonTitles: nil] show];
			
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
		
		
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClub viewControllerPushed:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
		else if (buttonIndex == 1){
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [NSString stringWithFormat:@"I have created the Selfieclub %@! Tap to join: \nhttp://joinselfie.club//%@/%@", [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@"'s Club"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@"'s Club"]];
			
			[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Your %@ has been copied!", [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@"'s Club"]]
                                        message:[NSString stringWithFormat:@"http://joinselfie.club/%@/%@\n\nPaste your URL anywhere to share!", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@"'s Club"]]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
				
		
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
