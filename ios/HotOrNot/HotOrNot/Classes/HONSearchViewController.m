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
#import "HONSearchViewCell.h"
#import "HONHeaderView.h"
#import "HONPopularUserVO.h"
#import "HONPopularSubjectVO.h"
#import "HONPopularSubjectViewCell.h"
#import "HONPopularUserViewCell.h"

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

- (id)initAsUserSearch:(NSString *)username {
	if ((self = [super init])) {
		_isUser = YES;
		_username = username;
	}
	
	return (self);
}

- (id)initAsSubjectSearch:(NSString *)subject {
	if ((self = [super init])) {
		_isUser = NO;
		_subject = subject;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Data Calls
- (void)retrieveUsers:(NSString *)username {
	_username = username;
	
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
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[unsortedUsers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO]]]];
			NSLog(@"HONChallengesViewController AFNetworking: %@", unsortedUsers);
			
			_results = [NSMutableArray array];
			for (NSDictionary *serverList in parsedUsers) {
				HONPopularUserVO *vo = [HONPopularUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[_results addObject:vo];
			}
			
			_emptySetImgView.hidden = ([_results count] > 0);
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"SearchViewController AFNetworking %@", [error localizedDescription]);
		
		if (_progressHUD != nil) {
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when submit fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
		}
	}];
}

- (void)retrieveSubjects:(NSString *)subject {
	_subject = subject;
	
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
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedSubjects = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedSubjects = [NSMutableArray arrayWithArray:[unsortedSubjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]]];
			NSLog(@"SearchViewController AFNetworking: %@", unsortedSubjects);
			
			_results = [NSMutableArray array];
			for (NSDictionary *serverList in parsedSubjects) {
				HONPopularSubjectVO *vo = [HONPopularSubjectVO subjectWithDictionary:serverList];
				
				if (vo != nil)
					[_results addObject:vo];
			}
			
			_emptySetImgView.hidden = ([_results count] > 0);
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"ChallengesViewController AFNetworking %@", [error localizedDescription]);
		
		if (_progressHUD != nil) {
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when submit fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
		}
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	_results = [NSMutableArray array];
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height - 188.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_results count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_isUser) {
		HONPopularUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONPopularUserViewCell alloc] initAsGreyCell:(indexPath.row % 2 == 1)];
		
		cell.userVO = [_results objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
		
	} else {
		HONPopularSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONPopularSubjectViewCell alloc] initAsGreyCell:(indexPath.row % 2 == 1)];
			cell.subjectVO = [_results objectAtIndex:indexPath.row];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	if (_isUser) {
		HONPopularUserVO *vo = (HONPopularUserVO *)[_results objectAtIndex:indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:vo.username];
		
	} else {
		HONPopularSubjectVO *vo = (HONPopularSubjectVO *)[_results objectAtIndex:indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:vo.subjectName];
	}
	
	

}


@end
