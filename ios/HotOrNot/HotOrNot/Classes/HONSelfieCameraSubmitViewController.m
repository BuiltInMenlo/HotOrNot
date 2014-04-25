//
//  HONCameraSubmitViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"


#import "HONSelfieCameraSubmitViewController.h"
#import "HONUtilsSuite.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONSelfieSubmitClubViewCell.h"
#import "HONUserClubVO.h"

@interface HONSelfieCameraSubmitViewController () <HONSelfieSubmitClubViewCellDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONProtoChallengeVO *protoChallengeVO;

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONUserClubVO *ownClub;
@property (nonatomic, strong) NSMutableArray *allClubs;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) NSMutableArray *selectedClubs;
@property (nonatomic, strong) NSMutableArray *viewCells;
@end


@implementation HONSelfieCameraSubmitViewController

- (id)initWithChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super init])) {
		NSLog(@"[:|:] [%@ initWithChallenge] (%@)", self.class, challengeVO.dictionary);
		
		_challengeVO = challengeVO;
	}
	
	return (self);
}

- (id)initWithProtoChallenge:(HONProtoChallengeVO *)protoChallengeVO {
	if ((self = [super init])) {
		NSLog(@"[:|:] [%@ initWithProtoChallenge] (%@)", self.class, protoChallengeVO.dictionary);
		
		_protoChallengeVO = protoChallengeVO;
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
	
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0)
			_ownClub = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
		
		if (_ownClub != nil)
			[_allClubs addObject:_ownClub];
		
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"joined"])
			[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		
		[_allClubs arrayByAddingObjectsFromArray:_joinedClubs];
		
		// --//> 2 fpo filler clubs for testing <//-- //
		for (NSDictionary *dict in [HONAppDelegate fpoClubDictionaries])
			[_allClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		// --//> 2 fpo filler clubs for testing <//-- //
		
		[_tableView reloadData];
		
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor brownColor];
	
	_allClubs = [NSMutableArray array];
	_joinedClubs = [NSMutableArray array];
	_selectedClubs = [NSMutableArray array];
	_viewCells = [NSMutableArray array];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + 90.0)) style:UITableViewStylePlain];
	_tableView.frame = CGRectOffset(_tableView.frame, 0.0, -20.0);
	[_tableView setBackgroundColor:[[HONColorAuthority sharedInstance] honDebugColor:HONDebugGreenColor]];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_tableView];
	
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Select Club"];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:cancelButton];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(227.0, 1.0, 93.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:submitButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[self _retrieveClubs];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Create Selfie - Back" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Create Selfie - Cancel" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Create Selfie - Submit" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	if ([_selectedClubs count] == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No clubs selected!"
															message:@"Would you like to select all?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:0];
		[alertView show];
	
	} else {
		
	}
}

- (void)_goSelectAllToggle {
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:[NSString stringWithFormat:@"Create Selfie - Select %@", ([_selectedClubs count] == [_allClubs count]) ? @"None" : @"All"]];
	
	
	if ([_selectedClubs count] == [_allClubs count]) {
		for (HONSelfieSubmitClubViewCell *cell in _viewCells)
			[cell toggleSelected:NO];
		
		[_selectedClubs removeAllObjects];
	
	} else {
		for (HONSelfieSubmitClubViewCell *cell in _viewCells)
			[cell toggleSelected:YES];
		
		[_selectedClubs addObjectsFromArray:_allClubs];
	}
}


#pragma mark - SelfieSubmitClubViewCell Delegates
- (void)selfieSubmitClubViewCell:(HONSelfieSubmitClubViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] selfieSubmitClubViewCell:selectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	if (![_selectedClubs containsObject:userClubVO])
		[_selectedClubs addObject:userClubVO];
}

- (void)selfieSubmitClubViewCell:(HONSelfieSubmitClubViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] selfieSubmitClubViewCell:deselectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	if ([_selectedClubs containsObject:userClubVO])
		[_selectedClubs removeObject:userClubVO];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_allClubs count] : 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ((section == 0) ? [[HONTableHeaderView alloc] initWithTitle:@"CLUBS"] : [[UIView alloc] initWithFrame:CGRectZero]);
	return ([[HONTableHeaderView alloc] initWithTitle:[@"SEC.%d" stringByAppendingString:[NSString stringWithFormat:@"%d", section]]]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSelfieSubmitClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSelfieSubmitClubViewCell alloc] initAsSelectAllCell:(indexPath.section == 1)];
	
	
	if (indexPath.section == 0) {
		cell.userClubVO = (HONUserClubVO *)[_allClubs objectAtIndex:indexPath.row];
		cell.delegate = self;
		
		NSLog(@"cell.userClubVO:(%@)", cell.userClubVO.dictionary);
	
	} else {
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
		cell.textLabel.frame = CGRectOffset(cell.textLabel.frame, 0.0, -2.0);
		cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
		cell.textLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.text = @"Select all";
	}
	
	int index = (indexPath.section == 0) ? indexPath.row : [_allClubs count];
	if ([_viewCells containsObject:cell])
		[_viewCells replaceObjectAtIndex:index withObject:cell];
	
	else
		[_viewCells addObject:cell];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((section == 0) ? kOrthodoxTableHeaderHeight : 0.0);
	return (kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section == 0) {
		HONSelfieSubmitClubViewCell *cell = (HONSelfieSubmitClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell invertSelect];
		
	} else
		[self _goSelectAllToggle];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Create Selfie - Empty Selection %@", (buttonIndex == 0) ? @"Cancel" : @"Select All"] properties:[[HONAnalyticsParams sharedInstance] userProperty]];
		
		if (buttonIndex == 1)
			[self _goSelectAllToggle];
	}
}


@end
