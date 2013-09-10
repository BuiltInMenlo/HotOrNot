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

@interface HONSnapPreviewViewController ()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *profileHolderView;
@property (nonatomic, strong) UIImageView *uploadingImageView;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) BOOL isVerify;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameAgeLabel;
@property (nonatomic, strong) UILabel *subscribersLabel;
@property (nonatomic, strong) UILabel *volleysLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIView *gridHolderView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic) int challengeCounter;
@property (nonatomic) BOOL isRefreshing;
@end


@implementation HONSnapPreviewViewController

@synthesize delegate = _delegate;

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_isVerify = YES;
	}
	
	return (self);
}

- (id)initWithOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if ((self = [super init])) {
		_opponentVO = opponentVO;
		_challengeVO = challengeVO;
		_isVerify = NO;
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
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
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
	NSLog(@"VERIFY RELOADING:[%@]", _opponentVO.avatarURL);
	[_imageView removeFromSuperview];
	_imageView = nil;
	
	__weak typeof(self) weakSelf = self;
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 320.0) * 0.5, 320.0, 320.0)];//CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim)];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_opponentVO.avatarURL]
														cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
						  [weakSelf.uploadingImageView stopAnimating];
						  weakSelf.imageView.image = image;
						  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.imageView.alpha = 1.0; } completion:nil];
					  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	[_imageHolderView addSubview:_imageView];
}

- (void)_reloadChallengeImage {
	NSLog(@"RELOADING:[%@]", [NSString stringWithFormat:@"%@_l.jpg", _opponentVO.imagePrefix]);
	[_imageView removeFromSuperview];
	_imageView = nil;
	
	__weak typeof(self) weakSelf = self;
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 320.0) * 0.5, 320.0, 320.0)];//CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim)];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _opponentVO.imagePrefix]]
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
	NSTimeInterval diff = [_challengeVO.addedDate timeIntervalSinceDate:[dateFormat dateFromString:@"2013-08-20 00:00:00"]];
	BOOL isOriginalImageAvailable = ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue] >= 11595 && diff > 0);
	
	float ratio = 0.56338028169014;//([HONAppDelegate isRetina5]) ? 0.56338028169014 : 0.75;
	NSString *imageURL = (isOriginalImageAvailable) ? _opponentVO.imagePrefix : _opponentVO.avatarURL;
	CGRect frame = (isOriginalImageAvailable) ? CGRectMake(((self.view.frame.size.height * ratio) - self.view.frame.size.width) * -0.5, 0.0, (self.view.frame.size.height * ratio), self.view.frame.size.height) : CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 320.0) * 0.5, 320.0, 320.0);//CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim);
	
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
	
	NSLog(@"VERIFY -- ORIGINAL:[%d] DIFF:[%f] IMG:[%@] DATA:[%@]\n", isOriginalImageAvailable, diff, imageURL, _opponentVO.dictionary);
}

- (void)_loadForChallenge {
	__weak typeof(self) weakSelf = self;
	self.view.backgroundColor = [UIColor blackColor];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSTimeInterval diff = [_opponentVO.joinedDate timeIntervalSinceDate:[dateFormat dateFromString:@"2013-08-03 00:00:00"]];
	BOOL isOriginalImageAvailable = ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue] >= 10500 && diff > 0);
	
	NSString *imageURL = [NSString stringWithFormat:@"%@_%@.jpg", _opponentVO.imagePrefix, (isOriginalImageAvailable) ? @"o" : @"l"];
	CGRect frame = (isOriginalImageAvailable) ? CGRectMake(((self.view.frame.size.height * 0.75) - self.view.frame.size.width) * -0.5, 0.0, (self.view.frame.size.height * 0.75), self.view.frame.size.height) : CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 320.0) * 0.5, 320.0, 320.0);//CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim);
	
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
	
	NSLog(@"CHALLENGE -- ORIGINAL:[%d] DIFF:[%f] IMG:[%@] DATA:[%@]\n", isOriginalImageAvailable, diff, imageURL, _opponentVO.dictionary);
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
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [challengesResult objectAtIndex:0]);
			
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	//NSLog(@"VERSION:[%d][%@]", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
	
	//if (_challengeVO != nil)
	if (_isVerify)
		_opponentVO = _challengeVO.creatorVO;
	
	_uploadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, ([UIScreen mainScreen].bounds.size.height - 45.0), 54.0, 14.0)];
	_uploadingImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										   [UIImage imageNamed:@"cameraUpload_002"],
										   [UIImage imageNamed:@"cameraUpload_003"], nil];
	_uploadingImageView.animationDuration = 0.5f;
	_uploadingImageView.animationRepeatCount = 0;
	[_uploadingImageView startAnimating];
	[self.view addSubview:_uploadingImageView];
	
	_imageHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_imageHolderView];
	
	//if (_challengeVO == nil)
	if (_isVerify)
		[self _loadForVerify];
	
	else
		[self _loadForChallenge];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.pagingEnabled = NO;
