//
//  HONClubTimelineViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:39 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "CKRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONClubTimelineViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONUserProfileViewController.h"
#import "HONClubPhotoViewCell.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONClubPhotoVO.h"


@interface HONClubTimelineViewController () <HONClubPhotoViewCellDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImageView *emptySetImageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) NSArray *clubPhotos;
@property (nonatomic) int imageQueueLocation;
@end


@implementation HONClubTimelineViewController

- (id)initWithClub:(HONUserClubVO *)clubVO {
	if ((self = [super init])) {
		_clubVO = clubVO;
		_clubPhotos = [[_clubVO.submissions reverseObjectEnumerator] allObjects];
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
- (void)_retrieveClub {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	_clubPhotos = [NSArray array];
	[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubVO.clubID withOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
		_clubVO = [HONUserClubVO clubWithDictionary:result];
		_clubPhotos = [[_clubVO.submissions reverseObjectEnumerator] allObjects];
		
		
		_emptySetImageView.hidden = [_clubPhotos count] > 0;
		[self _didFinishDataRefresh];
		
		
		_imageQueueLocation = 0;
		if ([_clubPhotos count] > 0) {
			NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_clubPhotos count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
			NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:MIN([_clubPhotos count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length)];
			
			int cnt = 0;
			for (int i=queueRange.location; i<queueRange.length; i++) {
				[imageQueue addObject:[NSURL URLWithString:[((HONClubPhotoVO *)[_clubPhotos objectAtIndex:i]).imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
				
				cnt++;
				_imageQueueLocation++;
				if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_clubPhotos count])
					break;
				
			}
			[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation)
											fromURLs:imageQueue
											 withTag:@"club"];
		}
		
		
	}];
}


#pragma mark - Data Handling
- (void)_cacheNextImagesWithRange:(NSRange)range {
	NSLog(@"RANGE:[%@]", NSStringFromRange(range));
	
	NSMutableArray *imagesToFetch = [NSMutableArray array];
	for (int i=range.location; i<MIN(range.length, [_clubPhotos count]); i++) {
		HONClubPhotoVO *vo = (HONClubPhotoVO *)[_clubPhotos objectAtIndex:i];
		NSString *type = [[HONDeviceIntrinsics sharedInstance] isRetina4Inch] ? kSnapLargeSuffix : kSnapTabSuffix;
		NSString *url = [vo.imagePrefix stringByAppendingString:type];
		[imagesToFetch addObject:[NSURL URLWithString:url]];
	}
	
	if ([imagesToFetch count] > 0)
		[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(0, [imagesToFetch count])
										fromURLs:imagesToFetch
										 withTag:@"club"];
}

- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[self _retrieveClub];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_tableView = [[HONTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	[_tableView setContentInset:UIEdgeInsetsMake(-20.0, 0.0, 0.0, 0.0)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.pagingEnabled = YES;
	_tableView.showsHorizontalScrollIndicator = NO;
	_tableView.alwaysBounceVertical = YES;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	_emptySetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifyEmpty"]];
	_emptySetImageView.frame = CGRectOffset(_emptySetImageView.frame, 0.0, 58.0);
	_emptySetImageView.hidden = YES;
	[_tableView addSubview:_emptySetImageView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:_clubVO.clubName hasBackground:NO];
	[headerView toggleLightStyle:YES];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(1.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backWhiteButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backWhiteButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	if (_clubVO == nil)
		[self _retrieveClub];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Back"
									   withUserClub:_clubVO];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Refresh"
									   withUserClub:_clubVO];
	
	[self _retrieveClub];
}


#pragma mark - ClubPhotoViewCell Delegates
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell advancePhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:advancePhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Advance Photo"
									  withClubPhoto:clubPhotoVO];
	
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:cell.indexPath.row inSection:cell.indexPath.section + 1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell showUserProfileForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:showUserProfileForClubPhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Show Profile"
									  withClubPhoto:clubPhotoVO];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:clubPhotoVO.userID] animated:YES];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell replyToPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:replyToPhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Reply Photo"
									  withClubPhoto:clubPhotoVO];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithClub:_clubVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell upvotePhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:upvotePhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Upvote Photo"
									   withClubPhoto:clubPhotoVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	[[HONAPICaller sharedInstance] verifyUserWithUserID:clubPhotoVO.userID asLegit:YES completion:^(NSDictionary *result) {
		if (cell.indexPath.section < [_clubPhotos count] - 1)
			[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:cell.indexPath.row inSection:cell.indexPath.section + 1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:[HONChallengeVO challengeWithDictionary:result]];
	}];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_clubPhotos count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONClubPhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONClubPhotoViewCell alloc] init];
	
	cell.delegate = self;
	cell.clubName = _clubVO.clubName;
	cell.indexPath = indexPath;
	cell.clubPhotoVO = (HONClubPhotoVO *)[_clubPhotos objectAtIndex:indexPath.section];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (self.view.bounds.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section < [_clubPhotos count] - 1) ? indexPath : nil);
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section + 1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
	//	NSLog(@"tableView:didEndDisplayingCell:[%@]forRowAtIndexPath:[%d]", NSStringFromCGPoint(cell.frame.origin), indexPath.section);
	
	if (indexPath.section % [HONAppDelegate rangeForImageQueue].location == 0 || [_clubPhotos count] - _imageQueueLocation <= [HONAppDelegate rangeForImageQueue].location) {
		NSRange queueRange = NSMakeRange(_imageQueueLocation, MIN([_clubPhotos count], _imageQueueLocation + [HONAppDelegate rangeForImageQueue].length));
		//NSLog(@"QUEUEING:#%d -/> %d\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", queueRange.location, queueRange.length);
		
		int cnt = 0;
		NSMutableArray *imageQueue = [NSMutableArray arrayWithCapacity:queueRange.length];
		for (int i=queueRange.location; i<queueRange.length; i++) {
			[imageQueue addObject:[NSURL URLWithString:[((HONClubPhotoVO *)[_clubPhotos objectAtIndex:i]).imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]];
			
			cnt++;
			_imageQueueLocation++;
			if ([imageQueue count] >= [HONAppDelegate rangeForImageQueue].length || _imageQueueLocation >= [_clubPhotos count])
				break;
			
		}
		[HONAppDelegate cacheNextImagesWithRange:NSMakeRange(_imageQueueLocation - cnt, _imageQueueLocation)
										fromURLs:imageQueue
										 withTag:@"club"];
	}
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return (proposedDestinationIndexPath);
}


@end
