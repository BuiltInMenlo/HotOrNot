//
//  HONSnapPreviewViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"

#import "HONSnapPreviewViewController.h"
#import "HONImageLoadingView.h"
#import "HONUserVO.h"
#import "HONHeaderView.h"

@interface HONSnapPreviewViewController () <HONSnapPreviewViewControllerDelegate>
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *releaseHolderView;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *profileHolderView;
@property (nonatomic, strong) UIImageView *uploadingImageView;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) BOOL isVerify;

@property (nonatomic, strong) UIView *avatarHolderView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *subscribersLabel;
@property (nonatomic, strong) UILabel *volleysLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIView *gridHolderView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic) int challengeCounter;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isRoot;
@end


@implementation HONSnapPreviewViewController

@synthesize delegate = _delegate;

- (id)initWithChallenge:(HONChallengeVO *)vo asRoot:(BOOL)isFirst {
	if ((self = [super init])) {
		_challengeVO = vo;
		_isVerify = YES;
		_isRoot = isFirst;
	}
	
	return (self);
}

- (id)initWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO asRoot:(BOOL)isFirst {
	if ((self = [super init])) {
		_opponentVO = opponentVO;
		_challengeVO = challengeVO;
		_isVerify = NO;
		_isRoot = isFirst;
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
- (void)_retrieveUser:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[NSString stringWithFormat:@"%d", userID], @"userID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			_userVO = [HONUserVO userWithDictionary:userResult];
			
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
			
			_subscribersLabel.text = [NSString stringWithFormat:@"%@ subscriber%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
			_volleysLabel.text = [NSString stringWithFormat:@"%@ volley%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]], (_userVO.pics == 1) ? @"" : @"s"];
			_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_reloadVerifyImage {
	[_imageView removeFromSuperview];
	_imageView = nil;
	
	__weak typeof(self) weakSelf = self;
	
	CGSize imageSize = ([HONAppDelegate isRetina5]) ? CGSizeMake(426.0, 568.0) : CGSizeMake(360.0, 480.0);
	NSMutableString *imageURL = [_opponentVO.avatarURL mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"_o.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	CGRect frame = CGRectMake((imageSize.width - 320.0) * -0.5, 0.0, imageSize.width, imageSize.height);
	
	NSLog(@"VERIFY RELOADING:[%@]", imageURL);
	
	_imageView = [[UIImageView alloc] initWithFrame:frame];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
														cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
						  [weakSelf.uploadingImageView stopAnimating];
						  weakSelf.imageView.image = image;
						  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.imageView.alpha = 1.0; } completion:nil];
					  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	[_imageHolderView addSubview:_imageView];
}

- (void)_reloadChallengeImage {
	[_imageView removeFromSuperview];
	_imageView = nil;
	
	NSString *imageURL = [NSString stringWithFormat:@"%@_o.jpg", _opponentVO.imagePrefix];
	CGSize imageSize = ([HONAppDelegate isRetina5]) ? CGSizeMake(426.0, 568.0) : CGSizeMake(360.0, 480.0);
	CGRect frame = CGRectMake((imageSize.width - 320.0) * -0.5, 0.0, imageSize.width, imageSize.height);
	
	NSLog(@"CHALLENGE RELOADING:[%@]", imageURL);
	
	__weak typeof(self) weakSelf = self;
	_imageView = [[UIImageView alloc] initWithFrame:frame];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
														cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
						  [weakSelf.uploadingImageView stopAnimating];
						  weakSelf.imageView.image = image;
						  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.imageView.alpha = 1.0; } completion:nil];
					  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	[_imageHolderView addSubview:_imageView];
}

- (void)_loadForVerify {
	__weak typeof(self) weakSelf = self;
	self.view.backgroundColor = [UIColor blackColor];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//	NSTimeInterval diff = [_challengeVO.addedDate timeIntervalSinceDate:[dateFormat dateFromString:@"2013-08-20 00:00:00"]];
//	BOOL isOriginalImageAvailable = ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue] >= 11595 && diff > 0);
//	NSString *imageURL = (isOriginalImageAvailable) ? _opponentVO.imagePrefix : _opponentVO.avatarURL;
//	CGRect frame = (isOriginalImageAvailable) ? CGRectMake(((self.view.frame.size.height * ratio) - self.view.frame.size.width) * -0.5, 0.0, (self.view.frame.size.height * ratio), self.view.frame.size.height) : CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 320.0) * 0.5, 320.0, 320.0);//CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim);
	
	
	NSMutableString *imageURL = [_opponentVO.avatarURL mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	CGRect frame = CGRectMake(0.0, (568.0 - self.view.frame.size.height) * -0.5, 320.0, 568.0);
	
	NSLog(@"VERIFY LOADING:[%@]", imageURL);
	
	_imageView = [[UIImageView alloc] initWithFrame:frame];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
						  [weakSelf.uploadingImageView stopAnimating];
						  weakSelf.imageView.image = image;
						  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.imageView.alpha = 1.0; } completion:nil];
					  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
						  [weakSelf _reloadVerifyImage];
					  }];
	[_imageHolderView addSubview:_imageView];
	
