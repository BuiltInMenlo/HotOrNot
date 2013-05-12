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
@property(nonatomic, strong) NSMutableArray *defaultUsers;
@property(nonatomic, strong) NSMutableArray *pastUsers;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) UIImageView *emptySetImgView;
@property(nonatomic, strong) UIView *whiteBGView;
@property(nonatomic, strong) UIImageView *toggleImageView;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic) BOOL isUser;
@property(nonatomic) BOOL isResults;

@end

@implementation HONSearchViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_retrieveUserSearchResults:) name:@"RETRIEVE_USER_SEARCH_RESULTS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_retrieveSubjectSearchResults:) name:@"RETRIEVE_SUBJECT_SEARCH_RESULTS" object:nil];
		
		_isUser = YES;
		_isResults = NO;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Data Calls
- (void)retrieveDefaultUsers {
	NSString *usernames = @"";
	
	for (NSString *username in [HONAppDelegate searchUsers])
		usernames = [NSString stringWithFormat:@"%@|%@", usernames, username];
	
	usernames = [usernames substringFromIndex:1];
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 3], @"action",
									usernames, @"usernames",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
			//NSLog(@"HONSearchViewController AFNetworking: %@", unsortedUsers);
			
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[_defaultUsers addObject:vo];
			}
			
			_emptySetImgView.hidden = ([_defaultUsers count] > 0);
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				if ([_defaultUsers count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
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
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_retrievePastUsers {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 4], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONChallengerPickerViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[unsortedUsers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES]]]];
			//NSLog(@"HONChallengerPickerViewController AFNetworking: %@", parsedUsers);
			
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[_pastUsers addObject:vo];
			}
			
			if (_progressHUD != nil) {
				if ([_pastUsers count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
					
				} else {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONChallengerPickerViewController AFNetworking %@", [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


- (void)retrieveUsers:(NSString *)username {
	_username = username;
	_isUser = YES;
	_isResults = YES;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 1], @"action",
									_username, @"username",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
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
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)retrieveSubjects:(NSString *)subject {
	_subject = subject;
	_isUser = NO;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchHashtags", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 2], @"action",
									_subject, @"subjectName",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
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
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	_defaultUsers = [NSMutableArray array];
	_pastUsers = [NSMutableArray array];
	
	_whiteBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 52.0)];
	_whiteBGView.backgroundColor = [UIColor whiteColor];
	_whiteBGView.alpha = 0.0;
	[self.view addSubview:_whiteBGView];
	
	_toggleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 11.0, 301.0, 31.0)];
	_toggleImageView.image = [UIImage imageNamed:@"searchToggle_Users"];
	_toggleImageView.alpha = 0.0;
	[self.view addSubview:_toggleImageView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 52.0, 320.0, [UIScreen mainScreen].bounds.size.height - 332.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.alpha = 0.0;
	[self.view addSubview:_tableView];
	
	[self retrieveDefaultUsers];
	[self _retrievePastUsers];
	
	[self performSelector:@selector(_showTable) withObject:nil afterDelay:0.25];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)_showTable {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tableView.alpha = 1.0;
		_whiteBGView.alpha = 1.0;
		_toggleImageView.alpha = 1.0;
	}];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notifications
- (void)_retrieveSubjectSearchResults:(NSNotification *)notification {
	[self retrieveSubjects:[notification object]];
}

