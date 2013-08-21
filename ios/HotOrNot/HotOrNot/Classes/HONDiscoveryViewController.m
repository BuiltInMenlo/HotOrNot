//
//  HONDiscoveryViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONDiscoveryViewController.h"
#import "HONRefreshButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONSearchBarHeaderView.h"
#import "HONImagePickerViewController.h"
#import "HONTimelineViewController.h"
#import "HONDiscoveryViewCell.h"

@interface HONDiscoveryViewController ()<UITableViewDataSource, UITableViewDelegate, HONDiscoveryViewCellDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) HONRefreshButtonView *refreshButtonView;
@property(nonatomic, strong) UIImageView *emptySetImgView;
@property(nonatomic, strong) NSMutableDictionary *allChallenges;
@property(nonatomic, strong) NSMutableArray *currChallenges;
@property(nonatomic, strong) HONSearchBarHeaderView *searchHeaderView;
@property (nonatomic, strong) UIView *bannerView;
@end

@implementation HONDiscoveryViewController

- (id)init {
	if ((self = [super init])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedDiscoveryTab:) name:@"SELECTED_DISCOVERY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshDiscoveryTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshDiscoveryTab:) name:@"REFRESH_DISCOVERY_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSearchTable:) name:@"SHOW_SEARCH_TABLE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideSearchTable:) name:@"HIDE_SEARCH_TABLE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_resignSearchBarFocus:) name:@"RESIGN_SEARCH_BAR_FOCUS" object:nil];
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
- (void)_retrieveChallenges {
	[_refreshButtonView toggleRefresh:YES];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIDiscover, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIDiscover parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], parsedLists);
			
			_allChallenges = [NSMutableDictionary dictionary];
			NSMutableArray *retrievedChallenges = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *challengeVO = [HONChallengeVO challengeWithDictionary:serverList];
				[retrievedChallenges addObject:[NSNumber numberWithInt:challengeVO.challengeID]];
				[_allChallenges setObject:challengeVO forKey:[NSString stringWithFormat:@"c_%d", challengeVO.challengeID]];
			}
			
			_currChallenges = [NSMutableArray array];
			for (NSNumber *cID in [HONAppDelegate fillDiscoverChallenges:retrievedChallenges])
				[_currChallenges addObject:[_allChallenges objectForKey:[NSString stringWithFormat:@"c_%d", [cID intValue]]]];
			
			
			_emptySetImgView.hidden = ([_currChallenges count] > 0);
			[_tableView reloadData];
		}
		
		[_refreshButtonView toggleRefresh:NO];
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIDiscover, [error localizedDescription]);
		
		[_refreshButtonView toggleRefresh:NO];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_refreshButtonView = [[HONRefreshButtonView alloc] initWithTarget:self action:@selector(_goRefresh)];
	self.navigationController.navigationBar.topItem.title = @"Explore";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_refreshButtonView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	
	_emptySetImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 285.0)];
	_emptySetImgView.image = [UIImage imageNamed:@"noSnapsAvailable"];
	_emptySetImgView.hidden = YES;
	[self.view addSubview:_emptySetImgView];
	
	_bannerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
	[self.view addSubview:_bannerView];
	
	UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
	[bannerImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate bannerForSection:1]] placeholderImage:nil];
	[_bannerView addSubview:bannerImageView];
	
	UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	bannerButton.frame = bannerImageView.frame;
	[bannerButton addTarget:self action:@selector(_goCloseBanner) forControlEvents:UIControlEventTouchUpInside];
	[_bannerView addSubview:bannerButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"], 320.0, [UIScreen mainScreen].bounds.size.height - 10.0 - kTabSize.height - (90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"])) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self _retrieveChallenges];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[HONAppDelegate offsetSubviewsForIOS7:self.view];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Discover - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"refresh:[%d]", [_allChallenges count]);
	_currChallenges = [NSMutableArray array];
	
	if ([_allChallenges count] > 0) {
		for (NSNumber *cID in [HONAppDelegate refreshDiscoverChallenges])
			[_currChallenges addObject:[_allChallenges objectForKey:[NSString stringWithFormat:@"c_%d", [cID intValue]]]];
		
		[_refreshButtonView toggleRefresh:NO];
		[_tableView reloadData];
	}
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Discover - Create Snap"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goCloseBanner {
	[[Mixpanel sharedInstance] track:@"Discover - Close Banner"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
		_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y - 90.0, _tableView.frame.size.width, _tableView.frame.size.height + 90.0);
	} completion:^(BOOL finished) {
		[_bannerView removeFromSuperview];
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"discover_banner"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
}


#pragma mark - Notifications
- (void)_selectedDiscoveryTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	[_refreshButtonView toggleRefresh:YES];
	[self _goRefresh];
}

- (void)_refreshDiscoveryTab:(NSNotification *)notification {
	[_refreshButtonView toggleRefresh:YES];
	[self _goRefresh];
}

- (void)_showSearchTable:(NSNotification *)notification {
	if (self.view.frame.origin.y >= 0) {
		[UIView animateWithDuration:0.25 delay:0.125 options:UIViewAnimationOptionCurveLinear animations:^(void) {
			//self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -kNavBarHeaderHeight);
			self.view.frame = CGRectOffset(self.view.frame, 0.0, -kNavBarHeaderHeight);
			_tableView.frame = CGRectOffset(_tableView.frame, 0.0, -90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"]);
			_bannerView.alpha = 0.0;
		} completion:^(BOOL finished) {
			_bannerView.hidden = YES;
			[self.navigationController setNavigationBarHidden:YES animated:YES];
		}];
	}
}

- (void)_hideSearchTable:(NSNotification *)notification {
	if (self.view.frame.origin.y <= 0) {
		_bannerView.hidden = NO;
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		[UIView animateWithDuration:0.25 delay:0.125 options:UIViewAnimationOptionCurveLinear animations:^(void) {
			//self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, kNavBarHeaderHeight);
			self.view.frame = CGRectOffset(self.view.frame, 0.0, kNavBarHeaderHeight);
			_tableView.frame = CGRectOffset(_tableView.frame, 0.0, 90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"] isEqualToString:@"YES"]);
			_bannerView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	}
}

- (void)_resignSearchBarFocus:(NSNotification *)notification {
	if (_searchHeaderView != nil)
		[_searchHeaderView toggleFocus:NO];
}


#pragma mark - DiscoveryViewCell Delegates
- (void)discoveryViewCell:(HONDiscoveryViewCell *)cell selectLeftChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Discover - Select"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	
	[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithSubject:challengeVO.subjectName] animated:YES];
}

- (void)discoveryViewCell:(HONDiscoveryViewCell *)cell selectRightChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Discover - Select"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithSubject:challengeVO.subjectName] animated:YES];
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (ceil([_currChallenges count] * 0.5));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	_searchHeaderView = [[HONSearchBarHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, kSearchHeaderHeight)];
	return (_searchHeaderView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONDiscoveryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[HONDiscoveryViewCell alloc] init];
	}
	
	cell.lChallengeVO = [_currChallenges objectAtIndex:(indexPath.row * 2)];
	
	if ((indexPath.row * 2) + 1 < [_currChallenges count])
		cell.rChallengeVO = [_currChallenges objectAtIndex:(indexPath.row * 2) + 1];
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row == ceil([_currChallenges count] * 0.5) - 1) ? 168.0 : 117.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kSearchHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

@end
