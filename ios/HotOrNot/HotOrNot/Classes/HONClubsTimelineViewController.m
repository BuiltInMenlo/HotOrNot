//
//  HONClubsTimelineViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 10:58 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"


#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

#import "HONClubsTimelineViewController.h"
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
	[[HONAPICaller sharedInstance] retrieveClubTimelineForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result)
			[_dictItems addObject:dict];
		
		
		_joinedClubs = [NSMutableArray array];
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
			
			if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0) {
				[_dictItems addObject:[((NSDictionary *)result) objectForKey:@"owned"]];
				_ownClub = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
			}
			
			
			for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"joined"]) {
				[_dictItems addObject:dict];
				[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
			}
			
			// --//> *** POPULATED FPO CLUBS *** <//-- //
			for (NSDictionary *dict in [[HONClubAssistant sharedInstance] fpoJoinedClubs]) {
				[_dictItems addObject:dict];
				[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
			} // --//> *** POPULATED FPO CLUBS *** <//-- //
			
			
			
			_invitedClubs = [NSMutableArray array];
			[[HONAPICaller sharedInstance] retrieveClubInvitesForUserWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
				for (NSDictionary *dict in (NSArray *)result) {
					[_dictItems addObject:dict];
					[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
				}
				
				
				// --//> *** POPULATED FPO CLUBS *** <//-- //
				for (NSDictionary *dict in [[HONClubAssistant sharedInstance] fpoInviteClubs]) {
					[_dictItems addObject:dict];
					[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
				} // --//> *** POPULATED FPO CLUBS *** <//-- //
				
				
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
				[self _sortItems];
			}];
		}];
	}];
}


#pragma mark - Data Tally
- (void)_sortItems {
	for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]])
		[_timelineItems addObject:[HONTimelineItemVO timelineItemWithDictionary:dict]];
	
	self.view.hidden = NO;
	[_tableView reloadData];
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}



#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.frame = CGRectMake(0.0, kNavHeaderHeight + 55.0, 320.0, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + 55.0));
	
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height) style:UITableViewStylePlain];
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
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	[self tare];
	self.view.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	[self _retrieveTimeline];
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
- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Refresh"];
	
	[self _retrieveTimeline];
}


#pragma mark - ClubsTimelineViewCell Delegates
- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell selectedCTARow:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] clubTimelineViewCell:selectedCTARow:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Selected CTA Row"
									   withUserClub:userClubVO];
	
	
}

- (void)clubTimelineViewCell:(HONClubTimelineViewCell *)viewCell selectedClubRow:(HONUserClubVO *)userClubVO {
	NSLog(@"[*:*] selectedClubRow:(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club News - Selected Club Row"
									   withUserClub:userClubVO];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_timelineItems count]);
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
	
	cell.timelineItemVO = (HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONTimelineItemVO *vo = (HONTimelineItemVO *)[_timelineItems objectAtIndex:indexPath.row];
	return ((vo.timelineItemType == HONTimelineItemTypeSelfie) ? 330.0 : 111.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
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
