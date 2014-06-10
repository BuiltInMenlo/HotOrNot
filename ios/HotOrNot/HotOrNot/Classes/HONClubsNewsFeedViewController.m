//
//  HONClubsTimelineViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 10:58 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "NSString+DataTypes.h"


#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

#import "HONClubsNewsFeedViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONCreateClubViewController.h"
#import "HONUserClubsViewController.h"
#import "HONClubNewsFeedViewCell.h"
#import "HONHeaderView.h"
#import "HONCreateSnapButtonView.h"
#import "HONTableHeaderView.h"

#import "HONTimelineItemVO.h"


@interface HONClubsNewsFeedViewController () <EGORefreshTableHeaderDelegate, HONClubNewsFeedViewCellDelegate>
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NSMutableArray *dictItems;
@property (nonatomic, strong) NSMutableArray *timelineItems;

@property (nonatomic, strong) NSMutableArray *ownedClubs;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) NSMutableArray *invitedClubs;
@property (nonatomic, strong) NSMutableArray *suggestedClubs;
@end


@implementation HONClubsNewsFeedViewController


- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedNewsTab:) name:@"SELECTED_NEWS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareNewsTab:) name:@"TARE_NEWS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshNewsTab:) name:@"REFRESH_NEWS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshNewsTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
- (void)_retrieveTimeline {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	_dictItems = [NSMutableArray array];
	_timelineItems = [NSMutableArray array];
	
	_ownedClubs = [NSMutableArray array];
	_joinedClubs = [NSMutableArray array];
	_invitedClubs = [NSMutableArray array];
	_suggestedClubs = [NSMutableArray array];
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		
		if ([((NSDictionary *)result) objectForKey:@"owned"] != nil) {
			for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"owned"]) {
				HONUserClubVO *ownedClubVO = [HONUserClubVO clubWithDictionary:dict];
				[_ownedClubs addObject:ownedClubVO];
				
				if (ownedClubVO.totalSubmissions > 0)
					[_dictItems addObject:dict];
			}
		}
		
		if ([((NSDictionary *)result) objectForKey:@"member"] != nil) {
			for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"member"]) {
				HONUserClubVO *joinedClubVO = [HONUserClubVO clubWithDictionary:dict];
				[_joinedClubs addObject:joinedClubVO];
				
				if (joinedClubVO.totalSubmissions > 0)
					[_dictItems addObject:dict];
			}
		}
		
		if ([((NSDictionary *)result) objectForKey:@"pending"] != nil) {
			for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"pending"]) {
				HONUserClubVO *invitedClubVO = [HONUserClubVO clubWithDictionary:dict];
				[_invitedClubs addObject:invitedClubVO];
				
				if (invitedClubVO.totalSubmissions > 0)
					[_dictItems addObject:dict];
			}
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		_suggestedClubs = [NSMutableArray array];
		[self _suggestClubs];
		[self _sortItems];
	}];
}

- (void)_joinClub:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] joinClub:userClubVO withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		
	}];
}


- (void)_createClubWithProtoVO:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] createClubWithTitle:userClubVO.clubName withDescription:userClubVO.blurb withImagePrefix:userClubVO.coverImagePrefix completion:^(NSObject *result) {
		[self _retrieveTimeline];
	}];
}

