//
//  HONStickerButtonsPickerView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"

#import "HONStickerButtonsPickerView.h"
#import "HONStickerButtonView.h"
#import "HONPaginationView.h"

const CGSize kStickerImgSize = {64.0f, 64.0f};
const CGSize kStickerImgPaddingSize = {12.0f, 12.0f};
const CGSize kStickerGrpBtnSize = {64.0f, 49.0f};

@interface HONStickerButtonsPickerView () <HONStickerButtonViewDelegate>
@property (nonatomic, strong) __block NSMutableArray *availableEmotions;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSMutableArray *buttonPageViews;
@property (nonatomic, strong) NSMutableArray *buttonViews;
@property (nonatomic) CGSize gridItemSpacingSize;
@property (nonatomic, strong) HONPaginationView *paginationView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) int prevPage;
@property (nonatomic) int totalPages;
@property (nonatomic) BOOL isGlobal;
@end

@implementation HONStickerButtonsPickerView
@synthesize delegate = _delegate;
@synthesize stickerGroupIndex = _stickerGroupIndex;

- (id)initWithFrame:(CGRect)frame asGroupIndex:(int)stickerGroupIndex {
	if ((self = [super initWithFrame:frame])) {
		
		_gridItemSpacingSize = CGSizeMake(kStickerImgSize.width + kStickerImgPaddingSize.width, kStickerImgSize.height + kStickerImgPaddingSize.height);
		
		_stickerGroupIndex = stickerGroupIndex;
		_availableEmotions = [NSMutableArray array];
		_selectedEmotions = [NSMutableArray array];
		
		_prevPage = 0;
		_totalPages = 0;
		_buttonPageViews = [NSMutableArray array];
		_buttonViews = [NSMutableArray array];
		
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emojiPanelBG"]];
		[self addSubview:_bgImageView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 5.0, 320.0, _gridItemSpacingSize.height * ROWS_PER_PAGE)];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		[[[HONStickerAssistant sharedInstance] fetchStickersForGroupIndex:_stickerGroupIndex] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[_availableEmotions addObject:[HONEmotionVO emotionWithDictionary:(NSDictionary *)obj]];
		}];
		
		_totalPages = ((int)ceil([_availableEmotions count] / (COLS_PER_ROW * ROWS_PER_PAGE))) + 1;
		_scrollView.contentSize = CGSizeMake(_totalPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
		
		_paginationView = [[HONPaginationView alloc] initAtPosition:CGPointMake(160.0, 160.0) withTotalPages:_totalPages usingDiameter:4.0 andPadding:6.0];
		_paginationView.hidden = (_totalPages == 1);
		[_paginationView updateToPage:0];
		[self addSubview:_paginationView];
	}
	
	return (self);
}

- (void)dealloc {
	_scrollView.delegate = nil;
	
	[_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONStickerButtonView *view = (HONStickerButtonView *)obj;
		view.delegate = nil;
	}];
}


#pragma mark - Public APIs
- (void)disablePagesStartingAt:(int)page {
	for (int i=page; i<[_buttonPageViews count]; i++) {
		UIView *pageView = (UIView *)[_buttonPageViews objectAtIndex:i];
		pageView.userInteractionEnabled = NO;
	}
}

- (void)scrollToPage:(int)page {
	[_scrollView scrollRectToVisible:CGRectMake(page * _scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:NO];
	[_paginationView updateToPage:page];
}

- (void)preloadImages {
	if (_activityIndicatorView == nil)
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_activityIndicatorView.frame = CGRectOffset(_activityIndicatorView.frame, (self.frame.size.width - _activityIndicatorView.frame.size.width) * 0.5, ((self.frame.size.height - _activityIndicatorView.frame.size.height) * 0.5) - 30.0);
	[self addSubview:_activityIndicatorView];
	
	if (![_activityIndicatorView isAnimating])
		[_activityIndicatorView startAnimating];
	
	//NSLocalizedString(@"hud_loading", @"Loading…");
	
	__block int cnt = 0;
	for (HONEmotionVO *vo in _availableEmotions) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
			if (++cnt == [_availableEmotions count]) {
				if (_activityIndicatorView != nil) {
					[_activityIndicatorView removeFromSuperview];
					if ([_activityIndicatorView isAnimating])
						[_activityIndicatorView stopAnimating];
					_activityIndicatorView = nil;
				}
				
				[self _buildGrid];
			}
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			if (++cnt == [_availableEmotions count]) {
				if (_activityIndicatorView != nil) {
					[_activityIndicatorView removeFromSuperview];
					if ([_activityIndicatorView isAnimating])
						[_activityIndicatorView stopAnimating];
					_activityIndicatorView = nil;
				}
				
				[self _buildGrid];
			}
		};
		
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:vo.largeImageURL]
														   cachePolicy:kOrthodoxURLCachePolicy
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:imageSuccessBlock
								  failure:imageFailureBlock];
	}
}


