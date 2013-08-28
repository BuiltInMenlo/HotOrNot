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

#import "HONHeaderView.h"
#import "HONChallengeDetailsViewController.h"
#import "HONImagePickerViewController.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONChallengeOverlayView.h"

@interface HONChallengeDetailsViewController () <UIActionSheetDelegate, UIActionSheetDelegate, HONChallengeOverlayViewDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *creatorChallengeImageView;
@property (nonatomic, strong) UIView *gridHolderView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) NSTimer *tapTimer;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) HONChallengeOverlayView *challengeOverlayView;
@property (nonatomic) BOOL isDoubleTap;
@property (nonatomic) BOOL isModal;
@property (nonatomic) BOOL isChallengeCreator;
@property (nonatomic) BOOL isChallengeOpponent;
@end

@implementation HONChallengeDetailsViewController

- (id)initWithChallenge:(HONChallengeVO *)vo asModal:(BOOL)isModal {
	if ((self = [super init])) {
		_challengeVO = vo;
		_isModal = isModal;
		
		NSLog(@"CHALLENGE DETAILS:[%@]", _challengeVO.dictionary);
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_removePreview:) name:@"REMOVE_PREVIEW" object:nil];
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
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
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
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
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

- (void)_flagUser:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 10], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"targetID",
							[NSString stringWithFormat:@"%d", 0], @"approves",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_addFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target",
							@"0", @"auto", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeFriendsList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}



#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.topItem.title = _challengeVO.subjectName;
	
	int offset = (_isModal * kNavBarHeaderHeight);
	
	if (_isModal) {
		HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:_challengeVO.subjectName];
		[self.view addSubview:headerView];
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(-7.0, 0.0, 64.0, 44.0);
		[closeButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_Active"] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:closeButton];
	}
	
	_isChallengeCreator = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorVO.userID);
	_isChallengeOpponent = NO;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.userID) {
			_isChallengeOpponent = YES;
			break;
		}
	}
	
	int respondedOpponents = 0;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([vo.imagePrefix length] > 0)
			respondedOpponents++;
	}
	
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0 + offset, 320.0, 61.0)];
	headerView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:headerView];
	
	UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 9.0, 38.0, 38.0)];
	[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL] placeholderImage:nil];
	creatorAvatarImageView.userInteractionEnabled = YES;
	[headerView addSubview:creatorAvatarImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 10.0, 170.0, 20.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[headerView addSubview:subjectLabel];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 28.0, 150.0, 19.0)];
	creatorNameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	creatorNameLabel.textColor = [HONAppDelegate honGrey518Color];
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorVO.username];
	[headerView addSubview:creatorNameLabel];
	
	if ([_challengeVO.challengers count] > 0) {
		UILabel *lastJoinedLabel = [[UILabel alloc] initWithFrame:CGRectMake(226.0, 5.0, 80.0, 19.0)];
		lastJoinedLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
		lastJoinedLabel.textColor = [HONAppDelegate honOrthodoxGreenColor];
		lastJoinedLabel.backgroundColor = [UIColor clearColor];
		lastJoinedLabel.textAlignment = NSTextAlignmentRight;
		lastJoinedLabel.text = [NSString stringWithFormat:@"@%@", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).username];
		[headerView addSubview:lastJoinedLabel];
	}
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 24.0, 160.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	timeLabel.textColor = [HONAppDelegate honGreyTimeColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
	[headerView addSubview:timeLabel];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = creatorAvatarImageView.frame;
	[avatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[avatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:avatarButton];
	
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 61.0 + offset, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.contentSize = CGSizeMake(320.0, 569.0 + (kSnapMediumDim * (respondedOpponents / 5)) - (_isModal * 85.0));
	_scrollView.pagingEnabled = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	[_scrollView addGestureRecognizer:lpGestureRecognizer];
	
	__weak typeof(self) weakSelf = self;
	_creatorChallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 0.0, 294.0, 294.0)];
	_creatorChallengeImageView.userInteractionEnabled = YES;
	_creatorChallengeImageView.alpha = [_creatorChallengeImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorVO.imagePrefix]]]];
	[_scrollView addSubview:_creatorChallengeImageView];
	
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
	[_scrollView addSubview:leftButton];
	
	UIView *footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 187.0, 320.0, 200.0)];
	footerHolderView.backgroundColor = [UIColor whiteColor];
	[_scrollView addSubview:footerHolderView];
	
