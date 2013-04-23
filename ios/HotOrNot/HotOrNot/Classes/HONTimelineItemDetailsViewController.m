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
#import "HONUserVO.h"

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
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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
	_progressHUD.labelText = NSLocalizedString(@"hud_loadSnap", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 14.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:(_isCreator || !_isInSession) ? _challengeVO.creatorAvatar : _challengeVO.challengerAvatar] placeholderImage:nil];
	[self.view addSubview:avatarImageView];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0, 26.0, 200.0, 14.0)];
	creatorNameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
	creatorNameLabel.textColor = [HONAppDelegate honGreyTxtColor];
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = [NSString stringWithFormat:@"@%@", (_isCreator || !_isInSession) ? _challengeVO.creatorName : _challengeVO.challengerName];
	[self.view addSubview:creatorNameLabel];
	
	if ([_challengeVO.rechallengedUsers length] > 0) {
		UIImageView *rechallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(217.0, 17.0, 24.0, 24.0)];
		rechallengeImageView.image = [UIImage imageNamed:@"reSnappedIcon"];
		[self.view addSubview:rechallengeImageView];
	}
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(252.0, 24.0, 60.0, 12.0)];
	timeLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.startedDate];
	//[self.view addSubview:timeLabel];
	
	//NSLog(@"_isInSession:[%d] _isOwner:[%d] _isCreator:[%d] statusID:[%d]", _isInSession, _isOwner, _isCreator, _challengeVO.statusID);
	
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
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 69.0, kLargeW * 0.5, kLargeW * 0.5)];
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		weakSelf.imageView.image = image;
		[weakSelf _hideHUD];
	
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		[weakSelf _hideHUD];
	}];
	_imageView.userInteractionEnabled = YES;
	[self.view addSubview:_imageView];
		
	UIImageView *footerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([HONAppDelegate isRetina5]) ? 472.0 : 384.0, 320.0, 96.0)];
	footerImageView.image = [UIImage imageNamed:@"cameraFooterBackground"];
	footerImageView.userInteractionEnabled = YES;
	[self.view addSubview:footerImageView];
	
	int offset = ([HONAppDelegate isRetina5]) ? 110.0 : 0.0;
	
	UIButton *pokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pokeButton.frame = CGRectMake(33.0, 399.0 + offset, 44.0, 44.0);
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"pokeButton_nonActive"] forState:UIControlStateNormal];
	[pokeButton setBackgroundImage:[UIImage imageNamed:@"pokeButton_Active"] forState:UIControlStateHighlighted];
	[pokeButton addTarget:self action:(_isCreator || _challengeVO.statusID == 1 || _challengeVO.statusID == 2) ? @selector(_goPokeCreator) : @selector(_goPokeChallenger) forControlEvents:UIControlEventTouchUpInside];
	pokeButton.hidden = (_isOwner);
//	[self.view addSubview:pokeButton];
	
	UIButton *voteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	voteButton.frame = CGRectMake(32.0, 388.0 + offset, 44.0, 44.0);
	[voteButton setBackgroundImage:[UIImage imageNamed:@"largeHeart_nonActive"] forState:UIControlStateNormal];
	[voteButton setBackgroundImage:[UIImage imageNamed:@"largeHeart_Active"] forState:UIControlStateHighlighted];
	[voteButton addTarget:self action:@selector(_goUpvote) forControlEvents:UIControlEventTouchUpInside];
	voteButton.hidden = (!_isInSession);
	[self.view addSubview:voteButton];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(243.0, 388.0 + offset, 44.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"overlayMoreButton_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"overlayMoreButton_Active"] forState:UIControlStateHighlighted];
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
	[[Mixpanel sharedInstance] track:@"Timeline Details - More Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Report Abuse"
																	otherButtonTitles:[NSString stringWithFormat:@"Snap this %@", _challengeVO.subjectName], [NSString stringWithFormat:@"Poke @%@", (_isCreator) ? _challengeVO.creatorName : _challengeVO.challengerName], nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:0];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}

- (void)_goUpvote {
	[self performSelector:@selector(_dismiss) withObject:nil afterDelay:0.075];
}

- (void)_dismiss {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Timeline Details - Flag"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
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
				[[Mixpanel sharedInstance] track:@"Timeline Details - New Snap at User"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
													  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
													  _challengeVO.subjectName, @"subject", nil]];
				
				HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																					[NSString stringWithFormat:@"%d", (_isCreator) ? _challengeVO.creatorID : _challengeVO.challengerID], @"id",
																					[NSString stringWithFormat:@"%d", 0], @"points",
																					[NSString stringWithFormat:@"%d", 0], @"votes",
																					[NSString stringWithFormat:@"%d", 0], @"pokes",
																					[NSString stringWithFormat:@"%d", 0], @"pics",
																					(_isCreator) ? _challengeVO.creatorName : _challengeVO.challengerName, @"username",
																					(_isCreator) ? _challengeVO.creatorFB : _challengeVO.challengerFB, @"fb_id",
																					(_isCreator) ? _challengeVO.creatorAvatar: _challengeVO.challengerAvatar, @"avatar_url", nil]];
				
				UINavigationController *navigationController = (_isOwner) ? [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:_challengeVO.subjectName]] : [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO withSubject:_challengeVO.subjectName]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				break;}
			
			case 2: {
				[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline Details - Poke %@", (_isCreator) ? @"Creator" : @"Challenger"]
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
															 
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 6], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"pokerID",
												[NSString stringWithFormat:@"%d", (_isCreator) ? _challengeVO.creatorID : _challengeVO.challengerID], @"pokeeID", //(_isCreator || _challengeVO.statusID == 1 || _challengeVO.statusID == 2) ? _challengeVO.creatorID : _challengeVO.challengerID
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
					_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
				}];
				
				[self dismissViewControllerAnimated:NO completion:^(void) {
				}];
				
				break;}
		}
	}
}

@end
