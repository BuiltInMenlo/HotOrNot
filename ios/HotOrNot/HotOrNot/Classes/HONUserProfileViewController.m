//
//  HONUserProfileViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "EGORefreshTableHeaderView.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONImagePickerViewController.h"
#import "HONAddContactsViewController.h"
#import "HONPopularViewController.h"
#import "HONSuggestedFollowViewController.h"
#import "HONFAQViewController.h"
#import "HONSettingsViewController.h"
#import "HONPopularViewController.h"
#import "HONImagingDepictor.h"
#import "HONImageLoadingView.h"
#import "HONUserProfileGridView.h"
#import "HONChallengeVO.h"
#import "HONOpponentVO.h"
#import "HONHeaderView.h"
#import "HONUserVO.h"
#import "HONEmotionVO.h"

#import "HONFollowingViewController.h"
#import "HONFollowersViewController.h"

//[UIColor colorWithRed:0.808 green:0.420 blue:0.431 alpha:1.0][UIColor colorWithRed:0.808 green:0.420 blue:0.431 alpha:0.5]


@interface HONUserProfileViewController () <HONSnapPreviewViewControllerDelegate, HONParticipantGridViewDelegate>
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) UIView *bgHolderView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIButton *verifyButton;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) HONUserProfileGridView *profileGridView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UILabel *selfiesLabel;
@property (nonatomic, strong) UILabel *followersLabel;
@property (nonatomic, strong) UILabel *followingLabel;
//@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIView *gridHolderView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *challengeImages;
@property (nonatomic, strong) UIToolbar *footerToolbar;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UIButton *flagButton;
@property (nonatomic) int challengeCounter;
@property (nonatomic) int followingCounter;
@property (nonatomic) BOOL isUser;
@property (nonatomic) BOOL isFollowing;
@property (nonatomic) BOOL isRefreshing;
@end


@implementation HONUserProfileViewController
@synthesize userID = _userID;