//	UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	commentsButton.frame = CGRectMake(8.0, 14.0, 24.0, 24.0);
//	[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateNormal];
//	[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateHighlighted];
//	[commentsButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
//	[footerHolderView addSubview:commentsButton];
//	
//	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(37.0, 15.0, 40.0, 22.0)];
//	_commentsLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
//	_commentsLabel.textColor = [HONAppDelegate honBlueTextColor];
//	_commentsLabel.backgroundColor = [UIColor clearColor];
//	_commentsLabel.text = (_challengeVO.commentTotal >= 99) ? @"99+" : [NSString stringWithFormat:@"%d", _challengeVO.commentTotal];
//	[footerHolderView addSubview:_commentsLabel];
//	
//	UIButton *commentsLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	commentsLabelButton.frame = _commentsLabel.frame;
//	[commentsLabelButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
//	[commentsLabelButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
//	[footerHolderView addSubview:commentsLabelButton];
	
	UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likesButton.frame = CGRectMake(8.0, 14.0, 24.0, 24.0);
	[likesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateNormal];
	[likesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateHighlighted];
	[likesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:likesButton];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(37.0, 15.0, 40.0, 22.0)];
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
	
//	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	moreButton.frame = CGRectMake(254.0, 0.0, 64.0, 44.0);
//	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
//	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
//	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
//	[footerHolderView addSubview:moreButton];
	
	UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinButton.frame = CGRectMake(244.0, 8.0, 64.0, 39.0);
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
	[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:joinButton];
	
	UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	dividerImageView.frame = CGRectOffset(dividerImageView.frame, 0.0, 242.0);
	[_scrollView addSubview:dividerImageView];
	
	UILabel *challengersLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 252.0, 300.0, 20.0)];
	challengersLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	challengersLabel.textColor = [HONAppDelegate honGrey455Color];
	challengersLabel.backgroundColor = [UIColor clearColor];
	challengersLabel.text = [NSString stringWithFormat:@"%d Volley%@ - Tap and Hold to view", (respondedOpponents + 1), ((respondedOpponents + 1) != 1) ? @"s" : @""];
	[_scrollView addSubview:challengersLabel];
	
	_gridHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 283.0, 320.0, (kSnapMediumDim + 1.0) * ((respondedOpponents / 4) + 1))];
	_gridHolderView.backgroundColor = [UIColor whiteColor];
	[_scrollView addSubview:_gridHolderView];
	
	int opponentCounter = 0;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([vo.imagePrefix length] > 0) {
			CGPoint pos = CGPointMake((kSnapMediumDim + 1.0) * (opponentCounter % 4), (kSnapMediumDim + 1.0) * (opponentCounter / 4));
			
			UIView *opponentHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapMediumDim, kSnapMediumDim)];
			[_gridHolderView addSubview:opponentHolderView];
			
			UIImageView *opponentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
			opponentImageView.userInteractionEnabled = YES;
			[opponentImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]] placeholderImage:nil];
			[opponentHolderView addSubview:opponentImageView];
			
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
			rightButton.frame = opponentImageView.frame;
			[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
			[rightButton addTarget:self action:@selector(_goTapOpponent:) forControlEvents:UIControlEventTouchUpInside];
			[rightButton setTag:vo.userID];
			[opponentHolderView addSubview:rightButton];
			
			opponentCounter++;
		}
		
