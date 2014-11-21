//
//  HONAnimatedBGsViewController.m
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONAnimatedBGsViewController.h"
#import "HONAnimatedBGViewFlowLayout.h"
#import "HONAnimatedBGCollectionViewCell.h"
#import "HONCollectionView.h"
#import "HONRefreshControl.h"
#import "HONHeaderView.h"
#import "HONEmotionVO.h"

@interface HONAnimatedBGsViewController () <HONAnimatedBGCollectionViewCellDelegate>
@property (nonatomic, strong) HONCollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *animatedEmotions;
@property (nonatomic, strong) HONEmotionVO *selectedEmotionVO;
@end

@implementation HONAnimatedBGsViewController
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeAnimatedBGs;
		_viewStateType = HONStateMitigatorViewStateTypeAnimatedBGs;
	}
	
	return (self);
}

-(void)dealloc {
	[[_collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONAnimatedBGCollectionViewCell *cell = (HONAnimatedBGCollectionViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_collectionView.dataSource = nil;
	_collectionView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveEmotions {
	NSLog(@"[_] _retrieveEmotions");
	
	_animatedEmotions = [NSMutableArray array];
	[[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CountryCodes" ofType:@"plist"]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[_animatedEmotions addObject:[HONEmotionVO emotionWithDictionary:(NSDictionary *)obj]];
	}];
	
	[self _didFinishDataRefresh];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"BG Animations - Refresh"];
	[self _retrieveEmotions];
}

- (void)_didFinishDataRefresh {
	NSLog(@"[_] _didFinishDataRefresh");
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_collectionView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Animations"];
	[_headerView addCloseButtonWithTarget:self action:@selector(_goClose)];
	[self.view addSubview:_headerView];
	
	_collectionView = [[HONCollectionView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) collectionViewLayout:[[HONAnimatedBGViewFlowLayout alloc] init]];
	[_collectionView registerClass:[HONAnimatedBGCollectionViewCell class] forCellWithReuseIdentifier:[HONAnimatedBGCollectionViewCell cellReuseIdentifier]];
	_collectionView.backgroundColor = [UIColor whiteColor];
	[_collectionView setContentInset:UIEdgeInsetsZero];
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.alwaysBounceVertical = YES;
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	[self.view addSubview:_collectionView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_collectionView addSubview: _refreshControl];
	
	[self _retrieveEmotions];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.5;
	lpGestureRecognizer.delegate = self;
	lpGestureRecognizer.delaysTouchesBegan = YES;
	[self.collectionView addGestureRecognizer:lpGestureRecognizer];
}


#pragma mark - Navigation
- (void)_goClose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"BG Animations - Close"];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goDone {
	if ([self.delegate respondsToSelector:@selector(animatedBGViewController:didSelectEmotion:)])
		[self.delegate animatedBGViewController:self didSelectEmotion:_selectedEmotionVO];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
		return;
	
	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.collectionView]];
	
	if (indexPath != nil) {
		HONAnimatedBGCollectionViewCell *viewCell = (HONAnimatedBGCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
		_selectedEmotionVO = viewCell.emotionVO;
		
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"BG Animations - Long Press Cell"
//											  withEmotion:viewCell.emotionVO];
		
	}
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"BG Animations - Close SWIPE"];
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}


#pragma mark - AnimatedBGCollectionViewCell Delegates
- (void)animatedBGCollectionViewCell:(HONAnimatedBGCollectionViewCell *)viewCell didSelectEmotion:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] animatedBGCollectionViewCell:didSelectEmotion:[%@])", emotionVO.dictionary);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"BG Animations - Seleted Emotion"
//										  withEmotion:emotionVO];
	
	_selectedEmotionVO = emotionVO;
	[self _goDone];
}


#pragma mark - CollectionView DataSources
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return (1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return ([_animatedEmotions count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"[_] collectionView:cellForItemAtIndexPath:%@)", [@"" stringFromIndexPath:indexPath]);
	
	HONAnimatedBGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HONAnimatedBGCollectionViewCell cellReuseIdentifier]
																					  forIndexPath:indexPath];
	
	HONEmotionVO *vo = (HONEmotionVO *)[_animatedEmotions objectAtIndex:indexPath.row];
	cell.emotionVO = vo;
	cell.delegate = self;
	
	return (cell);
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//	HONEmotionVO *vo =  ((HONAnimatedBGViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).emotionVO;
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[_] collectionView:didSelectItemAtIndexPath:%@)", [@"" stringFromIndexPath:indexPath]);
	
	HONAnimatedBGCollectionViewCell *viewCell = (HONAnimatedBGCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	
//	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"BG Animations - Selected Emotion"
//										  withEmotion:viewCell.emotionVO];
	
	_selectedEmotionVO = viewCell.emotionVO;
	[self _goDone];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}


@end
