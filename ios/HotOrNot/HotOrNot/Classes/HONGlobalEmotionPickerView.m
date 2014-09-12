//
//  HONEmotionsPickerView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "HONGlobalEmotionPickerView.h"
#import "HONEmoticonPickerItemView.h"
#import "HONPaginationView.h"

#define COLS_PER_ROW	1
#define ROWS_PER_PAGE	1

const CGSize kImageSpacingSize = {154.0f, 149.0f};

@interface HONGlobalEmotionPickerView () <HONEmotionItemViewDelegate, SKProductsRequestDelegate>
@property (nonatomic, strong) __block NSMutableArray *availableEmotions;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) HONPaginationView *paginationView;
@property (nonatomic) int prevPage;
@property (nonatomic) int totalPages;
@property (nonatomic) BOOL isGlobal;
@end

@implementation HONGlobalEmotionPickerView
@synthesize delegate = _delegate;


- (void)_delayed {
	NSLog(@"STICKERS:[%@]", _availableEmotions);
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_availableEmotions = [NSMutableArray array];
		_selectedEmotions = [NSMutableArray array];
		
		_prevPage = 0;
		_totalPages = 10;
		_pageViews = [NSMutableArray array];
		_itemViews = [NSMutableArray array];
		
		
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emojiPanelBG"]];
		[self addSubview:_bgImageView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 272.0)];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		UILabel *stickerPackLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 9.0, 280.0, 18.0)];
		stickerPackLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
		stickerPackLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
		stickerPackLabel.backgroundColor = [UIColor clearColor];
		stickerPackLabel.textAlignment = NSTextAlignmentCenter;
		stickerPackLabel.text = NSLocalizedString(@"global_sticker", nil);
		[self addSubview:stickerPackLabel];
		
		UIButton *globalButton = [UIButton buttonWithType:UIButtonTypeCustom];
		globalButton.frame = CGRectMake(0, self.frame.size.height - 49.0, 160.0, 49.0);
		[globalButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_Active"] forState:UIControlStateNormal];
		[globalButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_Active"] forState:UIControlStateHighlighted];
		[globalButton addTarget:self action:@selector(_goGlobal) forControlEvents:UIControlEventTouchDown];
		[self addSubview:globalButton];
		
		UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		deleteButton.frame = CGRectMake(160.0, self.frame.size.height - 49.0, 160.0, 49.0);
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"emojiDeleteButton_nonActive"] forState:UIControlStateNormal];
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"emojiDeleteButton_Active"] forState:UIControlStateHighlighted];
		[deleteButton addTarget:self action:@selector(_goDelete) forControlEvents:UIControlEventTouchDown];
		[self addSubview:deleteButton];
		
		
		NSArray *contentGroupIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:@"paid"];
		for (NSString *contentGroupID in contentGroupIDs)
			[_availableEmotions addObject:[HONEmotionVO emotionWithDictionary:[[HONStickerAssistant sharedInstance] fetchCoverStickerForContentGroup:contentGroupID]]];
		
		_totalPages = ((int)([_availableEmotions count] / (COLS_PER_ROW * ROWS_PER_PAGE)));
		_scrollView.contentSize = CGSizeMake(_totalPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
		
		_paginationView = [[HONPaginationView alloc] initAtPosition:CGPointMake(160.0, 242.0) withTotalPages:_totalPages usingDiameter:6.0 andPadding:8.0];
		[_paginationView updateToPage:0];
		[self addSubview:_paginationView];
		
		[self _buildGrid];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)scrollToPage:(int)page {
	[_scrollView scrollRectToVisible:CGRectMake(page * _scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:NO];
	[_paginationView updateToPage:page];
}


#pragma mark - Navigation
- (void)_goDelete {
	if ([self.delegate respondsToSelector:@selector(emotionsPickerView:deselectedEmotion:)])
		[self.delegate emotionsPickerView:self deselectedEmotion:(HONEmotionVO *)[_selectedEmotions lastObject]];
	
	[_selectedEmotions removeLastObject];
}

-(void)_goGlobal {
	[self.delegate globalEmotionsPickerView:self globalButton:YES];
}


#pragma mark - UI Presentation
static dispatch_queue_t sticker_request_operation_queue;
- (void)_buildGrid {
	//NSLog(@"\t—//]> [%@ _buildGrid] (%d)", self.class, _totalPages);
	
	sticker_request_operation_queue = dispatch_queue_create("com.builtinmenlo.selfieclub.sticker-request", 0);
	
	int cnt = 0;
	int row = 0;
	int col = 0;
	int page = 0;
	
	for (int i=0; i<_totalPages; i++) {
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(84.0 + (i * _scrollView.frame.size.width), 46.0, COLS_PER_ROW * kImageSpacingSize.width, ROWS_PER_PAGE * kImageSpacingSize.height)];
		[holderView setTag:i];
		[_pageViews addObject:holderView];
		[_scrollView addSubview:holderView];
	}
	
	for (HONEmotionVO *vo in _availableEmotions) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:vo.contentGroupID] != nil) {
				
			} else {
//				[[HONStickerAssistant sharedInstance] retrieveContentsForContentGroup:vo.contentGroupID completion:nil];
			}
		});
		
		col = cnt % COLS_PER_ROW;
		row = (int)floor(cnt / COLS_PER_ROW) % ROWS_PER_PAGE;
		page = (int)floor(cnt / (COLS_PER_ROW * ROWS_PER_PAGE));
		
		HONEmoticonPickerItemView *emotionItemView = [[HONEmoticonPickerItemView alloc] initAtLargePosition:CGPointMake(col * kImageSpacingSize.width, row * kImageSpacingSize.height) withEmotion:vo withDelay:cnt * 0.125];
		emotionItemView.delegate = self;
		[_itemViews addObject:emotionItemView];
		[(UIView *)[_pageViews objectAtIndex:page] addSubview:emotionItemView];
		
		cnt++;
	}
}


