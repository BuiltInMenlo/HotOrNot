//
//  HONStoreProductsViewController.m
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "HONStoreProductsViewController.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONRefreshControl.h"
#import "HONTableView.h"
#import "HONStoreProductViewCell.h"
#import "HONStoreProductVO.h"
#import "HONStoreProductViewController.h"

@interface HONStoreProductsViewController () <HONStoreProductViewControllerDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *storeProducts;
@property (nonatomic, strong) HONStoreProductVO *storeProductVO;
@end

@implementation HONStoreProductsViewController
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeStoreProducts;
		_viewStateType = HONStateMitigatorViewStateTypeStoreProducts;
	}
	
	return (self);
}

-(void)dealloc {
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retreiveStoreProducts {
	_storeProducts = [NSMutableArray array];
	
	__block NSMutableArray *names = [NSMutableArray array];
	[[[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypePaid] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dict = (NSDictionary *)obj;
		[[HONStickerAssistant sharedInstance] nameForContentGroupID:[dict objectForKey:@"cg_id"] completion:^(NSString *result) {
			
			__block BOOL isFound = NO;
			[names enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				isFound = ([(NSString *)obj isEqualToString:result]);
				*stop = isFound;
			}];
			
			if (!isFound) {
				[names addObject:result];
				HONEmotionVO *vo = [HONEmotionVO emotionWithDictionary:[[HONStickerAssistant sharedInstance] fetchCoverStickerForContentGroupID:[dict objectForKey:@"cg_id"]]];
				[_storeProducts addObject:[HONStoreProductVO productWithDictionary:@{@"product_id"	: [dict objectForKey:@"cg_id"],
																					 @"cg_id"		: [dict objectForKey:@"cg_id"],
																					 @"name"		: result,
																					 @"img_url"		: vo.smallImageURL,
																					 @"price"		: @"0.00",
																					 @"index"		: @([names count])}]];
			}
			
			[self _didFinishDataRefresh];
		}];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Sticker Store - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeStoreProductsRefresh];
	
	[self _reloadTableViewContents];
}

- (void)_reloadTableViewContents {
	_storeProducts = [NSMutableArray array];
	[_tableView reloadData];
	[self _retreiveStoreProducts];
}

- (void)_didFinishDataRefresh {
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Store"];
	[_headerView addCloseButtonWithTarget:self action:@selector(_goClose)];
	[self.view addSubview:_headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight)];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	[self _reloadTableViewContents];
}


#pragma mark - Navigation
- (void)_goClose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Sticker Store - Done"];
	[self dismissViewControllerAnimated:[[HONAnimationOverseer sharedInstance] isSegueAnimationEnabledForModalViewController:self] completion:nil];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Sticker Store - Close SWIPE"];
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}


#pragma mark - StoreProductViewController Delegates
- (void)storeProductViewController:(HONStoreProductViewController *)storeProductViewController didDownloadProduct:(HONStoreProductVO *)storeProductVO {
	NSLog(@"[*:*] storeProductViewController:didDownloadProduct:[%@ - %@]", storeProductVO.productID, storeProductVO.productName);
	
	if ([self.delegate respondsToSelector:@selector(storeProductsViewController:didDownloadProduct:)])
		[self.delegate storeProductsViewController:self didDownloadProduct:storeProductVO];
}

- (void)storeProductViewController:(HONStoreProductViewController *)storeProductViewController didPurchaseProduct:(HONStoreProductVO *)storeProductVO {
	NSLog(@"[*:*] storeProductViewController:didPurchaseProduct:[%@ - %@]", storeProductVO.productID, storeProductVO.productName);
	
	if ([self.delegate respondsToSelector:@selector(storeProductsViewController:didPurchaseProduct:)])
		[self.delegate storeProductsViewController:self didPurchaseProduct:storeProductVO];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_storeProducts count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *url = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"store"] objectForKey:@"banner"]  stringByReplacingOccurrencesOfString:@"png" withString:[[[NSLocale preferredLanguages] firstObject] stringByAppendingString:@".png"]];
	
	UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectFromSize([tableView rectForHeaderInSection:section].size)];
	[headerImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"storeProductsBanner"]];
	
	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONStoreProductViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONStoreProductViewCell alloc] init];
	
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	cell.storeProductVO = (HONStoreProductVO *)[_storeProducts objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (74.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (100.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONStoreProductViewCell *viewCell = (HONStoreProductViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	viewCell.isPurchased = YES;
	
	_storeProductVO = (viewCell.isPurchased) ? viewCell.storeProductVO : nil;
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Sticker Store - Selected Product"
//									 withStoreProduct:_storeProductVO];
	
	HONStoreProductViewController *storeProductViewController = [[HONStoreProductViewController alloc] initWithStoreProduct:_storeProductVO];
	storeProductViewController.delegate = self;
	[self.navigationController pushViewController:storeProductViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 1.0;
//	cell.alpha = 0.0;
//	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
//		cell.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}


@end
