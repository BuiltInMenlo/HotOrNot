//
//  HONChallengesViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"

#import "HONAppDelegate.h"
#import "HONChallengesViewController.h"
#import "HONChallengeViewCell.h"
#import "HONChallengeVO.h"
#import "HONFacebookCaller.h"

#import "HONSettingsViewController.h"
#import "HONCreateChallengeViewController.h"
#import "HONImagePickerViewController.h"
#import "HONLoginViewController.h"

@interface HONChallengesViewController() <ASIHTTPRequestDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic) BOOL isFirstRun;

- (void)_retrieveChallenges;
@end

@implementation HONChallengesViewController

@synthesize tableView = _tableView;
@synthesize challenges = _challenges;
@synthesize isFirstRun = _isFirstRun;

- (id)init {
	if ((self = [super init])) {
		self.tabBarItem.image = [UIImage imageNamed:@"tab01_nonActive"];
		self.challenges = [NSMutableArray new];
		self.isFirstRun = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_acceptChallenge:) name:@"ACCEPT_CHALLENGE" object:nil];
	}
	
	return (self);
}
							
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 50.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 70.0;
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
	
	if (FBSession.activeSession.state == FBSessionStateCreated && self.isFirstRun) {
		self.isFirstRun = NO;
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
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
	ASIFormDataRequest *challengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kChallengesAPI]]];
	[challengeRequest setDelegate:self];
	[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[challengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[challengeRequest startAsynchronous];
}


#pragma mark - Navigation
- (void)_goCreateChallenge {
	//[self.navigationController pushViewController:[[HONCreateChallengeViewController alloc] init] animated:YES];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_acceptChallenge:(NSNotification *)notification {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
	
	[self.navigationController pushViewController:[[HONImagePickerViewController alloc] initWithChallenge:[notification object]] animated:YES];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 0)
		return (0);
	
	else
		return ([self.challenges count] + 2);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 45.0)];
	
	if (section == 0) {
		
		NSLog(@"PROFILE URL:[%@]", [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [[HONAppDelegate fbProfileForUser] objectForKey:@"id"]]);
		
		UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
		imgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[imgView setImage:[UIImage imageNamed:@"basicHeader.png"]];
		[headerView addSubview:imgView];
//
//		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 10.0, 200.0, 16.0)];
//		//ptsLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
//		//ptsLabel = [SNAppDelegate snLinkColor];
//		ptsLabel.backgroundColor = [UIColor clearColor];
//		ptsLabel.text = [NSString stringWithFormat:@"%d points", [[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue]];
//		[headerView addSubview:ptsLabel];
//		
//		UILabel *playedLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 200.0, 16.0)];
//		//playedLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
//		//playedLabel = [SNAppDelegate snLinkColor];
//		playedLabel.backgroundColor = [UIColor clearColor];
//		playedLabel.text = [NSString stringWithFormat:@"%d rounds played", [[[HONAppDelegate infoForUser] objectForKey:@"matches"] intValue]];
//		[headerView addSubview:playedLabel];
	
	} else {
		headerView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
		
		UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		createChallengeButton.frame = CGRectMake(0.0, 0.0, 320.0, 75.0);
		[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"mainCTA_nonActive.png"] forState:UIControlStateNormal];
		[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"mainCTA_Active.png"] forState:UIControlStateHighlighted];
		[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:createChallengeButton];
	}
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//static NSString * MyIdentifier = @"SNTwitterFriendViewCell_iPhone";
	
	//SNTwitterFriendViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNTwitterFriendViewCell_iPhone cellReuseIdentifier]];
	HONChallengeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	//NSMutableArray *letterArray = [_friendsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
	

	if (cell == nil) {
		if (indexPath.row == 0)
			cell = [[HONChallengeViewCell alloc] initAsTopCell:[[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] withSubject:@"funnyface"];
		
		else if (indexPath.row == [_challenges count] + 1)
			cell = [[HONChallengeViewCell alloc] initAsBottomCell];
				
		else
			cell = [[HONChallengeViewCell alloc] initAsChallengeCell];
	}
	
	if (indexPath.row > 0 && indexPath.row < [_challenges count] + 1)
		cell.challengeVO = [_challenges objectAtIndex:indexPath.row - 1];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0)
		return (55.0);
		
	else
		return (70.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if (section == 0)
		return (45.0);
	
	else
		return (75.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	NSLog(@"didSelectRowAtIndexPath");
	//[HONFacebookCaller postToTimeline:[_challenges objectAtIndex:indexPath.row]];
	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
//		
//	} completion:^(BOOL finished) {
//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
//	}];
	
	//[self.navigationController pushViewController:[[SNFriendProfileViewController alloc] initWithTwitterUser:(SNTwitterUserVO *)[_friends objectAtIndex:indexPath.row]] animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return YES if you want the specified item to be editable.
	return (YES);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.challenges removeObjectAtIndex:indexPath.row - 1];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}



#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONChallengesViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		
		NSError *error = nil;
		if (error != nil)
			NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
		
		else {
			NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]];
			
			_challenges = [NSMutableArray new];
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil)
					[list addObject:vo];
			}
			
			_challenges = [list copy];
			[_tableView reloadData];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
