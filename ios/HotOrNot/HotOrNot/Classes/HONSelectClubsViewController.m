//
//  HONSelectClubsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/21/2014 @ 18:38 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONSelectClubsViewController.h"

@interface HONSelectClubsViewController () <HONClubToggleViewCellDelegate>
@end


@implementation HONSelectClubsViewController

- (id)init {
	if ((self = [super init])) {
		
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
	
	if ([[[HONClubAssistant sharedInstance] fetchUserClubs] count] == 0) {
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
			[[HONClubAssistant sharedInstance] writeUserClubs:result];
			
			for (NSString *key in @[@"owned", @"member"]) {
				NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
				
				for (NSDictionary *dict in [result objectForKey:key])
					[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
				
				[_dictClubs addObjectsFromArray:[result objectForKey:key]];
				[_clubIDs setValue:clubIDs forKey:key];
			}
			
			for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO]]]])
				[_allClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
			
			_segmentedClubs = [self _populateSegmentedDictionary];
			
			_selectedClubs = [NSMutableArray array];
			_viewCells = [NSMutableArray arrayWithCapacity:[_allClubs count]];
			
			[self _didFinishDataRefresh];
		}];
	
	} else {
		for (NSString *key in @[@"owned", @"member"]) {
			NSMutableArray *clubIDs = [_clubIDs objectForKey:key];
			
			for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:key])
				[clubIDs addObject:[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]]];
			
			[_dictClubs addObjectsFromArray:[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:key]];
			[_clubIDs setValue:clubIDs forKey:key];
		}
		
		for (NSDictionary *dict in [NSMutableArray arrayWithArray:[_dictClubs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO]]]])
			[_allClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		_segmentedClubs = [self _populateSegmentedDictionary];
		
		_selectedClubs = [NSMutableArray array];
		_viewCells = [NSMutableArray arrayWithCapacity:[_allClubs count]];
		
		[self _didFinishDataRefresh];
	}
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[_dictClubs removeAllObjects];
	[_allClubs removeAllObjects];
	[_clubIDs removeAllObjects];
	
	[[HONClubAssistant sharedInstance] wipeUserClubs];
	[self _retrieveClubs];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight + 87.0)) style:UITableViewStylePlain];
	[_tableView setContentInset:UIEdgeInsetsMake(-20.0, 0.0, 0.0, 0.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"" hasBackground:YES];
	[self.view addSubview:_headerView];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(0.0, self.view.frame.size.height - 77.0, 320.0, 64.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[self _retrieveClubs];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
	
	NSLog(@"INSET:[%@]", NSStringFromUIEdgeInsets(_tableView.contentInset));
	NSLog(@"OFFSET:[%@]", NSStringFromCGPoint(_tableView.contentOffset));
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRefresh {
	[_dictClubs removeAllObjects];
	[_allClubs removeAllObjects];
	[_clubIDs removeAllObjects];
	[self _retrieveClubs];
}

- (void)_goSubmit {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_NEWS_TAB" object:@"Y"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:@"Y"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

- (void)_goSelectAllToggle {
	if ([_selectedClubs count] != [_allClubs count]) {
		for (HONClubToggleViewCell *cell in _viewCells)
			[cell toggleSelected:YES];
		
		[_selectedClubs removeAllObjects];
		[_selectedClubs addObjectsFromArray:_allClubs];
		
	} else {
		for (HONClubToggleViewCell *cell in _viewCells)
			[cell toggleSelected:NO];
		
		[_selectedClubs removeAllObjects];
	}
	
	HONClubToggleViewCell *cell = (HONClubToggleViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	[cell toggleSelected:[_selectedClubs count] == [_allClubs count]];
}


#pragma mark - ClubToggleViewCelll Delegates
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] clubToggleViewCell:selectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	

	
	if (![_selectedClubs containsObject:userClubVO])
		[_selectedClubs addObject:userClubVO];
}

- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] clubToggleViewCell:deselectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	

	
	if ([_selectedClubs containsObject:userClubVO])
		[_selectedClubs removeObject:userClubVO];
	
	HONClubToggleViewCell *toggleAllCell = (HONClubToggleViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	[toggleAllCell toggleSelected:NO];
}

- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectAllToggled:(BOOL)isSelected {
	NSLog(@"[*|*] clubToggleViewCell:selectAllToggled(%d)", isSelected);
	
	[self _goSelectAllToggle];
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
	HONClubToggleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubToggleViewCell alloc] initAsCellType:(indexPath.section == 0) ? HONClubToggleViewCellTypeClub : ([_allClubs count] == 0) ? HONClubToggleViewCellTypeCreateClub : HONClubToggleViewCellTypeSelectAll];
	
	if (indexPath.section == 0) {
		cell.userClubVO = (HONUserClubVO *)[_allClubs objectAtIndex:indexPath.row];
		
		if (_clubID == cell.userClubVO.clubID)
			[cell toggleSelected:YES];
		
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
	return (([_allClubs count] == 0) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section == 0) {
		HONClubToggleViewCell *cell = (HONClubToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell invertSelected];
		
		
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
