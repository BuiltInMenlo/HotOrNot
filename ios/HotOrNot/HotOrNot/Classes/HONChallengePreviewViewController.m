//
//  HONChallengePreviewViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.01.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImageView+WebCache.h"

#import "HONChallengePreviewViewController.h"
#import "HONAppDelegate.h"

@interface HONChallengePreviewViewController () <ASIHTTPRequestDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic) BOOL isCreator;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONChallengePreviewViewController

- (id)initAsCreator:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_isCreator = YES;
	}
	
	return (self);
}

- (id)initAsChallenger:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_isCreator = NO;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Touch controls
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	if ([touch view] == _imageView)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CLOSE_PREVIEW" object:nil];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading Image…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 40.0, kLargeW * 0.5, kLargeW * 0.5)];
	[_imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.imageURL]] placeholderImage:nil options:SDWebImageProgressiveDownload success:^(UIImage *image, BOOL cached) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	} failure:nil];
	_imageView.userInteractionEnabled = YES;
	[self.view addSubview:_imageView];
	
	UIImageView *creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 30.0, 25.0, 25.0)];
	creatorImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _challengeVO.creatorFB]] placeholderImage:nil];
	[self.view addSubview:creatorImageView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 40.0, 200.0, 14.0)];
	titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = _challengeVO.subjectName;
	[self.view addSubview:titleLabel];
	
	UIButton *pokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pokeButton.frame = CGRectMake(7.0, 340.0, 96.0, 60.0);
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"tableButtonWaiting_nonActive.png"] forState:UIControlStateNormal];
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"tableButtonWaiting_Active.png"] forState:UIControlStateHighlighted];
	[self.view addSubview:pokeButton];
	
	if (_isCreator) {
		[pokeButton addTarget:self action:@selector(_goPokeChallenger) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *challengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengeButton.frame = CGRectMake(160.0, 340.0, 96.0, 60.0);
		[challengeButton setBackgroundImage:[UIImage imageNamed:@"tableButtonTie_nonActive.png"] forState:UIControlStateNormal];
		[challengeButton setBackgroundImage:[UIImage imageNamed:@"tableButtonTie_Active.png"] forState:UIControlStateHighlighted];
		[challengeButton addTarget:self action:@selector(_goRechallenge) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:challengeButton];
	
	} else {
		[pokeButton addTarget:self action:@selector(_goPokeCreator) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
		acceptButton.frame = CGRectMake(160.0, 340.0, 96.0, 60.0);
		[acceptButton setBackgroundImage:[UIImage imageNamed:@"tableButtonAccept_nonActive.png"] forState:UIControlStateNormal];
		[acceptButton setBackgroundImage:[UIImage imageNamed:@"tableButtonAccept_Active.png"] forState:UIControlStateHighlighted];
		[acceptButton addTarget:self action:@selector(_goAccept) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:acceptButton];
		
		ASIFormDataRequest *seenRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
		[seenRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
		[seenRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
		[seenRequest setDelegate:self];
		[seenRequest startAsynchronous];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goAccept {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ACCEPT_CHALLENGE" object:_challengeVO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CLOSE_PREVIEW" object:nil];
}

- (void)_goRechallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_CHALLENGE" object:_challengeVO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CLOSE_PREVIEW" object:nil];
}

- (void)_goPokeCreator {
	[[Mixpanel sharedInstance] track:@"Challenge Wall - Poke Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
	
	ASIFormDataRequest *pokeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
	[pokeRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[pokeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
	[pokeRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.creatorID] forKey:@"pokeeID"];
	[pokeRequest startAsynchronous];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CLOSE_PREVIEW" object:nil];
}

- (void)_goPokeChallenger {
	[[Mixpanel sharedInstance] track:@"Challenge Wall - Poke Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
	
	ASIFormDataRequest *pokeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
	[pokeRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[pokeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
	[pokeRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengerID] forKey:@"pokeeID"];
	[pokeRequest startAsynchronous];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CLOSE_PREVIEW" object:nil];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONChallengePreviewViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		if (error != nil)
			NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
		
		else {
			
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
