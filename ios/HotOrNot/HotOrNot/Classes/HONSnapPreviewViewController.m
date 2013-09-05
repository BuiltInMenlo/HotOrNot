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

#import "HONSnapPreviewViewController.h"
#import "HONImageLoadingView.h"
#import "HONUserVO.h"

@interface HONSnapPreviewViewController ()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIView *controlsHolderView;
@property (nonatomic, strong) UIImageView *uploadingImageView;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic) BOOL isVerify;
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
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:userResult];
			_ageLabel.text = ([userVO.birthday timeIntervalSince1970] == 0.0) ? @"" : [NSString stringWithFormat:@"%d", [HONAppDelegate ageForDate:userVO.birthday]];
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
	
	
	UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 11.0, kSnapThumbDim, kSnapThumbDim)];
	[challengeImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _opponentVO.avatarURL]] placeholderImage:nil];
	[self.view addSubview:challengeImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 19.0, 200.0, 20.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:@"@%@", _opponentVO.username];
	[self.view addSubview:nameLabel];
	
	_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(145.0, 19.0, 150.0, 20.0)];
	_ageLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
	_ageLabel.textAlignment = NSTextAlignmentRight;
	_ageLabel.textColor = [UIColor whiteColor];
	_ageLabel.backgroundColor = [UIColor clearColor];
	_ageLabel.text = ([_opponentVO.birthday timeIntervalSince1970] == 0.0) ? @"" : [NSString stringWithFormat:@"%d", [HONAppDelegate ageForDate:_opponentVO.birthday]];
	[self.view addSubview:_ageLabel];
	
	_controlsHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	_controlsHolderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
	_controlsHolderView.hidden = YES;
	_controlsHolderView.alpha = 0.0;
	[self.view addSubview:_controlsHolderView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = _controlsHolderView.frame;
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
	[_controlsHolderView addSubview:closeButton];
	
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
	
	//[self _retrieveUser:_opponentVO.userID];
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
	[self.delegate snapPreviewViewControllerProfile:self opponent:_opponentVO forChallenge:_challengeVO];
}

- (void)_goFlag {
	[self.delegate snapPreviewViewControllerFlag:self opponent:_opponentVO forChallenge:_challengeVO];
}


@end