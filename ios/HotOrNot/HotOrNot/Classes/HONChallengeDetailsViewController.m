//
//  HONChallengeDetailsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/7/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONChallengeDetailsViewController.h"
#import "HONImagePickerViewController.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"

@interface HONChallengeDetailsViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UIImageView *creatorChallengeImageView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) NSTimer *tapTimer;
@property (nonatomic) BOOL isDoubleTap;
@property (nonatomic) BOOL isChallengeCreator;
@property (nonatomic) BOOL isChallengeOpponent;
@end

@implementation HONChallengeDetailsViewController

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
- (void)_flagChallenge {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 11], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], flagResult);
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
	}];
}

- (void)_upvoteChallenge:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 6], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							[NSString stringWithFormat:@"%d", userID], @"challengerID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], voteResult);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.topItem.title = _challengeVO.subjectName;
	
	_isChallengeCreator = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorVO.userID);
	_isChallengeOpponent = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == ((HONOpponentVO *)[_challengeVO.challengers lastObject]).userID);
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	scrollView.contentSize = CGSizeMake(320.0, 520.0 + ((kSnapMediumDim + 1.0) * ([_challengeVO.challengers count] / 3)));
	scrollView.pagingEnabled = NO;
	scrollView.showsVerticalScrollIndicator = YES;
	scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:scrollView];
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
	[scrollView addSubview:headerView];
	
	UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 11.0, 38.0, 38.0)];
	[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL] placeholderImage:nil];
	creatorAvatarImageView.userInteractionEnabled = YES;
	[self.view addSubview:creatorAvatarImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0, 15.0, 180.0, 20.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:18];
	subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self.view addSubview:subjectLabel];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0, 30.0, 150.0, 19.0)];
	creatorNameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	creatorNameLabel.textColor = [HONAppDelegate honGrey518Color];
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorVO.username];
	[self.view addSubview:creatorNameLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 27.0, 160.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	timeLabel.textColor = [HONAppDelegate honGreyTimeColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
	[self.view addSubview:timeLabel];
	

	__weak typeof(self) weakSelf = self;
	_creatorChallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 56.0, 294.0, 348.0)];
	_creatorChallengeImageView.userInteractionEnabled = YES;
	_creatorChallengeImageView.alpha = [_creatorChallengeImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorVO.imagePrefix]]]];
	[scrollView addSubview:_creatorChallengeImageView];
	
	[_creatorChallengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorVO.imagePrefix]]
																  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.creatorChallengeImageView.image = image;
									[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.creatorChallengeImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	
	UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftButton.frame = _creatorChallengeImageView.frame;
	[leftButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[leftButton addTarget:self action:@selector(_goTapCreator) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview:leftButton];
	
	UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinButton.frame = CGRectMake(10.0, 198.0, 57.0, 52.0);
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
	[joinButton addTarget:self action:(_isChallengeOpponent) ? @selector(_goAcceptChallenge) : @selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview:joinButton];
	
	UIView *footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 250.0, 320.0, 200.0)];
	footerHolderView.backgroundColor = [UIColor whiteColor];
	[scrollView addSubview:footerHolderView];
	
	UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentsButton.frame = CGRectMake(16.0, 10.0, 24.0, 24.0);
	[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateNormal];
	[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateHighlighted];
	[commentsButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:commentsButton];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(43.0, 11.0, 40.0, 22.0)];
	_commentsLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	_commentsLabel.textColor = [HONAppDelegate honBlueTextColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	_commentsLabel.text = (_challengeVO.commentTotal >= 99) ? @"99+" : [NSString stringWithFormat:@"%d", _challengeVO.commentTotal];
	[footerHolderView addSubview:_commentsLabel];
	
	UIButton *commentsLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentsLabelButton.frame = _commentsLabel.frame;
	[commentsLabelButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[commentsLabelButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:commentsLabelButton];
	
	UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likesButton.frame = CGRectMake(79.0, 10.0, 24.0, 24.0);
	[likesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateNormal];
	[likesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateHighlighted];
	[likesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:likesButton];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(108.0, 11.0, 40.0, 22.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	_likesLabel.textColor = [HONAppDelegate honBlueTextColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
	[footerHolderView addSubview:_likesLabel];
	
	UIButton *likesLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likesLabelButton.frame = _likesLabel.frame;
	[likesLabelButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[likesLabelButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:likesLabelButton];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(254.0, 0.0, 64.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:moreButton];
	
	UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	dividerImageView.frame = CGRectOffset(dividerImageView.frame, 5.0, 299.0);
	[scrollView addSubview:dividerImageView];
	
	UILabel *challengersLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 309.0, 300.0, 20.0)];
	challengersLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	challengersLabel.textColor = [HONAppDelegate honGrey455Color];
	challengersLabel.backgroundColor = [UIColor clearColor];
	challengersLabel.text = [NSString stringWithFormat:@"%d Voley%@", [_challengeVO.challengers count], ([_challengeVO.challengers count] != 1) ? @"s" : @""];
	[scrollView addSubview:challengersLabel];
	
	UIView *gridHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 341.0, 320.0, (kSnapMediumDim + 1.0) * (([_challengeVO.challengers count] + 1) / 3))];
	gridHolderView.backgroundColor = [UIColor whiteColor];
	[scrollView addSubview:gridHolderView];
	
	int opponentCounter = 0;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		CGPoint pos = CGPointMake((kSnapMediumDim + 1.0) * (opponentCounter % 3), (kSnapMediumDim + 1.0) * (opponentCounter / 3));
		
		UIView *opponentHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapMediumDim, kSnapMediumDim)];
		[gridHolderView addSubview:opponentHolderView];
		
		UIImageView *opponentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
		opponentImageView.userInteractionEnabled = YES;
		[opponentImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]] placeholderImage:nil];
		[opponentHolderView addSubview:opponentImageView];
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rightButton.frame = opponentImageView.frame;
		[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[rightButton addTarget:self action:@selector(_goTapOpponent:) forControlEvents:UIControlEventTouchUpInside];
		[opponentHolderView addSubview:rightButton];
		
		UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kSnapMediumDim - 38.0, 38.0, 38.0)];
		[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).avatarURL] placeholderImage:nil];
		challengerAvatarImageView.userInteractionEnabled = YES;
		challengerAvatarImageView.clipsToBounds = YES;
		[opponentHolderView addSubview:challengerAvatarImageView];
		
		UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerAvatarButton.frame = challengerAvatarImageView.frame;
		[challengerAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[challengerAvatarButton addTarget:self action:@selector(_goOpponentTimeline:) forControlEvents:UIControlEventTouchUpInside];
		[challengerAvatarButton setTag:opponentCounter];
		[opponentHolderView addSubview:challengerAvatarButton];
		
		opponentCounter++;
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_tapTimeout {
	_isDoubleTap = NO;
}

- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Go Back"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goScore {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Show Voters"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:_challengeVO] animated:YES];
}

