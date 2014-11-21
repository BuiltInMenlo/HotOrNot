//
//  HONStoreProductViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/3/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONStoreProductViewController.h"
#import "HONStoreProductViewFlowLayout.h"
#import "HONStoreProductImageViewCell.h"
#import "HONRefreshControl.h"
#import "HONHeaderView.h"
#import "HONCollectionView.h"

@interface HONStoreProductViewController ()
@property (nonatomic, strong) HONCollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) HONStoreProductVO *storeProductVO;
@property (nonatomic, strong) UILabel *productNameLabel;
@property (nonatomic, strong) UILabel *productPriceLabel;
@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@property (nonatomic, strong) NSMutableArray *productImages;
@property (nonatomic, strong) UIButton *purchaseButton;
@end

@implementation HONStoreProductViewController

- (id)initWithStoreProduct:(HONStoreProductVO *)storeProductVO {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeStoreProductDetails;
		_viewStateType = HONStateMitigatorViewStateTypeStoreProductDetails;
		
		_storeProductVO = storeProductVO;
	}
	
	return (self);
}

-(void)dealloc {
	_collectionView.dataSource = nil;
	_collectionView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveProductImages {
	_productImages = [NSMutableArray array];
	[[HONStickerAssistant sharedInstance] retrieveContentsForContentGroupID:_storeProductVO.contentGroupID ignoringCache:YES completion:^(NSArray *result) {
		[result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			HONEmotionVO *vo = [HONEmotionVO emotionWithDictionary:(NSDictionary *)obj];
			[_productImages addObject:@{@"url"	: vo.smallImageURL,
										@"type"	: (vo.imageType == HONEmotionImageTypeGIF) ? @"gif" : @"png"}];
		}];
		
		[self _didFinishDataRefresh];
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Product Details - Refresh"
//									 withStoreProduct:_storeProductVO];
	
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeStoreProductDetailsRefresh];
	[self _reloadCollectionViewContents];
}

- (void)_reloadCollectionViewContents {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_productImages = [NSMutableArray array];
	[_collectionView reloadData];
	
	[self _retrieveProductImages];
}

- (void)_didFinishDataRefresh {
	NSLog(@"[%@ _didFinishDataRefresh", self.class);
	
	[_collectionView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_productImages = [NSMutableArray array];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:_storeProductVO.productName];
	[_headerView addBackButtonWithTarget:self action:@selector(_goBack)];
	[self.view addSubview:_headerView];
	
	UIView *summaryHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, 74.0)];
	[self.view addSubview:summaryHolderView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 16.0, 50.0, 50.0)];
	bgImageView.image = [UIImage imageNamed:@"stickerItemBG"];
	[summaryHolderView addSubview:bgImageView];
	
	_productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(79.0, 20.0, 260.0, 21.0)];
	_productNameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
	_productNameLabel.textColor =  [UIColor blackColor];
	_productNameLabel.backgroundColor = [UIColor clearColor];
	_productNameLabel.text = [NSString stringWithFormat:@"%d. %@", _storeProductVO.displayIndex, _storeProductVO.productName];
	[summaryHolderView addSubview:_productNameLabel];
	
	_productPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(79.0, 44.0, 260.0, 18.0)];
	_productPriceLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	_productPriceLabel.textColor =  [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	_productPriceLabel.backgroundColor = [UIColor clearColor];
	_productPriceLabel.text = (_storeProductVO.isPurchased) ? @"PURCHASED" : [NSString stringWithFormat:@"$%.02f", _storeProductVO.price];
	[summaryHolderView addSubview:_productPriceLabel];
	
	if (_storeProductVO.imageType == HONStoreProuctImageTypeGIF) {
		if (!_animatedImageView) {
			_animatedImageView = [[FLAnimatedImageView alloc] init];
			_animatedImageView.contentMode = UIViewContentModeScaleAspectFill;
			_animatedImageView.clipsToBounds = YES;
		}
		
		_animatedImageView.frame = bgImageView.frame;
		[summaryHolderView addSubview:_animatedImageView];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURL *url = [NSURL URLWithString:_storeProductVO.imageURL];
			FLAnimatedImage *animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				_animatedImageView.animatedImage = animatedImage;
			});
		});
		
	} else if (_storeProductVO.imageType == HONStoreProuctImageTypePNG) {
		_productImageView = [[UIImageView alloc] initWithFrame:bgImageView.frame];
		[summaryHolderView addSubview:_productImageView];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_productImageView.image = image;
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		};
		
		[_productImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_storeProductVO.imageURL]
																   cachePolicy:kOrthodoxURLCachePolicy
															   timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:nil
									   success:imageSuccessBlock
									   failure:imageFailureBlock];
	}
	
	_collectionView = [[HONCollectionView alloc] initWithFrame:CGRectMake(0.0, 145.0, 320.0, self.view.frame.size.height - 195.0) collectionViewLayout:[[HONStoreProductViewFlowLayout alloc] init]];
	[_collectionView registerClass:[HONStoreProductImageViewCell class] forCellWithReuseIdentifier:[HONStoreProductImageViewCell cellReuseIdentifier]];
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
	
	_purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_purchaseButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 50.0, 320.0, 50.0);
	[_purchaseButton setBackgroundImage:[UIImage imageNamed:(_storeProductVO.isPurchased) ? @"downloadButton_nonActive" : @"purchaseButton_nonActive"] forState:UIControlStateNormal];
	[_purchaseButton setBackgroundImage:[UIImage imageNamed:(_storeProductVO.isPurchased) ? @"downloadButton_Active" : @"purchaseButton_Active"] forState:UIControlStateHighlighted];
	[_purchaseButton addTarget:self action:(_storeProductVO.isPurchased) ? @selector(_goDownload) : @selector(_goPurchase) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_purchaseButton];
	
	[self _retrieveProductImages];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}


