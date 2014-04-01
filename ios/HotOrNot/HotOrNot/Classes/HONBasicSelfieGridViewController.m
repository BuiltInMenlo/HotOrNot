//
//  HONBasicSelfieGridViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/27/2014 @ 07:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONBasicSelfieGridViewController.h"
#import "HONAPICaller.h"
#import "HONHeaderView.h"
#import "HONImagePickerViewController.h"
#import "HONChallengeDetailsViewController.h"

@interface HONBasicSelfieGridViewController () <HONSnapPreviewViewControllerDelegate>
	
@end


@implementation HONBasicSelfieGridViewController
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super init])) {
		_yPos = yPos;
		
		_challenges = [NSMutableArray arrayWithObject:challengeVO];
		_heroOpponentVO = opponentVO;
	}
	
	return (self);
}

- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super init])) {
		_yPos = yPos;
		
		_challenges = [challenges mutableCopy];
		_heroOpponentVO = opponentVO;
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


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:_heroOpponentVO.username];
	headerView.alpha = 0.667;
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(15.0, 0.0, 64.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, (animated) ? @"YES" : @"NO");
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Public APIs
- (void)buildGrid {
	_gridViews = [NSMutableArray array];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, _yPos, 320.0, kSnapThumbSize.height * (([_gridItems count] / 4) + ([_gridItems count] % 4 != 0)))];
	[_scrollView addSubview:_holderView];
	
	_itemCounter = 0;
	for (NSDictionary *dict in _gridItems) {
		UIView *gridItemView = [self createItemForParticipant:[dict objectForKey:@"participant"] fromChallenge:[dict objectForKey:@"challenge"]];
		[gridItemView setTag:_itemCounter];
		[_gridViews addObject:gridItemView];
		[_holderView addSubview:gridItemView];
		
		_itemCounter++;
	}
	
	// attach long tap
	_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(goLongPress:)];
	_lpGestureRecognizer.minimumPressDuration = 0.25;
	[self.view addGestureRecognizer:_lpGestureRecognizer];
}

- (UIView *)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO {
	//	NSLog(@"\t--GRID IMAGE(%d):[%@]", _participantCounter, [NSString stringWithFormat:@"%@",  [opponentVO.imagePrefix stringByReplacingOccurrencesOfString:@"https://d1fqnfrnudpaz6.cloudfront.net/" withString:@""]]);
	
	CGPoint pos = CGPointMake(kSnapThumbSize.width * (_itemCounter % 4), kSnapThumbSize.height * (_itemCounter / 4));
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapThumbSize.width, kSnapThumbSize.height)];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapThumbSize.width, kSnapThumbSize.height)];
	[imageHolderView addSubview:imageView];
	
	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteButton.frame = CGRectMake(55.0, 55.0, 24.0, 24.0);
	[deleteButton setBackgroundImage:[UIImage imageNamed:@"deleteIcon_nonActive"] forState:UIControlStateNormal];
	[deleteButton setBackgroundImage:[UIImage imageNamed:@"deleteIcon_Active"] forState:UIControlStateHighlighted];
	[deleteButton addTarget:self action:@selector(_goDelete:) forControlEvents:UIControlEventTouchUpInside];
	[deleteButton setTag:_itemCounter];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			if (_selfieGridType == HONSelfieGridTypeOwnProfile)
				[imageHolderView addSubview:deleteButton];
			
//			if (![vo.subjectName isEqualToString:challengeVO.creatorVO.subjectName])
//				[imageHolderView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"replyVolleyOverlay"]]];
		}];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//		NSLog(@"FAILED:[%@]", error.description);
//		[[HONAPICaller sharedInstance] notifyToProcessImageSizesForURL:opponentVO.imagePrefix completion:nil];
		imageHolderView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		if (_selfieGridType == HONSelfieGridTypeOwnProfile)
			[imageHolderView addSubview:deleteButton];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[opponentVO.imagePrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval] * 50.0]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:imageFailureBlock];
	
	_previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_previewButton.frame = imageView.frame;
	[_previewButton addTarget:self action:(_selfieGridType == HONSelfieGridTypeDetails) ? @selector(_goPreview:) : @selector(_goDetails:) forControlEvents:UIControlEventTouchUpInside];
	[_previewButton setTag:_itemCounter];
	[imageHolderView addSubview:_previewButton];
	
	return (imageHolderView);
}

- (void)refreshGrid {
	for (UIView *view in _gridViews)
		[view removeFromSuperview];
	
	[_gridViews removeAllObjects];
	
	[self buildGrid];
}

-(void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	NSLog(@"goLongPress:[%d]", lpGestureRecognizer.state);
	
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goDelete:(id)sender {
	NSDictionary *dict = [_gridItems objectAtIndex:[sender tag]];
	HONChallengeVO *challengeVO = (HONChallengeVO *)[dict objectForKey:@"challenge"];
	HONOpponentVO *opponentVO = (HONOpponentVO *)[dict objectForKey:@"participant"];
	
	[[Mixpanel sharedInstance] track:@"User Profile - Remove Selfie"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d", opponentVO.userID], @"userID", nil]];
	
	_selectedChallengeVO = challengeVO;
	_selectedOpponentVO = opponentVO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete your selfie?"
														message:@""
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goDetails:(id)sender {
	NSDictionary *dict = [_gridItems objectAtIndex:[sender tag]];
	HONChallengeVO *challengeVO = (HONChallengeVO *)[dict objectForKey:@"challenge"];
//	HONOpponentVO *opponentVO = (HONOpponentVO *)[dict objectForKey:@"participant"];
	
	[[Mixpanel sharedInstance] track:@"User Profile - Show Details"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goPreview:(id)sender {
	NSDictionary *dict = [_gridItems objectAtIndex:[sender tag]];
	HONChallengeVO *challengeVO = (HONChallengeVO *)[dict objectForKey:@"challenge"];
	HONOpponentVO *opponentVO = (HONOpponentVO *)[dict objectForKey:@"participant"];
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initFromProfileWithOpponent:opponentVO forChallenge:challengeVO];
	_snapPreviewViewController.delegate = self;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}


#pragma mark - UI Presentation
- (void)_removeSnapOverlay {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController upvoteOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController flagOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController joinChallenge:(HONChallengeVO *)challengeVO {
	[self _removeSnapOverlay];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	[self _removeSnapOverlay];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Remove Selfie %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _selectedOpponentVO.userID, _selectedOpponentVO.username], @"opponent", nil]];
	
	if (buttonIndex == 1) {
		[[HONAPICaller sharedInstance] removeChallengeForChallengeID:_selectedChallengeVO.challengeID withImagePrefix:_selectedOpponentVO.imagePrefix completion:^(NSObject *result) {
			if (result != nil)
				[self refreshGrid];
		}];
	}
}

@end
