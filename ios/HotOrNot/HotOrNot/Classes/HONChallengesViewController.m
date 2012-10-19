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
#import "Mixpanel.h"

#import "HONAppDelegate.h"
#import "HONChallengesViewController.h"
#import "HONChallengeViewCell.h"
#import "HONChallengeVO.h"

#import "HONSettingsViewController.h"
#import "HONCreateChallengeViewController.h"
#import "HONImagePickerViewController.h"
#import "HONLoginViewController.h"
#import "HONPhotoViewController.h"
#import "HONVoteViewController.h"
#import "HONHeaderView.h"

@interface HONChallengesViewController() <UIAlertViewDelegate, ASIHTTPRequestDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic) BOOL isFirstRun;
@property(nonatomic, strong) UIImageView *tutorialOverlayImgView;
@property(nonatomic, strong) NSDate *lastDate;
@property(nonatomic, strong) ASIFormDataRequest *nextChallengesRequest;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) NSIndexPath *idxPath;

- (void)_retrieveChallenges;
@end

@implementation HONChallengesViewController

@synthesize tableView = _tableView;
@synthesize challenges = _challenges;
@synthesize isFirstRun = _isFirstRun;
@synthesize tutorialOverlayImgView = _tutorialOverlayImgView;
@synthesize lastDate = _lastDate;
@synthesize nextChallengesRequest = _nextChallengesRequest;
@synthesize challengeVO = _challengeVO;
@synthesize idxPath = _idxPath;

