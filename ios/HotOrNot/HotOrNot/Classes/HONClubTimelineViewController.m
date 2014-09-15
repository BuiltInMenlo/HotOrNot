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
#import "HONInviteContactsViewController.h"
#import "HONClubPhotoViewCell.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONClubPhotoVO.h"


@interface HONClubTimelineViewController () <HONClubPhotoViewCellDelegate, HONSelfieCameraViewControllerDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImageView *emptySetImageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic) int clubID;
@property (nonatomic, strong) NSArray *clubPhotos;
@property (nonatomic) int index;
@property (nonatomic) int clubPhotoID;
@property (nonatomic) int imageQueueLocation;
@end


@implementation HONClubTimelineViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshClubTimeline:) name:@"REFRESH_CLUB_TIMELINE" object:nil];		
	}
	
	return (self);
}

- (id)initWithClub:(HONUserClubVO *)clubVO atPhotoIndex:(int)index {
	NSLog(@"%@ - initWithClub:[%d] atPhotoIndex:[%d]", [self description], clubVO.clubID, index);
	if ((self = [self init])) {
		_clubVO = clubVO;
		_clubID = _clubVO.clubID;
		_clubPhotoID = 0;
		_index = index;
		_clubPhotos = _clubVO.submissions;
	}
	
	return (self);
}

- (id)initWithClubID:(int)clubID atPhotoIndex:(int)index {
	NSLog(@"%@ - initWithClubID:[%d] atPhotoIndex:[%d]", [self description], clubID, index);
	if ((self = [self init])) {
		_clubVO = nil;
		_clubID = clubID;
		_index = index;
		_clubPhotoID = 0;
		_clubPhotos = _clubVO.submissions;
	}
	
	return (self);
}

