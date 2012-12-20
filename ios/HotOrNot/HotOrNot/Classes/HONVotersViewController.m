//
//  HONVotersViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVotersViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONVoterViewCell.h"
#import "HONVoterVO.h"
#import "HONImagePickerViewController.h"

#import "ASIFormDataRequest.h"
#import "Mixpanel.h"

@interface HONVotersViewController () <ASIHTTPRequestDelegate>
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
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_retrieveUsers {
	ASIFormDataRequest *usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[usersRequest setDelegate:self];
	[usersRequest setPostValue:[NSString stringWithFormat:@"%d", 15] forKey:@"action"];
	[usersRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
	//[usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[usersRequest startAsynchronous];
}

- (void)_voterChallenge:(NSNotification *)notification {
	_voterVO = (HONVoterVO *)[notification object];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Challenge User"
																	message:[NSString stringWithFormat:@"Want to #%@ challenge %@?", _challengeVO.subjectName, _voterVO.username]
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
}

#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:[NSString stringWithFormat:@"Voters for #%@", _challengeVO.subjectName]];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:backButton];
	
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
	
	[self _retrieveUsers];
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
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);//interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Navigation
- (void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	[self.navigationController popViewControllerAnimated:YES];
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
			[self presentViewController:navigationController animated:NO completion:nil];
			break;
			
		case 1:
			break;
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_voters count] + 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONVoterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		if (indexPath.row == 0)
			cell = [[HONVoterViewCell alloc] initAsTopCell];
		
		else if (indexPath.row == [_voters count] + 1)
			cell = [[HONVoterViewCell alloc] initAsBottomCell];
		
		else
			cell = [[HONVoterViewCell alloc] initAsMidCell];
	}
	
	if (indexPath.row > 0 && indexPath.row < [_voters count] + 1)
		cell.voterVO = [_voters objectAtIndex:indexPath.row - 1];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0)
		return (20.0);
	
	else
		return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}



#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"HONVotersViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	
	@autoreleasepool {
		NSError *error = nil;
		if (error != nil)
			NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
		
		else {
			NSArray *unsortedList = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			NSArray * parsedLists = [unsortedList sortedArrayUsingDescriptors:
											 [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]];
			
				_voters = [NSMutableArray new];
				for (NSDictionary *serverList in parsedLists) {
					HONVoterVO *vo = [HONVoterVO voterWithDictionary:serverList];
					NSLog(@"VO:[%d]", vo.userID);
					
					if (vo != nil)
						[_voters addObject:vo];
				}
			
			[_tableView reloadData];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