//	NSLog(@"VERIFY -- ORIGINAL:[%d] DIFF:[%f] IMG:[%@] DATA:[%@]\n", isOriginalImageAvailable, diff, imageURL, _opponentVO.dictionary);
}

- (void)_loadForChallenge {
	__weak typeof(self) weakSelf = self;
	self.view.backgroundColor = [UIColor blackColor];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//	NSTimeInterval diff = [_opponentVO.joinedDate timeIntervalSinceDate:[dateFormat dateFromString:@"2013-08-03 00:00:00"]];
//	BOOL isOriginalImageAvailable = ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue] >= 10500 && diff > 0);
//	NSString *imageURL = [NSString stringWithFormat:@"%@_%@.jpg", _opponentVO.imagePrefix, (isOriginalImageAvailable) ? @"o" : @"l"];
//	CGRect frame = (isOriginalImageAvailable) ? CGRectMake(((self.view.frame.size.height * 0.75) - self.view.frame.size.width) * -0.5, 0.0, (self.view.frame.size.height * 0.75), self.view.frame.size.height) : CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 320.0) * 0.5, 320.0, 320.0);//CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim);

	NSString *imageURL = [NSString stringWithFormat:@"%@Large_640x1136.jpg", _opponentVO.imagePrefix];
	CGRect frame = CGRectMake(0.0, (568.0 - self.view.frame.size.height) * -0.5, 320.0, 568.0);
	
	NSLog(@"CHALLENGE LOADING:[%@]", imageURL);
	
	_imageView = [[UIImageView alloc] initWithFrame:frame];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
						  [weakSelf.uploadingImageView stopAnimating];
						  weakSelf.imageView.image = image;
						  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.imageView.alpha = 1.0; } completion:nil];
					  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
						  [weakSelf _reloadChallengeImage];
					  }];
	[_imageHolderView addSubview:_imageView];
	
//	NSLog(@"CHALLENGE -- ORIGINAL:[%d] DIFF:[%f] IMG:[%@] DATA:[%@]\n", isOriginalImageAvailable, diff, imageURL, _opponentVO.dictionary);
}


- (void)_retrieveChallenges {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"%d", 9] forKey:@"action"];
	[params setObject:@"N" forKey:@"isPrivate"];
	[params setObject:_userVO.username forKey:@"username"];
	[params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"p"];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *challengesResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengesResult);
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [challengesResult objectAtIndex:0]);
			
			_challenges = [NSMutableArray array];
			
			for (NSDictionary *serverList in challengesResult) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					if (vo.expireSeconds != 0)
						[_challenges addObject:vo];
				}
			}
			
			_isRefreshing = NO;
