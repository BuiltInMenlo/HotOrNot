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

#import "CKRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONPrivacyPolicyViewController.h"
#import "HONSettingsViewController.h"
//#import "HONInviteClubsViewController.h"
//#import "HONInviteContactsViewController.h"
#import "HONInsetOverlayView.h"
#import "HONImageLoadingView.h"
#import "HONActivityItemViewCell.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONClubTimelineViewController.h"

#import "HONUserVO.h"
#import "HONUserClubVO.h"
#import "HONActivityItemVO.h"

@interface HONUserProfileViewController () <HONActivityItemViewCellDelegate, HONInsetOverlayViewDelegate>
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, assign, readonly) HONUserProfileType userProfileType;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *activityAlerts;
@property (nonatomic, strong) NSArray *cohortRows;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *profileHolderView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NSMutableArray *ownedClubs;
@property (nonatomic, strong) HONInsetOverlayView *insetOverlayView;
@end


@implementation HONUserProfileViewController
@synthesize userID = _userID;

- (id)initWithUserID:(int)userID {
	if ((self = [super init])) {
		_userID = userID;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshProfile:)
													 name:@"REFRESH_PROFILE" object:nil];
	}
	
	return  (self);
}

- (id)init {
	if ((self = [self initWithUserID:0])) {
	}
	
	return (self);
}

- (void)dealloc {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONActivityItemViewCell *cell = (HONActivityItemViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	_insetOverlayView.delegate = nil;
}


#pragma mark - Data Calls
- (void)_retrieveUser {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] retrieveUserByUserID:_userID completion:^(NSDictionary *result) {
		if ([result objectForKey:@"id"] != nil) {
			_userVO = [HONUserVO userWithDictionary:result];
			_userProfileType = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID) ? HONUserProfileTypeUser : HONUserProfileTypeOpponent;
	
			[_headerView setTitle:(_userProfileType == HONUserProfileTypeOpponent) ? _userVO.username :NSLocalizedString(@"header_activity", nil)]; //@"Activity"];
			[self _makeProfile];
			[self _retrieveActivityItems];
			
		} else {
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"user_notfound", nil);  //@"User not found!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
	}];
}

- (void)_retrieveActivityItems {
	_activityAlerts = [NSMutableArray array];
	[[HONAPICaller sharedInstance] retrieveNewActivityForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSArray *result) {
		[result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSMutableDictionary *dict = (NSMutableDictionary *)[obj mutableCopy];
			[dict setValue:@{@"id"			: [@""stringFromInt:_userVO.userID],
							 @"username"	: _userVO.username} forKey:@"recip"];
			
			[_activityAlerts addObject:[HONActivityItemVO activityWithDictionary:[dict copy]]];
		}];
		
		[_activityAlerts addObject:[HONActivityItemVO activityWithDictionary:@{@"id"			: [NSString stringWithFormat:@"0_2394_%d", (int)[[NSDate date] timeIntervalSince1970]],
																			   @"activity_type"	: @"0",
																			   @"challengeID"	: @"0",
																			   @"club_id"		: @"0",
																			   @"club_name"		: @"",
																			   @"time"			: [[HONAppDelegate infoForUser] objectForKey:@"added"],
																			   @"user"			: @{@"id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																									@"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],
																									@"avatar_url"	: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]},
																			   @"recip"			: @{@"id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																									@"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"]}}]];
		
		[self _didFinishDataRefresh];
	}];
}


