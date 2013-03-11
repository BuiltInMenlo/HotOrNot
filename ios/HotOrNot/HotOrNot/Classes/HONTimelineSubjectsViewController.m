//
//  HONTimelineSubjectsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "HONTimelineSubjectsViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONSearchHeaderView.h"
#import "HONTimelineSubjectViewCell.h"
#import "HONVoteSubjectVO.h"
#import "HONTimelineViewController.h"

@interface HONTimelineSubjectsViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) UIButton *refreshButton;
@property(nonatomic, strong) UIImageView *emptySetImgView;
@property(nonatomic, strong) NSMutableDictionary *subjects;
@property(nonatomic, strong) NSMutableArray *subjectNames;
@end

@implementation HONTimelineSubjectsViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_VOTE_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_challengeSubjectSelected:) name:@"CHALLENGE_SUBJECT_SELECTED" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - Data Calls
- (void)_retrieveSubjects {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
		
	[httpClient postPath:kVotesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONVoteSubjectsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"HONVoteSubjectsViewController AFNetworking: %@", parsedLists);
			_subjects = [NSMutableDictionary dictionary];
			_subjectNames = [NSMutableArray array];
			
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *challengeVO = [HONChallengeVO challengeWithDictionary:serverList];
				if ([_subjects objectForKey:challengeVO.subjectName] == nil) {
					[_subjects setObject:[NSMutableArray new] forKey:challengeVO.subjectName];
					[_subjectNames addObject:challengeVO.subjectName];
				}
				
				[[_subjects objectForKey:challengeVO.subjectName] addObject:challengeVO];
			}
			
			_emptySetImgView.hidden = ([_subjects count] > 0);
			[_tableView reloadData];
		}
		
		_refreshButton.hidden = NO;
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"VoteSubjectsViewController AFNetworking %@", [error localizedDescription]);
		
		_refreshButton.hidden = NO;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"HOME"];
	[self.view addSubview:_headerView];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectMake(284.0, 10.0, 24.0, 24.0);
	[activityIndicatorView startAnimating];
	[_headerView addSubview:activityIndicatorView];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_refreshButton.frame = CGRectMake(270.0, 0.0, 44.0, 44.0);
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_refreshButton];
	
	_emptySetImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 115.0, 320.0, 285.0)];
	_emptySetImgView.image = [UIImage imageNamed:@"noChallengesOverlay"];
	_emptySetImgView.hidden = YES;
	[self.view addSubview:_emptySetImgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 45.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Getting Challenges…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self _retrieveSubjects];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Vote Wall - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_refreshButton.hidden = YES;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Refreshing…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self _retrieveSubjects];
}

#pragma mark - Notifications
- (void)_refreshVoteTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	
	[self _retrieveSubjects];
}

- (void)_challengeSubjectSelected:(NSNotification *)notification {
	[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[(NSNumber *)[notification object] intValue] inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_subjectNames count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	HONSearchHeaderView *headerView = [[HONSearchHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 71.0)];
	[headerView.inviteFriendsButton addTarget:self action:@selector(_goInviteFriends) forControlEvents:UIControlEventTouchUpInside];
	[headerView.dailyChallengeButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONTimelineSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[HONTimelineSubjectViewCell alloc] initWithSubject:[_subjectNames objectAtIndex:indexPath.row]];
		[cell setChallenges:[_subjects objectForKey:[_subjectNames objectAtIndex:indexPath.row]]];
		cell.index = indexPath.row;
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (128.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (71.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithSubjectName:[_subjectNames objectAtIndex:indexPath.row]] animated:YES];
}

@end