- (void)_retrieveUserSearchResults:(NSNotification *)notification {
	[self retrieveUsers:[notification object]];
	
	_tableView.frame = CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height - kNavBarHeaderHeight);
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((_isResults) ? [_results count] : (section == 0) ? [_defaultUsers count] : [_pastUsers count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//return ((_isResults) ? 1 : 2);
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 31.0)];
	headerView.image = [UIImage imageNamed:@"searchDiscoverHeader"];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, 31.0)];
	label.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:12];
	label.textColor = [HONAppDelegate honBlueTxtColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"Official accounts" : @"People you have snapped with";
	[headerView addSubview:label];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_isUser) {
		HONSearchUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONSearchUserViewCell alloc] init];
		
		cell.userVO = (_isResults) ? [_results objectAtIndex:indexPath.row] : (indexPath.section == 0) ? [_defaultUsers objectAtIndex:indexPath.row] : [_pastUsers objectAtIndex:indexPath.row];
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
	return (kDefaultCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((_isResults) ? 0.0 : 31.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RESIGN_SEARCH_BAR_FOCUS" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
	
	if (_isUser) {
		HONUserVO *vo = (HONUserVO *)[_results objectAtIndex:indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:vo.username];
		
	} else {
		HONSubjectVO *vo = (HONSubjectVO *)[_results objectAtIndex:indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:vo.subjectName];
	}
}


@end

/*
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
@property(nonatomic) BOOL isDefaultSearch;

@end

@implementation HONSearchViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_retrieveUserSearchResults:) name:@"RETRIEVE_USER_SEARCH_RESULTS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_retrieveSubjectSearchResults:) name:@"RETRIEVE_SUBJECT_SEARCH_RESULTS" object:nil];
		
		_isUser = YES;
		_isDefaultSearch = NO;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Data Calls
- (void)retrieveDefaultUsers {
	NSString *usernames = @"";
	
	for (NSString *username in [HONAppDelegate searchUsers])
		usernames = [NSString stringWithFormat:@"%@|%@", usernames, username];
	
	usernames = [usernames substringFromIndex:1];
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 3], @"action",
									usernames, @"usernames",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONSearchViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[unsortedUsers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"points" ascending:YES]]]];
			//NSLog(@"HONSearchViewController AFNetworking: %@", unsortedUsers);
			
			_results = [[NSMutableArray alloc] init];
			NSMutableArray *defaultUsers = [NSMutableArray array];
			
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[defaultUsers addObject:vo];
			}
			
			[_results addObject:defaultUsers];
			
			if (_progressHUD != nil) {
				if ([_results count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
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
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_retrievePastUsers {
	_isDefaultSearch = YES;
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 4], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONSearchViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[unsortedUsers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES]]]];
			NSLog(@"HONSearchViewController AFNetworking: %@", parsedUsers);
			
			NSMutableArray *pastUsers = [NSMutableArray array];
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[pastUsers addObject:vo];
			}
			
			[_results addObject:pastUsers];
			_emptySetImgView.hidden = ([_results count] > 0);
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				if ([_results count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
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
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)retrieveUsers:(NSString *)username {
	_username = username;
	_isUser = YES;
	_isDefaultSearch = NO;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 1], @"action",
									_username, @"username",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
			
			_results = [[NSMutableArray alloc] init];
			NSMutableArray *users = [NSMutableArray array];
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[users addObject:vo];
			}
			
			[_results addObject:users];
			_emptySetImgView.hidden = ([users count] > 0);
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				if ([_results count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
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
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)retrieveSubjects:(NSString *)subject {
	_subject = subject;
	_isUser = NO;
	_isDefaultSearch = NO;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchHashtags", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 2], @"action",
									_subject, @"subjectName",
									nil];
	
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
			
			_results = [[NSMutableArray alloc] init];
			NSMutableArray *subjects = [NSMutableArray array];
			for (NSDictionary *serverList in parsedSubjects) {
				HONSubjectVO *vo = [HONSubjectVO subjectWithDictionary:serverList];
				
				if (vo != nil)
					[subjects addObject:vo];
			}
			
			[_results addObject:subjects];
			_emptySetImgView.hidden = ([subjects count] > 0);
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				if ([_results count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
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
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	//_results = [[NSMutableArray alloc] init];
	_results = [NSMutableArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], nil];
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height - 280.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.alpha = 0.0;
	[self.view addSubview:_tableView];
	
	[self retrieveDefaultUsers];
	[self _retrievePastUsers];
	[self performSelector:@selector(_showTable) withObject:nil afterDelay:0.25];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)_showTable {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tableView.alpha = 1.0;
	}];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notifications
- (void)_retrieveSubjectSearchResults:(NSNotification *)notification {
	[self retrieveSubjects:[notification object]];
}

- (void)_retrieveUserSearchResults:(NSNotification *)notification {
	[self retrieveUsers:[notification object]];
	
	_tableView.frame = CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height - kNavBarHeaderHeight);
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"numberOfRowsInSection [%d]", [[_results objectAtIndex:section] count]);
	return ((_isDefaultSearch) ? [[_results objectAtIndex:0] count] + [[_results objectAtIndex:1] count] : [[_results objectAtIndex:0] count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1 + (int)_isDefaultSearch);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 31.0)];
	headerView.image = [UIImage imageNamed:@"searchTopRowPopularHeader"];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_isUser) {
		HONSearchUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONSearchUserViewCell alloc] init];
		
		if (_isDefaultSearch)
			cell.userVO = [[_results objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		
		else
			cell.userVO = [[_results objectAtIndex:0] objectAtIndex:indexPath.row];
		
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
	return (kDefaultCellHeight);
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return (31.0);
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RESIGN_SEARCH_BAR_FOCUS" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
	
	if (_isUser) {
		HONUserVO *vo = (HONUserVO *)[_results objectAtIndex:indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:vo.username];
		
	} else {
		HONSubjectVO *vo = (HONSubjectVO *)[_results objectAtIndex:indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:vo.subjectName];
	}
}


@end
 
 */
