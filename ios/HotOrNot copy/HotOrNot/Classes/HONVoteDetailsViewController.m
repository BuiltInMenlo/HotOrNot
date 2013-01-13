//
//  HONVoteDetailsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.11.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImageView+WebCache.h"

#import "HONVoteDetailsViewController.h"
#import "HONAppDelegate.h"

@interface HONVoteDetailsViewController ()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic) BOOL isOwner;
@property (nonatomic) BOOL isCreator;
@property (nonatomic) BOOL isInSession;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONVoteDetailsViewController

- (id)initAsNotInSession:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_isOwner = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.creatorID);
		_isCreator = NO;
		_isInSession = NO;
		
		_challengeVO = vo;
	}
	
	return (self);
}

- (id)initAsInSessionCreator:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_isOwner = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.creatorID);
		_isCreator = YES;
		_isInSession = YES;
		
		_challengeVO = vo;
	}
	
	return (self);
}

- (id)initAsInSessionChallenger:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_isOwner = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.challengerID);
		_isCreator = NO;
		_isInSession = YES;
		
		_challengeVO = vo;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Touch controls
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == _imageView || [touch view] == _bgView) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
		}];
	}
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
	
	_bgView = [[UIView alloc] initWithFrame:self.view.bounds];
	_bgView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:_bgView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading Image…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 13.0, 280.0, 16.0)];
	titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	titleLabel.textColor = [HONAppDelegate honGreyTxtColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = [HONAppDelegate ctaForChallenge:_challengeVO];
	[self.view addSubview:titleLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 33.0, 200.0, 24.0)];
	subjectLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:19];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self.view addSubview:subjectLabel];
	
	NSLog(@"_isInSession:[%d] _isOwner:[%d] _isCreator:[%d] statusID:[%d]", _isInSession, _isOwner, _isCreator, _challengeVO.statusID);
	//NSLog(@"BOOL:[%d] _isOwner:[%d] vo.creatorID:[%d] vo.challengerID:[%d]", ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorID), _isOwner, _challengeVO.creatorID, _challengeVO.challengerID);
	
	NSString *imgURL;
	if (_isInSession) {
		if (_isCreator) {
			imgURL = [NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorImgPrefix];
			
		} else {
			imgURL = [NSString stringWithFormat:@"%@_l.jpg", _challengeVO.challengerImgPrefix];
		}
		
	} else {
		imgURL = [NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorImgPrefix];
	}
	
	__weak id weakSelf = self;
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 64.0, kLargeW * 0.5, kLargeW * 0.5)];
	[_imageView setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:nil options:SDWebImageLowPriority success:^(UIImage *image, BOOL cached) {
		[weakSelf _hideHUD];
	} failure:nil];
	_imageView.userInteractionEnabled = YES;
	[self.view addSubview:_imageView];
	
	UIButton *challengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	challengeButton.frame = CGRectMake(87.0, 300.0, 147.0, 62.0);
	[challengeButton setBackgroundImage:[UIImage imageNamed:@"submitChallengeButton2_nonActive"] forState:UIControlStateNormal];
	[challengeButton setBackgroundImage:[UIImage imageNamed:@"submitChallengeButton2_Active"] forState:UIControlStateHighlighted];
	[challengeButton addTarget:self action:@selector(_goChallenge) forControlEvents:UIControlEventTouchUpInside];
	//challengeButton.hidden = (_isOwner || (!_isOwner && !_isInSession));
	challengeButton.hidden = (_isOwner || _challengeVO.statusID == 1);
	[self.view addSubview:challengeButton];
	
	UIButton *pokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pokeButton.frame = CGRectMake(24.0, 380.0, 124.0, 58.0);
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"pokeUserButton_nonActive"] forState:UIControlStateNormal];
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"pokeUserButton_Active"] forState:UIControlStateHighlighted];
	[pokeButton addTarget:self action:(_isCreator) ? @selector(_goPokeCreator) : @selector(_goPokeChallenger) forControlEvents:UIControlEventTouchUpInside];
	pokeButton.hidden = (_isOwner);
	[self.view addSubview:pokeButton];
	
	UIButton *voteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	voteButton.frame = CGRectMake(160.0, 378.0, 147.0, 62.0);
	[voteButton setBackgroundImage:[UIImage imageNamed:@"voteButton_nonActive"] forState:UIControlStateNormal];
	[voteButton setBackgroundImage:[UIImage imageNamed:@"voteButton_Active"] forState:UIControlStateHighlighted];
	voteButton.titleLabel.font = [[HONAppDelegate qualcommBold] fontWithSize:14];
	[voteButton setTitleColor:[HONAppDelegate honGreyTxtColor] forState:UIControlStateNormal];
	[voteButton setTitle:@"VOTE!" forState:UIControlStateNormal];
	[voteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
	voteButton.hidden = (!_isInSession);
	[self.view addSubview:voteButton];
	
	UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
	acceptButton.frame = CGRectMake(160.0, 380.0, 124.0, 58.0);
	[acceptButton setBackgroundImage:[UIImage imageNamed:@"acceptCameraButton_nonActive"] forState:UIControlStateNormal];
	[acceptButton setBackgroundImage:[UIImage imageNamed:@"acceptCameraButton_Active"] forState:UIControlStateHighlighted];
	[acceptButton addTarget:self action:@selector(_goAccept) forControlEvents:UIControlEventTouchUpInside];
	acceptButton.hidden = (_challengeVO.statusID == 2 || _isInSession || _isOwner);
	[self.view addSubview:acceptButton];
	
	if (_challengeVO.challengerID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] && !_isInSession)
		acceptButton.hidden = NO;
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goChallenge {
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
		[[NSNotificationCenter defaultCenter] postNotificationName:(_isCreator || !_isInSession) ? @"NEW_CREATOR_CHALLENGE" : @"NEW_CHALLENGER_CHALLENGE" object:_challengeVO];
	}];
}

- (void)_goPokeCreator {
	[[Mixpanel sharedInstance] track:@"Vote Details - Poke Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 6], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"pokerID",
									[NSString stringWithFormat:@"%d", _challengeVO.creatorID], @"pokeeID",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSDictionary *pokeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSLog(@"HONVoteDetailsViewController AFNetworking: %@", pokeResult);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
	}];
	
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	}];
}

- (void)_goPokeChallenger {
	[[Mixpanel sharedInstance] track:@"Vote Details - Poke Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 6], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"pokerID",
									[NSString stringWithFormat:@"%d", _challengeVO.challengerID], @"pokeeID",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSDictionary *pokeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSLog(@"HONVoteDetailsViewController AFNetworking: %@", pokeResult);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
	}];
	
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	}];
}

- (void)_goAccept {
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
	}];
}

- (void)_goUpvote {
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
		[[NSNotificationCenter defaultCenter] postNotificationName:(_isCreator) ? @"UPVOTE_CREATOR" : @"UPVOTE_CHALLENGER" object:_challengeVO];
	}];
}

- (void)_hideHUD {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}

@end
