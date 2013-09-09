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
@property (nonatomic, strong) UIView *controlsHolderView;
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
	
	_controlsHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	_controlsHolderView.hidden = YES;
	_controlsHolderView.alpha = 0.0;
	[self.view addSubview:_controlsHolderView];
	
	_profileHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	_profileHolderView.hidden = YES;
	_profileHolderView.alpha = 0.0;
	[self.view addSubview:_profileHolderView];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(105.0, 50.0, 109.0, 109.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_opponentVO.avatarURL] placeholderImage:nil];
	[_controlsHolderView addSubview:avatarImageView];
	
	BOOL isVerified = ([[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] < 0);
	UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isVerified) ? @"verified" : @"notVerified"]];
	verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 200.0, 72.0);
	[_controlsHolderView addSubview:verifiedImageView];
	
	_nameAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 200.0, 200.0, 20.0)];
	_nameAgeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
	_nameAgeLabel.textColor = [UIColor whiteColor];
	_nameAgeLabel.textAlignment = NSTextAlignmentCenter;
	_nameAgeLabel.backgroundColor = [UIColor clearColor];
	_nameAgeLabel.text = [NSString stringWithFormat:@"@%@, %d", _opponentVO.username, [HONAppDelegate ageForDate:_opponentVO.birthday]];
	[_controlsHolderView addSubview:_nameAgeLabel];
	
	UIView *buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 42.0, 320.0, 84.0)];
	[_controlsHolderView addSubview:buttonHolderView];
	
	UIButton *upvoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	upvoteButton.frame = CGRectMake(18.0, 0.0, 84.0, 84.0);
	[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[upvoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
	[upvoteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:upvoteButton];
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(116.0, 0.0, 84.0, 84.0);
	[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive"] forState:UIControlStateNormal];
	[profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_Active"] forState:UIControlStateHighlighted];
	[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:profileButton];
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(217.0, 0.0, 84.0, 84.0);
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:flagButton];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_subscribersLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 230.0, 260.0, 16.0)];
	_subscribersLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
	_subscribersLabel.textColor = [UIColor whiteColor];
	_subscribersLabel.backgroundColor = [UIColor clearColor];
	_subscribersLabel.text = [NSString stringWithFormat:@"%@ subscriber%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
	[_profileHolderView addSubview:_subscribersLabel];
	
	_volleysLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 260.0, 260.0, 16.0)];
	_volleysLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
	_volleysLabel.textColor = [UIColor whiteColor];
	_volleysLabel.backgroundColor = [UIColor clearColor];
	_volleysLabel.text = [NSString stringWithFormat:@"%@ volley%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]], (_userVO.pics == 1) ? @"" : @"s"];
	[_profileHolderView addSubview:_volleysLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 290.0, 260.0, 16.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
	_likesLabel.textColor = [UIColor whiteColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
	[_profileHolderView addSubview:_likesLabel];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = _controlsHolderView.frame;
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
	[_profileHolderView addSubview:closeButton];
	
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
	_controlsHolderView.hidden = NO;
	
	_imageView.image = [_imageView.image applyBlurWithRadius:5.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
	[UIView animateWithDuration:0.33 animations:^(void) {
		_controlsHolderView.alpha = 1.0;
	}];
}


#pragma mark - Navigation
- (void)_goClose {
	[self.delegate snapPreviewViewControllerClose:self];
}

- (void)_goUpvote {
	[self.delegate snapPreviewViewControllerUpvote:self opponent:_opponentVO forChallenge:_challengeVO];
}

- (void)_goProfile {
//	[self.delegate snapPreviewViewControllerProfile:self opponent:_opponentVO forChallenge:_challengeVO];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_controlsHolderView.alpha = 0.0;
	}];
	
	_profileHolderView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_profileHolderView.alpha = 1.0;
	}];
	
	[self _profileTransition];
}

- (void)_goFlag {
	[self.delegate snapPreviewViewControllerFlag:self opponent:_opponentVO forChallenge:_challengeVO];
}


#pragma mark - UI Presentation
- (void)_profileTransition {
	//[self _retrieveChallenges];
}


@end