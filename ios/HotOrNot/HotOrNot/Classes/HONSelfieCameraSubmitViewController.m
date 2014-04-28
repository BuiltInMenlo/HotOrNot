//
//  HONCameraSubmitViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "NSString+DataTypes.h"

#import "MBProgressHUD.h"

#import "HONSelfieCameraSubmitViewController.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONSelfieCameraClubViewCell.h"
#import "HONUserClubVO.h"

@interface HONSelfieCameraSubmitViewController () <HONSelfieCameraClubViewCellDelegate>
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

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Submit"];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//		NSLog(@"_selfieSubmitType:[%d]", _selfieSubmitType);
		
//		if (_selfieSubmitType == HONSelfieCameraSubmitTypeCreateChallenge || _selfieSubmitType == HONSelfieCameraSubmitTypeReplyChallenge)
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
//		
//		else if (_selfieSubmitType == HONSelfieCameraSubmitTypeCreateMessage)
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGES" object:nil];
//		
//		else if (_selfieSubmitType == HONSelfieCameraSubmitTypeReplyMessage) {
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGES" object:nil];
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGE" object:nil];
//		}
	}];
}

- (void)_goSelectAllToggle {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Create Selfie - Select %@", ([_selectedClubs count] == [_allClubs count]) ? @"None" : @"All"]];
	
	
	if ([_selectedClubs count] == [_allClubs count]) {
		for (HONSelfieCameraClubViewCell *cell in _viewCells) {
			if (cell.userClubVO != nil)
				[cell toggleSelected:NO];
		}
		
		[_selectedClubs removeAllObjects];
	
	} else {
		for (HONSelfieCameraClubViewCell *cell in _viewCells) {
			if (cell.userClubVO != nil)
				[cell toggleSelected:YES];
		}
		
		[_selectedClubs addObjectsFromArray:_allClubs];
	}
}


#pragma mark - SelfieCameraClubViewCell Delegates
- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO {
	NSLog(@"[*|*] selfieSubmitClubViewCell:selectedClub(%d - %@)", userClubVO.clubID, userClubVO.clubName);
	
	if (![_selectedClubs containsObject:userClubVO])
		[_selectedClubs addObject:userClubVO];
}

- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO {
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
	return ([[HONTableHeaderView alloc] initWithTitle:[@"SEC.%d" stringByAppendingString:[@"" stringFromInt:section]]]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSelfieCameraClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSelfieCameraClubViewCell alloc] initAsSelectAllCell:(indexPath.section == 1)];
	
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
	
	[cell hideChevron];
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
		HONSelfieCameraClubViewCell *cell = (HONSelfieCameraClubViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell invertSelect];
		
	} else
		[self _goSelectAllToggle];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Create Selfie - Empty Selection " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Select All"]];
		
		if (buttonIndex == 1)
			[self _goSelectAllToggle];
	}
}


@end