#pragma mark - Data Manip
- (void)_suggestClubs {
	NSMutableArray *segmentedKeys = [[NSMutableArray alloc] init];
	NSMutableDictionary *segmentedDict = [[NSMutableDictionary alloc] init];
	NSMutableArray *unsortedContacts = [NSMutableArray array];
	NSString *clubName = @"";
	
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = MIN(100, ABAddressBookGetPersonCount(addressBook));
	
	for (int i=0; i<nPeople; i++) {
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		
		NSString *fName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		NSString *lName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
		
		if ([fName length] == 0)
			continue;
		
		if ([lName length] == 0)
			lName = @"";
		
		
		ABMultiValueRef phoneProperties = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		CFIndex phoneCount = ABMultiValueGetCount(phoneProperties);
		
		NSString *phoneNumber = @"";
		if (phoneCount > 0)
			phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, 0);
		
		CFRelease(phoneProperties);
		
		
		NSString *email = @"";
		ABMultiValueRef emailProperties = ABRecordCopyValue(ref, kABPersonEmailProperty);
		CFIndex emailCount = ABMultiValueGetCount(emailProperties);
		
		if (emailCount > 0)
			email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailProperties, 0);
		
		CFRelease(emailProperties);
		
		if ([email length] == 0)
			email = @"";
		
		if ([phoneNumber length] > 0 || [email length] > 0) {
			[unsortedContacts addObject:[HONContactUserVO contactWithDictionary:@{@"f_name"	: fName,
																				  @"l_name"	: lName,
																				  @"phone"	: phoneNumber,
																				  @"email"	: email,
																				  @"image"	: UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"])}]];
		}
	}
	
	
	
	// family
	NSArray *deviceName = [[[HONDeviceIntrinsics sharedInstance] deviceName] componentsSeparatedByString:@" "];
	if ([[deviceName lastObject] isEqualToString:@"iPhone"] || [[deviceName lastObject] isEqualToString:@"iPod"])
		clubName = [NSString stringWithFormat:@"%@ Family", [[[[deviceName objectAtIndex:1] substringToIndex:1] uppercaseString] stringByAppendingString:[[deviceName objectAtIndex:2] substringWithRange:NSMakeRange(1, [[deviceName objectAtIndex:1] length] - 2)]]];
	
	else {
		for (HONContactUserVO *vo in unsortedContacts) {
			if (![segmentedKeys containsObject:vo.lastName]) {
				[segmentedKeys addObject:vo.lastName];
				
				NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
				[segmentedDict setValue:newSegment forKey:vo.lastName];
				
			} else {
				NSMutableArray *prevSegment = (NSMutableArray *)[segmentedDict valueForKey:vo.lastName];
				[prevSegment addObject:vo];
				[segmentedDict setValue:prevSegment forKey:vo.lastName];
			}
		}
	
		for (NSString *key in segmentedDict) {
			if ([[segmentedDict objectForKey:key] count] >= 2) {
				clubName = [NSString stringWithFormat:@"%@ Family", key];
				break;
			}
		}
	}
	
	if ([clubName length] > 0) {
		NSMutableDictionary *familyClubDict = [[[HONClubAssistant sharedInstance] emptyClubDictionary] mutableCopy];
		[familyClubDict setValue:clubName forKey:@"name"];
		[familyClubDict setValue:@"SUGGESTED" forKey:@"club_type"];
		
		NSLog(@"FAMILY CLUB:[%@]", familyClubDict);
		
		HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:[familyClubDict copy]];
		[_suggestedClubs addObject:vo];
		[_dictItems addObject:vo.dictionary];
	}
	
	
	// area code
	if ([[HONAppDelegate phoneNumber] length] > 0) {
		NSMutableDictionary *areaCodeDict = [[[HONClubAssistant sharedInstance] emptyClubDictionary] mutableCopy];
		[areaCodeDict setValue:[[[HONAppDelegate phoneNumber] substringWithRange:NSMakeRange(2, 3)] stringByAppendingString:@" club"] forKey:@"name"];
		[areaCodeDict setValue:@"NEARBY" forKey:@"club_type"];
		
		
		HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:[areaCodeDict copy]];
		[_suggestedClubs addObject:vo];
		[_dictItems addObject:vo.dictionary];
	}
	
	
	// email domain
	[segmentedDict removeAllObjects];
	[segmentedKeys removeAllObjects];
	
	for (HONContactUserVO *vo in unsortedContacts) {
		if ([vo.email length] > 0) {
			NSString *emailDomain = [[vo.email componentsSeparatedByString:@"@"] lastObject];
			
			
			BOOL isValid = YES;
			for (NSString *domain in [HONAppDelegate excludedClubDomains]) {
				if ([emailDomain isEqualToString:domain]) {
					isValid = NO;
					break;
				}
			}
			
			if (isValid) {
				if (![segmentedKeys containsObject:emailDomain]) {
					[segmentedKeys addObject:emailDomain];
					
					NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
					[segmentedDict setValue:newSegment forKey:emailDomain];
					
				} else {
					NSMutableArray *prevSegment = (NSMutableArray *)[segmentedDict valueForKey:emailDomain];
					[prevSegment addObject:vo];
					[segmentedDict setValue:prevSegment forKey:emailDomain];
				}
			}
		}
	}
	
	clubName = @"";
	for (NSString *key in segmentedDict) {
		if ([[segmentedDict objectForKey:key] count] >= 2) {
			clubName = [key stringByAppendingString:@" Club"];
			break;
		}
	}
	
	if ([clubName length] > 0) {
		NSMutableDictionary *familyClubDict = [[[HONClubAssistant sharedInstance] emptyClubDictionary] mutableCopy];
		[familyClubDict setValue:clubName forKey:@"name"];
		[familyClubDict setValue:@"SUGGESTED" forKey:@"club_type"];
		
		HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:[familyClubDict copy]];
		[_suggestedClubs addObject:vo];
		[_dictItems addObject:vo.dictionary];
	}
}