#pragma mark - EmotionItemView Delegates
- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView selectedLargeEmotion:(HONEmotionVO *)emotionVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Selected Sticker Pak"
										withEmotion:emotionVO];
	
	[[HONStickerAssistant sharedInstance] nameForContentGroupID:emotionVO.contentGroupID completion:^(NSString *name) {
		if ([[name lowercaseString] rangeOfString:@" - free"].location != NSNotFound)
			name = [name substringToIndex:[[name lowercaseString] rangeOfString:@" - free"].location];

		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"confirm_purchase", nil), name]
															message:@""
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
		[alertView setTag:0];
		[alertView show];
		
		
//		if ([[name lowercaseString] rangeOfString:@" - free"].location != NSNotFound)
//			name = [name substringToIndex:[[name lowercaseString] rangeOfString:@" - free"].location];
//
//		SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:@"Sticker_Pack_001", nil]];
//		request.delegate = self;
//		[request start];
	}];
}

- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView selectedEmotion:(HONEmotionVO *)emotionVO {
	if ([_selectedEmotions count] < 100) {
		[_selectedEmotions addObject:emotionVO];
		
		if ([self.delegate respondsToSelector:@selector(emotionsPickerView:selectedEmotion:)])
			[self.delegate emotionsPickerView:self selectedEmotion:emotionVO];
	}
}

- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView deselectedEmotion:(HONEmotionVO *)emotionVO {
	[_selectedEmotions removeObject:emotionVO];
	if ([self.delegate respondsToSelector:@selector(emotionsPickerView:deselectedEmotion:)])
		[self.delegate emotionsPickerView:self deselectedEmotion:emotionVO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	int offsetPage = MIN(MAX(round(scrollView.contentOffset.x / scrollView.frame.size.width), 0), _totalPages);
	
	if (offsetPage != _prevPage) {
		[_paginationView updateToPage:offsetPage];
		
		if ([self.delegate respondsToSelector:@selector(emotionsPickerView:didChangeToPage:withDirection:)])
			[self.delegate emotionsPickerView:self didChangeToPage:offsetPage withDirection:(_prevPage < offsetPage) ? 1 : -1];
		
		_prevPage = offsetPage;
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Failed to load list of products.\n%@", error.description);
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	NSArray *skProducts = response.products;
	
	SKProduct *product = (SKProduct *)[skProducts firstObject];
	NSLog(@"Found product: %@ %@ %0.2f", product.productIdentifier, product.localizedTitle, product.price.floatValue);
	SKMutablePayment *myPayment = [SKMutablePayment paymentWithProduct:product];
	[[SKPaymentQueue defaultQueue] addPayment:myPayment];
		
//	for (SKProduct *skProduct in skProducts) {
//		NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
//		
//		SKMutablePayment *myPayment = [SKMutablePayment paymentWithProduct:skProduct];
//		[[SKPaymentQueue defaultQueue] addPayment:myPayment];
//	}
}

#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
			
			[[NSUserDefaults standardUserDefaults] setObject:@"Y" forKey:@"iap_01"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RELOAD_EMOTION_PICKER"
																object:nil];
			[self _goGlobal];
		}
	}
		
}



@end
