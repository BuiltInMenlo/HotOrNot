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
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 8], @"action",
							(_challengeVO.creatorID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? _challengeVO.challengerName : _challengeVO.creatorName, @"username",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:userResult];
			
			if (userVO.age == 1)
				_ageLabel.text = @"13-17";
			
			else if (userVO.age == 2)
				_ageLabel.text = @"18-25";
			
			else if (userVO.age == 3)
				_ageLabel.text = @"26-35";
			
			else if (userVO.age == 3)
				_ageLabel.text = @"36+";
			
			else
				_ageLabel.text = @"ANY";
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


#pragma mark - Touch Handlers
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	//CGPoint location = [touch locationInView:self.view];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_PREVIEW" object:nil];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	//NSLog(@"VERSION:[%d][%@]", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
	
	__weak typeof(self) weakSelf = self;
	self.view.backgroundColor = [UIColor blackColor];
	self.view.frame = CGRectOffset(self.view.frame, 0.0, -(20.0));
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSTimeInterval diff = [_challengeVO.addedDate timeIntervalSinceDate:[dateFormat dateFromString:@"2013-08-03 00:00:00"]];
	
	BOOL isCreator = _challengeVO.creatorID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	BOOL isOriginalImageAvailable = ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue] >= 10500 && diff > 0);
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(128.0, ([UIScreen mainScreen].bounds.size.height - 64.0) * 0.5)];
	[self.view addSubview:imageLoadingView];
	
	CGRect frame = (isOriginalImageAvailable) ? CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) : CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim);
	_imageView = [[UIImageView alloc] initWithFrame:frame];
	_imageView.alpha = 0.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_%@.jpg", (isCreator && _challengeVO.statusID == 4) ? _challengeVO.challengerImgPrefix : _challengeVO.creatorImgPrefix, (isOriginalImageAvailable) ? @"o" : @"l"]]
														cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
					  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
						  weakSelf.imageView.image = image;
						  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.imageView.alpha = 1.0; } completion:nil];
					  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	[self.view addSubview:_imageView];
	
	UIView *headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kSnapThumbDim + 30.0)];
	headerBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[self.view addSubview:headerBGView];
	
	UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 15.0, kSnapThumbDim, kSnapThumbDim)];
	[challengeImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", (isCreator) ? _challengeVO.challengerAvatar : _challengeVO.creatorAvatar]] placeholderImage:nil];
	[self.view addSubview:challengeImageView];

	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 27.0, 200.0, 20.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:@"@%@", (isCreator) ? _challengeVO.challengerName : _challengeVO.creatorName];
	[self.view addSubview:nameLabel];
	
	_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(155.0, 27.0, 150.0, 20.0)];
	_ageLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	_ageLabel.textAlignment = NSTextAlignmentRight;
	_ageLabel.textColor = [UIColor whiteColor];
	_ageLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_ageLabel];
	
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