#pragma mark - Public APIs
- (void)setUserID:(int)userID {
	_userID = userID;
	[self _retrieveUser];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
	[self _retrieveActivityItems];
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
	
	_activityAlerts = [NSMutableArray array];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight + kOrthodoxTableCellHeight - 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + kOrthodoxTableCellHeight - 20))];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.alwaysBounceVertical = YES;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	_profileHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kOrthodoxTableCellHeight)];
	[_profileHolderView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]]];
	[self.view addSubview:_profileHolderView];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 12.0, 195.0, 22.0)];
	_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.backgroundColor = [UIColor clearColor];
	[_profileHolderView addSubview:_nameLabel];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(6.0, 2.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	if (_userID != 0)
		[self _retrieveUser];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
	
	NSLog(@"%@ -TOT- (%d)", self.class, [[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeUnknown]);
	NSLog(@"%@ -INC- (%d)", self.class, [[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeUnknown]);
	NSLog(@"%@ -TOT- (%d)", self.class, [[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeUnknown]);
	
	if ([[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeUnknown] == 1) {
		if (_insetOverlayView == nil)
			_insetOverlayView = [[HONInsetOverlayView alloc] initAsType:HONInsetOverlayViewTypeInvite];
		_insetOverlayView.delegate = self;
		
		[[HONViewDispensor sharedInstance] appWindowAdoptsView:_insetOverlayView];
		[_insetOverlayView introWithCompletion:nil];
	}
}


#pragma mark - Navigation
- (void)_goInvite {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Invite User"
									withTrivialUser:[HONTrivialUserVO userFromUserVO:_userVO]];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithTrivialUser:[HONTrivialUserVO userFromUserVO:_userVO]]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}
- (void)_goBack {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Back"];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goChangeAvatar {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Change Avatar"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Refresh"];
	
	_activityAlerts = [NSMutableArray array];
	[self _retrieveUser];
}

//- (void)_goShoutout {
//	[[HONAPICaller sharedInstance] createShoutoutChallengeWithUserID:_userVO.userID completion:^(NSObject *result) {
//		[[[UIAlertView alloc] initWithTitle:@"Shoutout Sent!"
//									message:@"Check your Home timeline to like and reply."
//								   delegate:nil
//						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//						  otherButtonTitles:nil] show];
//	}];
//}

- (void)_goFlag {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Invite User"
									withTrivialUser:[HONTrivialUserVO userFromUserVO:_userVO]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"are_you_sure", @"Are you sure?")
														message: NSLocalizedString(@"flag_person", @"This person will be flagged for review")
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
											  otherButtonTitles: NSLocalizedString(@"yes_flag", nil) , nil];
	
	[alertView setTag:HONUserProfileAlertTypeFlag];
	[alertView show];
}

//- (void)_goFAQ {
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPrivacyPolicyViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
//}

//- (void)_goSettings {
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
//}


#pragma mark - Notifications
- (void)_refreshProfile:(NSNotification *)notification {
	[self _retrieveUser];
}


#pragma mark - UI Presentation
- (void)_makeProfile {
//	NSLog(@"AVATAR LOADING:[%@]", [_userVO.avatarURL stringByAppendingString:kSnapThumbSuffix]);
	
	UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 0.0, 64.0, 64.0)];
	[_profileHolderView addSubview:avatarHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:avatarHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[avatarHolderView addSubview:imageLoadingView];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityAvatarBG"]];
	avatarImageView.frame = CGRectOffset(avatarImageView.frame, 10.0, 10.0);
	avatarImageView.alpha = 0.0;
	[avatarHolderView addSubview:avatarImageView];
	
	[[HONViewDispensor sharedInstance] maskView:avatarImageView withMask:[UIImage imageNamed:@"thumbPhotoMask"]];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
		
//		avatarImageView.image = [UIImage imageNamed:@"activityAvatarBG"];
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			avatarImageView.alpha = 1.0;
//		} completion:nil];
	};
	
	if ([_userVO.avatarPrefix rangeOfString:@"defaultAvatar"].location == NSNotFound) {
		NSLog(@"avatarPrefix:[%@]", [_userVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]);
		[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]]
																 cachePolicy:kOrthodoxURLCachePolicy
															 timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:imageSuccessBlock
										failure:imageFailureBlock];
	}
	
	_nameLabel.text = _userVO.username;
	
	if (_userVO.isVerified) {
		UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUserIcon"]];
		verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 40.0, 34.0);
		[_profileHolderView addSubview:verifiedImageView];
	}
	
	UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_userVO.isVerified) ? @"verifiedUserArrow" : @"unverifiedUserArrow"]];
	arrowImageView.frame = CGRectOffset(arrowImageView.frame, 63.0, 28.0);
	[_profileHolderView addSubview:arrowImageView];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(84.0, 34.0, 33.0, 13.0)];
	scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
	scoreLabel.textColor = (_userVO.isVerified) ? [[HONColorAuthority sharedInstance] honGreenTextColor] : [[HONColorAuthority sharedInstance] honGreyTextColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.text = [@"" stringFromInt:_userVO.totalUpvotes];
	[_profileHolderView addSubview:scoreLabel];
	
	if (_userProfileType == HONUserProfileTypeUser) {
//		UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		settingsButton.frame = CGRectMake(227.0, 0.0, 93.0, 44.0);
//		[settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_nonActive"] forState:UIControlStateNormal];
//		[settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_Active"] forState:UIControlStateHighlighted];
//		[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
//		[_headerView addButton:settingsButton];
		
		UIButton *changeAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeAvatarButton.frame = CGRectMake(257.0, 0.0, 64.0, 64.0);
		[changeAvatarButton setBackgroundImage:[UIImage imageNamed:@"changeAvatarButton_nonActive"] forState:UIControlStateNormal];
		[changeAvatarButton setBackgroundImage:[UIImage imageNamed:@"changeAvatarButton_Active"] forState:UIControlStateHighlighted];
		[changeAvatarButton addTarget:self action:@selector(_goChangeAvatar) forControlEvents:UIControlEventTouchUpInside];
		[_profileHolderView addSubview:changeAvatarButton];
	
	} else {
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(227.0, 0.0, 93.0, 44.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addButton:inviteButton];

	}
}

