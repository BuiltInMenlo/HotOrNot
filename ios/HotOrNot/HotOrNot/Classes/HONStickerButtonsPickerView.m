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
const CGSize kStickerImgPaddingSize = {11.0f, 9.0f};

@interface HONStickerButtonsPickerView () <HONStickerButtonViewDelegate>
@property (nonatomic, strong) __block NSMutableArray *availableEmotions;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSMutableArray *buttonPageViews;
@property (nonatomic, strong) NSMutableArray *buttonViews;
@property (nonatomic) CGSize gridItemSpacingSize;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) HONPaginationView *paginationView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) BOOL hasCachedAllStickers;
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
		_hasCachedAllStickers = NO;
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
		
		if (!_hasCachedAllStickers) {
			_downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_downloadButton.frame = CGRectMake(64.0, 65.0, 191.0, 44.0);
			[_downloadButton setBackgroundImage:[UIImage imageNamed:@"dlGroupButton_nonActive"] forState:UIControlStateNormal];
			[_downloadButton setBackgroundImage:[UIImage imageNamed:@"dlGroupButton_Active"] forState:UIControlStateHighlighted];
			_downloadButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
			[_downloadButton setTitleColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor] forState:UIControlStateNormal];
			[_downloadButton setTitleColor:[[HONColorAuthority sharedInstance] percentGreyscaleColor:0.33] forState:UIControlStateHighlighted];
			[_downloadButton setTitle:@"Download stickers" forState:(UIControlStateNormal&UIControlStateHighlighted)];
			[_downloadButton addTarget:self action:@selector(_goDownloadStickers) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_downloadButton];
		}
		
		_paginationView = [[HONPaginationView alloc] initAtPosition:CGPointMake(160.0, 165.0) withTotalPages:_totalPages usingDiameter:4.0 andPadding:6.0];
		_paginationView.hidden = YES;
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

- (void)willMoveToSuperview:(UIView *)newSuperview {
	NSLog(@"willMoveToSuperview:newSuperview:[%@]", newSuperview);
	[super willMoveToSuperview:newSuperview];
}

- (void)didMoveToSuperview {
	NSLog(@"didMoveToSuperview");
	[super didMoveToSuperview];
	
	if (_hasCachedAllStickers) {
		if (_downloadButton != nil) {
			[_downloadButton removeTarget:self action:@selector(_goDownloadStickers) forControlEvents:UIControlEventTouchUpInside];
			[_downloadButton removeFromSuperview];
			_downloadButton = nil;
		}
	}
}


#pragma mark - Public APIs
- (void)disablePagesStartingAt:(int)page {
	for (int i=page; i<[_buttonPageViews count]; i++) {
		UIView *pageView = (UIView *)[_buttonPageViews objectAtIndex:i];
		pageView.userInteractionEnabled = NO;
	}
}

- (void)scrollToPage:(int)page {
	[_scrollView scrollRectToVisible:CGRectMake(page * _scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:[[HONAnimationOverseer sharedInstance] isScrollingAnimationEnabledForScrollView:self]];
	[_paginationView updateToPage:page];
}

- (void)cacheStickerContentInRange:(NSRange)range {
	CGAffineTransform transform = [[HONViewDispensor sharedInstance] affineFrameTransformationByPercentage:0.10 forView:_downloadButton];
	[UIView animateWithDuration:0.250 delay:0.000
		 usingSpringWithDamping:0.925 initialSpringVelocity:0.0625
						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
					 animations:^(void) {
						 _downloadButton.transform = transform;
						 _downloadButton.alpha = 0.0;
					 }
					 completion:^(BOOL finished) {
						 if (_downloadButton != nil) {
							 [_downloadButton removeTarget:self action:@selector(_goDownloadStickers) forControlEvents:UIControlEventTouchUpInside];
							 [_downloadButton removeFromSuperview];
							 _downloadButton = nil;
						 }
					 }];
	
	if (_activityIndicatorView == nil)
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_activityIndicatorView.frame = CGRectOffset(_activityIndicatorView.frame, (self.frame.size.width - _activityIndicatorView.frame.size.width) * 0.5, ((self.frame.size.height - _activityIndicatorView.frame.size.height) * 0.5) - 23.0);
	[self addSubview:_activityIndicatorView];
	
	if (![_activityIndicatorView isAnimating])
		[_activityIndicatorView startAnimating];
	
	//NSLocalizedString(@"hud_loading", @"Loading…");
	
	__block int cnt = 0;
	__block int ind = 0;
	for (HONEmotionVO *vo in _availableEmotions) {
		if (ind >= range.location) {
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
			void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
				imageView.image = image;
				
				_hasCachedAllStickers = (++cnt == range.length);
				if (_hasCachedAllStickers)
					[self _finishCachingStickers];
			};
			
			void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
				_hasCachedAllStickers = (++cnt == range.length);
				if (_hasCachedAllStickers)
					[self _finishCachingStickers];
			};
			
			[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:vo.largeImageURL]
															   cachePolicy:kOrthodoxURLCachePolicy
														   timeoutInterval:[HONAppDelegate timeoutInterval]]
							 placeholderImage:nil
									  success:imageSuccessBlock
									  failure:imageFailureBlock];
		}
		
		if (++ind >= range.location + range.length)
			break;
	}
}
- (void)cacheAllStickerContent {
	[self cacheStickerContentInRange:NSMakeRange(0, [_availableEmotions count])];
}


#pragma mark - Data Handling
- (void)_finishCachingStickers {
	if (_activityIndicatorView != nil) {
		[_activityIndicatorView removeFromSuperview];
		if ([_activityIndicatorView isAnimating])
			[_activityIndicatorView stopAnimating];
		_activityIndicatorView = nil;
	}
	
	[self _buildGrid];
}

#pragma mark - Navigation
- (void)_goDownloadStickers {
	if ([self.delegate respondsToSelector:@selector(stickerButtonsPickerViewDidStartDownload:)])
		[self.delegate stickerButtonsPickerViewDidStartDownload:self];
}

#pragma mark - UI Presentation
static dispatch_queue_t sticker_request_operation_queue;
- (void)_buildGrid {
	NSLog(@"\t—//]> [%@ _buildGrid] (%d)/(%d)", self.class, _totalPages, [_availableEmotions count]);
	
	_paginationView.hidden = NO;
	
//	sticker_request_operation_queue = dispatch_queue_create("com.builtinmenlo.selfieclub.sticker-request", 0);
	
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
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(15.0 + (i * _scrollView.frame.size.width), 10.0, COLS_PER_ROW * _gridItemSpacingSize.width, ROWS_PER_PAGE * _gridItemSpacingSize.height)];
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
