//
//  HONEmotionsPickerView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionsPickerView.h"
#import "HONEmoticonPickerItemView.h"
#import "HONPaginationView.h"

const CGSize kStickerImgSize = {64.0f, 64.0f};
const CGSize kStickerImgPaddingSize = {12.0f, 12.0f};
const CGSize kStickerGrpBtnSize = {64.0f, 49.0f};

@interface HONEmotionsPickerView () <HONEmotionItemViewDelegate>
@property (nonatomic, strong) __block NSMutableArray *availableEmotions;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic) CGSize gridItemSpacingSize;
@property (nonatomic, strong) HONPaginationView *paginationView;
@property (nonatomic) int prevPage;
@property (nonatomic) int totalPages;
@property (nonatomic) BOOL isGlobal;
@end

@implementation HONEmotionsPickerView
@synthesize delegate = _delegate;
@synthesize stickerGroupType = _stickerGroupType;

- (id)initWithFrame:(CGRect)frame asEmotionGroupType:(HONStickerGroupType)stickerGroupType {
	if ((self = [super initWithFrame:frame])) {
		
		_gridItemSpacingSize = CGSizeMake(kStickerImgSize.width + kStickerImgPaddingSize.width, kStickerImgSize.height + kStickerImgPaddingSize.height);

		self.backgroundColor = [[HONColorAuthority sharedInstance] honBGLightGreyColor];
		_stickerGroupType = stickerGroupType;
		_availableEmotions = [NSMutableArray array];
		_selectedEmotions = [NSMutableArray array];
		
		_prevPage = 0;
		_totalPages = 0;
		_pageViews = [NSMutableArray array];
		_itemViews = [NSMutableArray array];
		
//		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emojiPanelBG"]];
//		_bgImageView.backgroundColor = [[HONColorAuthority sharedInstance] honGreenTextColor];
//		[self addSubview:_bgImageView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 5.0, 320.0, _gridItemSpacingSize.height * ROWS_PER_PAGE)];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		UIButton *stickersButton = [UIButton buttonWithType:UIButtonTypeCustom];
		stickersButton.frame = CGRectMake(0.0, self.frame.size.height - kStickerGrpBtnSize.height, kStickerGrpBtnSize.width, kStickerGrpBtnSize.height);
		[stickersButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_nonActive"] forState:UIControlStateNormal];
		[stickersButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_Active"] forState:UIControlStateHighlighted];
		[stickersButton addTarget:self action:@selector(_goGroup:) forControlEvents:UIControlEventTouchDown];
		[stickersButton setTag:HONStickerGroupTypeStickers];
		[self addSubview:stickersButton];
		
		UIButton *facesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		facesButton.frame = CGRectMake(1 * kStickerGrpBtnSize.width, self.frame.size.height - kStickerGrpBtnSize.height, kStickerGrpBtnSize.width, kStickerGrpBtnSize.height);
		[facesButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_nonActive"] forState:UIControlStateNormal];
		[facesButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_Active"] forState:UIControlStateHighlighted];
		[facesButton addTarget:self action:@selector(_goGroup:) forControlEvents:UIControlEventTouchDown];
		[facesButton setTag:HONStickerGroupTypeFaces];
		[self addSubview:facesButton];
		
		UIButton *animalsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		animalsButton.frame = CGRectMake(2 * kStickerGrpBtnSize.width, self.frame.size.height - kStickerGrpBtnSize.height, kStickerGrpBtnSize.width, kStickerGrpBtnSize.height);
		[animalsButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_nonActive"] forState:UIControlStateNormal];
		[animalsButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_Active"] forState:UIControlStateHighlighted];
		[animalsButton addTarget:self action:@selector(_goGroup:) forControlEvents:UIControlEventTouchDown];
		[animalsButton setTag:HONStickerGroupTypeAnimals];
		[self addSubview:animalsButton];
		
		UIButton *objectsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		objectsButton.frame = CGRectMake(3 * kStickerGrpBtnSize.width, self.frame.size.height - kStickerGrpBtnSize.height, kStickerGrpBtnSize.width, kStickerGrpBtnSize.height);
		[objectsButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_nonActive"] forState:UIControlStateNormal];
		[objectsButton setBackgroundImage:[UIImage imageNamed:@"emojiStoreButton_Active"] forState:UIControlStateHighlighted];
		[objectsButton addTarget:self action:@selector(_goGroup:) forControlEvents:UIControlEventTouchDown];
		[objectsButton setTag:HONStickerGroupTypeObjects];
		[self addSubview:objectsButton];
		
		UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		deleteButton.frame = CGRectMake(4 * kStickerGrpBtnSize.width, self.frame.size.height - kStickerGrpBtnSize.height, kStickerGrpBtnSize.width, kStickerGrpBtnSize.height);
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"emojiDeleteButton_nonActive"] forState:UIControlStateNormal];
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"emojiDeleteButton_Active"] forState:UIControlStateHighlighted];
		[deleteButton addTarget:self action:@selector(_goDelete) forControlEvents:UIControlEventTouchDown];
		[self addSubview:deleteButton];
		
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForGroupType:_stickerGroupType])
			[_availableEmotions addObject:[HONEmotionVO emotionWithDictionary:dict]];
		
		_totalPages = ((int)ceil([_availableEmotions count] / (COLS_PER_ROW * ROWS_PER_PAGE))) + 1;
		_scrollView.contentSize = CGSizeMake(_totalPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
		
		_paginationView = [[HONPaginationView alloc] initAtPosition:CGPointMake(160.0, 16.0) withTotalPages:_totalPages usingDiameter:6.0 andPadding:8.0];
		_paginationView.hidden = (_totalPages == 1);
		[_paginationView updateToPage:0];
		[self addSubview:_paginationView];
		
		[self _buildGrid];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)disablePagesStartingAt:(int)page {
	for (int i=page; i<[_pageViews count]; i++) {
		UIView *pageView = (UIView *)[_pageViews objectAtIndex:i];
		pageView.userInteractionEnabled = NO;
	}
}

- (void)scrollToPage:(int)page {
	[_scrollView scrollRectToVisible:CGRectMake(page * _scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:NO];
	[_paginationView updateToPage:page];
}


#pragma mark - Navigation
- (void)_goGroup:(id)sender {
	if ([self.delegate respondsToSelector:@selector(emotionsPickerView:changeGroup:)])
		[self.delegate emotionsPickerView:self changeGroup:((UIButton *)sender).tag];
}

- (void)_goDelete {
	if ([_selectedEmotions count] > 0) {
		if ([self.delegate respondsToSelector:@selector(emotionsPickerView:deselectedEmotion:)])
			[self.delegate emotionsPickerView:self deselectedEmotion:(HONEmotionVO *)[_selectedEmotions lastObject]];
		
		[_selectedEmotions removeLastObject];
	}
}


#pragma mark - UI Presentation
static dispatch_queue_t sticker_request_operation_queue;
- (void)_buildGrid {
	NSLog(@"\t—//]> [%@ _buildGrid] (%d)/(%d)", self.class, _totalPages, [_availableEmotions count]);
	
	sticker_request_operation_queue = dispatch_queue_create("com.builtinmenlo.selfieclub.sticker-request", 0);
	
	int cnt = 0;
	int row = 0;
	int col = 0;
	int page = 0;
	
	for (int i=0; i<_totalPages; i++) {
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(10.0 + (i * _scrollView.frame.size.width), 14.0, COLS_PER_ROW * _gridItemSpacingSize.width, ROWS_PER_PAGE * _gridItemSpacingSize.height)];
		[holderView setTag:i];
//		holderView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugBlueColor];
		[_pageViews addObject:holderView];
		[_scrollView addSubview:holderView];
	}
	
	for (HONEmotionVO *vo in _availableEmotions) {
//		cnt = (cnt > 0 && (cnt % ((COLS_PER_ROW * ROWS_PER_PAGE) - 1)) == 0) ? cnt++ : cnt;
		
		col = cnt % COLS_PER_ROW;
		row = (int)floor(cnt / COLS_PER_ROW) % ROWS_PER_PAGE;
		page = (int)floor(cnt / (COLS_PER_ROW * ROWS_PER_PAGE));
		
//		NSLog(@"CNT:[%02d] PAGE:[%d] COL:[%d] ROW:[%d]", cnt, page, col, row);
		
		HONEmoticonPickerItemView *emotionItemView = [[HONEmoticonPickerItemView alloc] initAtPosition:CGPointMake(col * _gridItemSpacingSize.width, row * _gridItemSpacingSize.height) withEmotion:vo withDelay:cnt * 0.125];
		emotionItemView.delegate = self;
		[_itemViews addObject:emotionItemView];
		[(UIView *)[_pageViews objectAtIndex:page] addSubview:emotionItemView];
		
		cnt++;
	}
}


#pragma mark - EmotionItemView Delegates
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
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	int offsetPage = MIN(MAX(round(scrollView.contentOffset.x / scrollView.frame.size.width), 0), _totalPages);
	
	if (offsetPage != _prevPage) {
		[_paginationView updateToPage:offsetPage];
		
		if ([self.delegate respondsToSelector:@selector(emotionsPickerView:didChangeToPage:withDirection:)])
			[self.delegate emotionsPickerView:self didChangeToPage:offsetPage withDirection:(_prevPage < offsetPage) ? 1 : -1];
		
		_prevPage = offsetPage;
	}
}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	int offsetPage = MIN(MAX(round(scrollView.contentOffset.x / scrollView.frame.size.width), 0), _totalPages);
//	
//	if (offsetPage != _prevPage) {
//		[_paginationView updateToPage:offsetPage];
//		
//		if ([self.delegate respondsToSelector:@selector(emotionsPickerView:didChangeToPage:withDirection:)])
//			[self.delegate emotionsPickerView:self didChangeToPage:offsetPage withDirection:(_prevPage < offsetPage) ? 1 : -1];
//		
//		_prevPage = offsetPage;
//	}
//}


@end
