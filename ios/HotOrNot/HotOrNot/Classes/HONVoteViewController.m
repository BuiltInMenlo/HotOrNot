//
//  HONVoteViewController
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteViewController.h"
#import "HONVoteItemViewCell.h"
#import "ASIFormDataRequest.h"
#import "HONAppDelegate.h"

@interface HONVoteViewController() <ASIHTTPRequestDelegate>
- (void)_retrieveChallenges;
@property(nonatomic) int subjectID;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic, strong) ASIFormDataRequest *challengesRequest;
@end

@implementation HONVoteViewController
@synthesize subjectID = _subjectID;
@synthesize tableView = _tableView;
@synthesize challenges = _challenges;
@synthesize challengesRequest = _challengesRequest;

- (id)init {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Vote", @"Vote");
		self.tabBarItem.image = [UIImage imageNamed:@"second"];
		self.subjectID = 0;
		
		self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
	}
	
	return (self);
}

- (id)initWithSubject:(int)subjectID {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Vote", @"Vote");
		self.tabBarItem.image = [UIImage imageNamed:@"second"];
		self.subjectID = subjectID;
		
		self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
	}
	
	return (self);
}
							
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	NSLog(@"SUBJECT:[%d]", self.subjectID);
	
	UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
	[headerImgView setImage:[UIImage imageNamed:@"basicHeader.png"]];
	[self.view addSubview:headerImgView];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, self.view.frame.size.width, self.view.frame.size.height - 95.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 180.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	//self.tableView.contentInset = UIEdgeInsetsMake(9.0, 0.0f, 9.0f, 0.0f);
	[self.view addSubview:self.tableView];
	
	[self _retrieveChallenges];
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
	[self _retrieveChallenges];
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

- (void)_retrieveChallenges {
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kChallengesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	if (self.subjectID == 0)
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
	
	else {
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", self.subjectID] forKey:@"subjectID"];
	}
	
	[self.challengesRequest startAsynchronous];
}

#pragma mark - Notifications
- (void)_voteMain:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	NSLog(@"VOTE MAIN \n%d", vo.challengeID);
	
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kChallengesAPI]]];
	[voteRequest setDelegate:self];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
	[voteRequest setPostValue:@"Y" forKey:@"creator"];
	[voteRequest startAsynchronous];
}

- (void)_voteSub:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	NSLog(@"VOTE SUB \n%d", vo.challengeID);
	
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kChallengesAPI]]];
	[voteRequest setDelegate:self];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
	[voteRequest setPostValue:@"N" forKey:@"creator"];
	[voteRequest startAsynchronous];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([self.challenges count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 50.0)];
	headerView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	
	HONChallengeVO *vo = [_challenges objectAtIndex:section];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 3.0, 200.0, 16.0)];
	//label = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	//label = [SNAppDelegate snLinkColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = [NSString stringWithFormat:@"#%@", vo.subjectName];
	[headerView addSubview:label];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//static NSString * MyIdentifier = @"SNTwitterFriendViewCell_iPhone";
	
	//SNTwitterFriendViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNTwitterFriendViewCell_iPhone cellReuseIdentifier]];
	HONVoteItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	//NSMutableArray *letterArray = [_friendsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
	
	
	if (cell == nil) {
		cell = [[HONVoteItemViewCell alloc] init];
	}
	
	cell.challengeVO = [_challenges objectAtIndex:indexPath.section];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (180.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (50.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	//	[UIView animateWithDuration:0.25 animations:^(void) {
	//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
	//
	//	} completion:^(BOOL finished) {
	//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
	//	}];
	
	//[self.navigationController pushViewController:[[SNFriendProfileViewController alloc] initWithTwitterUser:(SNTwitterUserVO *)[_friends objectAtIndex:indexPath.row]] animated:YES];
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONVoteViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:self.challengesRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				_challenges = [NSMutableArray new];
				
				NSMutableArray *list = [NSMutableArray array];
				for (NSDictionary *serverList in parsedLists) {
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
					//NSLog(@"VO:[%@]", vo.image2URL);
					
					if (vo != nil)
						[list addObject:vo];
				}
				
				_challenges = [list copy];
				[_tableView reloadData];
			}
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
