//
//  HONVoteDetailsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.11.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImageView+WebCache.h"

#import "HONVoteDetailsViewController.h"
#import "HONAppDelegate.h"

@interface HONVoteDetailsViewController () <ASIHTTPRequestDelegate>
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


//- (id)initAsCreatorInSession:(HONChallengeVO *)vo {
//	if ((self = [super init])) {
//		_isOwner = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID);
//		_isCreator = YES;
//		_isInSession = YES;
//		
//		_challengeVO = vo;
//	}
//	
//	return (self);
//}
//
//- (id)initAsChallengerInSession:(HONChallengeVO *)vo {
//	if ((self = [super init])) {
//		_isOwner = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.challengerID);
//		_isCreator = NO;
//		_isInSession = YES;
//		
//		_challengeVO = vo;
//	}
//	
//	return (self);
//}
//
//- (id)initAsOwnerCreated:(HONChallengeVO *)vo {
//	if ((self = [super init])) {
//		_isOwner = YES;
//		_isCreator = YES;
//		_isInSession = NO;
//		
//		_challengeVO = vo;
//	}
//	
//	return (self);
//}
//
//- (id)initAsOwnerWaiting:(HONChallengeVO *)vo {
//	if ((self = [super init])) {
//		_isOwner = YES;
//		_isCreator = YES;
//		_isInSession = NO;
//		
//		_challengeVO = vo;
//	}
//	
//	return (self);
//}
//
//- (id)initAsNotOwnerCreated:(HONChallengeVO *)vo {
//	if ((self = [super init])) {
//		_isOwner = NO;
//		_isCreator = YES;
//		_isInSession = NO;
//		
//		_challengeVO = vo;
//	}
//	
//	return (self);
//}
//
//- (id)initAsNotOwnerWaiting:(HONChallengeVO *)vo {
//	if ((self = [super init])) {
//		_isOwner = NO;
//		_isCreator = YES;
//		_isInSession = NO;
//		
//		_challengeVO = vo;
//	}
//	
//	return (self);
//}


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
	
	NSLog(@"_isInSession:[%d] _isOwner:[%d] _isCreator:[%d]", _isInSession, _isOwner, _isCreator);
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
	[self.view addSubview:voteButton];
	
	if (!_isInSession || _isOwner)
		voteButton.hidden = YES;
	
	UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
	acceptButton.frame = CGRectMake(160.0, 380.0, 124.0, 58.0);
	[acceptButton setBackgroundImage:[UIImage imageNamed:@"acceptCameraButton_nonActive"] forState:UIControlStateNormal];
	[acceptButton setBackgroundImage:[UIImage imageNamed:@"acceptCameraButton_Active"] forState:UIControlStateHighlighted];
	[acceptButton addTarget:self action:@selector(_goAccept) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:acceptButton];
	
	if (_challengeVO.statusID == 2 || _isInSession || _isOwner)
		acceptButton.hidden = YES;
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goPokeCreator {
	[[Mixpanel sharedInstance] track:@"Vote Details - Poke Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
	
	ASIFormDataRequest *pokeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
	[pokeRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[pokeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
	[pokeRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.creatorID] forKey:@"pokeeID"];
	[pokeRequest startAsynchronous];
	
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	}];
}

- (void)_goPokeChallenger {
	[[Mixpanel sharedInstance] track:@"Vote Details - Poke Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
	
	ASIFormDataRequest *pokeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
	[pokeRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[pokeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
	[pokeRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengerID] forKey:@"pokeeID"];
	[pokeRequest startAsynchronous];
	
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
