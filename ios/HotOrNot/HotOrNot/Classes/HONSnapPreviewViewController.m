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
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *ageLabel;
@end


@implementation HONSnapPreviewViewController

- (id)initWithImageURL:(NSString *)url {
	if ((self = [super init])) {
		_url = url;
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
	}
	
	return (self);
}

- (id)initWithOpponent:(HONOpponentVO *)vo {
	if ((self = [super init])) {
		_opponentVO = vo;
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
- (void)_retrieveUser:(NSString *)username {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 8], @"action",
							username, @"username",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:userResult];
			_ageLabel.text = [NSString stringWithFormat:@"%d", [HONAppDelegate ageForDate:userVO.birthday]];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	//NSLog(@"VERSION:[%d][%@]", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
	
	__weak typeof(self) weakSelf = self;
	self.view.backgroundColor = [UIColor blackColor];
	//self.view.frame = CGRectOffset(self.view.frame, 0.0, -(20.0));
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSTimeInterval diff = [(_challengeVO != nil) ? _challengeVO.addedDate : _opponentVO.joinedDate timeIntervalSinceDate:[dateFormat dateFromString:@"2013-08-03 00:00:00"]];
	BOOL isOriginalImageAvailable = ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue] >= 10500 && diff > 0);
	BOOL isCreator = (_challengeVO.creatorVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	
	NSLog(@"ORIGINAL:[%d] DIFF:[%f][%@]\n", isOriginalImageAvailable, diff, _opponentVO.dictionary);
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(128.0, ([UIScreen mainScreen].bounds.size.height - 64.0) * 0.5)];
	[self.view addSubview:imageLoadingView];
	
	CGRect frame = (isOriginalImageAvailable) ? CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) : CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim);
	_imageView = [[UIImageView alloc] initWithFrame:frame];
	_imageView.alpha = 0.0;
	
	
	NSString *imageURL;
	NSString *avatarURL;
	NSString *username;
	
	if (_challengeVO != nil) {
		imageURL = [NSString stringWithFormat:@"%@_%@.jpg", (isCreator && _challengeVO.statusID == 4) ? ((HONOpponentVO *)[_challengeVO.challengers lastObject]).imagePrefix : _challengeVO.creatorVO.imagePrefix, (isOriginalImageAvailable) ? @"o" : @"l"];
		avatarURL = [NSString stringWithFormat:@"%@", (isCreator) ? ((HONOpponentVO *)[_challengeVO.challengers lastObject]).avatarURL : _challengeVO.creatorVO.avatarURL];
		username = [NSString stringWithFormat:@"@%@", (isCreator) ? ((HONOpponentVO *)[_challengeVO.challengers lastObject]).username : _challengeVO.creatorVO.username];
		
		[self _retrieveUser:(_challengeVO.creatorVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? ((HONOpponentVO *)[_challengeVO.challengers lastObject]).username : _challengeVO.creatorVO.username];
	}
	
	if (_opponentVO != nil) {
		imageURL = [NSString stringWithFormat:@"%@_%@.jpg", _opponentVO.imagePrefix, (isOriginalImageAvailable) ? @"o" : @"l"];
		avatarURL = [NSString stringWithFormat:@"%@", _opponentVO.avatarURL];
		username = [NSString stringWithFormat:@"@%@", _opponentVO.username];
		
		[self _retrieveUser:_opponentVO.username];
	}
		
		
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
														cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
						  weakSelf.imageView.image = image;
						  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.imageView.alpha = 1.0; } completion:nil];
					  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
						  [weakSelf.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", weakSelf.opponentVO.imagePrefix]] placeholderImage:nil];
					  }];
	[self.view addSubview:_imageView];
	
	
	
	UIView *headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kSnapThumbDim + 30.0)];
	headerBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[self.view addSubview:headerBGView];
	
	UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 15.0, kSnapThumbDim, kSnapThumbDim)];
	[challengeImageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:nil];
	[self.view addSubview:challengeImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 27.0, 200.0, 20.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = username;
	[self.view addSubview:nameLabel];
	
	_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(155.0, 27.0, 150.0, 20.0)];
	_ageLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	_ageLabel.textAlignment = NSTextAlignmentRight;
	_ageLabel.textColor = [UIColor whiteColor];
	_ageLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_ageLabel];
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


@end