#pragma mark - Navigation
- (void)_goBack {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Product Details - Back"
//									 withStoreProduct:_storeProductVO];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goDownload {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Product Details - Download"
//									 withStoreProduct:_storeProductVO];
	
	if ([self.delegate respondsToSelector:@selector(storeProductViewController:didDownloadProduct:)])
		[self.delegate storeProductViewController:self didDownloadProduct:_storeProductVO];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goPurchase {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Product Details - Purchase"
//									 withStoreProduct:_storeProductVO];
	
	[[[UIAlertView alloc] initWithTitle:@"Congrats!"
								message:@"All store content is currently FREE. The items you have selected have been unlocked"
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", @"OK")
					  otherButtonTitles:nil] show];
	
	[[HONStickerAssistant sharedInstance] purchaseStickerPakWithContentGroupID:_storeProductVO.contentGroupID];
	
	if ([self.delegate respondsToSelector:@selector(storeProductViewController:didPurchaseProduct:)])
		[self.delegate storeProductViewController:self didPurchaseProduct:_storeProductVO];
	
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
//	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:@"Sticker_Pack_001", nil]];
//	request.delegate = self;
//	[request start];
//	
//	if ([self.delegate respondsToSelector:@selector(storeProductViewController:didPurchaseProduct:)])
//		[self.delegate storeProductViewController:self didPurchaseProduct:_storeProductVO];
}


#pragma mark - CollectionView DataSources
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return (1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return ([_productImages count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"[_] collectionView:cellForItemAtIndexPath:%@)", [@"" stringFromIndexPath:indexPath]);
	
	HONStoreProductImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HONStoreProductImageViewCell cellReuseIdentifier]
																					  forIndexPath:indexPath];
	
	[cell setIndexPath:indexPath];
	cell.imageDict = [_productImages objectAtIndex:indexPath.row];
	
	return (cell);
}


#pragma mark - CollectionView Delegates
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return (NO);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"[_] collectionView:didSelectItemAtIndexPath:%@)", [@"" stringFromIndexPath:indexPath]);	
//	HONStoreProductImageViewCell *viewCell = (HONStoreProductImageViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
}


#pragma mark - ProductsRequest Delegates
- (void)requestDidFinish:(SKRequest *)request {
	NSLog(@"[*:*] requestDidFinish:(%@) [*:*]", request.description);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"[*:*] request:(%@) didFailWithError:(%@) [*:*]", request.description, error.description);
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	NSLog(@"[*:*] productsRequest:(%@) didReceiveResponse:(%@) [*:*]", request.description, response.description);
	
	NSArray *skProducts = response.products;
	SKProduct *product = (SKProduct *)[skProducts firstObject];
	SKMutablePayment *myPayment = [SKMutablePayment paymentWithProduct:product];
	[[SKPaymentQueue defaultQueue] addPayment:myPayment];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}


@end
