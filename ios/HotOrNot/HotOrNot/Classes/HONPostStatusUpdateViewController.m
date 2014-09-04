//
//  HONPostStatusUpdateViewController.m
//  HotOrNot
//
//  Created by Anirudh Agarwala on 9/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONPostStatusUpdateViewController.h"
#import "HONTableView.h"
#import "HONPostStatusUpdateViewCell.h"
#import "CKRefreshControl.h"
#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"
#import "HONHeaderView.h"
#import "HONActivityHeaderButtonView.h"

#import "NSString+DataTypes.h"

@interface HONPostStatusUpdateViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) NSArray *captions;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONPostStatusUpdateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_captions = @[ @"Happy",
					   @"Sad",
					   @"In love",
					   @"Angry",
					   @"OMG",
					   @"Confused",
					   @"Excited"];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Select"]; //@"Settings"];
	[self.view addSubview:headerView];
	
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(3.0, 17.0, 44.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cameraX_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cameraX_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
	
	//_activityHeaderView = [[HONActivityHeaderButtonView alloc] initWithTarget:self action:@selector(_goTimeline)];
	
	//	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	//	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	//	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	//	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	//	[doneButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	//	[headerView addButton:doneButton];
	
	//Go to Timeline
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0)];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.alwaysBounceVertical = YES;
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.scrollsToTop = NO;
	[self.view addSubview:_tableView];
	
	
	
	
}



#pragma mark - Navigation

- (void)_goCancel {
	[self dismissViewControllerAnimated:YES completion:^(void) {}];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_captions count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONPostStatusUpdateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONPostStatusUpdateViewCell alloc] initWithCaption:[_captions objectAtIndex:indexPath.row]];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (40.0);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 20.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:12];
	label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.text = [@"Version " stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
	[footerView addSubview:label];
	
	return (footerView);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONPostStatusUpdateViewCell *cell = (HONPostStatusUpdateViewCell*) [tableView cellForRowAtIndexPath: indexPath];
	NSLog(@"FEELING_CAPTION -> %@", cell.caption);
}

@end
