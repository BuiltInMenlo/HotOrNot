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

#import "HONClubsTimelineViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONCreateClubViewController.h"
#import "HONUserClubsViewController.h"
#import "HONClubTimelineViewCell.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"

#import "HONTimelineItemVO.h"


@interface HONClubsTimelineViewController () <EGORefreshTableHeaderDelegate, HONClubTimelineViewCellDelegate>
@property (nonatomic, strong) UIViewController *wrapperViewController;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NSMutableArray *dictItems;
@property (nonatomic, strong) NSMutableArray *timelineItems;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) NSMutableArray *invitedClubs;
@property (nonatomic, strong) HONUserClubVO *ownClub;
@end


@implementation HONClubsTimelineViewController


- (id)initWithWrapperViewController:(UIViewController *)wrapperViewController {
	if ((self = [super init])) {
		_wrapperViewController = wrapperViewController;
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

- (void)refresh {
	[self _goRefresh];
}

- (void)tare {
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
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
//	[[HONAPICaller sharedInstance] retrieveClubTimelineForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		
		_joinedClubs = [NSMutableArray array];
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
			
			if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0) {
				[_dictItems addObject:[[((NSDictionary *)result) objectForKey:@"owned"] objectAtIndex:0]];
				_ownClub = [HONUserClubVO clubWithDictionary:[[((NSDictionary *)result) objectForKey:@"owned"] objectAtIndex:0]];
			}
			
			
			for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"joined"]) {
				[_dictItems addObject:dict];
				[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
			}
			
			_invitedClubs = [NSMutableArray array];
			[self _suggestClubs];
			
			[[HONAPICaller sharedInstance] retrieveClubInvitesForUserWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
				for (NSDictionary *dict in (NSArray *)result) {
					[_dictItems addObject:dict];
					[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
				}
				
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
				//[self _sortItems];
				
				for (NSDictionary *dict in _dictItems) {
					[_timelineItems addObject:[HONTimelineItemVO timelineItemWithDictionary:dict]];
				}
				
				self.view.hidden = NO;
				[_tableView reloadData];
				[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
			}];
		}];
//	}];
}

- (void)_joinClub:(HONUserClubVO *)userClubVO {
	[[HONAPICaller sharedInstance] joinClub:userClubVO withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		
	}];
}


#pragma mark - Data Manip
- (void)_suggestClubs {
	NSMutableArray *unsortedContacts = [NSMutableArray array];
	
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
		
		
		NSData *imageData = nil;
		if (ABPersonHasImageData(ref))
			imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
		
		
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
																				  @"image"	: (imageData != nil) ? imageData : UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"])}]];
		}
	}
	
	NSMutableArray *segmentedKeys = [[NSMutableArray alloc] init];
	NSMutableDictionary *segmentedDict = [[NSMutableDictionary alloc] init];
	
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
	
	NSString *clubName = @"";
	NSArray *deviceName = [[[HONDeviceIntrinsics sharedInstance] deviceName] componentsSeparatedByString:@" "];
	if ([[deviceName lastObject] isEqualToString:@"iPhone"] || [[deviceName lastObject] isEqualToString:@"iPod"])
		clubName = [NSString stringWithFormat:@"The %@ Family", [[[[deviceName objectAtIndex:1] substringToIndex:1] uppercaseString] stringByAppendingString:[[deviceName objectAtIndex:2] substringWithRange:NSMakeRange(1, [[deviceName objectAtIndex:1] length] - 2)]]];
	
	else {
		for (NSString *key in segmentedDict) {
			if ([[segmentedDict objectForKey:key] count] >= 2) {
				clubName = [NSString stringWithFormat:@"The %@ family", key];
				break;
			}
		}
	}
	
	if ([clubName length] > 0) {
		NSMutableDictionary *familyClubDict = [[[HONClubAssistant sharedInstance] emptyClubDictionary] mutableCopy];
		[familyClubDict setValue:clubName forKey:@"name"];
		
		HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:[familyClubDict copy]];
		[_invitedClubs addObject:vo];
		[_dictItems addObject:vo.dictionary];
	}
	
	
	if ([[HONAppDelegate phoneNumber] length] > 0) {
		NSMutableDictionary *areaCodeDict = [[[HONClubAssistant sharedInstance] emptyClubDictionary] mutableCopy];
		[areaCodeDict setValue:[[[HONAppDelegate phoneNumber] substringWithRange:NSMakeRange(2, 3)] stringByAppendingString:@" club"] forKey:@"name"];
		
		HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:[areaCodeDict copy]];
		[_invitedClubs addObject:vo];
		[_dictItems addObject:vo.dictionary];
	}
	
	
	
	[segmentedDict removeAllObjects];
	[segmentedKeys removeAllObjects];
	
	for (HONContactUserVO *vo in unsortedContacts) {
		if ([vo.email length] > 0) {
			NSString *emailDomain = [[vo.email componentsSeparatedByString:@"@"] lastObject];
			
			if (![emailDomain isEqualToString:@"gmail.com"] && ![emailDomain isEqualToString:@"live.com"] && ![emailDomain isEqualToString:@"yahoo.com"] && ![emailDomain isEqualToString:@"hotmail.com"]) {
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
			clubName = [key stringByAppendingString:@" club"];
			break;
		}
	}
	
	if ([clubName length] > 0) {
		NSMutableDictionary *familyClubDict = [[[HONClubAssistant sharedInstance] emptyClubDictionary] mutableCopy];
		[familyClubDict setValue:clubName forKey:@"name"];
		
		HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:[familyClubDict copy]];
		[_invitedClubs addObject:vo];
		[_dictItems addObject:vo.dictionary];
	}
}