//			[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
			
			_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, 500.0 + (kSnapMediumDim * ([_challenges count] / 5))));
			[self _makeGrid];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
	}];
}

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
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
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
	
	NSLog(@"PARAMS:[%@]", params);
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], voteResult);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
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
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_removeFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIRemoveFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIRemoveFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	//NSLog(@"VERSION:[%d][%@]", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
	
	if (_isVerify)
		_opponentVO = _challengeVO.creatorVO;
	
	_uploadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, ([UIScreen mainScreen].bounds.size.height - 22.0), 54.0, 14.0)];
	_uploadingImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										   [UIImage imageNamed:@"cameraUpload_002"],
										   [UIImage imageNamed:@"cameraUpload_003"], nil];
	_uploadingImageView.animationDuration = 0.5f;
	_uploadingImageView.animationRepeatCount = 0;
	[_uploadingImageView startAnimating];
	[self.view addSubview:_uploadingImageView];
	
	_imageHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_imageHolderView];
	
	if (_isVerify)
		[self _loadForVerify];
	
	else
		[self _loadForChallenge];
	
	BOOL isFriend = NO;
	for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
		if (vo.userID == _userVO.userID) {
			isFriend = YES;
			break;
		}
	}
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.pagingEnabled = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_scrollView addGestureRecognizer:lpGestureRecognizer];
	
	_profileHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	_profileHolderView.hidden = YES;
	_profileHolderView.alpha = 0.0;
	[_scrollView addSubview:_profileHolderView];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = self.view.frame;
//	_closeButton.backgroundColor = [UIColor greenColor];
	_closeButton.hidden = YES;
	[_closeButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchDown];
	[_scrollView addSubview:_closeButton];
	
	_buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 23.0, 320.0, 164.0)];
	_buttonHolderView.alpha = 0.0;
	[_scrollView addSubview:_buttonHolderView];
	
	UIButton *upvoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	upvoteButton.frame = CGRectMake(24.0, 0.0, 74.0, 74.0);
	[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
	[upvoteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
	[_buttonHolderView addSubview:upvoteButton];
	
	UIButton *profileSubscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileSubscribeButton.frame = CGRectMake(121.0, 0.0, 74.0, 74.0);
	[profileSubscribeButton setBackgroundImage:[UIImage imageNamed:@"subscribeButton_nonActive"] forState:UIControlStateNormal];
	[profileSubscribeButton setBackgroundImage:[UIImage imageNamed:@"subscribeButton_nonActive"] forState:UIControlStateHighlighted];
	profileSubscribeButton.alpha = 0.33;
	[_buttonHolderView addSubview:profileSubscribeButton];
	
	if (_isRoot) {
		[profileSubscribeButton addTarget:self action:@selector(_goSubscribeProfile) forControlEvents:UIControlEventTouchUpInside];
		[profileSubscribeButton setBackgroundImage:[UIImage imageNamed:@"subscribeButton_Active"] forState:UIControlStateHighlighted];
		profileSubscribeButton.alpha = 1.0;
	}
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(222.0, 0.0, 74.0, 74.0);
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	[_buttonHolderView addSubview:flagButton];
	
	_avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 225.0)];
	_avatarHolderView.clipsToBounds = YES;
	[_profileHolderView addSubview:_avatarHolderView];
	
	NSMutableString *imageURL = [_opponentVO.avatarURL mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	CGRect frame = CGRectMake(0.0, -185.0, 320.0, 568.0);
	
	NSLog(@"PROFILE LOADING:[%@]", imageURL);
	
	__weak typeof(self) weakSelf = self;
	_avatarImageView = [[UIImageView alloc] initWithFrame:frame];
	_avatarImageView.alpha = 0.0;
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
															  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
								weakSelf.avatarImageView.image = image;
								[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.avatarImageView.alpha = 1.0; } completion:nil];
							} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
								[weakSelf _reloadProfileImage];
							}];
	[_avatarHolderView addSubview:_avatarImageView];
	
	UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUser"]];
	verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 114.0, 46.0);
	verifiedImageView.hidden = ([HONAppDelegate ageForDate:_userVO.birthday] > 19);
	[_avatarImageView addSubview:verifiedImageView];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_subscribersLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 260.0, 260.0, 28.0)];
	_subscribersLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
	_subscribersLabel.textColor = [UIColor whiteColor];
	_subscribersLabel.backgroundColor = [UIColor clearColor];
	[_profileHolderView addSubview:_subscribersLabel];
	
	_volleysLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 312.0, 260.0, 28.0)];
	_volleysLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
	_volleysLabel.textColor = [UIColor whiteColor];
	_volleysLabel.backgroundColor = [UIColor clearColor];
	[_profileHolderView addSubview:_volleysLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 364.0, 260.0, 28.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
	_likesLabel.textColor = [UIColor whiteColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	[_profileHolderView addSubview:_likesLabel];
	
	[self _retrieveUser:_opponentVO.userID];
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


#pragma mark - Public APIs
- (void)showControls {
	_imageView.image = [_imageView.image applyBlurWithRadius:16.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.75] saturationDeltaFactor:1.0 maskImage:nil];
	
	_closeButton.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_buttonHolderView.alpha = 1.0;
	}];
}


