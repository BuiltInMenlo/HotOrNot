//
//  HONChallengesViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "EGOImageView.h"
#import "ASIFormDataRequest.h"
#import "MBLAsyncResource.h"
#import "MBLResourceLoader.h"

#import "HONAppDelegate.h"
#import "HONChallengesViewController.h"
#import "HONChallengeViewCell.h"
#import "HONChallengeVO.h"

#import "HONSettingsViewController.h"
#import "HONCreateChallengeViewController.h"
#import "HONImagePickerViewController.h"

@interface HONChallengesViewController() <ASIHTTPRequestDelegate, MBLResourceObserverProtocol>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic, strong) MBLAsyncResource *challengeResource;
- (void)_retrieveChallenges;
@end

@implementation HONChallengesViewController

@synthesize tableView = _tableView;
@synthesize challenges = _challenges;
@synthesize challengeResource = _challengeResource;

- (id)init {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Challenges", @"Challenges");
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_acceptChallenge:) name:@"ACCEPT_CHALLENGE" object:nil];
	}
	
	return (self);
}
							
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.challengeResource = nil;
}

- (void)setChallengeResource:(MBLAsyncResource *)challengeResource {
	if (_challengeResource != nil) {
		[_challengeResource unsubscribe:self];
		_challengeResource = nil;
	}
	
	_challengeResource = challengeResource;
	
	if (_challengeResource != nil)
		[_challengeResource subscribe:self];
}

- (void)_retrieveChallenges {
	if (_challengeResource == nil) {
		NSMutableDictionary *userFormValues = [NSMutableDictionary dictionary];
		[userFormValues setObject:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
		[userFormValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"userID"];
		//[userFormValues setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kChallengesAPI];
		_challengeResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:userFormValues forceFetch:YES expiration:[NSDate date]];
		[_challengeResource subscribe:self];
	}
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 100.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 56.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	//self.tableView.contentInset = UIEdgeInsetsMake(9.0, 0.0f, 9.0f, 0.0f);
	[self.view addSubview:self.tableView];
	
	ASIFormDataRequest *challengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kChallengesAPI]]];
	[challengeRequest setDelegate:self];
	[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[challengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[challengeRequest startAsynchronous];
	
	//[self _retrieveChallenges];
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
	
	//[self _retrieveChallenges];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}


#pragma mark - Navigation
- (void)_goCreateChallenge {
	//[self presentViewController:[[HONCreateChallengeViewController alloc] init] animated:YES completion:nil];
	[self.navigationController pushViewController:[[HONCreateChallengeViewController alloc] init] animated:YES];
}

- (void)_goSettings {
	[self presentViewController:[[HONSettingsViewController alloc] init] animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_acceptChallenge:(NSNotification *)notification {
	[self.navigationController pushViewController:[[HONImagePickerViewController alloc] initWithChallenge:[notification object]] animated:YES];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 0)
		return (0);
	
	else
		return ([self.challenges count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 50.0)];
	headerView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	
	if (section == 0) {
		EGOImageView *imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(2.0, 2.0, 32.0, 32.0)];
		imgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		imgView.imageURL = [NSURL URLWithString:@""];
		[headerView addSubview:imgView];
		
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 10.0, 200.0, 16.0)];
		//ptsLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//ptsLabel = [SNAppDelegate snLinkColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
		ptsLabel.text = [NSString stringWithFormat:@"%d points", [[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue]];
		[headerView addSubview:ptsLabel];
		
		UILabel *playedLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 200.0, 16.0)];
		//playedLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//playedLabel = [SNAppDelegate snLinkColor];
		playedLabel.backgroundColor = [UIColor clearColor];
		playedLabel.text = [NSString stringWithFormat:@"%d rounds played", [[[HONAppDelegate infoForUser] objectForKey:@"matches"] intValue]];
		[headerView addSubview:playedLabel];
		
		UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		settingsButton.frame = CGRectMake(290.0, 2.0, 22.0, 22.0);
		[settingsButton setBackgroundColor:[UIColor whiteColor]];
		[settingsButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[settingsButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:settingsButton];
	
	} else {
		UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		createChallengeButton.frame = CGRectMake(20.0, 2.0, 280.0, 43.0);
		[createChallengeButton setBackgroundColor:[UIColor whiteColor]];
		[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
		//createChallengeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[createChallengeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[createChallengeButton setTitle:@"Create Challenge" forState:UIControlStateNormal];
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
		cell = [[HONChallengeViewCell alloc] init];
	}
	
	cell.challengeVO = [_challenges objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (56.0);
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



#pragma mark - AsyncResource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	if (resource == _challengeResource) {

		NSError *error = nil;
		NSArray *parsedChallenges = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
		
		} else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedChallenges) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
			}
			
			
			_challenges = list;
			[_tableView reloadData];
			_tableView.userInteractionEnabled = YES;
		}
	}
}


- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
//	if (_hud != nil) {
//		_hud.graceTime = 0.0;
//		_hud.mode = MBProgressHUDModeCustomView;
//		_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
//		_hud.labelText = NSLocalizedString(@"Error", @"Error");
//		[_hud show:NO];
//		[_hud hide:YES afterDelay:1.5];
//		_hud = nil;
//	}
	
	if (resource == _challengeResource)
		_challengeResource = nil;
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONChallengesViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
