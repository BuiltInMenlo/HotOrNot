//
//  HONChallengePreviewViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.01.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONChallengePreviewViewController.h"
#import "HONAppDelegate.h"

@interface HONChallengePreviewViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic) BOOL isCreator;
@property (nonatomic, strong) UIView *bgView;
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
	
	if ([touch view] == _imageView || [touch view] == _bgView) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
		}];
	}
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
	
	_bgView = [[UIView alloc] initWithFrame:self.view.bounds];
	_bgView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:_bgView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading Image…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	__weak id weakSelf = self;
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 64.0, kLargeW * 0.5, kLargeW * 0.5)];
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorImgPrefix]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_imageView.image = image;
		[weakSelf _hideHUD];
	
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		[weakSelf _hideHUD];
	}];
	_imageView.userInteractionEnabled = YES;
	[self.view addSubview:_imageView];
	
	NSString *creatorCaption = (_isCreator) ? [NSString stringWithFormat:@"You challenged %@ to…", _challengeVO.challengerName] : [NSString stringWithFormat:@"%@ challenged you…", _challengeVO.creatorName];
	
	if (_isCreator && _challengeVO.challengerID == 0)
		creatorCaption = @"You are waiting for someone…";
	
	UILabel *creatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 13.0, 200.0, 16.0)];
	creatorLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	creatorLabel.textColor = [HONAppDelegate honGreyTxtColor];
	creatorLabel.backgroundColor = [UIColor clearColor];
	creatorLabel.text = creatorCaption;
	[self.view addSubview:creatorLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 33.0, 200.0, 24.0)];
	subjectLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:19];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self.view addSubview:subjectLabel];
	
	UIButton *pokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pokeButton.frame = CGRectMake(24.0, 380.0, 124.0, 58.0);
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"pokeUserButton_nonActive"] forState:UIControlStateNormal];
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"pokeUserButton_Active"] forState:UIControlStateHighlighted];
	pokeButton.hidden = (_challengeVO.challengerID == 0);
	[self.view addSubview:pokeButton];
	
	if (_isCreator) {
		[pokeButton addTarget:self action:@selector(_goPokeChallenger) forControlEvents:UIControlEventTouchUpInside];
		
//		UIButton *challengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		challengeButton.frame = CGRectMake(160.0, 378.0, 96.0, 60.0);
//		[challengeButton setBackgroundImage:[UIImage imageNamed:@"tableButtonTie_nonActive"] forState:UIControlStateNormal];
//		[challengeButton setBackgroundImage:[UIImage imageNamed:@"tableButtonTie_Active"] forState:UIControlStateHighlighted];
//		[challengeButton addTarget:self action:@selector(_goRechallenge) forControlEvents:UIControlEventTouchUpInside];
//		[self.view addSubview:challengeButton];
	
	} else {
		[pokeButton addTarget:self action:@selector(_goPokeCreator) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
		acceptButton.frame = CGRectMake(160.0, 378.0, 147.0, 62.0);
		[acceptButton setBackgroundImage:[UIImage imageNamed:@"acceptCameraButton_nonActive"] forState:UIControlStateNormal];
		[acceptButton setBackgroundImage:[UIImage imageNamed:@"acceptCameraButton_Active"] forState:UIControlStateHighlighted];
		[acceptButton addTarget:self action:@selector(_goAccept) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:acceptButton];
		
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 6], @"action",
										[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
										nil];
		
		[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSLog(@"AFNetworking HONChallengePreviewViewController: %@", result);
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"ChallengePreviewViewController AFNetworking %@", [error localizedDescription]);
		}];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goAccept {
	[self dismissViewControllerAnimated:NO completion:^(void) {
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ACCEPT_CHALLENGE" object:_challengeVO];
	}];
}

- (void)_goRechallenge {
	[self dismissViewControllerAnimated:NO completion:^(void) {
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_CHALLENGE" object:_challengeVO];
	}];
}

- (void)_goPokeCreator {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Poke Player"
																		 message:[NSString stringWithFormat:@"Want to poke %@?", _challengeVO.creatorName]
																		delegate:self
															cancelButtonTitle:@"Yes"
															otherButtonTitles:@"No", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goPokeChallenger {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Poke Player"
																		 message:[NSString stringWithFormat:@"Want to poke %@?", _challengeVO.challengerName]
																		delegate:self
															cancelButtonTitle:@"Yes"
															otherButtonTitles:@"No", nil];
	[alertView setTag:1];
	[alertView show];
}

- (void)_hideHUD {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 0) {
			[[Mixpanel sharedInstance] track:@"Challenge Wall - Poke Creator"
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
				NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				
				if (error != nil)
					NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
				else {
					NSLog(@"AFNetworking HONChallengePreviewViewController: %@", result);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"ChallengePreviewViewController AFNetworking %@", [error localizedDescription]);
			}];
			
			[self dismissViewControllerAnimated:NO completion:^(void) {
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
			}];
		}
	
	} else if (alertView.tag == 1) {
		if (buttonIndex == 0) {
			[[Mixpanel sharedInstance] track:@"Challenge Wall - Poke Challenger"
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
				NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				
				if (error != nil)
					NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
				else {
					NSLog(@"AFNetworking HONChallengePreviewViewController: %@", result);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"ChallengePreviewViewController AFNetworking %@", [error localizedDescription]);
			}];
			
			[self dismissViewControllerAnimated:NO completion:^(void) {
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
			}];
		}
	}
}

@end
