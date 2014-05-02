//
//  HONUserProfileViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONFAQViewController.h"
#import "HONSettingsViewController.h"
#import "HONImageLoadingView.h"
#import "HONActivityItemViewCell.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONCreateSnapButtonView.h"

#import "HONUserVO.h"
#import "HONUserClubVO.h"
#import "HONActivityItemVO.h"

@interface HONUserProfileViewController () <EGORefreshTableHeaderDelegate, HONActivityItemViewCellDelegate>
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign, readonly) HONUserProfileType userProfileType;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *activityAlerts;
@property (nonatomic, strong) NSArray *cohortRows;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *profileHolderView;
@property (nonatomic, strong) UILabel *nameLabel;
@end


@implementation HONUserProfileViewController
@synthesize userID = _userID;

- (id)initWithUserID:(int)userID {
	if ((self = [super init])) {
		_userID = userID;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshProfile:)
													 name:@"REFRESH_PROFILE" object:nil];
		
		_cohortRows = @[@"Invite to my club",
						@"Shoutout",
						@"Share",
						@"Report"];
	}
	
	return  (self);
}

- (id)init {
	if ((self = [self initWithUserID:0])) {
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
- (void)_retrieveUser {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] retrieveUserByUserID:_userID completion:^(NSObject *result) {
		if ([(NSDictionary *)result objectForKey:@"id"] != nil) {
			_userVO = [HONUserVO userWithDictionary:(NSDictionary *)result];
			_userProfileType = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID) ? HONUserProfileTypeUser : HONUserProfileTypeOpponent;
	
			[_headerView setTitle:(_userProfileType == HONUserProfileTypeOpponent) ? _userVO.username : @"Activity"];
			[self _makeProfile];
			[self _retrieveAlerts];
			
		} else {
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"User not found!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
	}];
}

- (void)_retrieveAlerts {
	_activityAlerts = [NSMutableArray array];
	[[HONAPICaller sharedInstance] retrieveAlertsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result)
			[_activityAlerts addObject:[HONActivityItemVO activityWithDictionary:dict]];
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:_userVO.userID completion:^(NSObject *result) {
			if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0)
				_userClubVO = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
		}];
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}


#pragma mark - Public APIs
- (void)setUserID:(int)userID {
	_userID = userID;
	[self _retrieveUser];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_activityAlerts = [NSMutableArray array];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight + 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + 0.0)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:NO];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
	
	_profileHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kOrthodoxTableCellHeight)];
	[_profileHolderView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]]];
	[self.view addSubview:_profileHolderView];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 20.0, 195.0, 22.0)];
	_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.backgroundColor = [UIColor clearColor];
	[_profileHolderView addSubview:_nameLabel];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"" hasBackground:YES];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	if (_userID != 0)
		[self _retrieveUser];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Profile - Back"
									 withCohortUser:_userVO];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goChangeAvatar {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Profile - Take New Avatar"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	_activityAlerts = [NSMutableArray array];
	[self _retrieveUser];
}

- (void)_goShoutout {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Profile - Shoutout"
									 withCohortUser:_userVO];
	
	[[HONAPICaller sharedInstance] createShoutoutChallengeWithUserID:_userVO.userID completion:^(NSObject *result) {
		[[[UIAlertView alloc] initWithTitle:@"Shoutout Sent!"
									message:@"Check your Home timeline to like and reply."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}];
}

- (void)_goFlag {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Profile - Flag"
									 withCohortUser:_userVO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:HONUserProfileAlertTypeFlag];
	[alertView show];
}

- (void)_goShare {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Profile - Share"];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate facebookShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [HONImagingDepictor shareTemplateImageForType:HONImagingDepictorShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}

- (void)_goFAQ {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Profile - FAQ"];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFAQViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSettings {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Profile - Settings"];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_refreshProfile:(NSNotification *)notification {
	[self _retrieveUser];
}


#pragma mark - UI Presentation
- (void)_makeProfile {
//	NSLog(@"AVATAR LOADING:[%@]", [_userVO.avatarURL stringByAppendingString:kSnapThumbSuffix]);
	
	UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 8.0, 48.0, 48.0)];
	[_profileHolderView addSubview:avatarHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:avatarHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[avatarHolderView addSubview:imageLoadingView];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 48.0, 48.0)];
	avatarImageView.alpha = 0.0;
	[avatarHolderView addSubview:avatarImageView];
	
	[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_userVO.avatarPrefix forBucketType:HONS3BucketTypeAvatars completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapTabSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
	_nameLabel.text = _userVO.username;
	
//	if (_userVO.isVerified) {
		_nameLabel.frame = CGRectOffset(_nameLabel.frame, 0.0, -8.0);
		
		UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUserIcon"]];
		verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 40.0, 34.0);
		[_profileHolderView addSubview:verifiedImageView];
		
		UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUserArrow"]];
		arrowImageView.frame = CGRectOffset(arrowImageView.frame, 63.0, 28.0);
		[_profileHolderView addSubview:arrowImageView];
		
		UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(84.0, 34.0, 33.0, 13.0)];
		scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
		scoreLabel.textColor = [[HONColorAuthority sharedInstance] honGreenTextColor];
		scoreLabel.backgroundColor = [UIColor clearColor];
		scoreLabel.text = [@"" stringFromInt:-_userVO.abuseCount];
		[_profileHolderView addSubview:scoreLabel];
