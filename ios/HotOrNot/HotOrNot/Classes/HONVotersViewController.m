//
//  HONVotersViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "MBProgressHUD.h"

#import "HONVotersViewController.h"
#import "HONTableViewCell.h"
#import "HONVoterViewCell.h"
#import "HONVoterVO.h"
#import "HONUserVO.h"
#import "HONComposeTopicViewController.h"
#import "HONTableView.h"


@interface HONVotersViewController()
- (void)_retrieveUsers;

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONVoterVO *voterVO;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *voters;
@end

@implementation HONVotersViewController

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		
		self.voters = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voterChallenge:) name:@"VOTER_CHALLENGE" object:nil];
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
- (void)_retrieveUsers {
//	NSDictionary *params = @{@"action"		: NSStringFromInt(5),
//							 @"challengeID"	: @(_challengeVO.challengeID)};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//> (%@/%@) %@\n\n", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	
	/*
	 AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kProgressHUDDisplayTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			result = [[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] sortedArrayUsingDescriptors:
					  [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]];
			
			//SelfieclubJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			_voters = [NSMutableArray new];
			for (NSDictionary *dict in result) {
				HONVoterVO *vo = [HONVoterVO voterWithDictionary:dict];
				
				if (vo != nil)
					[_voters addObject:vo];
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kProgressHUDDisplayTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kProgressHUDErrorTime];
		_progressHUD = nil;
	}];*/
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.topItem.title = @"Likes";

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 81.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	[self _retrieveUsers];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


- (void)viewDidUnload {
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VOTER_CHALLENGE" object:nil];
}


#pragma mark - Navigation
- (void)_goBack {
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Votes - Back"
//									  withChallenge:_challengeVO];
	
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notifications
- (void)_voterChallenge:(NSNotification *)notification {
	_voterVO = (HONVoterVO *)[notification object];
	
//	HONUserVO *vo = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//												   @(_voterVO.userID], @"id),
//												   @(_voterVO.points], @"points),
//												   @(_voterVO.votes], @"total_votes),
//												   @(_voterVO.pokes], @"pokes),
//												   NSStringFromInt(0), @"pics",
//												   NSStringFromInt(0), @"age",
//												   _voterVO.username, @"username",
//												   _voterVO.fbID, @"fb_id",
//												   _voterVO.imageURL, @"avatar_url", nil]];
//	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithUser:vo withSubject:_challengeVO.subjectName]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_voters count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONVoterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONVoterViewCell alloc] init];
	
	cell.voterVO = [_voters objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[(HONVoterViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	_voterVO = (HONVoterVO *)[_voters objectAtIndex:indexPath.row];
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Votes - Selected Row"  withChallenge:_challengeVO];
}


@end
