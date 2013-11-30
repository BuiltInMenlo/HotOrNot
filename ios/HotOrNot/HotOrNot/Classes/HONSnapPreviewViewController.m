//
//  HONSnapPreviewViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "ImageFilter.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "HONSnapPreviewViewController.h"
#import "HONImageLoadingView.h"
#import "HONUserVO.h"
#import "HONEmotionVO.h"
#import "HONHeaderView.h"
#import "HONImagingDepictor.h"
#import "HONFollowersViewController.h"
#import "HONFollowingViewController.h"
#import "HONUserProfileGridView.h"
#import "HONUserProfileViewController.h"

@interface HONSnapPreviewViewController ()
//@property (nonatomic, copy) imageLoadComplete_t heroCompleteBlock;
//@property (nonatomic, copy) imageLoadFailure_t heroFailureBlock;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *releaseHolderView;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONChallengeVO *newestChallengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, retain) HONUserProfileViewController *userProfileViewController;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic) BOOL isVerify;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isFromProfile;
@end


@implementation HONSnapPreviewViewController
@synthesize delegate = _delegate;
//- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
//    self.completionBlock = ^{
//        if () {
//            if (failure) {
//
//            }
//        } else {
//            if (success) {
//
//            }
//        }
//    };
//#pragma clang diagnostic pop
//}

//static void (^heroSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image);
//
//void (^heroSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//	
//static void imageLoadComplete_t(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusForFlags(flags);
//    AFNetworkReachabilityStatusBlock block = (__bridge AFNetworkReachabilityStatusBlock)info;
//    if (block) {
//        block(status);
//    }
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingReachabilityDidChangeNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:status] forKey:AFNetworkingReachabilityNotificationStatusItem]];
//    });
//}




- (id)initWithVerifyChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_opponentVO = vo.creatorVO;
		_isVerify = YES;
		_isFromProfile = NO;
		
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	}
	
	return (self);
}

- (id)initWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super init])) {
		_opponentVO = opponentVO;
		_challengeVO = challengeVO;
		_isVerify = NO;
		_isFromProfile = NO;
		
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		
		//NSLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCHALLENGE DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n", _challengeVO.dictionary);
	}
	
	return (self);
}

- (id)initFromProfileWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [self initWithOpponent:opponentVO forChallenge:challengeVO])) {
		_isFromProfile = YES;
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
- (void)_flagUser:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 10], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"targetID",
							[NSString stringWithFormat:@"%d", 0], @"approves",
							nil];
	
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
		
		[self _goClose];
		
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

- (void)_upvoteChallenge:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 6], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							[NSString stringWithFormat:@"%d", userID], @"challengerID",
							_opponentVO.imagePrefix, @"imgURL",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"], params);
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
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			_challengeVO = [HONChallengeVO challengeWithDictionary:result];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:result];
			[self.delegate snapPreviewViewControllerUpvote:self opponent:_opponentVO forChallenge:_challengeVO];
		}
		
		[self _goClose];
		
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
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target",
							@"0", @"auto", nil];
	
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
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
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

