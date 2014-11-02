//
//  HONStoreProductsViewController.m
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONRefreshControl.h"
#import "MBProgressHUD.h"


#import "HONStoreProductsViewController.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONTableView.h"
#import "HONStoreProductViewCell.h"
#import "HONStoreProductVO.h"

@interface HONStoreProductsViewController () <HONStoreProductCellDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *storeProducts;
@property (nonatomic, strong) HONStoreProductVO *storeProductVO;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end


@implementation HONStoreProductsViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeStickerStore;
		_viewStateType = HONStateMitigatorViewStateTypeStickerStore;
	}
	
	return (self);
}

-(void)dealloc {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONStoreProductViewCell *cell = (HONStoreProductViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retreiveStoreProducts {
	_storeProducts = [NSMutableArray array];
	[[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CountryCodes" ofType:@"plist"]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[_storeProducts addObject:[HONStoreProductVO productWithDictionary:(NSDictionary *)obj]];
		*stop = idx >= 2;
	}];
	
	[self _didFinishDataRefresh];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[self _retreiveStoreProducts];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(-2.0, 1.0, 44.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"closeButtonActive"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Store"];
	[headerView addButton:closeButton];
	[self.view addSubview:headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight)];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	[self _retreiveStoreProducts];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}


#pragma mark - Navigation
- (void)_goDone {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Sticker Store - Done"];
	[self dismissViewControllerAnimated:[[HONAnimationOverseer sharedInstance] isAnimationEnabledForViewControllerModalSegue:self] completion:nil];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Sticker Store - Close SWIPE"];
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}


#pragma mark - StoreProductCell Delegates
- (void)storeProductCell:(HONStoreProductViewCell *)cell purchaseStoreItem:(HONStoreProductVO *)storeItemVO {
	NSLog(@"[*:*] storeProductCell:purchaseStoreItem:[%@])", storeItemVO.dictionary);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Sticker Store - Selected Product"
									 withStoreProduct:storeItemVO];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_storeProducts count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return ([[HONTableHeaderView alloc] initWithTitle:@"Quotes"]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONStoreProductViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONStoreProductViewCell alloc] init];
	
	
	cell.storeProductVO = (HONStoreProductVO *)[_storeProducts objectAtIndex:indexPath.row];
	[cell hideChevron];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONStoreProductViewCell *viewCell = (HONStoreProductViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	viewCell.isPurchased = YES;
	
	_storeProductVO = (viewCell.isPurchased) ? viewCell.storeProductVO : nil;
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Sticker Store - Selected Product"
									 withStoreProduct:_storeProductVO];
	
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:@"Sticker_Pack_001", nil]];
	request.delegate = self;
	[request start];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 1.0;
//	cell.alpha = 0.0;
//	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
//		cell.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}


#pragma mark - ProductRequest Delegates
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	NSLog(@"[*:*] productsRequest:(%@) didReceiveResponse:(%@) [*:*]", request.description, response.description);
	
	NSArray *skProducts = response.products;
	SKProduct *product = (SKProduct *)[skProducts firstObject];
	SKMutablePayment *myPayment = [SKMutablePayment paymentWithProduct:product];
	[[SKPaymentQueue defaultQueue] addPayment:myPayment];
}


#pragma mark - StoreKitRequest Delegates
- (void)requestDidFinish:(SKRequest *)request {
	NSLog(@"[*:*] requestDidFinish:(%@) [*:*]", request.description);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"[*:*] productsRequest:(%@) didFailWithError:(%@) [*:*]", request.description, error.description);
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

@end