//		UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kSnapMediumDim - 38.0, 38.0, 38.0)];
//		[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).avatarURL] placeholderImage:nil];
//		challengerAvatarImageView.userInteractionEnabled = YES;
//		challengerAvatarImageView.clipsToBounds = YES;
//		[opponentHolderView addSubview:challengerAvatarImageView];
//		
//		UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		challengerAvatarButton.frame = challengerAvatarImageView.frame;
//		[challengerAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
//		[challengerAvatarButton addTarget:self action:@selector(_goOpponentTimeline:) forControlEvents:UIControlEventTouchUpInside];
//		[challengerAvatarButton setTag:opponentCounter];
//		[opponentHolderView addSubview:challengerAvatarButton];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_scrollView];
		
		CGRect creatorFrame = CGRectMake(_creatorChallengeImageView.frame.origin.x, _creatorChallengeImageView.frame.origin.y, _creatorChallengeImageView.frame.size.width, _creatorChallengeImageView.frame.size.height * 0.5);
		if (CGRectContainsPoint(creatorFrame, touchPoint))
			_opponentVO = _challengeVO.creatorVO;
			_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:_challengeVO.creatorVO];
		
		if (CGRectContainsPoint(_gridHolderView.frame, touchPoint)) {
			int col = touchPoint.x / (kSnapMediumDim + 1.0);
			int row = (touchPoint.y - _gridHolderView.frame.origin.y) / (kSnapMediumDim + 1.0);
			_opponentVO = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:(row * 4) + col];
			
			_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:_opponentVO];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		if (_snapPreviewViewController != nil) {
			[_snapPreviewViewController.view removeFromSuperview];
			_snapPreviewViewController = nil;
		}
		
		_challengeOverlayView = [[HONChallengeOverlayView alloc] initWithChallenge:_challengeVO forOpponent:_opponentVO];
		_challengeOverlayView.delegate = self;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_challengeOverlayView];
	}
}



#pragma mark - Navigation
- (void)_tapTimeout {
	_isDoubleTap = NO;
}

- (void)_goClose {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Go Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self dismissViewControllerAnimated:YES completion:nil];

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
	[[Mixpanel sharedInstance] track:@"Timeline Details - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"creator", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:_challengeVO.creatorVO.username];
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

- (void)_goUpvoteChallenger:(int)userID {
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
		[self _upvoteChallenge:userID];
	}
	
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
}


#pragma mark - Notifications
- (void)_removePreview:(NSNotification *)notification {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	_challengeOverlayView = [[HONChallengeOverlayView alloc] initWithChallenge:_challengeVO forOpponent:_opponentVO];
	_challengeOverlayView.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_challengeOverlayView];
}


#pragma mark - ChallengeOverlay Delegates
- (void)challengeOverlayViewClose:(HONChallengeOverlayView *)challengeOverlayView {
	if (_challengeOverlayView != nil) {
		[_challengeOverlayView removeFromSuperview];
		_challengeOverlayView = nil;
	}
}

- (void)challengeOverlayViewUpvote:(HONChallengeOverlayView *)challengeOverlayView opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline Details - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	if (_challengeOverlayView != nil) {
		[_challengeOverlayView removeFromSuperview];
		_challengeOverlayView = nil;
	}
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 28.0, (([UIScreen mainScreen].bounds.size.height - 108.0) * 0.5) + 10.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
	
	if (_opponentVO.userID == _challengeVO.creatorVO.userID)
		[self _goUpvoteCreator];
	
	else
		[self _goUpvoteChallenger:_opponentVO.userID];
}

- (void)challengeOverlayViewFlag:(HONChallengeOverlayView *)challengeOverlayView opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline Details - Flag User"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:0];
	[alertView show];
	
	if (_challengeOverlayView != nil) {
		[_challengeOverlayView removeFromSuperview];
		_challengeOverlayView = nil;
	}
}

- (void)challengeOverlayViewProfile:(HONChallengeOverlayView *)challengeOverlayView opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"creator", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:_opponentVO.username];
	
	if (_challengeOverlayView != nil) {
		[_challengeOverlayView removeFromSuperview];
		_challengeOverlayView = nil;
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1)
			[self _flagUser:_opponentVO.userID];
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Timeline Details - Flag Challenge"
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
}

@end