#pragma mark - InsetOverlay Delegates
- (void)insetOverlayViewDidClose:(HONInsetOverlayView *)view {
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
	}];
}

- (void)insetOverlayViewDidInvite:(HONInsetOverlayView *)view {
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
	}];
	

	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"captions"			: @{@"instagram"	: [NSString stringWithFormat:[HONAppDelegate instagramShareMessage], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																													@"twitter"		: [NSString stringWithFormat:[HONAppDelegate twitterShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																													@"sms"			: [NSString stringWithFormat:[HONAppDelegate smsShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																													@"email"		: @[[[HONAppDelegate emailShareComment] objectForKey:@"subject"], [NSString stringWithFormat:[[HONAppDelegate emailShareComment] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"]]],//  [[[[HONAppDelegate emailShareComment] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareComment] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"]]],
																													@"clipboard"	: [NSString stringWithFormat:[HONAppDelegate smsShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]]},
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [[HONImageBroker sharedInstance] shareTemplateImageForType:HONImageBrokerShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"club"				: [[HONClubAssistant sharedInstance] userSignupClub].dictionary,
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
	
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] userSignupClub] viewControllerPushed:NO]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - ActivityItemView Delegates
- (void)activityItemViewCell:(HONActivityItemViewCell *)cell showProfileForUser:(HONTrivialUserVO *)trivialUserVO {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Show User Activity" withTrivialUser:trivialUserVO];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:trivialUserVO.userID] animated:YES];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_activityAlerts count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:NSLocalizedString(@"header_activity", @"ACTIVITY")]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONActivityItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONActivityItemViewCell alloc] init];
		}
		
		cell.activityItemVO = (HONActivityItemVO *)[_activityAlerts objectAtIndex:indexPath.row];
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
	return (44.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	HONActivityItemVO *vo = [_activityAlerts objectAtIndex:indexPath.row];
	return ((vo.activityType == HONActivityItemTypeSignup) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONActivityItemVO *vo = [_activityAlerts objectAtIndex:indexPath.row];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Activity - Selected Row"];
	
	NSLog(@"vo:[%@]", vo.dictionary);
	NSLog(@"vo.activityType:[%@]", (vo.activityType == HONActivityItemTypeClubSubmission) ? @"ClubSubmission" : (vo.activityType == HONActivityItemTypeInviteAccepted) ? @"InviteAccepted" : (vo.activityType == HONActivityItemTypeInviteRequest) ? @"InviteRequest" : (vo.activityType == HONActivityItemTypeLike) ? @"Like" : (vo.activityType == HONActivityItemTypeShoutout) ? @"Shoutout" : @"UNKNOWN");
	
	UIViewController *viewController;
	if (vo.activityType == HONActivityItemTypeInviteAccepted) {
		
	} else if (vo.activityType == HONActivityItemTypeInviteRequest) {
		if (_userProfileType == HONUserProfileTypeOpponent) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithTrivialUser:[HONTrivialUserVO userFromUserVO: _userVO]]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else {
			HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.originUserID];
			viewController = userPofileViewController;
		}
		
	} else if (vo.activityType == HONActivityItemTypeLike) {
		HONClubTimelineViewController *clubTimelineViewControler = [[HONClubTimelineViewController alloc] initWithClubID:vo.clubID withClubPhotoID:vo.challengeID];
		viewController = clubTimelineViewControler;
		
	} else if (vo.activityType == HONActivityItemTypeShoutout) {
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.originUserID];
		viewController = userPofileViewController;
		
	} else if (vo.activityType == HONActivityItemTypeClubSubmission) {
		HONClubTimelineViewController *userPofileViewController = [[HONClubTimelineViewController alloc] initWithClubID:vo.clubID withClubPhotoID:vo.challengeID];
		viewController = userPofileViewController;
	}
	
	if (viewController != nil)
		[self.navigationController pushViewController:viewController animated:YES];
}


@end
