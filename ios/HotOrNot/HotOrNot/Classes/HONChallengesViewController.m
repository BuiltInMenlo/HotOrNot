//
//  HONChallengesViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "EGOImageView.h"
#import "HONAppDelegate.h"
#import "HONChallengesViewController.h"
#import "HONChallengeViewCell.h"

#import "HONSettingsViewController.h"
#import "HONCreateChallengeViewController.h"

@interface HONChallengesViewController()
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;

@end

@implementation HONChallengesViewController

@synthesize tableView = _tableView;
@synthesize challenges = _challenges;

- (id)init {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Challenges", @"Challenges");
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
		
		self.challenges = [NSMutableArray new];
		
		[self.challenges addObject:@"derp"];
		[self.challenges addObject:@"derp"];
		[self.challenges addObject:@"derp"];
		[self.challenges addObject:@"derp"];
		[self.challenges addObject:@"derp"];
		[self.challenges addObject:@"derp"];
	}
	
	return (self);
}
							
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 50.0) style:UITableViewStylePlain];
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
		playedLabel.text = [NSString stringWithFormat:@"%d rounds played", (int)((arc4random() % 100) + 10)];
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
	
	//cell.twitterUserVO = [_friends objectAtIndex:indexPath.row];
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

@end
