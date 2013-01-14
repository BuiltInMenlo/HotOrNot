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
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake((_isOwner && !_isInSession) ? 37.0 : 10.0, 378.0, (_isOwner && !_isInSession) ? 247.0 : 147.0, 62.0);
	[shareButton setBackgroundImage:[UIImage imageNamed:(_isOwner && !_isInSession) ? @"shareLarge_nonActive" : @"shareButton_nonActive"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:(_isOwner && !_isInSession) ? @"shareLarge_Active" : @"shareButton_Active"] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	shareButton.hidden = (!_isOwner);
	[self.view addSubview:shareButton];
	
	UIButton *pokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pokeButton.frame = CGRectMake((!_isOwner && !_isInSession) ? 37.0 : 10.0, 378.0, (!_isOwner && !_isInSession) ? 247 : 147.0, 62.0);
	[pokeButton setBackgroundImage:[UIImage imageNamed:(!_isOwner && !_isInSession) ? @"pokeUser_nonActive" : @"pokeButton_nonActive"] forState:UIControlStateNormal];
	[pokeButton setBackgroundImage:[UIImage imageNamed:(!_isOwner && !_isInSession) ? @"pokeUser_Active" : @"pokeButton_Active"] forState:UIControlStateHighlighted];
	[pokeButton addTarget:self action:(_isCreator || _challengeVO.statusID == 1 || _challengeVO.statusID == 2) ? @selector(_goPokeCreator) : @selector(_goPokeChallenger) forControlEvents:UIControlEventTouchUpInside];
	pokeButton.hidden = (_isOwner);
	[self.view addSubview:pokeButton];
	
	UIButton *voteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	voteButton.frame = CGRectMake(160.0, 378.0, 147.0, 62.0);
	[voteButton setBackgroundImage:[UIImage imageNamed:@"vote_nonActive"] forState:UIControlStateNormal];
	[voteButton setBackgroundImage:[UIImage imageNamed:@"vote_Active"] forState:UIControlStateHighlighted];
	[voteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
	voteButton.hidden = (!_isInSession);
	[self.view addSubview:voteButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goShare {
	
	if ([HONAppDelegate allowsFBPosting]) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Challenge"
																				 message:[NSString stringWithFormat:@"%@ challenge posted to your wall!", _challengeVO.subjectName]
																				delegate:nil
																	cancelButtonTitle:@"OK"
																	otherButtonTitles:nil];
			[alertView show];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_CHALLENGE" object:_challengeVO];
		}];
	
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Challenge"
																			 message:@"You need to enable Facebook posting first!"
																			delegate:nil
																cancelButtonTitle:@"OK"
																otherButtonTitles:nil];
		[alertView show];
	}
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

- (void)_goUpvote {
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
		[[NSNotificationCenter defaultCenter] postNotificationName:(_isCreator) ? @"UPVOTE_CREATOR" : @"UPVOTE_CHALLENGER" object:_challengeVO];
	}];
}


#pragma mark - Behaviors
- (void)_hideHUD {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}

@end