- (id)init {
	if ((self = [super init])) {
		//self.tabBarItem.image = [UIImage imageNamed:@"tab01_nonActive"];
		self.challenges = [NSMutableArray array];
		self.isFirstRun = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_acceptChallenge:) name:@"ACCEPT_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dailyChallenge:) name:@"DAILY_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_nextChallengeBlock:) name:@"NEXT_CHALLENGE_BLOCK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshList:) name:@"REFRESH_LIST" object:nil];
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
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 70.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	//self.tableView.bounces = NO;
	
	//self.tableView.contentInset = UIEdgeInsetsMake(9.0, 0.0f, 9.0f, 0.0f);
	[self.view addSubview:self.tableView];
	
	[self _retrieveChallenges];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue] == 0) {
		NSString *buttonImage;// = [NSString stringWithFormat:@"tutorial_00%d.png", ((arc4random() % 4) + 1)];
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
		
		NSLog(@"HEIGHT:[%f]", screenHeight);
		
		if ([HONAppDelegate isRetina5])
			buttonImage = [NSString stringWithFormat:@"tutorial_00%d-568h.png", ((arc4random() % 4) + 1)];
		
		else
			buttonImage = [NSString stringWithFormat:@"tutorial_00%d.png", ((arc4random() % 4) + 1)];
		
		_tutorialOverlayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, self.view.frame.size.height)];
		_tutorialOverlayImgView.image = [UIImage imageNamed:buttonImage];
		_tutorialOverlayImgView.userInteractionEnabled = YES; 
		[[[UIApplication sharedApplication] delegate].window addSubview:_tutorialOverlayImgView];
	
		UIButton *closeTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeTutorialButton.frame = _tutorialOverlayImgView.frame;
		[closeTutorialButton addTarget:self action:@selector(_goTutorialCancel) forControlEvents:UIControlEventTouchUpInside];
		[_tutorialOverlayImgView addSubview:closeTutorialButton];
		
		UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		createChallengeButton.frame = CGRectMake(0.0, 45.0, 320.0, 78.0);
		[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButtonClear.png"] forState:UIControlStateNormal];
		[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButtonClear_active.png"] forState:UIControlStateHighlighted];
		[createChallengeButton addTarget:self action:@selector(_goTutorialClose) forControlEvents:UIControlEventTouchUpInside];
		[_tutorialOverlayImgView addSubview:createChallengeButton];
	
		UIButton *createChallenge2Button = [UIButton buttonWithType:UIButtonTypeCustom];
		createChallenge2Button.frame = CGRectMake(128.0, _tutorialOverlayImgView.frame.size.height - 48.0, 64.0, 48.0);
		[createChallenge2Button setBackgroundImage:[UIImage imageNamed:@"tabbar_003_nonActive.png"] forState:UIControlStateNormal];
		[createChallenge2Button setBackgroundImage:[UIImage imageNamed:@"tabbar_003_active.png"] forState:UIControlStateHighlighted];
		[createChallenge2Button addTarget:self action:@selector(_goTutorialClose) forControlEvents:UIControlEventTouchUpInside];
		[_tutorialOverlayImgView addSubview:createChallenge2Button];
	}
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
	
	if (FBSession.activeSession.state != 513 && self.isFirstRun) {
		self.isFirstRun = NO;
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
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
	ASIFormDataRequest *challengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[challengeRequest setDelegate:self];
	[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[challengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[challengeRequest startAsynchronous];
}


#pragma mark - Navigation
- (void)_goCreateChallenge {
	//[self.navigationController pushViewController:[[HONCreateChallengeViewController alloc] init] animated:YES];
	
	[[Mixpanel sharedInstance] track:@"Create Challenge"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[self _retrieveChallenges];
}

- (void)_goTutorialCancel {
	int boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
	boot_total++;
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_tutorialOverlayImgView.hidden = YES;
	[_tutorialOverlayImgView removeFromSuperview];
}

- (void)_goTutorialClose {
	int boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
	boot_total++;
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_tutorialOverlayImgView.hidden = YES;
	[_tutorialOverlayImgView removeFromSuperview];
	
	[self _goCreateChallenge];
}


#pragma mark - Notifications
- (void)_acceptChallenge:(NSNotification *)notification {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithChallenge:[notification object]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_dailyChallenge:(NSNotification *)notification {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:[HONAppDelegate dailySubjectName]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_nextChallengeBlock:(NSNotification *)notification {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	self.nextChallengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[self.nextChallengesRequest setDelegate:self];
	[self.nextChallengesRequest setPostValue:[NSString stringWithFormat:@"%d", 12] forKey:@"action"];
	[self.nextChallengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.nextChallengesRequest setPostValue:[dateFormat stringFromDate:self.lastDate] forKey:@"datetime"];
	[self.nextChallengesRequest startAsynchronous];
}

- (void)_refreshList:(NSNotification *)notification {
	[self _retrieveChallenges];
}

#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	ASIFormDataRequest *challengeRequest;
	
	switch(buttonIndex) {
		case 0:
			[self.challenges removeObjectAtIndex:self.idxPath.row - 1];
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.idxPath] withRowAnimation:UITableViewRowAnimationFade];
			
			challengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
			[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", 10] forKey:@"action"];
			[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengeVO.challengeID] forKey:@"challengeID"];
			[challengeRequest startAsynchronous];
			break;
			
		case 1:
			break;
	}
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
		//NSLog(@"PROFILE URL:[%@]", [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [[HONAppDelegate fbProfileForUser] objectForKey:@"id"]]);
		[headerView addSubview:[[HONHeaderView alloc] initWithTitle:@"Challenges"]];
		
		UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
		refreshButton.frame = CGRectMake(270.0, 0.0, 50.0, 45.0);
		[refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
		[refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
		[refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:refreshButton];
	
	} else {
		UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		createChallengeButton.frame = CGRectMake(0.0, 0.0, 320.0, 78.0);
		[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton.png"] forState:UIControlStateNormal];
		[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton_active.png"] forState:UIControlStateHighlighted];
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
			cell = [[HONChallengeViewCell alloc] initAsTopCell:[[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] withSubject:[HONAppDelegate dailySubjectName]];
		
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
	return (70.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if (section == 0)
		return (45.0);
	
	else
		return (78.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	HONChallengeVO *vo = [_challenges objectAtIndex:indexPath.row - 1];
	
	if ([vo.status isEqualToString:@"Started"] || [vo.status isEqualToString:@"Accept"] || [vo.status isEqualToString:@"Waiting"])
		return (indexPath);
	
	else
		return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	HONChallengeVO *vo = [_challenges objectAtIndex:indexPath.row - 1];
	
	if ([vo.status isEqualToString:@"Accept"] || [vo.status isEqualToString:@"Waiting"]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPhotoViewController alloc] initWithImagePath:vo.imageURL withTitle:vo.subjectName]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	
	} else if ([vo.status isEqualToString:@"Started"]) {
		[self.navigationController pushViewController:[[HONVoteViewController alloc] initWithChallenge:vo] animated:YES];
	}
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return YES if you want the specified item to be editable.
	return (YES);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		self.idxPath = indexPath;
		self.challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row - 1];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Challenge"
																		message:@"Are you sure you want to remove this challenge?"
																	  delegate:self
														  cancelButtonTitle:@"Yes"
														  otherButtonTitles:@"No", nil];
		[alert show];
	}
}

#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex ) {
		case 0:
			break;
			
		case 1:
			break;
			
		case 2:
			break;
	}
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONChallengesViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if (request == self.nextChallengesRequest) {
		@autoreleasepool {
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]];
				
				for (NSDictionary *serverList in parsedLists) {
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
					
					if (vo != nil)
						[_challenges addObject:vo];
				}
								
				self.lastDate = ((HONChallengeVO *)[_challenges lastObject]).addedDate;
				[_tableView reloadData];
			}
		}
	
	} else {
		@autoreleasepool {
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]];
				
				_challenges = [NSMutableArray array];
				for (NSDictionary *serverList in parsedLists) {
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
					
					if (vo != nil)
						[_challenges addObject:vo];
				}
				
				//_challenges = [list copy];
				
				self.lastDate = ((HONChallengeVO *)[_challenges lastObject]).addedDate;
				[_tableView reloadData];
			}
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