- (void)_verifyUser:(int)userID asLegit:(BOOL)isApprove {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 10], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"targetID",
							[NSString stringWithFormat:@"%d", (int)isApprove], @"approves",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"], params);
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
			if (isApprove) {
				int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"verifyAction_total"] intValue];
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"verifyAction_total"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				if (total == 0 && [HONAppDelegate switchEnabledForKey:@"verify_share"]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"SHARE %@ with your friends?", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub"]
																		message:@"Get more subscribers now, tap OK."
																	   delegate:self
															  cancelButtonTitle:@"Cancel"
															  otherButtonTitles:@"OK", nil];
					[alertView setTag:5];
					[alertView show];
					
				} else
					[self _goClose];
			
			} else
				[self _goClose];
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	
	_imageHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_imageHolderView];
	
	_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageHolderView asLargeLoader:NO];
	[_imageHolderView addSubview:_imageLoadingView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[_imageLoadingView stopAnimating];

		_imageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.33 animations:^(void) {
				_buttonHolderView.alpha = 1.0;
			}];
		}];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:_opponentVO.imagePrefix];
		[_imageLoadingView stopAnimating];
		[UIView animateWithDuration:0.33 animations:^(void) {
			_buttonHolderView.alpha = 1.0;
		}];
	};
	
	//_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (kSnapLargeSize.height - self.view.frame.size.height) * -0.5, kSnapLargeSize.width, kSnapLargeSize.height)];
	_imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	[_imageHolderView addSubview:_imageView];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_opponentVO.imagePrefix stringByAppendingString:([HONAppDelegate isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
					  placeholderImage:nil
							   success:successBlock
							   failure:failureBlock];
	
	//NSLog(@"%@ --> HERO:[%@] DATA:[%@]\n", (_isVerify) ? @"VERIFY" : @"OPPONENT", _opponentVO.imagePrefix, _opponentVO.dictionary);
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = self.view.frame;
	[_closeButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:_closeButton];
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
	headerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[self.view addSubview:headerView];
	
	
	//NSLog(@"AVATAR:[%@]", [_opponentVO.avatarURL stringByAppendingString:kSnapThumbSuffix]);
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:[_opponentVO.avatarURL stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
	[headerView addSubview:avatarImageView];
	
	CGSize size;
	CGFloat maxNameWidth = (_isVerify) ? 260.0 : 110.0;
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 10.0, maxNameWidth, 18.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	[headerView addSubview:nameLabel];
	
	if ([HONAppDelegate isIOS7]) {
		size = [[_opponentVO.username stringByAppendingString:@"…"] boundingRectWithSize:CGSizeMake(maxNameWidth, 19.0)
																				 options:NSStringDrawingTruncatesLastVisibleLine
																			  attributes:@{NSFontAttributeName:nameLabel.font}
																				 context:nil].size;
		
	} //else
//		size = [_opponentVO.username sizeWithFont:nameLabel.font constrainedToSize:CGSizeMake(maxNameWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
	nameLabel.text = (_isVerify) ? _opponentVO.username : (size.width >= maxNameWidth) ? _opponentVO.username : [_opponentVO.username stringByAppendingString:@"…"];
	nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, MIN(maxNameWidth, size.width), nameLabel.frame.size.height);
	
	if (!_isVerify) {
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + (nameLabel.frame.size.width + 3.0), 10.0, 320.0 - (nameLabel.frame.size.width + 110.0), 18.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _opponentVO.subjectName;
		subjectLabel.hidden = _isVerify;
		[headerView addSubview:subjectLabel];
		
		if ([HONAppDelegate isIOS7]) {
			size = [subjectLabel.text boundingRectWithSize:CGSizeMake(320.0 - (nameLabel.frame.size.width + maxNameWidth), 18.0)
												   options:NSStringDrawingTruncatesLastVisibleLine
												attributes:@{NSFontAttributeName:nameLabel.font}
												   context:nil].size;
			
		} //else
//		size = [subjectLabel.text sizeWithFont:subjectLabel.font constrainedToSize:CGSizeMake(320.0 - (nameLabel.frame.size.width + maxNameWidth), CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		subjectLabel.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y, MIN(320.0 - (nameLabel.frame.size.width + maxNameWidth), size.width), subjectLabel.frame.size.height);
	}
	
	//NSLog(@"NAME:_[%@]_ <|> SUB:_[%@]_", NSStringFromCGSize(nameLabel.frame.size), NSStringFromCGSize(subjectLabel.frame.size));
	
//	BOOL isEmotionFound = NO;
//	if (!_isVerify) {
//		HONEmotionVO *emotionVO = [self _emotionForParticipant:_opponentVO];
//		isEmotionFound = (emotionVO != nil);
//		
//		if (isEmotionFound) {
//			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-1.0, 0.0, 43.0, 43.0)];
//			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.imageLargeURL] placeholderImage:nil];
//			[_nameHolderView addSubview:emoticonImageView];
//		}
//		
//		participantLabel.frame = CGRectOffset(participantLabel.frame, ((int)isEmotionFound) * 34.0, 0.0);
//		subjectLabel.frame = CGRectOffset(subjectLabel.frame, ((int)isEmotionFound) * 34.0, 0.0);
//	}
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(0.0, 0.0, nameLabel.frame.origin.x + nameLabel.frame.size.width, headerView.frame.size.height);
	[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:profileButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(253.0, -3.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneButton];
	
	_buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(239.0, [UIScreen mainScreen].bounds.size.height - (159.0 + ((_isVerify && [HONAppDelegate switchEnabledForKey:@"verify_tab"]) * 86.0)), 64.0, 196.0)];
	_buttonHolderView.alpha = 0.0;
	[self.view addSubview:_buttonHolderView];
	
	if (_isVerify) {
		UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		approveButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
		[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_nonActive"] forState:UIControlStateNormal];
		[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_Active"] forState:UIControlStateHighlighted];
		[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:approveButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(0.0, 78.0, 64.0, 64.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"nayButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"nayButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:skipButton];
		
		UIButton *disapproveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		disapproveButton.frame = CGRectMake(0.0, 132.0, 64.0, 64.0);
		[disapproveButton setBackgroundImage:[UIImage imageNamed:@"verifyMoreButton_nonActive"] forState:UIControlStateNormal];
		[disapproveButton setBackgroundImage:[UIImage imageNamed:@"verifyMoreButton_Active"] forState:UIControlStateHighlighted];
		[disapproveButton addTarget:self action:@selector(_goDisprove) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:disapproveButton];
		
	} else {
		UIButton *upvoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		upvoteButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
		[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
		[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
		[upvoteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
		[_buttonHolderView addSubview:upvoteButton];
		
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flagButton.frame = CGRectMake(0.0, 78.0, 64.0, 64.0);
		[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
		[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
		[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		flagButton.hidden = _isVerify;
		[_buttonHolderView addSubview:flagButton];
	}
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


#pragma mark - Navigation
- (void)_goDone {
	NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n%@\n\n", _opponentVO.username);
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
//	if (_isVerify)
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VERIFY_TAB" object:nil];
	
//	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"preview_total"] intValue];
//	if (![HONAppDelegate isFollowingUser:_userVO.userID] && total < [HONAppDelegate profileSubscribeThreshold]) {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//															message:[NSString stringWithFormat:@"Want to subscribe to @%@'s updates?", _userVO.username]
//														   delegate:self
//												  cancelButtonTitle:@"No"
//												  otherButtonTitles:@"Yes", nil];
//		[alertView setTag:3];
//		[alertView show];
//		
//	} else
		[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goClose {
	if (_isVerify)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VERIFY_TAB" object:nil];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goUpvote {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	[self _upvoteChallenge:_opponentVO.userID];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"like_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"like_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 0 && [HONAppDelegate switchEnabledForKey:@"like_share"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"SHARE %@ with your friends?", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub"]
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:4];
		[alertView show];
	}
}

- (void)_goProfile {
//	NSLog(@"USER:[%@]", _userVO.dictionary);
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self _addBlur];
	_userProfileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	_userProfileViewController.userID = _opponentVO.userID;
	[self.view addSubview:_userProfileViewController.view];
}

- (void)_goFlag {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"Nevermind"//@"No"
											  otherButtonTitles:@"Yes, flag 'em!t", nil];
//											  otherButtonTitles:@"Yes, kick 'em out", nil];
//											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:0];
	[alertView show];
}

- (void)_goApprove {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - %@ Approve", ([HONAppDelegate switchEnabledForKey:@"verify_tab"]) ? @"Verify" : @"Follow"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	if ([HONAppDelegate switchEnabledForKey:@"autosubscribe"])
		[self _addFriend:_challengeVO.creatorVO.userID];
	
	[self _verifyUser:_challengeVO.creatorVO.userID asLegit:YES];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkLargeAnimation"]]];
	
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:[[HONAppDelegate infoForABTab] objectForKey:@"yay_format"], _opponentVO.username]
//														message:@""
//													   delegate:self
//											  cancelButtonTitle:@"Cancel"
//											  otherButtonTitles:@"Yes", nil];
//	[alertView setTag:([HONAppDelegate switchEnabledForKey:@"verify_tab"]) ? 1 : 3];
//	[alertView show];
}

- (void)_goDisprove {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Flag Sheet"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:[[HONAppDelegate infoForABTab] objectForKey:@"nay_format"], _opponentVO.username]
															 delegate:self
													cancelButtonTitle:@"Cancel"//@"Nevermind"//@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Yes", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
	
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:[[HONAppDelegate infoForABTab] objectForKey:@"nay_format"], _opponentVO.username]
//														message:@""
//													   delegate:self
//											  cancelButtonTitle:@"Cancel"
//											  otherButtonTitles:@"Yes", nil];
//	[alertView setTag:([HONAppDelegate switchEnabledForKey:@"verify_tab"]) ? 2 : 4];
//	[alertView show];
}

- (void)_goSkip {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - %@ Skip", ([HONAppDelegate switchEnabledForKey:@"verify_tab"]) ? @"Verify" : @"Follow"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	
	[self _goClose];
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


#pragma mark - UI Presentation
- (void)_addBlur {
//	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
//	_blurredImageView.alpha = 0.0;
//	[self.view addSubview:_blurredImageView];
//	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_blurredImageView.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}


#pragma mark - Data Tally
- (HONEmotionVO *)_emotionForParticipant:(HONOpponentVO *)opponentVO {
	NSLog(@"_emotionForParticipant:[%@]", opponentVO.subjectName);
	
	BOOL isEmotionFound = NO;
	HONEmotionVO *emotionVO;
	
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
//		NSLog(@"CHECKING:[%@]><[%@]", opponentVO.subjectName, vo.hastagName);
		if ([vo.hastagName isEqualToString:opponentVO.subjectName]) {
			emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
			isEmotionFound = YES;
			break;
		}
	}
	
	if (!isEmotionFound) {
		for (HONEmotionVO *vo in [HONAppDelegate replyEmotions]) {
//			NSLog(@"CHECKING:[%@]><[%@]", opponentVO.subjectName, vo.hastagName);
			if ([vo.hastagName isEqualToString:opponentVO.subjectName]) {
				emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
				isEmotionFound = YES;
				break;
			}
		}
	}
	
	return (emotionVO);
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Flag Sheet %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
		
		if (buttonIndex == 0) {
			[self _goClose];
			
		} else if (buttonIndex == 1) {
			[self _flagUser:_opponentVO.userID];
			[self.delegate snapPreviewViewControllerFlag:self opponent:_opponentVO forChallenge:_challengeVO];
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Flag %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _flagUser:_opponentVO.userID];
			[self.delegate snapPreviewViewControllerFlag:self opponent:_opponentVO forChallenge:_challengeVO];
		}
		
//	}  else if (alertView.tag == 1) {
//		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Verify Approve %@", (buttonIndex == 0) ? @"Cancel" : @" Confirm"]
//							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
//										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
//		
//		if (buttonIndex == 1) {
//			if ([HONAppDelegate switchEnabledForKey:@"autosubscribe"])
//				[self _addFriend:_challengeVO.creatorVO.userID];
//		
//			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:YES];
//		}
//		
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Verify Disprove %@", (buttonIndex == 0) ? @"Cancel" : @" Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:NO];
		}
//
//	} else if (alertView.tag == 3) {
//		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Follow Approve %@", (buttonIndex == 0) ? @"Cancel" : @" Confirm"]
//							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
//										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
//		
//		if (buttonIndex == 1) {
//			if ([HONAppDelegate switchEnabledForKey:@"autosubscribe"])
//				[self _addFriend:_challengeVO.creatorVO.userID];
//		
//			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:YES];
//		}
//		
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Follow Disprove %@", (buttonIndex == 0) ? @"Cancel" : @" Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			if ([HONAppDelegate switchEnabledForKey:@"autosubscribe"])
				[self _addFriend:_challengeVO.creatorVO.userID];
			
			[self _verifyUser:_challengeVO.creatorVO.userID asLegit:NO];
		}

	} else if (alertView.tag == 5) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Share %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																									@"image"			: [HONAppDelegate avatarImage],
																									@"url"				: @"",
																									@"mp_event"			: @"Volley Preview - Share",
																									@"view_controller"	: self}];
		}
	}
}


@end