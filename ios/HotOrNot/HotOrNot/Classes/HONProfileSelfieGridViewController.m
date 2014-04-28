//
//  HONProfileSelfieGridViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/27/2014 @ 07:22 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONProfileSelfieGridViewController.h"
#import "HONImagePickerViewController.h"

@interface HONProfileSelfieGridViewController () <HONSnapPreviewViewControllerDelegate>
@end


@implementation HONProfileSelfieGridViewController

- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initAtPos:yPos forChallenges:challenges asPrimaryOpponent:opponentVO])) {
		_selfieGridType = (opponentVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? HONSelfieGridTypeOwnProfile : HONSelfieGridTypeCohortProfile;
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
	
	[self buildGrid];
	
	_scrollView.frame = CGRectMake(0.0, 0.0, 320.0, ([UIScreen mainScreen].bounds.size.height));
	_scrollView.frame = CGRectOffset(_scrollView.frame, 0.0, -20.0);
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, MAX(_scrollView.frame.size.height + 220.0, _holderView.frame.size.height));
	
	NSLog(@"FRAME:[%@]", NSStringFromCGRect(_scrollView.frame));
	NSLog(@"SIZE:[%@]", NSStringFromCGSize(_scrollView.contentSize));
	NSLog(@"OFFSET:[%@]", NSStringFromCGPoint(_scrollView.contentOffset));
	NSLog(@"INSET:[%@]", NSStringFromUIEdgeInsets(_scrollView.contentInset));
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Public APIs
- (void)buildGrid {
	_gridItems = [NSMutableArray array];
	
	for (HONChallengeVO *vo in _challenges) {
		if (_heroOpponentVO.userID == vo.creatorVO.userID) {
			[_gridItems addObject:@{@"challenge"	: vo,
									@"participant"	: vo.creatorVO}];
		}
		
		for (HONOpponentVO *challenger in vo.challengers)
			if (_heroOpponentVO.userID == challenger.userID) {
				[_gridItems addObject:@{@"challenge"	: vo,
										@"participant"	: challenger}];
			}
	}
	
	NSLog(@"%@.buildGrid withTotal[%d]", [[self class] description], [_gridItems count]);
	[super buildGrid];
	
//	[_lpGestureRecognizer removeTarget:self action:@selector(goLongPress:)];
//	[self removeGestureRecognizer:_lpGestureRecognizer];
}

- (void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_holderView];
		NSLog(@"TOUCHPT:[%@]", NSStringFromCGPoint(touchPoint));
		
		NSDictionary *dict = [NSDictionary dictionary];
		if (CGRectContainsPoint(CGRectOffset(_holderView.frame, 0.0, -_yPos), touchPoint)) {
			int row = ((int)(touchPoint.y - _holderView.frame.origin.y) / (kSnapThumbSize.height + 1.0));
			int col = ((int)touchPoint.x / (kSnapThumbSize.width + 1.0));
			int idx = (row * 4) + col;
			
			NSLog(@"COORDS FOR CELL:[%d] -> (%d, %d)", idx, col, row);
			dict = ([_gridItems count] > 0 && idx < [_gridItems count]) ? [_gridItems objectAtIndex:idx] : [NSDictionary dictionary];
		}
		
		if ([dict count] > 0) {
			HONChallengeVO *challengeVO = (HONChallengeVO *)[dict objectForKey:@"challenge"];
			HONOpponentVO *opponentVO = (HONOpponentVO *)[dict objectForKey:@"participant"];
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"User Profile - Followers" withChallenge:challengeVO andParticipant:opponentVO];
			_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initFromProfileWithOpponent:opponentVO forChallenge:challengeVO];
			_snapPreviewViewController.delegate = self;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
			
		}
		//[self.delegate participantGridView:self removeParticipantItem:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}


#pragma mark - Navigation



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


@end