//	}
	
	if (_userProfileType == HONUserProfileTypeUser) {
		UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		settingsButton.frame = CGRectMake(227.0, 0.0, 93.0, 44.0);
		[settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_nonActive"] forState:UIControlStateNormal];
		[settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_Active"] forState:UIControlStateHighlighted];
		[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addButton:settingsButton];
		
		HONCreateSnapButtonView *changeAvatarButtonView = [[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goChangeAvatar) asLightStyle:NO];
		changeAvatarButtonView.frame = CGRectOffset(changeAvatarButtonView.frame, -6.0, 9.0);
		[_profileHolderView addSubview:changeAvatarButtonView];
	}
}


#pragma mark - ActivityItemView Delegates
- (void)activityItemViewCell:(HONActivityItemViewCell *)cell showProfileForUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"activityItemViewCell:[%@]", trivialUserVO.dictionary);
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:trivialUserVO.userID] animated:YES];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _retrieveUser];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_activityAlerts count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:@"ACTIVITY"]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONActivityItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (_userProfileType == HONUserProfileTypeUser) {
			if (cell == nil) {
				cell = [[HONActivityItemViewCell alloc] init];
				cell.activityItemVO = (HONActivityItemVO *)[_activityAlerts objectAtIndex:indexPath.row];
			}
		
		} else {
			if (cell == nil) {
				cell = [[HONActivityItemViewCell alloc] init];
				
				cell.textLabel.frame = CGRectOffset(cell.textLabel.frame, 0.0, -2.0);
				cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
				cell.textLabel.text = [_cohortRows objectAtIndex:indexPath.row];
				cell.textLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
			}
		}
		
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		return (cell);
		
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[UITableViewCell alloc] init];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 0) ? 44.0 : ([_activityAlerts count] > 5 + ((int)([[HONDeviceIntrinsics sharedInstance] isPhoneType5s]) * 2)) ? 48.0: 0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((_userProfileType == HONUserProfileTypeUser) ? (section == 0) ? kOrthodoxTableHeaderHeight : 0.0 : 0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 0) ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONActivityItemVO *vo = [_activityAlerts objectAtIndex:indexPath.row];
	
	NSString *mpAlertType;
	NSDictionary *mpParams;
	
	UIViewController *viewController;
	
	if (vo.activityType == HONActivityItemTypeVerify) {
		mpAlertType = @"Verify";
		mpParams = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.userID];
		viewController = userPofileViewController;
		
	} else if (vo.activityType == HONActivityItemTypeInviteAccepted) {
		mpAlertType = @"Accepted Invite";
		mpParams = @{@"club"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
		
	} else if (vo.activityType == HONActivityItemTypeInviteRequest) {
		mpAlertType = @"Club Invite";
		mpParams = @{@"club"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.userID];
		viewController = userPofileViewController;
		
	} else if (vo.activityType == HONActivityItemTypeLike) {
		mpAlertType = @"Like";
		mpParams = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.userID];
		viewController = userPofileViewController;
		
	} else if (vo.activityType == HONActivityItemTypeShoutout) {
		mpAlertType = @"Shoutout";
		mpParams = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.userID];
		viewController = userPofileViewController;
		
	} else if (vo.activityType == HONActivityItemTypeClubSubmission) {
		mpAlertType = @"Reply";
		mpParams = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.userID];
		viewController = userPofileViewController;
		
	} else {
		mpAlertType = @"Profile";
		mpParams = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.userID];
		viewController = userPofileViewController;
	}
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"User Profile - Select %@ Row", mpAlertType]
									 withProperties:mpParams];
	
	if (viewController != nil) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//	NSLog(@"**_[scrollViewDidScroll]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//	NSLog(@"**_[scrollViewDidEndDragging]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	//	NSLog(@"**_[scrollViewDidEndScrollingAnimation]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_tableView setContentOffset:CGPointZero animated:NO];
}


@end