- (id)initWithBackground:(UIImageView *)imageView {
	if ((self = [super init])) {
		_bgImageView = nil;//imageView;
		self.view.backgroundColor = (imageView == nil) ? [UIColor whiteColor] : [UIColor clearColor];
		
		_isUser = NO;
		_isFollowing = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshProfile:) name:@"REFRESH_PROFILE" object:nil];
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
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 5],
							 @"userID"	: [NSString stringWithFormat:@"%d", _userID]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"], params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if ([userResult objectForKey:@"id"] != nil) {
				_userVO = [HONUserVO userWithDictionary:userResult];
				_isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
				
				[_verifyButton setBackgroundImage:[UIImage imageNamed:((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_verified"] intValue]) ? @"userVerifiedButton_nonActive" : @"userNotVerifiedButton_nonActive"] forState:UIControlStateNormal];
				[_verifyButton setBackgroundImage:[UIImage imageNamed:((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_verified"] intValue]) ? @"userVerifiedButton_nonActive" : @"userNotVerifiedButton_nonActive"] forState:UIControlStateHighlighted];
				
//				[_verifyButton setBackgroundImage:[UIImage imageNamed:@"userVerifiedButton_nonActive"] forState:UIControlStateNormal];
//				[_verifyButton setBackgroundImage:[UIImage imageNamed:@"userVerifiedButton_nonActive"] forState:UIControlStateHighlighted];
				
				if (!_isUser) {
					[_verifyButton setBackgroundImage:[UIImage imageNamed:((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_verified"] intValue]) ? @"userVerifiedButton_Active" : @"userNotVerifiedButton_Active"] forState:UIControlStateHighlighted];
					[_verifyButton addTarget:self action:@selector(_goVerify) forControlEvents:UIControlEventTouchUpInside];
				}
				
				[self _retreiveSubscribees];
			
			} else {
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = @"User not found!";
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if ([error.description isEqualToString:kNetErrorNoConnection]) {
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = @"No network connection!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		}
	}];
}

- (void)_retreiveSubscribees {
	NSDictionary *params = @{@"userID"	: [NSString stringWithFormat:@"%d", _userID]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetSubscribees, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	
	[httpClient postPath:kAPIGetSubscribees parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %d", [[self class] description], [result count]);
			
			if (_isUser)
				[HONAppDelegate writeSubscribeeList:result];
			
			_followingCounter = [result count];
			[self _retrieveChallenges];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_retrieveChallenges {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"action"		: [NSString stringWithFormat:@"%d", 9],
							 @"isPrivate"	: @"N",
							 @"username"	: _userVO.username,
							 @"p"			: [NSString stringWithFormat:@"%d", 1]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: USER CHALLENGES:[%d]", [[self class] description], [result count]);
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [result objectAtIndex:0]);
			_challenges = [NSMutableArray array];
			
			for (NSDictionary *dict in result) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
				
				if (vo != nil)
					[_challenges addObject:vo];
			}
			
			_isRefreshing = NO;
			[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];

			[self _makeUI];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_addFriend:(int)userID {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"target"	: [NSString stringWithFormat:@"%d", userID],
							 @"auto"	: @"0"};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_removeFriend:(int)userID {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"target"	: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIRemoveFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIRemoveFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_flagUser:(int)userID {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 10],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [NSString stringWithFormat:@"%d", userID],
							 @"approves"	: [NSString stringWithFormat:@"%d", 0]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
//			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_verifyUser:(int)userID {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 10],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"targetID"	: [NSString stringWithFormat:@"%d", userID],
							 @"approves"	: [NSString stringWithFormat:@"%d", 1]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else
			[self _goRefresh];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_removeChallengeWithID:(int)challengeID usingImagePrefix:(NSString *)imagePrefix {
	NSDictionary *params = @{@"challengeID"	: [NSString stringWithFormat:@"%d", challengeID],
							 @"imgURL"	: imagePrefix};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIDeleteImage, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIDeleteImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil) {
				for (UIImageView *imageView in _gridHolderView.subviews)
					[imageView removeFromSuperview];
				
				[_gridHolderView removeFromSuperview];
				_gridHolderView = nil;
				
				[self _retrieveUser];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_sendShoutoutForUser:(int)userID {
	NSDictionary *params = @{@"target"	: [NSString stringWithFormat:@"%d", userID],
							 @"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIMakeShoutout, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIMakeShoutout parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			//			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


#pragma mark - Public APIs
- (void)setUserID:(int)userID {
	_userID = userID;
	
	_isFollowing = [HONAppDelegate isFollowingUser:_userID];
	[_followButton setBackgroundImage:[UIImage imageNamed:(_isFollowing) ? @"unfollow_nonActive" : @"followUser_nonActive"] forState:UIControlStateNormal];
	[_followButton setBackgroundImage:[UIImage imageNamed:(_isFollowing) ? @"unfollow_Active" : @"followUser_Active"] forState:UIControlStateHighlighted];
	[_followButton addTarget:self action:(_isFollowing) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
	[self _retrieveUser];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_bgHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_bgHolderView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
//	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
//	_refreshTableHeaderView.delegate = self;
//	[_scrollView addSubview:_refreshTableHeaderView];
//	[_refreshTableHeaderView refreshLastUpdatedDate];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	_verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_verifyButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:@""];
	[_headerView addButton:_verifyButton];
	[_headerView addButton:doneButton];
	[self.view addSubview:_headerView];
	
	_footerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
	[self.view addSubview:_footerToolbar];
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
	[_bgHolderView addSubview:_bgImageView];
		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RESET_PROFILE_BUTTON" object:nil];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"profile_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"profile_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 0 && _isUser) {
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
		_tutorialImageView.userInteractionEnabled = YES;
		_tutorialImageView.hidden = YES;
		_tutorialImageView.alpha = 0.0;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = _tutorialImageView.frame;
		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:closeButton];
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goDone {
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"profile_total"] intValue];
	if (total == 0 && _isUser && [HONAppDelegate switchEnabledForKey:@"profile_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"INVITE your friends to %@?", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub"]
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:5];
		[alertView show];
	
	} else {
//		int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"profile_total"] intValue];
//		if (!_isFollowing && total < [HONAppDelegate profileSubscribeThreshold]) {
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//																message:[NSString stringWithFormat:@"Want to subscribe to %@'s updates?", _userVO.username]
//															   delegate:self
//													  cancelButtonTitle:@"No"
//													  otherButtonTitles:@"Yes", nil];
//			[alertView setTag:0];
//			[alertView show];
//		
//		} else {
		
		if ([self parentViewController] != nil) {
			[self dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
			}];
		
		} else {
//			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
			[self.view removeFromSuperview];
		}
	}
}

- (void)_goChangeAvatar {
	[[Mixpanel sharedInstance] track:@"User Profile - Take New Avatar"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	for (UIImageView *imageView in _gridHolderView.subviews)
		[imageView removeFromSuperview];
	
	[_gridHolderView removeFromSuperview];
	_gridHolderView = nil;
	
	[self _retrieveUser];
}

- (void)_goVerify {
	[[Mixpanel sharedInstance] track:@"User Profile - Verify User"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"participant", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Verify & follow user", @"Verify user only", [NSString stringWithFormat:@"This user does not look %d to %d", [HONAppDelegate ageRangeAsSeconds:NO].location, [HONAppDelegate ageRangeAsSeconds:NO].length], nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
}

- (void)_goSubscribe {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Subscribe%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will receive %@ updates from %@", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:3];
	[alertView show];
}

- (void)_goUnsubscribe {
	[[Mixpanel sharedInstance] track:@"User Profile - Unsubscribe"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will no longer receive %@ updates from %@", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:4];
	[alertView show];
}

- (void)_goShoutout {
	[self _sendShoutoutForUser:_userID];
}

- (void)_goFlag {
	[[Mixpanel sharedInstance] track:@"User Profile - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:2];
	[alertView show];
}

- (void)_goInviteFriends {
	[[Mixpanel sharedInstance] track:@"User Profile - Find People"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Find Friends", @"Search", @"Suggested People", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:1];
	[actionSheet showInView:self.view];
}

- (void)_goShare {
	[[Mixpanel sharedInstance] track:@"User Profile - Share"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIImage *shareImage = ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [HONImagingDepictor defaultShareImage];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																							@"image"			: shareImage,
																							@"url"				: @"",
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}

- (void)_goFAQ {
	[[Mixpanel sharedInstance] track:@"User Profile - Show FAQ"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFAQViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSettings {
	[[Mixpanel sharedInstance] track:@"User Profile - Settings"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


- (void)_goSubscribers {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFollowersViewController alloc] initWithUserID:_userID]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSubscribees {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFollowingViewController alloc] initWithUserID:_userID]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goVolleys {
	[_scrollView scrollRectToVisible:CGRectMake(0.0, _scrollView.frame.size.height, 320.0, _gridHolderView.frame.size.height) animated:YES];
}

- (void)_goRemoveTutorial {
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		if (_tutorialImageView != nil) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}
	}];
}

- (void)_goTapHoldAlert {
	[[[UIAlertView alloc] initWithTitle:@"Tap and hold to view full screen!"
								message:@""
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}



#pragma mark - Notifications
- (void)_refreshProfile:(NSNotification *)notification {
	[self _retrieveUser];
}


#pragma mark - UI Presentation
- (void)_makeUI {
	[_headerView setTitle:_userVO.username];
	
	for (UIView *view in _scrollView.subviews)
		[view removeFromSuperview];
	
	
	[self _makeAvatarImage];
	
		
//	HONEmotionVO *emotionVO = [self _latestChallengeEmotion];
//	BOOL isEmotionFound = (emotionVO != nil);
//	
//	if (isEmotionFound) {
//		UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 222.0, 43.0, 43.0)];
//		[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
//		[_scrollView addSubview:emoticonImageView];
//	}
//	
//	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0 + (((int)isEmotionFound) * 32.0), 232.0, 250.0, 22.0)];
//	subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
//	subjectLabel.textColor = [UIColor whiteColor];
//	subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//	subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
//	subjectLabel.backgroundColor = [UIColor clearColor];
//	subjectLabel.text = ((HONChallengeVO *)[_challenges lastObject]).subjectName;
//	[_scrollView addSubview:subjectLabel];
	
	
	UIImageView *statsBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileLineBackground"]];
	statsBGImageView.frame = CGRectOffset(statsBGImageView.frame, 0.0, 180.0);
	[_scrollView addSubview:statsBGImageView];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	if (_selfiesLabel) {
		[_selfiesLabel removeFromSuperview];
		_selfiesLabel = nil;
	}
	
	if (_followersLabel) {
		[_followersLabel removeFromSuperview];
		_followersLabel = nil;
	}
	
	if (_followingLabel) {
		[_followingLabel removeFromSuperview];
		_followingLabel = nil;
	}
	
	_selfiesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 196.0, 107.0, 18.0)];
	_selfiesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	_selfiesLabel.textColor = [HONAppDelegate honGreyTextColor];
	_selfiesLabel.backgroundColor = [UIColor clearColor];
	_selfiesLabel.textAlignment = NSTextAlignmentCenter;
	_selfiesLabel.text = [NSString stringWithFormat:@"%@ Selfie%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.totalVolleys]], (_userVO.totalVolleys == 1) ? @"" : @"s"];
	[_scrollView addSubview:_selfiesLabel];
	
	_followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(106.0, 196.0, 107.0, 18.0)];
	_followersLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	_followersLabel.textColor = [HONAppDelegate honGreyTextColor];
	_followersLabel.backgroundColor = [UIColor clearColor];
	_followersLabel.textAlignment = NSTextAlignmentCenter;
	_followersLabel.text = [NSString stringWithFormat:@"%@ Follower%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
	[_scrollView addSubview:_followersLabel];

	_followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(213.0, 196.0, 107.0, 18.0)];
	_followingLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	_followingLabel.textColor = [HONAppDelegate honGreyTextColor];
	_followingLabel.backgroundColor = [UIColor clearColor];
	_followingLabel.textAlignment = NSTextAlignmentCenter;
	_followingLabel.text = [NSString stringWithFormat:@"%@ Following", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_followingCounter]]];
	[_scrollView addSubview:_followingLabel];

//	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 432.0, 260.0, 35.0)];
//	_likesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:27];
//	_likesLabel.textColor = [HONAppDelegate honGreyTextColor];
//	_likesLabel.backgroundColor = [UIColor clearColor];
//	_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
//	[_scrollView addSubview:_likesLabel];
	
	UIButton *followersButton = [UIButton buttonWithType:UIButtonTypeCustom];
	followersButton.frame = _followersLabel.frame;
	[followersButton addTarget:self action:@selector(_goSubscribers) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:followersButton];
	
	UIButton *followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	followingButton.frame = _followingLabel.frame;
	[followingButton addTarget:self action:@selector(_goSubscribees) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:followingButton];

	UIButton *volleysButton = [UIButton buttonWithType:UIButtonTypeCustom];
	volleysButton.frame = _selfiesLabel.frame;
	[volleysButton addTarget:self action:@selector(_goVolleys) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:volleysButton];
	
	if (_isUser) {
		UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		findFriendsButton.frame = CGRectMake(0.0, 233.0, 320.0, 45.0);
		[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findFriends_nonActive"] forState:UIControlStateNormal];
		[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findFriends_Active"] forState:UIControlStateHighlighted];
		[findFriendsButton addTarget:self action:@selector(_goInviteFriends) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:findFriendsButton];
		
		UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
		helpButton.frame = CGRectMake(0.0, 279.0, 320.0, 45.0);
		[helpButton setBackgroundImage:[UIImage imageNamed:@"helpButton_nonActive"] forState:UIControlStateNormal];
		[helpButton setBackgroundImage:[UIImage imageNamed:@"helpButton_Active"] forState:UIControlStateHighlighted];
		[helpButton addTarget:self action:@selector(_goFAQ) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:helpButton];
		
	} else {
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(0.0, 233.0, 320.0, 45.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:(_isFollowing) ? @"unfollow_nonActive" : @"followUser_nonActive"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:(_isFollowing) ? @"unfollow_Active" : @"followUser_Active"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:(_isFollowing) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:_followButton];
		
		UIButton *shoutoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shoutoutButton.frame = CGRectMake(0.0, 279.0, 320.0, 45.0);
		[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutoutButton_nonActive"] forState:UIControlStateNormal];
		[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutoutButton_Active"] forState:UIControlStateHighlighted];
		[shoutoutButton addTarget:self action:@selector(_goShoutout) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:shoutoutButton];
		
		UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
		reportButton.frame = CGRectMake(0.0, 325.0, 320.0, 45.0);
		[reportButton setBackgroundImage:[UIImage imageNamed:@"reportUser_nonActive"] forState:UIControlStateNormal];
		[reportButton setBackgroundImage:[UIImage imageNamed:@"reportUser_Active"] forState:UIControlStateHighlighted];
		[reportButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:reportButton];
	}
	
	float gridPos = 324.0 + ((int)(!_isUser) * 45.0);
	_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, (gridPos + 44.0) + (kSnapThumbSize.height * (([self _numberOfImagesForGrid] / 4) + 1))));
	_profileGridView = [[HONUserProfileGridView alloc] initAtPos:gridPos forChallenges:_challenges asPrimaryOpponent:[self _latestOpponentInChallenge]];
	_profileGridView.delegate = self;
	_profileGridView.clipsToBounds = YES;
	[_scrollView addSubview:_profileGridView];
	
	
	[self _makeFooterBar];
}

- (void)_makeAvatarImage {
//	NSLog(@"AVATAR LOADING:[%@]", [_userVO.avatarURL stringByAppendingString:kSnapThumbSuffix]);
	
	UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(120.0, 85.0, 80.0, 80.0)];
	[_scrollView addSubview:avatarHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:avatarHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[avatarHolderView addSubview:imageLoadingView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:_userVO.avatarURL];
	};
	
	if (_avatarImageView != nil) {
		[_avatarImageView removeFromSuperview];
		_avatarImageView = nil;
	}
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
	[avatarHolderView addSubview:_avatarImageView];
	_avatarImageView.alpha = 0.0;
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarURL stringByAppendingString:kSnapThumbSuffix]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:imageSuccessBlock
									 failure:imageFailureBlock];
	
	UIButton *changeAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	changeAvatarButton.frame = CGRectMake(120.0, 85.0, 80.0, 80.0);
	[changeAvatarButton setBackgroundImage:[UIImage imageNamed:@"profilePhotoButton_nonActive"] forState:UIControlStateNormal];
	[changeAvatarButton setBackgroundImage:[UIImage imageNamed:@"profilePhotoButton_Active"] forState:UIControlStateHighlighted];
	[changeAvatarButton addTarget:self action:@selector(_goChangeAvatar) forControlEvents:UIControlEventTouchUpInside];
	changeAvatarButton.hidden = (!_isUser);
	[_scrollView addSubview:changeAvatarButton];
}

- (void)_makeFooterBar {
	CGSize size;
	NSArray *footerElements;
	
	if (_isUser) {
//		UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		addFriendsButton.frame = CGRectMake(0.0, 0.0, 40.0, 44.0);
//		[addFriendsButton setTitleColor:[HONAppDelegate honBlueTextColor] forState:UIControlStateNormal];
//		[addFriendsButton setTitleColor:[HONAppDelegate honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
//		[addFriendsButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17.0]];
//		[addFriendsButton setTitle:@"Add Friends" forState:UIControlStateNormal];
//		[addFriendsButton addTarget:self action:@selector(_goInviteFriends) forControlEvents:UIControlEventTouchUpInside];
//		
//		size = [addFriendsButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
//															  options:NSStringDrawingTruncatesLastVisibleLine
//														   attributes:@{NSFontAttributeName:addFriendsButton.titleLabel.font}
//															  context:nil].size;
//		addFriendsButton.frame = CGRectMake(addFriendsButton.frame.origin.x, addFriendsButton.frame.origin.y, size.width, size.height);
		
		UIButton *shareFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shareFooterButton.frame = CGRectMake(0.0, 0.0, 80.0, 44.0);
		[shareFooterButton setTitleColor:[HONAppDelegate honBlueTextColor] forState:UIControlStateNormal];
		[shareFooterButton setTitleColor:[HONAppDelegate honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
		[shareFooterButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17.0]];
		[shareFooterButton setTitle:@"Share" forState:UIControlStateNormal];
		[shareFooterButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		
		if ([HONAppDelegate isIOS7]) {
			size = [shareFooterButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
												  options:NSStringDrawingTruncatesLastVisibleLine
											   attributes:@{NSFontAttributeName:shareFooterButton.titleLabel.font}
												  context:nil].size;
			
		} //else
//			size = [shareFooterButton.titleLabel.text sizeWithFont:shareFooterButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		shareFooterButton.frame = CGRectMake(shareFooterButton.frame.origin.x, shareFooterButton.frame.origin.y, size.width, size.height);
		
		UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		settingsButton.frame = CGRectMake(0.0, 0.0, 59.0, 44.0);
		[settingsButton setTitleColor:[HONAppDelegate honBlueTextColor] forState:UIControlStateNormal];
		[settingsButton setTitleColor:[HONAppDelegate honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
		[settingsButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17.0]];
		[settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
		[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
		
		if ([HONAppDelegate isIOS7]) {
			size = [settingsButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
												  options:NSStringDrawingTruncatesLastVisibleLine
											   attributes:@{NSFontAttributeName:settingsButton.titleLabel.font}
												  context:nil].size;
			
		} //else
//			size = [settingsButton.titleLabel.text sizeWithFont:settingsButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		settingsButton.frame = CGRectMake(settingsButton.frame.origin.x, settingsButton.frame.origin.y, size.width, size.height);
		
		footerElements = @[//[[UIBarButtonItem alloc] initWithCustomView:addFriendsButton],
//						   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
						   [[UIBarButtonItem alloc] initWithCustomView:shareFooterButton],
						   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
						   [[UIBarButtonItem alloc] initWithCustomView:settingsButton]];
		
	} else {
//		_subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_subscribeButton.frame = CGRectMake(0.0, 0.0, 95.0, 44.0);
//		[_subscribeButton setTitleColor:[HONAppDelegate honBlueTextColor] forState:UIControlStateNormal];
//		[_subscribeButton setTitleColor:[HONAppDelegate honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
//		[_subscribeButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17.0]];
//		[_subscribeButton setTitle:(_isFollowing) ? @"Unfollow" : @"Follow" forState:UIControlStateNormal];
//		[_subscribeButton addTarget:self action:(_isFollowing) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
//		size = [_subscribeButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
//											  options:NSStringDrawingTruncatesLastVisibleLine
//										   attributes:@{NSFontAttributeName:_subscribeButton.titleLabel.font}
//											  context:nil].size;
//		_subscribeButton.frame = CGRectMake(_subscribeButton.frame.origin.x, _subscribeButton.frame.origin.y, size.width, size.height);
		
		UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shareButton.frame = CGRectMake(0.0, 0.0, 80.0, 44.0);
		[shareButton setTitleColor:[HONAppDelegate honBlueTextColor] forState:UIControlStateNormal];
		[shareButton setTitleColor:[HONAppDelegate honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
		[shareButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17.0]];
		[shareButton setTitle:@"Share" forState:UIControlStateNormal];
		[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		
		if ([HONAppDelegate isIOS7]) {
			size = [shareButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
												  options:NSStringDrawingTruncatesLastVisibleLine
											   attributes:@{NSFontAttributeName:shareButton.titleLabel.font}
												  context:nil].size;
			
		} //else
//			size = [shareButton.titleLabel.text sizeWithFont:shareButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		shareButton.frame = CGRectMake(shareButton.frame.origin.x, shareButton.frame.origin.y, size.width, size.height);
		
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
		[flagButton setTitleColor:[HONAppDelegate honBlueTextColor] forState:UIControlStateNormal];
		[flagButton setTitleColor:[HONAppDelegate honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
		[flagButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17.0]];
		[flagButton setTitle:@"Flag" forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		
		if ([HONAppDelegate isIOS7]) {
			size = [flagButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 44.0)
												  options:NSStringDrawingTruncatesLastVisibleLine
											   attributes:@{NSFontAttributeName:flagButton.titleLabel.font}
												  context:nil].size;
			
		} //else
//			size = [flagButton.titleLabel.text sizeWithFont:flagButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		flagButton.frame = CGRectMake(flagButton.frame.origin.x, flagButton.frame.origin.y, size.width, size.height);
		
		footerElements = @[//[[UIBarButtonItem alloc] initWithCustomView:_subscribeButton],
//						   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
						   [[UIBarButtonItem alloc] initWithCustomView:shareButton],
						   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
						   [[UIBarButtonItem alloc] initWithCustomView:flagButton]];
	}
	
	[_footerToolbar setItems:footerElements];
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - GridView Delegates
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
//	NSLog(@"participantGridView:[%@]showPreview:[%@]forChallenge:[%d]", participantGridView, opponentVO.dictionary, challengeVO.challengeID);
	
	[[Mixpanel sharedInstance] track:(_isUser) ? [NSString stringWithFormat:@"User Profile - Remove Selfie%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"] : [NSString stringWithFormat:@"User Profile - Show Preview%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", opponentVO.userID], @"userID", nil]];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initFromProfileWithOpponent:opponentVO forChallenge:challengeVO];
	_snapPreviewViewController.delegate = self;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"participantGridView:showProfile:[%@]forChallenge:[%d]", opponentVO.dictionary, challengeVO.challengeID);
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", opponentVO.userID], @"userID", nil]];
	
	if ([HONAppDelegate hasTakenSelfie]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
		
		HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:nil];
		userPofileViewController.userID = opponentVO.userID;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
		[navigationController setNavigationBarHidden:YES];
		[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
	
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:2];
		[alertView show];
	}
}

- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView removeParticipantItem:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Remove Selfie%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", opponentVO.userID], @"userID", nil]];
	
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete your selfie?"
														message:@""
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:1];
	[alertView show];
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]]];
}

- (void)snapPreviewViewControllerFlag:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController joinChallenge:(HONChallengeVO *)challengeVO {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Close Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1)
			[self _addFriend:_userVO.userID];
		
		[self dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
		}];
		
	} else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Remove Selfie %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _removeChallengeWithID:_challengeVO.challengeID usingImagePrefix:_opponentVO.imagePrefix];
		}
		
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Flag %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _flagUser:_userVO.userID];
		}
		
	} else if (alertView.tag == 3) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			[self _addFriend:_userVO.userID];
			[_followButton setBackgroundImage:[UIImage imageNamed:@"unfollow_nonActive"] forState:UIControlStateNormal];
			[_followButton setBackgroundImage:[UIImage imageNamed:@"unfollow_Active"] forState:UIControlStateHighlighted];
			[_followButton removeTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_followButton addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
			
			[_subscribeButton setTitle:@"Unfollow" forState:UIControlStateNormal];
			_subscribeButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
			[_subscribeButton removeTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_subscribeButton addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
		
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Unsubscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _removeFriend:_userVO.userID];
			[_followButton setBackgroundImage:[UIImage imageNamed:@"followUser_nonActive"] forState:UIControlStateNormal];
			[_followButton setBackgroundImage:[UIImage imageNamed:@"followUser_Active"] forState:UIControlStateHighlighted];
			[_followButton removeTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_followButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
			
			
			[_subscribeButton setTitle:@"Follow" forState:UIControlStateNormal];
			_subscribeButton.frame = CGRectMake(0.0, 0.0, 47.0, 44.0);
			[_subscribeButton removeTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
	
	} else if (alertView.tag == 5) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];

		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		
		} else {
			[self dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
			}];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Verify User%@", (buttonIndex == 0) ? @" & Follow" : (buttonIndex == 1) ? @"" : @"Flag"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"participant", nil]];
		
		if (buttonIndex == 0) {
			[self _verifyUser:_userVO.userID];
			[self _addFriend:_userVO.userID];
		
		} else if (buttonIndex == 1) {
			[self _verifyUser:_userVO.userID];
			
		} else if (buttonIndex == 2) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																message:@"This person will be flagged for review"
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"Yes, flag user", nil];
			
			[alertView setTag:2];
			[alertView show];
		}
		
	} else if (actionSheet.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Find People %@", (buttonIndex == 0) ? @"Contacts" : (buttonIndex == 1) ? @"Search" : (buttonIndex == 2) ? @"Suggested" : @"Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex != 3) {
			NSArray *viewControllers = @[[[HONAddContactsViewController alloc] init],
										 [[HONPopularViewController alloc] init],
										 [[HONSuggestedFollowViewController alloc] init]];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[viewControllers objectAtIndex:buttonIndex]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - Data Tally
- (int)_numberOfImagesForGrid {
	
	int tot = 0;
	for (HONChallengeVO *vo in _challenges) {
		if (_userID == vo.creatorVO.userID)
			tot++;
		
		for (HONOpponentVO *challenger in vo.challengers) {
			if (_userID == challenger.userID)
				tot++;
		}
	}
	
	return (tot);
}


- (HONOpponentVO *)_latestOpponentInChallenge {
	HONOpponentVO *opponentVO;
	
	HONChallengeVO *newestChallenge = (HONChallengeVO *)[_challenges lastObject];
	if (_userID == newestChallenge.creatorVO.userID)
		opponentVO = newestChallenge.creatorVO;
	
	else {
		NSLog(@"newestChallenge -> opponents:[%d]", [newestChallenge.challengers count]);
		for (HONOpponentVO *vo in newestChallenge.challengers) {
			if (_userID == vo.userID) {
				opponentVO = vo;
				break;
			}
		}
	}
	
	return (opponentVO);
}

- (HONEmotionVO *)_latestChallengeEmotion {
	HONEmotionVO *emotionVO;
	HONOpponentVO *opponentVO = [self _latestOpponentInChallenge];
	
	BOOL isEmotionFound = NO;
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
		if ([vo.hastagName isEqualToString:opponentVO.subjectName]) {
			emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
			isEmotionFound = YES;
			break;
		}
	}
	
	if (!isEmotionFound) {
		for (HONEmotionVO *vo in [HONAppDelegate replyEmotions]) {
			if ([vo.hastagName isEqualToString:opponentVO.subjectName]) {
				emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
				isEmotionFound = YES;
				break;
			}
		}
	}
	
	return ((isEmotionFound) ? emotionVO : nil);
}


@end