#pragma mark - Data Tally
- (void)_sortItems {
	for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]])
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs"];
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
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) usingTareOffset:0.0];
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


#pragma mark - ClubsTimelineViewCell Delegates
- (void)clubTimelineViewCellCreateClub:(HONClubTimelineViewCell *)viewCell {
	NSLog(@"[*:*] clubTimelineViewCellCreateClub");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Create Club"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell selectedCTARow:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubTimelineViewCell:selectedCTARow:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Selected CTA Row"
									   withUserClub:userClubVO];
	
	
}

- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell selectedClubRow:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubTimelineViewCell:selectedClubRow:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Selected Club Row"
									   withUserClub:userClubVO];
}

- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell joinClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubTimelineViewCell:joinClub:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Join Club"
									   withUserClub:userClubVO];
	
	
	[self _joinClub:userClubVO];
}

- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell likeClubChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"[*:*] clubTimelineViewCell:likeClubChallenge:(%d - %@)", challengeVO.challengeID, challengeVO.subjectName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Liked"
									   withChallenge:challengeVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:challengeVO.challengeID forOpponent:challengeVO.creatorVO completion:^(NSObject *result){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:[HONChallengeVO challengeWithDictionary:(NSDictionary *)result]];
	}];
}

- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell moreClubChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"[*:*] clubTimelineViewCell:moreClubChallenge:(%d - %@)", challengeVO.clubID, challengeVO.subjectName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - More"
									   withChallenge:challengeVO];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:0], challengeVO.subjectName, challengeVO.creatorVO.username];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], challengeVO.subjectName, challengeVO.creatorVO.username, [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], challengeVO.subjectName, challengeVO.creatorVO.username, [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:0], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:0] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:0] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: [[UIImage alloc] init],
																							@"url"				: [challengeVO.creatorVO.imagePrefix stringByAppendingString:kSnapLargeSuffix],
																							@"mp_event"			: @"Timeline Details",
																							@"view_controller"	: self}];

}

- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell replyClubChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"[*:*] clubTimelineViewCell:replyClubChallenge:(%d - %@)", challengeVO.clubID, challengeVO.subjectName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Reply"
									   withChallenge:challengeVO];
}


- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell shareClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubTimelineViewCell:shareClub:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Share"
									  withUserClub:userClubVO];
	
	
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_timelineItems count] + 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubTimelineViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubTimelineViewCell alloc] init];
	
	cell.cellType = (indexPath.row < [_timelineItems count]) ? HONClubTimelineCellTypeClub : HONClubTimelineCellTypeCreateClub;
	
	if (cell.cellType == HONClubTimelineCellTypeClub)
		cell.timelineItemVO = (HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row];
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [_timelineItems count])
		return (kOrthodoxTableCellHeight);
	
	HONTimelineItemVO *vo = (HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row];
	return ((vo.timelineItemType == HONTimelineItemTypeSelfie) ? 330.0 : 111.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row < [_timelineItems count]) ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONClubTimelineViewCell *cell = (HONClubTimelineViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.timelineItemVO.timelineItemType == HONTimelineItemTypeSelfie) {
		HONTimelineItemVO *vo = (HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row];
		vo.userClubVO.clubID = 40;
		
		NSLog(@"/// SHOW CLUB TIMELINE:(%@ - %@)", [vo.dictionary objectForKey:@"id"], [vo.dictionary objectForKey:@""]);
		[[HONAPICaller sharedInstance] retrieveClubByClubID:40 completion:^(NSObject *result) {
			
		}];
		
	} else if (cell.timelineItemVO.timelineItemType == HONTimelineItemTypeInviteRequest) {
		NSLog(@"/// SHOW CLUB STATS:(%@)", ((HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row]).dictionary);
	
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
