//
//  HONComposeViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSCharacterSet+AdditionalSets.h"
#import "NSDate+Operations.h"
#import "NSMutableDictionary+Replacements.h"
#import "NSString+Formatting.h"
#import "UIImageView+AFNetworking.h"

#import "Flurry.h"

#import "HONComposeViewController.h"
#import "HONComposeViewFlowLayout.h"
#import "HONRefreshControl.h"
#import "HONCollectionView.h"
#import "HONComposeViewCell.h"
#import "HONComposeImageVO.h"
#import "HONComposeSubmitViewController.h"

@interface HONComposeViewController () <HONComposeViewCellDelegate>
@property (nonatomic, strong) HONCollectionView *collectionView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *composeImages;
@property (nonatomic, strong) HONComposeImageVO *selectedComposeImageVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@end


@implementation HONComposeViewController

- (id)init {
	if ((self = [super init])) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - enter_compose"];
		
		_composeImages = [NSMutableArray array];
		_totalType = HONStateMitigatorTotalTypeCompose;
		_viewStateType = HONStateMitigatorViewStateTypeCompose;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshCompose:)
													 name:@"REFRESH_COMPOSE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_tareCompose:)
													 name:@"TARE_COMPOSE" object:nil];
		
	}
	
	return (self);
}

-(void)dealloc {
	[[_collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONComposeViewCell *cell = (HONComposeViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_collectionView.dataSource = nil;
	_collectionView.delegate = nil;
	
	[super destroy];
}


- (id)initWithClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithClub:[%d] (%@)", [self description], clubVO.clubID, clubVO.clubName);
	
	if ((self = [self init])) {
		_userClubVO = clubVO;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retrieveComposeImages {
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"compose_images"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dict = (NSDictionary *)obj;
		[_composeImages addObject:[HONComposeImageVO composeImageWithDictionary:dict]];
	}];
	
	
	[self _didFinishDataRefresh];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeComposeRefresh];
	[self _goReloadContents];
}

- (void)_goReloadContents {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_composeImages = [NSMutableArray array];
	[_collectionView reloadData];
	
	[self _retrieveComposeImages];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_collectionView reloadData];
	[_refreshControl endRefreshing];
	
	NSLog(@"%@._didFinishDataRefresh - [%d]", self.class, [_composeImages count]);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_composeImages = [NSMutableArray array];
	
	_headerView = [[HONHeaderView alloc] init];
	[self.view addSubview:_headerView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = _headerView.frame;
	[closeButton setBackgroundImage:[UIImage imageNamed:@"composeHeaderButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"composeHeaderButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:closeButton];
	
	
	_collectionView = [[HONCollectionView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, ((kComposeCollectionViewCellSize.width + kComposeCollectionViewCellSpacing.width) * 2.0), self.view.frame.size.height - kNavHeaderHeight) collectionViewLayout:[[HONComposeViewFlowLayout alloc] init]];
	[_collectionView registerClass:[HONComposeViewCell class] forCellWithReuseIdentifier:[HONComposeViewCell cellReuseIdentifier]];
	[_collectionView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)];
	_collectionView.backgroundColor = [UIColor clearColor];
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.alwaysBounceVertical = YES;
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	[self.view addSubview:_collectionView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_collectionView addSubview: _refreshControl];
	
	[self _goReloadContents];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	longPressGestureRecognizer.minimumPressDuration = 0.5;
	longPressGestureRecognizer.delegate = self;
	longPressGestureRecognizer.delaysTouchesBegan = YES;
	longPressGestureRecognizer.cancelsTouchesInView = NO;
	longPressGestureRecognizer.delaysTouchesBegan = NO;
	longPressGestureRecognizer.delaysTouchesEnded = NO;
	[self.collectionView addGestureRecognizer:longPressGestureRecognizer];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewWillAppear:animated];
}


