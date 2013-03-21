//
//  HONTimelineItemDetailsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.11.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemDetailsViewController.h"
#import "HONAppDelegate.h"
#import "HONFacebookCaller.h"
#import "HONImagePickerViewController.h"
#import "HONLoginViewController.h"

@interface HONTimelineItemDetailsViewController () <UIAlertViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic) BOOL isOwner;
@property (nonatomic) BOOL isCreator;
@property (nonatomic) BOOL isInSession;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONTimelineItemDetailsViewController

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

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - Touch controls
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == _imageView || [touch view] == _bgView) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
		}];
	}
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	_bgView = [[UIView alloc] initWithFrame:self.view.bounds];
	_bgView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:_bgView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading Image…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 13.0, 200.0, 24.0)];
	subjectLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:19];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self.view addSubview:subjectLabel];
	
	if ([_challengeVO.rechallengedUsers length] > 0) {
		UIImageView *rechallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(200.0, 8.0, 24.0, 24.0)];
		rechallengeImageView.image = [UIImage imageNamed:@"reSnappedIcon"];
		[self.view addSubview:rechallengeImageView];
		
		UILabel *rechallengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 8.0, 60.0, 24.0)];
		rechallengeLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:11];
		rechallengeLabel.textColor = [HONAppDelegate honGreyTxtColor];
		rechallengeLabel.backgroundColor = [UIColor clearColor];
		rechallengeLabel.textAlignment = NSTextAlignmentRight;
		rechallengeLabel.text = @"Resnapped";
		[self.view addSubview:rechallengeLabel];
	}
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0, 12.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.startedDate];
	[self.view addSubview:timeLabel];
	
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
	
	__weak typeof(self) weakSelf = self;
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 64.0, kLargeW * 0.5, kLargeW * 0.5)];
	_imageView.clipsToBounds = YES;
	_imageView.layer.cornerRadius = 8.0;
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		weakSelf.imageView.image = image;
		[weakSelf _hideHUD];
	
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		[weakSelf _hideHUD];
	}];
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
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(266.0, 385.0, 44.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:moreButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

#pragma mark - Navigation
- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Vote Image Details - More"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Report Abuse"
													otherButtonTitles:[NSString stringWithFormat:@"Snap this %@", _challengeVO.subjectName], @"Share", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:0];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}

- (void)_goShare {
	
	if ([HONAppDelegate allowsFBPosting]) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Challenge"
																				 message:[NSString stringWithFormat:@"%@ challenge posted to your wall!", _challengeVO.subjectName]
																				delegate:nil
																	cancelButtonTitle:@"OK"
																	otherButtonTitles:nil];
			[alertView show];
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

- (void)_goUpvote {
	[self performSelector:@selector(_dismiss) withObject:nil afterDelay:0.075];
}

- (void)_dismiss {
	[self dismissViewControllerAnimated:NO completion:^(void) {
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


#pragma mark AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 0) {
			[[Mixpanel sharedInstance] track:@"Vote Image Details - Poke Creator"
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
					NSLog(@"HONTimelineItemDetailsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
					
				} else {
					NSDictionary *pokeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					NSLog(@"HONTimelineItemDetailsViewController AFNetworking: %@", pokeResult);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"HONTimelineItemDetailsViewController AFNetworking %@", [error localizedDescription]);
				
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}];
			
			[self dismissViewControllerAnimated:NO completion:^(void) {
			}];
		}
	
	} else if (alertView.tag == 1) {
		if (buttonIndex == 0) {
			[[Mixpanel sharedInstance] track:@"Vote Image Details - Poke Challenger"
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
					NSLog(@"HONTimelineItemDetailsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
					
				} else {
					NSDictionary *pokeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					NSLog(@"HONTimelineItemDetailsViewController AFNetworking: %@", pokeResult);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"HONTimelineItemDetailsViewController AFNetworking %@", [error localizedDescription]);
				
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}];
			
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
				[[Mixpanel sharedInstance] track:@"Vote Image Details - Flag"
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
				
			case 1: {
				[[Mixpanel sharedInstance] track:@"Vote Image Details - Challenge Subject"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:_challengeVO.subjectName]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				break;}
				
			case 2: {
				if (FBSession.activeSession.state == 513)
					[HONFacebookCaller postToTimeline:_challengeVO];
				
				else {
					UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
					[navController setNavigationBarHidden:YES];
					[self presentViewController:navController animated:YES completion:nil];
				}
				break;}
		}
	}
}

@end