//	_scrollView.delegate = self;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = self.view.frame;
	[_closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
	[_scrollView addSubview:_closeButton];
	
	_profileHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	_profileHolderView.hidden = YES;
	_profileHolderView.alpha = 0.0;
	[_scrollView addSubview:_profileHolderView];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(105.0, 50.0, 109.0, 109.0)];
	[_avatarImageView setImageWithURL:[NSURL URLWithString:_opponentVO.avatarURL] placeholderImage:nil];
	_avatarImageView.alpha = 0.0;
	[_scrollView addSubview:_avatarImageView];
	
	BOOL isVerified = ([[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] < 0);
	UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isVerified) ? @"verified" : @"notVerified"]];
	verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 100.0, 22.0);
	[_avatarImageView addSubview:verifiedImageView];
	
	_nameAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 200.0, 180.0, 20.0)];
	_nameAgeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
	_nameAgeLabel.textColor = [UIColor whiteColor];
	_nameAgeLabel.textAlignment = NSTextAlignmentCenter;
	_nameAgeLabel.backgroundColor = [UIColor clearColor];
	[_scrollView addSubview:_nameAgeLabel];
	
	_buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 42.0, 320.0, 84.0)];
	_buttonHolderView.alpha = 0.0;
	[_scrollView addSubview:_buttonHolderView];
	
	UIButton *upvoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	upvoteButton.frame = CGRectMake(18.0, 0.0, 84.0, 84.0);
	[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
	[upvoteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
	[_buttonHolderView addSubview:upvoteButton];
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(116.0, 0.0, 84.0, 84.0);
	[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive"] forState:UIControlStateNormal];
	[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_Active"] forState:UIControlStateHighlighted];
	[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[_buttonHolderView addSubview:profileButton];
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(217.0, 0.0, 84.0, 84.0);
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	[_buttonHolderView addSubview:flagButton];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_subscribersLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 230.0, 260.0, 16.0)];
	_subscribersLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
	_subscribersLabel.textColor = [UIColor whiteColor];
	_subscribersLabel.backgroundColor = [UIColor clearColor];
	[_profileHolderView addSubview:_subscribersLabel];
	
	_volleysLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 260.0, 260.0, 16.0)];
	_volleysLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
	_volleysLabel.textColor = [UIColor whiteColor];
	_volleysLabel.backgroundColor = [UIColor clearColor];
	[_profileHolderView addSubview:_volleysLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 290.0, 260.0, 16.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
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
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(250.0, 20.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	_imageView.image = [_imageView.image applyBlurWithRadius:5.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
	_nameAgeLabel.text = [NSString stringWithFormat:@"@%@, %d", _opponentVO.username, [HONAppDelegate ageForDate:_opponentVO.birthday]];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_buttonHolderView.alpha = 1.0;
		_avatarImageView.alpha = 1.0;
	}];
}


#pragma mark - Navigation
- (void)_goClose {
	[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goDone {
	[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goUpvote {
	[self.delegate snapPreviewViewControllerUpvote:self opponent:_opponentVO forChallenge:_challengeVO];
}

- (void)_goProfile {
	[[Mixpanel sharedInstance] track:@"Timeline - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	_profileHolderView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_buttonHolderView.alpha = 0.0;
		_profileHolderView.alpha = 1.0;
	}];
	
	[_closeButton removeFromSuperview];
	[self _retrieveChallenges];
}

- (void)_goFlag {
	[self.delegate snapPreviewViewControllerFlag:self opponent:_opponentVO forChallenge:_challengeVO];
}


#pragma mark - UI Presentation
- (void)_makeGrid {
	_gridHolderView = [[UIView alloc] initWithFrame:CGRectMake(11.0, 400.0, 320.0, (kSnapMediumDim + 1.0) * (([_challenges count] / 4) + 1))];
	_gridHolderView.backgroundColor = [UIColor clearColor];
	[_scrollView addSubview:_gridHolderView];
	
	_challengeCounter = 0;
	for (HONChallengeVO *vo in _challenges) {
		CGPoint pos = CGPointMake((kSnapMediumDim + 1.0) * (_challengeCounter % 4), (kSnapMediumDim + 1.0) * (_challengeCounter / 4));
		
		UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapMediumDim, kSnapMediumDim)];
		[_gridHolderView addSubview:imageHolderView];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
		imageView.userInteractionEnabled = YES;
		[imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", vo.creatorVO.imagePrefix]] placeholderImage:nil];
		[imageHolderView addSubview:imageView];
		
		_challengeCounter++;
	}
}


@end