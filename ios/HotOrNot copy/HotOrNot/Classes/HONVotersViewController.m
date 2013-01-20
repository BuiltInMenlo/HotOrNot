//
//  HONVotersViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Mixpanel.h"

#import "HONVotersViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONAlternatingRowsViewCell.h"
#import "HONVoterViewCell.h"
#import "HONVoterVO.h"
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
		
		[HONAppDelegate toggleViewPushed:YES];
		self.view.backgroundColor = [UIColor whiteColor];
		self.voters = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voterChallenge:) name:@"VOTER_CHALLENGE" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_retrieveUsers {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 5], @"action",
									[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
									nil];
	
	[httpClient postPath:kVotesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
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
		NSLog(@"%@", [error localizedDescription]);
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"VOTES"];
	[self.view addSubview:_headerView];

	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:cancelButton];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 108.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 70.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self _retrieveUsers];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VOTER_CHALLENGE" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);//interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Navigation
- (void)_goBack {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VOTER_CHALLENGE" object:nil];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goCancel {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VOTER_CHALLENGE" object:nil];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {}];
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


#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	UINavigationController *navigationController;
	
	switch(buttonIndex) {
		case 0:
			[[Mixpanel sharedInstance] track:@"Challenge Voters - Create Challenge"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:_voterVO.userID withSubject:_challengeVO.subjectName]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;
			
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
		cell = [[HONVoterViewCell alloc] initAsGreyCell:indexPath.row % 2 == 1];
	
	cell.voterVO = [_voters objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[(HONVoterViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	
	_voterVO = (HONVoterVO *)[_voters objectAtIndex:indexPath.row];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Challenge User"
																		 message:[NSString stringWithFormat:@"Want to %@ challenge %@?", _challengeVO.subjectName, _voterVO.username]
																		delegate:self
															cancelButtonTitle:@"Yes"
															otherButtonTitles:@"No", nil];
	[alertView show];
}


@end