- (id)initWithClubID:(int)clubID withClubPhotoID:(int)photoID {
	NSLog(@"%@ - initWithClubID:[%d] withClubPhotoID:[%d]", [self description], clubID, photoID);
	if ((self = [self init])) {
		_clubVO = nil;
		_clubID = clubID;
		_index = 0;
		_clubPhotoID = photoID;
		_clubPhotos = _clubVO.submissions;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retrieveClub {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_clubPhotos = [NSArray array];
	[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubID withOwnerID:(_clubVO == nil) ? [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] : _clubVO.ownerID completion:^(NSDictionary *result) {
		_clubVO = [HONUserClubVO clubWithDictionary:result];
		_clubPhotos = _clubVO.submissions;
		
		[_headerView setTitle:_clubVO.clubName];
		[_headerView toggleLightStyle:YES];
		
		NSLog(@"TIMELINE FOR CLUB:[%@]\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n[%@]", _clubVO.dictionary, _clubVO.coverImagePrefix);
		
		_emptySetImageView.hidden = ([_clubPhotos count] > 0);
		_tableView.contentSize = CGSizeMake(_tableView.frame.size.width, _tableView.frame.size.height * [_clubPhotos count]);
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
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Refresh" withUserClub:_clubVO];
	
	_index = 0;
	_clubPhotoID = 0;
	
	[self _retrieveClub];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
	
	if (_index != 0 || _clubPhotoID != 0)
		[self _jumpToPhotoFromID];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_emptySetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"emptyTimeline" stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? @"-568h" : @""]]];
	_emptySetImageView.frame = [UIScreen mainScreen].bounds;
	_emptySetImageView.hidden = ([_clubPhotos count] > 0);

//	NSLog(@"[UIScreen mainScreen].bounds:[%@]", NSStringFromCGRect([UIScreen mainScreen].bounds));
	_tableView = [[HONTableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_tableView.contentSize = CGSizeMake(_tableView.frame.size.width, _tableView.frame.size.height * [_clubPhotos count]);
	[_tableView setContentInset:UIEdgeInsetsMake(-20.0, 0.0, 20.0 - (kNavHeaderHeight + 5.0), 0.0)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundView = _emptySetImageView;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.pagingEnabled = YES;
	_tableView.showsHorizontalScrollIndicator = NO;
	_tableView.alwaysBounceVertical = YES;
	[self.view addSubview:_tableView];
	
		
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:_clubVO.clubName];
	[_headerView toggleLightStyle:YES];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(1.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backWhiteButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backWhiteButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(255, 1.0, 64.0, 44.0);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"shareClubButton_nonActive"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"shareClubButton_Active"] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:shareButton];
	
	NSLog(@"CONTENT SIZE:[%@]", NSStringFromCGSize(_tableView.contentSize));
	
	if (_clubVO == nil && _clubID > 0)
		[self _retrieveClub];
	
	if (_index > 0) {
		_index = MIN(_index, [_clubPhotos count]);
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_TABS" object:@"HIDE"];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


#pragma mark - Navigation
- (void)_goShare {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Share" withUserClub:_clubVO];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], _clubVO.ownerName, _clubVO.clubName];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], _clubVO.ownerName, _clubVO.clubName];
//	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate facebookShareCommentForIndex:1], _clubVO.ownerName, _clubVO.clubName];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], _clubVO.ownerName, _clubVO.clubName];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"body"], _clubVO.ownerName, _clubVO.clubName]];
	NSString *clipboardCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], _clubVO.ownerName, _clubVO.clubName];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, @"", smsCaption, emailCaption, clipboardCaption],
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [[HONImageBroker sharedInstance] shareTemplateImageForType:HONImageBrokerShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"club"				: _clubVO.dictionary,
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}
- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Back" withUserClub:_clubVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_TABS" object:@"SHOW"];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notifications
- (void)_refreshClubTimeline:(NSNotification *)notification {
	_index = 0;
	_clubPhotoID = 0;
	
	[self _retrieveClub];
}


#pragma mark - UI Presentation
- (void)_advanceTimelineFromCell:(HONClubPhotoViewCell *)cell byAmount:(int)amount {
	int rows = MIN(amount, (([_tableView numberOfSections] - 1) - [_tableView indexPathForCell:cell].section));
	
	NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell *)cell];
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section + rows] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)_jumpToPhotoFromID {
	[_clubPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONClubPhotoVO *vo = (HONClubPhotoVO *)obj;
		
		if (vo.challengeID == _clubPhotoID) {
			_index = idx;
			*stop = YES;
		}
	}];
	
	_index = MIN(_index, [_clubPhotos count]);
	
	if (_index > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


#pragma mark - SelfieCameraViewController Delegates
- (void)selfieCameraViewControllerDidDismissByInviteOverlay:(HONSelfieCameraViewController *)viewController {
	NSLog(@"[*:*] selfieCameraViewControllerDidDismissByInviteOverlay");
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_clubVO viewControllerPushed:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - ClubPhotoViewCell Delegates
- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell advancePhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:advancePhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell showUserProfileForClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:showUserProfileForClubPhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:clubPhotoVO.userID] animated:YES];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell replyToPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:replyToPhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Reply" withClubPhoto:clubPhotoVO];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
	HONSelfieCameraViewController *selfieCameraViewController = [[HONSelfieCameraViewController alloc] initWithClub:_clubVO];
	selfieCameraViewController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selfieCameraViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)clubPhotoViewCell:(HONClubPhotoViewCell *)cell upvotePhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSLog(@"[*:*] clubPhotoViewCell:upvotePhoto:(%d - %@)", clubPhotoVO.userID, clubPhotoVO.username);
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Timeline - Upvote" withClubPhoto:clubPhotoVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:clubPhotoVO.challengeID forOpponent:clubPhotoVO completion:^(NSDictionary *result) {
		[[HONAPICaller sharedInstance] retrieveUserByUserID:clubPhotoVO.userID completion:^(NSDictionary *result) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:[HONChallengeVO challengeWithDictionary:result]];
		}];
		
		[self _advanceTimelineFromCell:cell byAmount:1];
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
	return ([UIScreen mainScreen].bounds.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self _advanceTimelineFromCell:(HONClubPhotoViewCell *)[tableView cellForRowAtIndexPath:indexPath] byAmount:1];
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
