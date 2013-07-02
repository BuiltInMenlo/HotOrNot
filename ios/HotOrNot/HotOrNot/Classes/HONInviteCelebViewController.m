//
//  HONInviteCelebViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.27.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONInviteCelebViewController.h"
#import "HONHeaderView.h"
#import "HONInviteCelebViewCell.h"

@interface HONInviteCelebViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *celebs;
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation HONInviteCelebViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Invite Celeb - Open"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"]];
	bgImageView.frame = self.view.bounds;
	[self.view addSubview:bgImageView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_inviteCelebs", nil)];
	[headerView hideRefreshing];
	[headerView leftAlignTitle];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
	
	_celebs = [HONAppDelegate inviteCelebs];
	
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight + 100.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (100.0 + kNavBarHeaderHeight + kTabSize.height)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Invite Celeb - Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_celebs count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBackground"]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 6.0, 310.0, 20.0)];
	label.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
	label.textColor = [HONAppDelegate honGreenTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = @"Invite Celebrities";
	[headerImageView addSubview:label];
	
	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONInviteCelebViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONInviteCelebViewCell alloc] init];
		
	[cell setContents:[_celebs objectAtIndex:indexPath.row]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	[[Mixpanel sharedInstance] track:@"Invite Celeb - Select"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 @"", @"celeb", nil]];
}
@end
