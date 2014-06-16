//
//  HONEmotionsPickerView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionsPickerView.h"
#import "HONEmoticonPickerItemView.h"
#import "HONEmotionPaginationView.h"

const CGSize kImageSpacingSize = {75.0f, 75.0f};

@interface HONEmotionsPickerView () <HONEmotionItemViewDelegate>
@property (nonatomic, strong) NSArray *freeEmotions;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) HONEmotionPaginationView *paginationView;
@property (nonatomic) int totalPages;
@end

@implementation HONEmotionsPickerView
@synthesize delegate = _delegate;


- (id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 321.0)])) {
		_freeEmotions = [HONAppDelegate freeEmotions];
		_selectedEmotions = [NSMutableArray array];
		
		_pageViews = [NSMutableArray array];
		_itemViews = [NSMutableArray array];
		
		_totalPages = ((int)([_freeEmotions count] / (COLS_PER_ROW * ROWS_PER_PAGE))) + 1;
		
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emojiPanelBG"]];
		[self addSubview:_bgImageView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 272.0)];
		_scrollView.contentSize = CGSizeMake(_totalPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		_paginationView = [[HONEmotionPaginationView alloc] initAtPosition:CGPointMake(160.0, 246.0) withTotalPages:_totalPages];
		[_paginationView updateToPage:0];
		[self addSubview:_paginationView];
		
		UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		deleteButton.frame = CGRectMake(0.0, self.frame.size.height - 49.0, 160.0, 49.0);
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"emojiDeleteButton_nonActive"] forState:UIControlStateNormal];
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"emojiDeleteButton_Active"] forState:UIControlStateHighlighted];
		[deleteButton addTarget:self action:@selector(_goDelete) forControlEvents:UIControlEventTouchDown];
		[self addSubview:deleteButton];
		
		[self _buildGrid];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goDelete {
	if ([self.delegate respondsToSelector:@selector(emotionsPickerView:deselectedEmotion:)])
		[self.delegate emotionsPickerView:self deselectedEmotion:(HONEmotionVO *)[_selectedEmotions lastObject]];
	
	[_selectedEmotions removeLastObject];
}


#pragma mark - UI Presentation
- (void)_buildGrid {
	//NSLog(@"\t—//]> [%@ _buildGrid] (%d)", self.class, _totalPages);
	
	int cnt = 0;
	int row = 0;
	int col = 0;
	int page = 0;
	
	for (int i=0; i<_totalPages; i++) {
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(10.0 + (i * _scrollView.frame.size.width), 5.0, COLS_PER_ROW * kImageSpacingSize.width, ROWS_PER_PAGE * kImageSpacingSize.height)];
		[holderView setTag:i];
		[_pageViews addObject:holderView];
		[_scrollView addSubview:holderView];
	}
	
	for (HONEmotionVO *vo in _freeEmotions) {
		col = cnt % COLS_PER_ROW;
		row = (int)floor(cnt / COLS_PER_ROW) % ROWS_PER_PAGE;
		page = (int)floor(cnt / (COLS_PER_ROW * ROWS_PER_PAGE));
		
		HONEmoticonPickerItemView *emotionItemView = [[HONEmoticonPickerItemView alloc] initAtPosition:CGPointMake(col * kImageSpacingSize.width, row * kImageSpacingSize.height) withEmotion:vo];
		emotionItemView.delegate = self;
		[emotionItemView setTag:cnt];
		[_itemViews addObject:emotionItemView];
		[(UIView *)[_pageViews objectAtIndex:page] addSubview:emotionItemView];
		
		cnt++;
	}
}


#pragma mark - EmotionItemView Delegates
- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView selectedEmotion:(HONEmotionVO *)emotionVO {
	
	[_selectedEmotions addObject:emotionVO];
	if ([self.delegate respondsToSelector:@selector(emotionsPickerView:selectedEmotion:)])
		[self.delegate emotionsPickerView:self selectedEmotion:emotionVO];
}

- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView deselectedEmotion:(HONEmotionVO *)emotionVO {
	
	[_selectedEmotions removeObject:emotionVO];
	if ([self.delegate respondsToSelector:@selector(emotionsPickerView:deselectedEmotion:)])
		[self.delegate emotionsPickerView:self deselectedEmotion:emotionVO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	int offsetPage = MIN(MAX(round(scrollView.contentOffset.x / scrollView.frame.size.width), 0), _totalPages);
	
	//NSLog(@"[*|*] scrollViewDidScroll:(%d) [*|*]", offsetPage);
	[_paginationView updateToPage:offsetPage];
}


@end