#pragma mark - Data Tally
- (void)_sortItems {
	for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]]])
		[_timelineItems addObject:[HONTimelineItemVO timelineItemWithDictionary:dict]];
	
	[_tableView reloadData];
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}



#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	editButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[editButton setBackgroundImage:[UIImage imageNamed:@"editClubsButton_nonActive"] forState:UIControlStateNormal];
	[editButton setBackgroundImage:[UIImage imageNamed:@"editClubsButton_Active"] forState:UIControlStateHighlighted];
	[editButton addTarget:self action:@selector(_goEditClubs) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"News"];
	[headerView addButton:editButton];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge) asLightStyle:NO]];
	[self.view addSubview:headerView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
	
	[self _retrieveTimeline];
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
	
	NSLog(@"newsTab_total:[%d]", [HONAppDelegate totalForCounter:@"newsTab"]);
	if ([HONAppDelegate incTotalForCounter:@"newsTab"] == 1) {
		[[[UIAlertView alloc] initWithTitle:@"News Tip"
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
- (void)_goEditClubs {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Edit Clubs"];
	
	[self.navigationController pushViewController:[[HONUserClubsViewController alloc] init] animated:YES];
}

- (void)_goCreateChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs Timeline - Create Challenge"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Refresh"];
	
	[self _retrieveTimeline];
}

- (void)_goConfirmClubs {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Confirm Clubs"];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateClub {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Create Club"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_selectedNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedNewsTab <|::");
}

- (void)_refreshNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshNewsTab <|::");
	[self _goRefresh];
}

- (void)_tareNewsTab:(NSNotification *)notification {
	NSLog(@"::|> _tareNewsTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
}


#pragma mark - ClubNewsFeedItemViewCell Delegates
- (void)clubNewsFeedViewCell:(HONClubNewsFeedViewCell *)viewCell createClubWithProtoVO:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:createClubWithProtoVO:(%@ - %@)", userClubVO.clubName, userClubVO.blurb);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Create Club"];
	[self _createClubWithProtoVO:userClubVO];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)clubNewsFeedItemViewCell:(HONClubNewsFeedViewCell *)viewCell selectedCTARow:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:selectedCTARow:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Selected CTA Row"
									   withUserClub:userClubVO];
	
	
}


- (void)clubNewsFeedItemViewCell:(HONClubNewsFeedViewCell *)viewCell selectedClubRow:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:selectedClubRow:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Selected Club Row"
									   withUserClub:userClubVO];
}

- (void)clubNewsFeedItemViewCell:(HONClubNewsFeedViewCell *)viewCell joinClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:joinClub:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Join Club"
									   withUserClub:userClubVO];
	
	
	[self _joinClub:userClubVO];
}