- (void)_goComments {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Comments"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:_challengeVO] animated:YES];
}

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Timeline - More Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Report Abuse"
													otherButtonTitles:@"Join Volley", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:1];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}

- (void)_goTapCreator {
	if (!_isDoubleTap) {
		_isDoubleTap = YES;
		_tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_tapTimeout) userInfo:nil repeats:NO];
		
	} else {
		if (_tapTimer != nil) {
			[_tapTimer invalidate];
			_tapTimer = nil;
		}
		
		_isDoubleTap = NO;
		[self _goUpvoteCreator];
	}
}

- (void)_goTapOpponent:(id)sender {
	if (!_isDoubleTap) {
		_isDoubleTap = YES;
		_tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_tapTimeout) userInfo:nil repeats:NO];
		
	} else {
		if (_tapTimer != nil) {
			[_tapTimer invalidate];
			_tapTimer = nil;
		}
		
		_isDoubleTap = NO;
		[self _goUpvoteChallenger:[(UIButton *)sender tag]];
	}
}


- (void)_goCreatorTimeline {
	
}

- (void)_goOpponentTimeline:(id)sender {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Show Challenger Timeline"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", ((HONOpponentVO *)[_challengeVO.challengers lastObject]).userID, ((HONOpponentVO *)[_challengeVO.challengers lastObject]).username], @"challenger", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:[(UIButton *)sender tag]]).username];
}

- (void)_goAcceptChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Accept Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithChallenge:_challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goJoinChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Join Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:_challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goUpvoteCreator {
//	_upvoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(41.0, 41.0, 128.0, 128.0)];
//	_upvoteImageView.image = [UIImage imageNamed:@"alertBackground"];
//	[_lHolderView addSubview:_upvoteImageView];
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 17.0, 94.0, 94.0)];
	heartImageView.image = [UIImage imageNamed:@"largeHeart"];
//	[_upvoteImageView addSubview:heartImageView];
	
	[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
//		_upvoteImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
//		[_upvoteImageView removeFromSuperview];
//		_upvoteImageView = nil;
	}];
	
	_challengeVO.creatorVO.score++;
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
		[[Mixpanel sharedInstance] track:@"Timeline Details - Upvote Creator"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		[HONAppDelegate setVote:_challengeVO.challengeID forCreator:YES];
		[self _upvoteChallenge:_challengeVO.creatorVO.userID];
	}
	
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
}

- (void)_goUpvoteChallenger:(int)index {
//	_upvoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(41.0, 41.0, 128.0, 128.0)];
//	_upvoteImageView.image = [UIImage imageNamed:@"alertBackground"];
//	[_rHolderView addSubview:_upvoteImageView];
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 17.0, 94.0, 94.0)];
	heartImageView.image = [UIImage imageNamed:@"largeHeart"];
//	[_upvoteImageView addSubview:heartImageView];
	
	[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
//		_upvoteImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
//		[_upvoteImageView removeFromSuperview];
//		_upvoteImageView = nil;
	}];
	
	((HONOpponentVO *)[_challengeVO.challengers lastObject]).score++;
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
		[[Mixpanel sharedInstance] track:@"Timeline Details - Upvote Challenger"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		[HONAppDelegate setVote:_challengeVO.challengeID forCreator:NO];
		[self _upvoteChallenge:((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index]).userID];
	}
	
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0: {
			[[Mixpanel sharedInstance] track:@"Timeline Details - Flag"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
											  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			[self _flagChallenge];
			break;}
			
		case 1:
			[self _goJoinChallenge];
			break;
	}
}

@end
