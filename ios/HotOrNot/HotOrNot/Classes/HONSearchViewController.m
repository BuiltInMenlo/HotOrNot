//
//  HONSearchViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.04.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "HONSearchViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONUserVO.h"
#import "HONSubjectVO.h"
#import "HONSearchSubjectViewCell.h"
#import "HONSearchUserViewCell.h"
#import "HONSearchToggleHeaderView.h"

@interface HONSearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *results;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) UIImageView *emptySetImgView;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic) BOOL isUser;

@end

@implementation HONSearchViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_retrieveSearchResults:) name:@"RETRIEVE_SEARCH_RESULTS" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Data Calls
- (void)retrieveUsers:(NSString *)username {
	_username = username;
	_isUser = YES;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Searching Users…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 1], @"action",
									_username, @"username",
									nil];
	
	[httpClient postPath:kSearchAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONSearchViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[unsortedUsers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO]]]];
			NSLog(@"HONSearchViewController AFNetworking: %@", unsortedUsers);
			
			_results = [NSMutableArray array];
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[_results addObject:vo];
			}
			
			_emptySetImgView.hidden = ([_results count] > 0);
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				if ([_results count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"No results found!", @"Status message when no network detected");
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
					
				} else {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"SearchViewController AFNetworking %@", [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)retrieveSubjects:(NSString *)subject {
	_subject = subject;
	_isUser = NO;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Searching Hashtags…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 2], @"action",
									_subject, @"subjectName",
									nil];
	
	[httpClient postPath:kSearchAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONSearchViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedSubjects = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedSubjects = [NSMutableArray arrayWithArray:[unsortedSubjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]]];
			NSLog(@"HONSearchViewController AFNetworking: %@", unsortedSubjects);
			
			_results = [NSMutableArray array];
			for (NSDictionary *serverList in parsedSubjects) {
				HONSubjectVO *vo = [HONSubjectVO subjectWithDictionary:serverList];
				
				if (vo != nil)
					[_results addObject:vo];
			}
			
			_emptySetImgView.hidden = ([_results count] > 0);
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				if ([_results count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"No results found!", @"Status message when no network detected");
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
				
				} else {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"ChallengesViewController AFNetworking %@", [error localizedDescription]);
		
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
	
	_isUser = NO;
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height - 188.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_results = [NSMutableArray array];
	for (NSString *subject in [HONAppDelegate searchSubjects]) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithInt:0], @"id",
									 [NSNumber numberWithInt:arc4random() % 100], @"score",
									 [NSNumber numberWithInt:0], @"active",
									 subject, @"name", nil];
		[_results addObject:[HONSubjectVO subjectWithDictionary:dict]];
	}
	
	
	[_tableView reloadData];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goSubjects {
	_isUser = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_SUBJECT_SEARCH" object:nil];
}

- (void)_goUsers {
	_isUser = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_USER_SEARCH" object:nil];
}

#pragma mark - Notifications
- (void)_retrieveSearchReults:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:(_isUser) ? @"SHOW_USER_SEARCH_RESULTS" : @"SHOW_SUBJECT_SEARCH_RESULTS" object:[notification object]];
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_results count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	HONSearchToggleHeaderView *headerView = [[HONSearchToggleHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 71.0)];
	[headerView.subjectButton addTarget:self action:@selector(_goSubjects) forControlEvents:UIControlEventTouchUpInside];
	[headerView.userButton addTarget:self action:@selector(_goUsers) forControlEvents:UIControlEventTouchUpInside];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_isUser) {
		HONSearchUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONSearchUserViewCell alloc] init];
		
		cell.userVO = [_results objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
		
	} else {
		HONSearchSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONSearchSubjectViewCell alloc] init];
			cell.subjectVO = [_results objectAtIndex:indexPath.row];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kRowHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kSearchHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	if (_isUser) {
		HONUserVO *vo = (HONUserVO *)[_results objectAtIndex:indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:vo.username];
		
	} else {
		HONSubjectVO *vo = (HONSubjectVO *)[_results objectAtIndex:indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:vo.subjectName];
	}
	
	

}


@end