- (void)clubNewsFeedItemViewCell:(HONClubNewsFeedViewCell *)viewCell likeClubChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:likeClubChallenge:(%d - %@)", challengeVO.challengeID, challengeVO.subjectNames);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Liked"
									   withChallenge:challengeVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:challengeVO.challengeID forOpponent:challengeVO.creatorVO completion:^(NSObject *result){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:[HONChallengeVO challengeWithDictionary:(NSDictionary *)result]];
	}];
}

- (void)clubNewsFeedItemViewCell:(HONClubNewsFeedViewCell *)viewCell moreClubChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:moreClubChallenge:(%d - %@)", challengeVO.clubID, challengeVO.subjectNames);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - More"
									   withChallenge:challengeVO];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:0], challengeVO.subjectNames, challengeVO.creatorVO.username];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], challengeVO.subjectNames, challengeVO.creatorVO.username, [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], challengeVO.subjectNames, challengeVO.creatorVO.username, [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:0], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:0] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:0] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: [[UIImage alloc] init],
																							@"url"				: [challengeVO.creatorVO.imagePrefix stringByAppendingString:kSnapLargeSuffix],
																							@"mp_event"			: @"Timeline Details",
																							@"view_controller"	: self}];

}

- (void)clubNewsFeedItemViewCell:(HONClubNewsFeedViewCell *)viewCell replyClubChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:replyClubChallenge:(%d - %@)", challengeVO.clubID, challengeVO.subjectNames);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Reply"
									   withChallenge:challengeVO];
}


- (void)clubNewsFeedItemViewCell:(HONClubNewsFeedViewCell *)viewCell shareClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubNewsFeedViewCell:shareClub:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Share"
									  withUserClub:userClubVO];
	
	
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_timelineItems count] : 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubNewsFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubNewsFeedViewCell alloc] init];
	
	cell.cellType = (indexPath.section == 0) ? HONClubNewsFeedCellTypeClub : HONClubNewsFeedCellTypeCreateClub;
	
	if (indexPath.section == 0) {
		cell.timelineItemVO = (HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row];
	
	} else {
		if (indexPath.row == 0) {
			UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
			createClubButton.frame = CGRectMake(0.0, 9.0, 320.0, 46.0);
			[createClubButton setBackgroundImage:[UIImage imageNamed:@"createClubButton_nonActive"] forState:UIControlStateNormal];
			[createClubButton setBackgroundImage:[UIImage imageNamed:@"createClubButton_Active"] forState:UIControlStateHighlighted];
			[createClubButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:createClubButton];
		
		} else {
			UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
			createClubButton.frame = CGRectMake(0.0, 9.0, 320.0, 46.0);
			[createClubButton setBackgroundImage:[UIImage imageNamed:@"createClubButton_nonActive"] forState:UIControlStateNormal];
			[createClubButton setBackgroundImage:[UIImage imageNamed:@"createClubButton_Active"] forState:UIControlStateHighlighted];
			[createClubButton addTarget:self action:@selector(_goCreateClub) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:createClubButton];
		}
	}
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1)
		return (kOrthodoxTableCellHeight);
	
	HONTimelineItemVO *vo = (HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row];
	return ((vo.timelineItemType == HONTimelineItemTypeUserCreated) ? 330.0 : kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);//return ((indexPath.section == 0) ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONClubNewsFeedViewCell *cell = (HONClubNewsFeedViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.timelineItemVO.timelineItemType == HONTimelineItemTypeUserCreated) {
		HONTimelineItemVO *vo = (HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row];
		vo.userClubVO.clubID = 40;
		
		NSLog(@"/// SHOW CLUB TIMELINE:(%@ - %@)", [vo.dictionary objectForKey:@"id"], [vo.dictionary objectForKey:@""]);
		[[HONAPICaller sharedInstance] retrieveClubByClubID:40 completion:^(NSObject *result) {
			
		}];
		
	} else
		NSLog(@"/// SOMETHING ELSE:(%@)", ((HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row]).dictionary);
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[_tableView setContentOffset:CGPointZero animated:NO];
}



@end
