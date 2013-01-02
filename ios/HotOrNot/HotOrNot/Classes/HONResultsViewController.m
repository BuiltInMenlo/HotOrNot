//
//  HONResultsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.21.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONResultsViewController.h"

#import "ASIFormDataRequest.h"

#import "HONAppDelegate.h"
#import "HONChallengeVO.h"
#import "HONHeaderView.h"
#import "HONResultsViewCell.h"
#import "HONImagePickerViewController.h"
#import "HONLoginViewController.h"

@interface HONResultsViewController () <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate>
@property(nonatomic, strong) NSArray *challenges;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic) int winTotal;
@property(nonatomic) int lossTotal;
@end

@implementation HONResultsViewController

@synthesize challenges = _challenges;
@synthesize winTotal = _winTotal;
@synthesize lossTotal = _lossTotal;


- (id)init {
	if ((self = [super init])) {
		self.challenges = [NSArray array];
		
		_winTotal = 0;
		_lossTotal = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showDailyChallenge:) name:@"SHOW_DAILY_CHALLENGE" object:nil];
	}
	
	return (self);
}

- (id)initWithChallenges:(NSArray *)challengeList {
	if ((self = [super init])) {
		self.challenges = [challengeList copy];
		
		_winTotal = 0;
		_lossTotal = 0;
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showDailyChallenge:) name:@"SHOW_DAILY_CHALLENGE" object:nil];
	}
	
	return (self);
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Daily Stats"];
	[self.view addSubview:headerView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(261.0, 5.0, 54.0, 34.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive.png"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active.png"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneButton];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 65.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:self.tableView];
		
	ASIFormDataRequest *challengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[challengeRequest setDelegate:self];
	[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[challengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[challengeRequest startAsynchronous];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_showDailyChallenge:(NSNotification *)notification {
//	if (FBSession.activeSession.state == 513) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsDailyChallenge:[HONAppDelegate dailySubjectName]]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
		
//	} else {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:YES completion:nil];
//	}
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (6);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONResultsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		switch (indexPath.row) {
			case 0:
				cell = [[HONResultsViewCell alloc] initAsTopCell];
				break;
				
			case 1:
				cell = [[HONResultsViewCell alloc] initAsResultCell:_state];
				break;
		
			case 2:
				cell = [[HONResultsViewCell alloc] initAsStatCell:[NSString stringWithFormat:@"%d Total Points", [[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue]]];
				break;
				
			case 3:
				if (_winTotal == 1)
					cell = [[HONResultsViewCell alloc] initAsStatCell:@"1 PicChallenge Win"];
				
				else
					cell = [[HONResultsViewCell alloc] initAsStatCell:[NSString stringWithFormat:@"%d PicChallenge Wins", _winTotal]];
				break;
				
			case 4:
				if (_lossTotal == 1)
					cell = [[HONResultsViewCell alloc] initAsStatCell:@"1 PicChallenge Loss"];
				
				else
					cell = [[HONResultsViewCell alloc] initAsStatCell:[NSString stringWithFormat:@"%d PicChallenge Losses", _lossTotal]];
				break;
				
			case 5:
				cell = [[HONResultsViewCell alloc] initAsBottomCell];
				break;
		}
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0)
		return (20.0);
	
	else if (indexPath.row == 1)
		return (150.0);
	
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
	//NSLog(@"HONResultsViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
			
			for (HONChallengeVO *vo in _challenges) {
				if (vo.creatorScore > vo.challengerScore)
					_winTotal++;
				
				else if (vo.creatorScore < vo.challengerScore)
					_lossTotal++;
			}
			
			if (_winTotal > _lossTotal)
				_state = HONChallengesWinning;
			
			else if (_winTotal < _lossTotal)
				_state = HONChallengesLosing;
			
			else
				_state = HONChallengesTie;
			[_tableView reloadData];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
