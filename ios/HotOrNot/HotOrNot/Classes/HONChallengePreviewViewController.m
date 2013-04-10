//
//  HONChallengePreviewViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.01.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONChallengePreviewViewController.h"
#import "HONAppDelegate.h"

@interface HONChallengePreviewViewController () <UIAlertViewDelegate, UIActionSheetDelegate>
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

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - Touch Controls
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == _imageView || [touch view] == _bgView) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[self dismissViewControllerAnimated:NO completion:^(void) {
		}];
	}
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
	bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience_Overlay-568h" : @"cameraExperience_Overlay"];
	bgImageView.userInteractionEnabled = YES;
	[self.view addSubview:bgImageView];
	
	_bgView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_bgView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading Image…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	CALayer *avatarMask = [CALayer layer];
	avatarMask.contents = (id)[[UIImage imageNamed:@"smallAvatarMask.png"] CGImage];
	avatarMask.frame = CGRectMake(0.0, 0.0, 38.0, 38.0);
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0, 10.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:(_isCreator) ? _challengeVO.challengerAvatar : _challengeVO.creatorAvatar] placeholderImage:nil];
	avatarImageView.layer.mask = avatarMask;
	avatarImageView.layer.masksToBounds = YES;
	[self.view addSubview:avatarImageView];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 24.0, 200.0, 14.0)];
	creatorNameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:11];
	creatorNameLabel.textColor = [HONAppDelegate honGreyTxtColor];
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = [NSString stringWithFormat:@"@%@", (_isCreator) ? _challengeVO.challengerName : _challengeVO.creatorName];
	[self.view addSubview:creatorNameLabel];
	
	if ([_challengeVO.rechallengedUsers length] > 0) {
		UIImageView *rechallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(217.0, 17.0, 24.0, 24.0)];
		rechallengeImageView.image = [UIImage imageNamed:@"reSnappedIcon"];
		[self.view addSubview:rechallengeImageView];
		
		UILabel *rechallengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(228.0, 23.0, 60.0, 12.0)];
		rechallengeLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:9];
		rechallengeLabel.textColor = [HONAppDelegate honGreyTxtColor];
		rechallengeLabel.backgroundColor = [UIColor clearColor];
		rechallengeLabel.textAlignment = NSTextAlignmentRight;
		rechallengeLabel.text = @"Resnapped";
		[self.view addSubview:rechallengeLabel];
	}
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(252.0, 24.0, 60.0, 12.0)];
	timeLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.startedDate];
	[self.view addSubview:timeLabel];
	
	__weak typeof(self) weakSelf = self;
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 64.0, kLargeW * 0.5, kLargeW * 0.5)];
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorImgPrefix]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		weakSelf.imageView.image = image;
		[weakSelf _hideHUD];
	
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		[weakSelf _hideHUD];
	}];
	_imageView.userInteractionEnabled = YES;
	_imageView.layer.cornerRadius = 4.0;
	_imageView.clipsToBounds = YES;
	[self.view addSubview:_imageView];
	
	int offset = (int)[HONAppDelegate isRetina5] * 88;
	
	UIButton *pokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pokeButton.frame = CGRectMake(23.0, 398.0 + offset, 64.0, 64.0);
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"pokeButton_nonActive"] forState:UIControlStateNormal];
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"pokeButton_Active"] forState:UIControlStateHighlighted];
	pokeButton.hidden = (_challengeVO.challengerID == 0);
	[self.view addSubview:pokeButton];
	
	if (_isCreator) {
		[pokeButton addTarget:self action:@selector(_goPokeChallenger) forControlEvents:UIControlEventTouchUpInside];
	
	} else {
		[pokeButton addTarget:self action:@selector(_goPokeCreator) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
		acceptButton.frame = CGRectMake(113.0, 385.0 + offset, 94.0, 94.0);
		[acceptButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[acceptButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
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
				NSLog(@"AFNetworking HONChallengePreviewViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSLog(@"AFNetworking HONChallengePreviewViewController: %@", result);
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"ChallengePreviewViewController AFNetworking %@", [error localizedDescription]);
			
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}];
	}
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(239.0, 400.0 + offset, 64.0, 64.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"overlayMoreButton_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"overlayMoreButton_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:moreButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goAccept {
	[[Mixpanel sharedInstance] track:@"Activity Details - Accept Snap"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ACCEPT_CHALLENGE" object:_challengeVO];
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

#pragma mark - Navigation
- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Activity Details - More Shelf"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																				delegate:self
																	cancelButtonTitle:@"Cancel"
															 destructiveButtonTitle:@"Report Abuse"
																	otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:0];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 0) {
			[[Mixpanel sharedInstance] track:@"Activity Details - Poke Creator"
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
					NSLog(@"AFNetworking HONChallengePreviewViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
				else {
					NSLog(@"AFNetworking HONChallengePreviewViewController: %@", result);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"ChallengePreviewViewController AFNetworking %@", [error localizedDescription]);
				
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}];
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[self dismissViewControllerAnimated:NO completion:^(void) {
			}];
		}
	
	} else if (alertView.tag == 1) {
		if (buttonIndex == 0) {
			[[Mixpanel sharedInstance] track:@"Activity Details - Poke Challenger"
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
				//NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				
				if (error != nil)
					NSLog(@"AFNetworking HONChallengePreviewViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
				else {
					//NSLog(@"AFNetworking HONChallengePreviewViewController: %@", result);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"ChallengePreviewViewController AFNetworking %@", [error localizedDescription]);
				
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}];
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[self dismissViewControllerAnimated:NO completion:^(void) {
			}];
		}
	}
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Activity Details - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 11], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						NSLog(@"HONTimelineItemDetailsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//NSLog(@"HONTimelineItemDetailsViewController AFNetworking: %@", flagResult);
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					NSLog(@"HONTimelineItemDetailsViewController AFNetworking %@", [error localizedDescription]);
				}];
				
				break;}
				
			case 1:
				break;
				
			case 2:
				break;
		}
	}
}
@end