#pragma mark - Navigation
- (void)_goDone {
	[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goUpvote {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	[self _upvoteChallenge:_opponentVO.userID];
	[self.delegate snapPreviewViewControllerUpvote:self opponent:_opponentVO forChallenge:_challengeVO];
}

- (void)_goSubscribeProfile {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Subscribe / Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	BOOL isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);

	BOOL isFriend = NO;
	if (!isUser) {
		for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
			if (vo.userID == _userVO.userID) {
				isFriend = YES;
				break;
			}
		}
	}

	UIActionSheet *actionSheet;
	if (isUser) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@""
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Profile", nil];
		
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@""
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Profile", (isFriend) ? @"Unsubscribe" : @"Subscribe", nil];
	}
		
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet showInView:self.view];
}

- (void)_goProfile {
//	NSLog(@"USER:[%@]", _userVO.dictionary);
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	[_closeButton removeFromSuperview];
	
	UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 7.0, 7.0);
	verifiedImageView.hidden = ([HONAppDelegate ageForDate:_userVO.birthday] > 19);
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:[NSString stringWithFormat:@"%@, %d", _userVO.username, [HONAppDelegate ageForDate:_userVO.birthday]]];
	[headerView addButton:verifiedImageView];
	[headerView addButton:doneButton];
	headerView.alpha = 0.0;
	[self.view addSubview:headerView];
	
	
	_profileHolderView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_buttonHolderView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.33 animations:^(void) {
			headerView.alpha = 1.0;
			_profileHolderView.alpha = 1.0;
		}];
	}];
	
	
	BOOL isFriend = NO;
	for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
		if (vo.userID == _userVO.userID) {
			isFriend = YES;
			break;
		}
	}
	
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _userVO.userID) {
		_subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_subscribeButton.frame = CGRectMake(0.0, 0.0, 95.0, 44.0);
		[_subscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_subscribeButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
		[_subscribeButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
		[_subscribeButton setTitle:(isFriend) ? @"Unsubscribe" : @"Subscribe" forState:UIControlStateNormal];
		[_subscribeButton addTarget:self action:(isFriend) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		_subscribeButton.frame = CGRectMake(0.0, 0.0, (isFriend) ? 95.0 : 73.0, 44.0);
		
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
		[flagButton setTitleColor:[UIColor colorWithRed:0.733 green:0.380 blue:0.392 alpha:1.0] forState:UIControlStateNormal];
		[flagButton setTitleColor:[UIColor colorWithRed:0.325 green:0.169 blue:0.174 alpha:1.0] forState:UIControlStateHighlighted];
		[flagButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
		[flagButton setTitle:@"Flag" forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		
		UIToolbar *footerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
		[footerToolbar setBarStyle:UIBarStyleBlackTranslucent];
		[footerToolbar setItems:[NSArray arrayWithObjects:
								  [[UIBarButtonItem alloc] initWithCustomView:_subscribeButton],
								  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
								  [[UIBarButtonItem alloc] initWithCustomView:flagButton], nil]];
		[self.view addSubview:footerToolbar];
	}
	
	
	[self _retrieveChallenges];
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
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:0];
	[alertView show];
}

- (void)_goSubscribe {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Subscribe"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will receive Volley updates from @%@", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:1];
	[alertView show];
}

- (void)_goUnsubscribe {
	[[Mixpanel sharedInstance] track:@"Volley Preview - Unsubscribe"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will no longer receive Volley updates from @%@", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:2];
	[alertView show];
	
}


#pragma mark - UI Presentation
- (void)_reloadProfileImage {
	__weak typeof(self) weakSelf = self;
	
	CGSize imageSize = ([HONAppDelegate isRetina5]) ? CGSizeMake(426.0, 568.0) : CGSizeMake(360.0, 480.0);
	NSMutableString *imageURL = [_opponentVO.avatarURL mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"_o.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	CGRect frame = CGRectMake((imageSize.width - 320.0) * -0.5, -114.0, imageSize.width, imageSize.height);
	
	NSLog(@"PROFILE RELOADING:[%@]", imageURL);
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:frame];
	_avatarImageView.alpha = 0.0;
	[_avatarHolderView addSubview:_avatarImageView];
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
															  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
								weakSelf.avatarImageView.image = image;
								[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.avatarImageView.alpha = 1.0; } completion:nil];
							} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
							}];
}

