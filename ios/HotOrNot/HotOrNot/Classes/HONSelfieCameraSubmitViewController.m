//
//  HONCameraSubmitViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "NSString+DataTypes.h"

#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

#import "HONSelfieCameraSubmitViewController.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONSelfieCameraClubViewCell.h"
#import "HONUserClubVO.h"

@interface HONSelfieCameraSubmitViewController () <EGORefreshTableHeaderDelegate, HONSelfieCameraClubViewCellDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONProtoChallengeVO *protoChallengeVO;

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONUserClubVO *clubVO;

@property (nonatomic, strong) NSMutableDictionary *clubIDs;
@property (nonatomic, strong) NSMutableArray *dictClubs;
@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) NSMutableArray *segmentedKeys;
@property (nonatomic, strong) NSDictionary *segmentedClubs;

@property (nonatomic, strong) NSMutableArray *selectedClubs;
@property (nonatomic, strong) NSMutableArray *viewCells;
@end


@implementation HONSelfieCameraSubmitViewController

- (id)initWithClub:(HONUserClubVO *)clubVO {
	NSLog(@"[:|:] [%@ initWithClub] (%@)", self.class, clubVO.dictionary);
	if ((self = [super init])) {
		_clubVO = clubVO;
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
	
	_dictClubs = [NSMutableArray array];
	_allClubs = [NSMutableArray array];
	_clubIDs = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array],
															[NSMutableArray array]]
												  forKeys:@[@"owned",
															@"member"]];
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
		for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
			NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
			
			for (NSDictionary *dict in [result objectForKey:key])
				[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
			
			[_clubIDs setValue:clubIDs forKey:key];
			[_dictClubs addObjectsFromArray:[result objectForKey:key]];
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[self _sortItems];
		_segmentedClubs = [self _populateSegmentedDictionary];
		
		_selectedClubs = [NSMutableArray array];
		_viewCells = [NSMutableArray arrayWithCapacity:[_allClubs count]];
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}


#pragma mark - Data Tally
- (void)_sortItems {
	for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO]]]])
		[_allClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight + 87.0)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setContentInset:UIEdgeInsetsZero];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:YES];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Select Club"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(0.0, self.view.frame.size.height - 77.0, 320.0, 64.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
	
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(changeTabToIndex:) withObject:@1];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[self _retrieveClubs];
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
- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Back"];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goCancel {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Cancel"];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Refresh"];
	
	[_dictClubs removeAllObjects];
	[_allClubs removeAllObjects];
	[_clubIDs removeAllObjects];
	[self _retrieveClubs];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Submit"];
	
	if ([_selectedClubs count] == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Club Selected!"
															message:@"You have to choose at least one club to submit your photo into."
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView setTag:0];
		[alertView show];
	
	} else {
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}

- (void)_goSelectAllToggle {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Create Selfie - Select %@", ([_selectedClubs count] == [_allClubs count]) ? @"None" : @"All"]];
	
	if ([_selectedClubs count] != [_allClubs count]) {
		for (HONSelfieCameraClubViewCell *cell in _viewCells)
			[cell toggleSelected:YES];
		
		[_selectedClubs removeAllObjects];
		[_selectedClubs addObjectsFromArray:_allClubs];
	
	} else {
		for (HONSelfieCameraClubViewCell *cell in _viewCells)
			[cell toggleSelected:NO];
		
		[_selectedClubs removeAllObjects];
	}
	
	HONSelfieCameraClubViewCell *cell = (HONSelfieCameraClubViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	[cell toggleSelected:[_selectedClubs count] == [_allClubs count]];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - SelfieCameraClubViewCell Delegates
- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] selfieSubmitClubViewCell:selectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Selected Club"
									   withUserClub:userClubVO];
	
	if (![_selectedClubs containsObject:userClubVO])
		[_selectedClubs addObject:userClubVO];
}

- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] selfieSubmitClubViewCell:deselectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Deselected Club"
									   withUserClub:userClubVO];
	
	if ([_selectedClubs containsObject:userClubVO])
		[_selectedClubs removeObject:userClubVO];
}

- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell selectAllToggled:(BOOL)isSelected {
	NSLog(@"[*|*] selfieSubmitClubViewCell:selectAllToggled(%d)", isSelected);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[@"Create Selfie - Select All " stringByAppendingString:(isSelected) ? @"On" : @"Off"]];
	[self _goSelectAllToggle];
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


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_allClubs count] : 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSelfieCameraClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSelfieCameraClubViewCell alloc] initAsSelectAllCell:(indexPath.section == 1)];
	
	if (indexPath.section == 0) {
		cell.userClubVO = (HONUserClubVO *)[_allClubs objectAtIndex:indexPath.row];
		
		if ([_viewCells containsObject:cell])
			[_viewCells replaceObjectAtIndex:indexPath.row withObject:cell];
		
		else
			[_viewCells addObject:cell];
	
	} else {
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 23.0, 238.0, 20.0)];
		captionLabel.backgroundColor = [UIColor clearColor];
		captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
		captionLabel.textColor = [UIColor blackColor];
		captionLabel.text = @"Select all clubs";
		[cell.contentView addSubview:captionLabel];
	}
	
	[cell hideChevron];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section == 0) {
		HONSelfieCameraClubViewCell *cell = (HONSelfieCameraClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell invertSelected];
		
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Create Selfie - %@elected Club", (cell.isSelected) ? @"S" : @"Des"]
										   withUserClub:cell.userClubVO];
		
		if (cell.isSelected) {
			if (![_selectedClubs containsObject:cell.userClubVO])
				[_selectedClubs addObject:cell.userClubVO];
		
		} else {
			if ([_selectedClubs containsObject:cell.userClubVO])
				[_selectedClubs removeObject:cell.userClubVO];
		}
		
	} else
		[self _goSelectAllToggle];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Create Selfie - Empty Selection " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Select All"]];
		
		if (buttonIndex == 1)
			[self _goSelectAllToggle];
	}
}


#pragma mark - Data Manip
-(NSDictionary *)_populateSegmentedDictionary {
	_segmentedKeys = [[NSMutableArray alloc] init];
	[_segmentedKeys removeAllObjects];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	for (HONUserClubVO *vo in _allClubs) {
		if ([vo.clubName length] > 0) {
			NSString *charKey = [[vo.clubName substringToIndex:1] lowercaseString];
			if (![_segmentedKeys containsObject:charKey]) {
				[_segmentedKeys addObject:charKey];
				
				NSMutableArray *newSegment = [[NSMutableArray alloc] initWithObjects:vo, nil];
				[dict setValue:newSegment forKey:charKey];
				
			} else {
				NSMutableArray *prevSegment = (NSMutableArray *)[dict valueForKey:charKey];
				[prevSegment addObject:vo];
				[dict setValue:prevSegment forKey:charKey];
			}
		}
	}
	
//	for (NSString *key in dict) {
//		for (HONUserClubVO *vo in [dict objectForKey:key])
//			NSLog(@"_segmentedKeys[%@] = [%@]", key, vo.clubName);
//	}

	return ([dict copy]);
}



@end
