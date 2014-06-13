//
//  HONUserClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "EGORefreshTableHeaderView.h"
#import "JLBPopSlideTransition.h"
#import "MBProgressHUD.h"

#import "HONUserClubsViewController.h"
#import "HONClubsViewFlowLayout.h"

#import "HONTableHeaderView.h"
#import "HONClubCollectionViewCell.h"
#import "HONHeaderView.h"
#import "HONCreateSnapButtonView.h"
#import "HONActivityHeaderButtonView.h"
#import "HONSelfieCameraViewController.h"
#import "HONUserProfileViewController.h"
#import "HONCreateClubViewController.h"
#import "HONClubSettingsViewController.h"
#import "HONClubInviteViewController.h"
#import "HONFeedViewController.h"
#import "HONUserClubVO.h"


#import "HONTrivialUserVO.h"

@interface HONUserClubsViewController () <EGORefreshTableHeaderDelegate, HONClubViewCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableDictionary *clubIDs;
@property (nonatomic, strong) NSMutableArray *dictClubs;
@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) HONUserClubVO *selectedClub;
@property (nonatomic, strong) HONActivityHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
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
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_allClubs = nil;
	[_collectionView reloadData];
	
	_dictClubs = [NSMutableArray array];
	_clubIDs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array],
															[NSMutableArray array],
															[NSMutableArray array],
															[NSMutableArray array]]
												  forKeys:[[HONClubAssistant sharedInstance] clubTypeKeys]];
//	[self _fpoPopulate];
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
			
			for (NSDictionary *dict in [(NSDictionary *)result objectForKey:key])
				[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
			
			[_clubIDs setValue:clubIDs forKey:key];
			[_dictClubs addObjectsFromArray:[(NSDictionary *)result objectForKey:key]];
		}
		
		
		NSMutableDictionary *dict = [[[HONClubAssistant sharedInstance] emptyClubDictionary] mutableCopy];
		[dict setValue:@"0" forKey:@"id"];
		[dict setValue:@"Create club" forKey:@"name"];
		[dict setValue:[[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsCloudFront] stringByAppendingString:@"/createClubCover"] forKey:@"img"];
		[_dictClubs addObject:[dict copy]];
		
		
		_allClubs = [NSMutableArray array];
		for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated"
																																							   ascending:NO]]]])
			[_allClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		[_collectionView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_collectionView];
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	}];
}

- (void)_deleteClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] deleteClubWithClubID:vo.clubID completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
}

- (void)_editClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] editClubWithClubID:vo.clubID withTitle:vo.clubName withDescription:vo.blurb withImagePrefix:vo.coverImagePrefix completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	
	self.view.backgroundColor = [UIColor whiteColor];
	_allClubs = [NSMutableArray array];
	
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs"];
	[headerView addButton:[[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) collectionViewLayout:[[HONClubsViewFlowLayout alloc] init]];
	[_collectionView registerClass:[HONClubCollectionViewCell class] forCellWithReuseIdentifier:[HONClubCollectionViewCell cellReuseIdentifier]];
	_collectionView.backgroundColor = [UIColor whiteColor];
	[_collectionView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0)];
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	[self.view addSubview:_collectionView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_collectionView.frame.size.height, _collectionView.frame.size.width, _collectionView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _collectionView;
	[_collectionView addSubview:_refreshTableHeaderView];
	
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
		[[[UIAlertView alloc] initWithTitle:@"Clubs Tip"
									message:@"The more clubs you join the more your feed fills up!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
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
	[self _joinClub:userClubVO];
}

- (void)clubViewCell:(HONClubCollectionViewCell *)cell quitClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Quit Club"
									   withUserClub:userClubVO];
	[self _leaveClub:userClubVO];
}

- (void)clubViewCellCreateClub:(HONClubCollectionViewCell *)cell {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Create Club"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
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
	[cell resetSubviews];
	
	HONUserClubVO *vo = [_allClubs objectAtIndex:indexPath.row];
	cell.clubVO = vo;
	cell.clubType = [self _clubTypeForClubVO:vo];
	cell.delegate = self;
	
    return (cell);
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	HONUserClubVO *vo =  ((HONClubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).clubVO;
	
	
	HONClubCollectionViewCell *cell = (HONClubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	if (cell.clubType != HONClubTypeOther) {
		NSLog(@"/// SHOW CLUB TIMELINE:(%@ - %@)", [vo.dictionary objectForKey:@"id"], [vo.dictionary objectForKey:@""]);
		HONFeedViewController *feedViewController = [[HONFeedViewController alloc] init];
		feedViewController.clubVO = vo;
		[self.navigationController pushViewController:feedViewController animated:YES];
	}
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[_collectionView setContentOffset:CGPointZero animated:NO];
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
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Clubs - Accept Invite " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]
										   withUserClub:_selectedClub];		
		if (buttonIndex == 1)
			[self _joinClub:_selectedClub];
	}
}


#pragma mark - Data Manip
- (HONClubType)_clubTypeForClubVO:(HONUserClubVO *)clubVO {
	NSArray *typeKeys = @[@"owned",
						  @"member",
						  @"pending",
						  @"other"];
	
	int ind = 0;
	for (NSString *key in typeKeys) {
		for (NSNumber *clubID in [_clubIDs objectForKey:key]) {
			if (clubVO.clubID == [clubID intValue])
				return ((HONClubType)ind);
		}
		
		ind++;
	}
	
	return (HONClubTypeUnknown);
}



#pragma mark - FPO Methods
- (void)_fpoPopulate {
	NSDictionary *fpoDict = @{@"owned"		: @[[[HONClubAssistant sharedInstance] fpoOwnedClubDictionary],
												[[HONClubAssistant sharedInstance] fpoJoinedClubDictionary],
												[[HONClubAssistant sharedInstance] fpoJoinedClubDictionary],
												[[HONClubAssistant sharedInstance] fpoJoinedClubDictionary]],
							  @"member"		: @[[[HONClubAssistant sharedInstance] fpoInviteClubDictionary],
												[[HONClubAssistant sharedInstance] fpoJoinedClubDictionary],
												[[HONClubAssistant sharedInstance] fpoJoinedClubDictionary],
												[[HONClubAssistant sharedInstance] fpoInviteClubDictionary],
												[[HONClubAssistant sharedInstance] fpoJoinedClubDictionary],
												[[HONClubAssistant sharedInstance] fpoInviteClubDictionary]],
							  @"pending"	: @[[[HONClubAssistant sharedInstance] fpoJoinedClubDictionary],
												[[HONClubAssistant sharedInstance] fpoInviteClubDictionary]]};
	
	for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
		NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
		
		for (NSDictionary *dict in [fpoDict objectForKey:key])
			[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
		
		[_clubIDs setValue:clubIDs forKey:key];
		[_dictClubs addObjectsFromArray:[fpoDict objectForKey:key]];
	}
}

@end
