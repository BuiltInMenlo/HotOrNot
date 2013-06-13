//
//  HONVotersViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

#import "HONVotersViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONGenericRowViewCell.h"
#import "HONVoterViewCell.h"
#import "HONVoterVO.h"
#import "HONUserVO.h"
#import "HONImagePickerViewController.h"


@interface HONVotersViewController()
- (void)_retrieveUsers;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONVoterVO *voterVO;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *voters;
@property(nonatomic, strong) HONHeaderView *headerView;
@end

@implementation HONVotersViewController

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		
		self.view.backgroundColor = [UIColor whiteColor];
		self.voters = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voterChallenge:) name:@"VOTER_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabsDropped:) name:@"TABS_DROPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabsRaised:) name:@"TABS_RAISED" object:nil];
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
- (void)_retrieveUsers {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 5], @"action",
									[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
									nil];
	
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONVotersViewControler AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSArray *unsortedList = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedLists = [unsortedList sortedArrayUsingDescriptors:
											[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]];
			
			//NSLog(@"HONVotersViewControler AFNetworking: %@", unsortedList);
			_voters = [NSMutableArray new];
			for (NSDictionary *serverList in parsedLists) {
				HONVoterVO *vo = [HONVoterVO voterWithDictionary:serverList];
				
				if (vo != nil)
					[_voters addObject:vo];
			}
			
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"VotersViewController AFNetworking %@", [error localizedDescription]);
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:_challengeVO.subjectName];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(3.0, 0.0, 64.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:backButton];
		
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 81.0)) style:UITableViewStylePlain];
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
	[[Mixpanel sharedInstance] track:@"Timeline Votes - Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notifications
- (void)_voterChallenge:(NSNotification *)notification {
	NSLog(@"VOTER_CHALLENGE");
	_voterVO = (HONVoterVO *)[notification object];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Challenge User"
																		 message:[NSString stringWithFormat:@"Want to %@ challenge %@?", _challengeVO.subjectName, _voterVO.username]
																		delegate:self
															cancelButtonTitle:@"Yes"
															otherButtonTitles:@"No", nil];
	[alertView show];
}

- (void)_tabsDropped:(NSNotification *)notification {
	_tableView.frame = CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 29.0));
}

- (void)_tabsRaised:(NSNotification *)notification {
	_tableView.frame = CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 81.0));
}


#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	UINavigationController *navigationController;
	
	switch(buttonIndex) {
		case 0: {
			[[Mixpanel sharedInstance] track:@"Challenge Voters - Create Challenge"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			HONUserVO *vo = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																		  [NSString stringWithFormat:@"%d", _voterVO.userID], @"id",
																		  [NSString stringWithFormat:@"%d", _voterVO.points], @"points",
																		  [NSString stringWithFormat:@"%d", _voterVO.votes], @"votes",
																		  [NSString stringWithFormat:@"%d", _voterVO.pokes], @"pokes",
																		  [NSString stringWithFormat:@"%d", 0], @"pics",
																		  _voterVO.username, @"username",
																		  _voterVO.fbID, @"fb_id",
																		  _voterVO.imageURL, @"avatar_url", nil]];
			
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:vo withSubject:_challengeVO.subjectName]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;}
			
		case 1:
			break;
	}
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
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Challenge User"
//																		 message:[NSString stringWithFormat:@"Want to %@ challenge %@?", _challengeVO.subjectName, _voterVO.username]
//																		delegate:self
//															cancelButtonTitle:@"Yes"
//															otherButtonTitles:@"No", nil];
//	[alertView show];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:_voterVO.username];
}


@end