#pragma mark - Navigation


#pragma mark - UI Presentation
static dispatch_queue_t sticker_request_operation_queue;
- (void)_buildGrid {
	NSLog(@"\t—//]> [%@ _buildGrid] (%d)/(%d)", self.class, _totalPages, [_availableEmotions count]);
	
	sticker_request_operation_queue = dispatch_queue_create("com.builtinmenlo.selfieclub.sticker-request", 0);
	
	[_buttonPageViews removeAllObjects];
	[_scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIView *view = (UIView *)obj;
		[view removeFromSuperview];
	}];
	
	int cnt = 0;
	int row = 0;
	int col = 0;
	int page = 0;
	
	for (int i=0; i<_totalPages; i++) {
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(10.0 + (i * _scrollView.frame.size.width), 3.0, COLS_PER_ROW * _gridItemSpacingSize.width, ROWS_PER_PAGE * _gridItemSpacingSize.height)];
		[holderView setTag:i];
		[_buttonPageViews addObject:holderView];
		[_scrollView addSubview:holderView];
	}
	
	for (HONEmotionVO *vo in _availableEmotions) {
		col = cnt % COLS_PER_ROW;
		row = (int)floor(cnt / COLS_PER_ROW) % ROWS_PER_PAGE;
		page = (int)floor(cnt / (COLS_PER_ROW * ROWS_PER_PAGE));
		
//		NSLog(@"CNT:[%02d] PAGE:[%d] COL:[%d] ROW:[%d]", cnt, page, col, row);
		
		HONStickerButtonView *emotionItemView = [[HONStickerButtonView alloc] initAtPosition:CGPointMake(col * _gridItemSpacingSize.width, row * _gridItemSpacingSize.height) withEmotion:vo withDelay:cnt * 0.05125];
		emotionItemView.delegate = self;
		[_buttonViews addObject:emotionItemView];
		[(UIView *)[_buttonPageViews objectAtIndex:page] addSubview:emotionItemView];
		
		cnt++;
	}
}


#pragma mark - StickerButtonView Delegates
- (void)stickerButtonView:(HONStickerButtonView *)stickerButtonView selectedEmotion:(HONEmotionVO *)emotionVO {
	if ([_selectedEmotions count] < 100) {
		[_selectedEmotions addObject:emotionVO];
		
		if ([self.delegate respondsToSelector:@selector(stickerButtonsPickerView:selectedEmotion:)])
			[self.delegate stickerButtonsPickerView:self selectedEmotion:emotionVO];
	}
}

- (void)emotionItemView:(HONStickerButtonView *)stickerButtonView deselectedEmotion:(HONEmotionVO *)emotionVO {
	[_selectedEmotions removeObject:emotionVO];
	if ([self.delegate respondsToSelector:@selector(stickerButtonsPickerView:deselectedEmotion:)])
		[self.delegate stickerButtonsPickerView:self deselectedEmotion:emotionVO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	int offsetPage = MIN(MAX(round(scrollView.contentOffset.x / scrollView.frame.size.width), 0), _totalPages);
	
	if (offsetPage != _prevPage) {
		[_paginationView updateToPage:offsetPage];
		
		if ([self.delegate respondsToSelector:@selector(stickerButtonsPickerView:didChangeToPage:withDirection:)])
			[self.delegate stickerButtonsPickerView:self didChangeToPage:offsetPage withDirection:(_prevPage < offsetPage) ? 1 : -1];
		
		_prevPage = offsetPage;
	}
}

@end