- (void)_makeGrid {
	_gridHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 429.0, 320.0, kSnapMediumDim * (([_challenges count] / 4) + 1))];
	_gridHolderView.backgroundColor = [UIColor clearColor];
	[_scrollView addSubview:_gridHolderView];
	
	_challengeCounter = 0;
	for (HONChallengeVO *vo in _challenges) {
		CGPoint pos = CGPointMake(kSnapMediumDim * (_challengeCounter % 4), kSnapMediumDim * (_challengeCounter / 4));
		
		UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapMediumDim, kSnapMediumDim)];
		[_gridHolderView addSubview:imageHolderView];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
		imageView.userInteractionEnabled = YES;
		[imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Small_160x160.jpg", vo.creatorVO.imagePrefix]] placeholderImage:nil];
		[imageHolderView addSubview:imageView];
		
		_challengeCounter++;
	}
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_scrollView];
		
		HONChallengeVO *challengeVO = nil;
		HONOpponentVO *opponentVO = nil;
		
		if (CGRectContainsPoint(_gridHolderView.frame, touchPoint)) {
			int col = touchPoint.x / (kSnapMediumDim + 1.0);
			int row = (touchPoint.y - _gridHolderView.frame.origin.y) / (kSnapMediumDim + 1.0);
			
			if ((row * 4) + col < [_challenges count]) {
				challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:(row * 4) + col];
				opponentVO = challengeVO.creatorVO;
			}
		}
		
		if (opponentVO != nil) {
			[[Mixpanel sharedInstance] track:@"Profile - Show Photo Detail"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
											  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
											  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent",
											  nil]];
			
			_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO asRoot:NO];
			_snapPreviewViewController.delegate = self;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
		}
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
//		[[Mixpanel sharedInstance] track:@"Timeline Details - Hide Photo Detail"
//							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
//										  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
//										  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent",
//										  nil]];
		
		[_snapPreviewViewController showControls];
	}
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	NSLog(@"fgdgdgdddddgd");
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 28.0, ([UIScreen mainScreen].bounds.size.height * 0.5) + 32.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
	
	[self _upvoteChallenge:_opponentVO.userID];
}

- (void)snapPreviewViewControllerFlag:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Volley Preview - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:0];
	[alertView show];
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
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
	
	} else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			[self _addFriend:_userVO.userID];
			[_subscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Volley Preview - Unsubscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _removeFriend:_userVO.userID];
			[_subscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	BOOL isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	
	BOOL isFriend = NO;
	if (!isUser) {
		for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
			if (vo.userID == _userVO.userID) {
				isFriend = YES;
				break;
			}
		}
	}
	
	if (buttonIndex == 0) {
		[self _goProfile];
	
	} else if (buttonIndex == 1) {
		if (!isUser) {
			if (isFriend)
				[self _goUnsubscribe];
			
			else
				[self _goSubscribe];
		}
	
	} else {
		[[Mixpanel sharedInstance] track:@"Volley Preview - Subscribe / Profile Cancel"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	}
}


@end