#pragma mark - Navigation
- (void)_goClose {
	NSLog(@"[*:*] _goClose");
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - exit_button"];
	
	[_headerView tappedTitle];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kButtonSelectDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
		}];
	});
}

- (void)_goNext {
	
	NSError *error;
	NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[_selectedComposeImageVO.composeImageName] options:0 error:&error]
												 encoding:NSUTF8StringEncoding];
	
	NSDictionary *submitParams = @{@"user_id"		: @([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]),
								   @"img_url"		: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], [[HONClubAssistant sharedInstance] defaultClubPhotoURL]],
								   @"club_id"		: @(_userClubVO.clubID),
								   @"challenge_id"	: @(0),
								   @"subjects"		: jsonString};
	NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", submitParams);
	
	[self.navigationController pushViewController:[[HONComposeSubmitViewController alloc] initWithSubmitParameters:submitParams] animated:NO];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
	
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:_collectionView]];
	
	if (indexPath != nil) {
		HONComposeViewCell *cell = (HONComposeViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
		_selectedComposeImageVO = cell.composeImageVO;
		
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
			NSLog(@"COMPOSE IMAGE:[%@]", [cell.composeImageVO toString]);
		}
	}
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Dismiss SWIPE"];
		
		[self dismissViewControllerAnimated:NO completion:^(void) {
		}];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Next SWIPE"];
//		[self _modifySubmitParamsAndSubmit:_subjectNames];
	}
}


#pragma mark - Notifications
- (void)_refreshCompose:(NSNotification *)notification {
	NSLog(@"::|> _refreshCompose <|::");
	[self _goReloadContents];
}

- (void)_tareCompose:(NSNotification *)notification {
	NSLog(@"::|> _tareCompose <|::");
	
	if ([_collectionView.visibleCells count] > 0)
		[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - UI Presentation


#pragma mark - ComposeImageViewCell Delegates
- (void)composeViewCell:(HONComposeViewCell *)viewCell didSelectComposeImage:(HONComposeImageVO *)composeImageVO {
	NSLog(@"[_] composeViewCell:didSelectComposeImage:[%@]", [composeImageVO toString]);
	
	_selectedComposeImageVO = viewCell.composeImageVO;
	NSLog(@"COMPOSE IMAGE:[%@]", [_selectedComposeImageVO toString]);
	
	[self _goNext];
}

#pragma mark - CollectionView DataSources
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	[collectionView.collectionViewLayout invalidateLayout];
	return (1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return ([_composeImages count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"[_] collectionView:cellForItemAtIndexPath:%@)", NSStringFromNSIndexPath(indexPath));
	
	HONComposeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HONComposeViewCell cellReuseIdentifier]
																		 forIndexPath:indexPath];
	
	[cell setIndexPath:indexPath];
	[cell setSize:kComposeCollectionViewCellSize];
	
	HONComposeImageVO *vo = (HONComposeImageVO *)[_composeImages objectAtIndex:indexPath.row];
	cell.composeImageVO = vo;
	cell.delegate = self;
	
//	if (!collectionView.decelerating)
//		[cell toggleImageLoading:YES];
	
	return (cell);
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[_] collectionView:didSelectItemAtIndexPath:[%@]", NSStringFromNSIndexPath(indexPath));
	HONComposeViewCell *cell = (HONComposeViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - select_image"];
	
	_selectedComposeImageVO = cell.composeImageVO;
	NSLog(@"COMPOSE IMAGE:[%@]", [_selectedComposeImageVO toString]);
	
	[self _goNext];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 1.0;
//	[UIView animateKeyframesWithDuration:0.125 delay:(0.125 * (indexPath.row / 3)) options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
//		cell.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//	HONHomeViewCell *viewCell = (HONHomeViewCell *)cell;
//	[viewCell toggleImageLoading:NO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	[[_collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONHomeViewCell *cell = (HONHomeViewCell *)obj;
//		[cell toggleImageLoading:YES];
//	}];
}



#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
		}
	}
}

@end
