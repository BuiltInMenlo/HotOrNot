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

@interface HONEmotionsPickerView () <HONEmotionItemViewDelegate>
@property (nonatomic, strong) NSArray *freeEmotions;
@property (nonatomic, strong) NSArray *paidEmotions;
@property (nonatomic, strong) NSArray *cameraEmotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) HONEmotionPaginationView *paginationView;
@property (nonatomic, assign) HONEmotionsPickerType emotionsPickerType;
@property (nonatomic) int totalPages;
@end

@implementation HONEmotionsPickerView
@synthesize delegate = _delegate;


- (id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 303.0)])) {
		_freeEmotions = [HONAppDelegate freeEmotions];
		_paidEmotions = [NSMutableArray array];
		_cameraEmotions = [NSMutableArray array];
		
		_pageViews = [NSMutableArray array];
		_itemViews = [NSMutableArray array];
		
		_emotionsPickerType = HONEmotionsPickerTypeFree;
		_totalPages = ((int)([_freeEmotions count] / (COLS_PER_ROW * ROWS_PER_PAGE))) + 1;
		
		
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_emotionsPickerType == HONEmotionsPickerTypeFree) ? @"emojiBG_free" : @"emojiBG_paid"]];
		[self addSubview:_bgImageView];
		
		UIView *buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 40.0, 320.0, 40.0)];
		buttonHolderView.backgroundColor = [UIColor brownColor];
		[self addSubview:buttonHolderView];
		
		UIButton *freeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		freeButton.frame = CGRectMake(0.0, 0.0, 107.0, 40.0);
		[freeButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
		[freeButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
		[freeButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
		[freeButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted|UIControlStateSelected];
		[freeButton addTarget:self action:@selector(_goFree) forControlEvents:UIControlEventTouchDown];
		[buttonHolderView addSubview:freeButton];
		
		UIButton *paidButton = [UIButton buttonWithType:UIButtonTypeCustom];
		paidButton.frame = CGRectMake(107.0, 0.0, 106.0, 40.0);
		[paidButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
		[paidButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
		[paidButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
		[paidButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted|UIControlStateSelected];
		[paidButton addTarget:self action:@selector(_goPaid) forControlEvents:UIControlEventTouchDown];
		[buttonHolderView addSubview:paidButton];
		
		UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraButton.frame = CGRectMake(213.0, 0.0, 107.0, 40.0);
		[cameraButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
		[cameraButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
		[cameraButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
		[cameraButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted|UIControlStateSelected];
		[cameraButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchDown];
		[buttonHolderView addSubview:cameraButton];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 263.0)];
		_scrollView.contentSize = CGSizeMake(_totalPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		_paginationView = [[HONEmotionPaginationView alloc] initAtPosition:CGPointMake(160.0, 246.0) withTotalPages:_totalPages];
		[_paginationView updateToPage:0];
		[self addSubview:_paginationView];
		
		[self _buildGrid];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goFree {
	_emotionsPickerType = HONEmotionsPickerTypeFree;
	_bgImageView.image = [UIImage imageNamed:@"emojiBG_free"];
}

- (void)_goPaid {
	_emotionsPickerType = HONEmotionsPickerTypePaid;
	_bgImageView.image = [UIImage imageNamed:@"emojiBG_paid"];
}

- (void)_goCamera {
	
}


#pragma mark - UI Presentation
- (void)_buildGrid {
	//NSLog(@"\t—//]> [%@ _buildGrid] (%d)", self.class, _totalPages);
	
	int cnt = 0;
	int row = 0;
	int col = 0;
	int page = 0;
	
	for (int i=0; i<_totalPages; i++) {
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(10.0 + (i * _scrollView.frame.size.width), 5.0, COLS_PER_ROW * 75.0, ROWS_PER_PAGE * 75.0)];
		[holderView setTag:i];
		[_pageViews addObject:holderView];
		[_scrollView addSubview:holderView];
	}
	
	for (HONEmotionVO *vo in _freeEmotions) {
		col = cnt % COLS_PER_ROW;
		row = (int)floor(cnt / COLS_PER_ROW) % ROWS_PER_PAGE;
		page = (int)floor(cnt / (COLS_PER_ROW * ROWS_PER_PAGE));
		
		HONEmoticonPickerItemView *emotionItemView = [[HONEmoticonPickerItemView alloc] initAtPosition:CGPointMake(col * 75.0, row * 75.0) withEmotion:vo];
		emotionItemView.delegate = self;
		[emotionItemView setTag:cnt];
		[_itemViews addObject:emotionItemView];
		[(UIView *)[_pageViews objectAtIndex:page] addSubview:emotionItemView];
		
		cnt++;
	}
}


#pragma mark - EmotionItemView Delegates
- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView selectedEmotion:(HONEmotionVO *)emotionVO {
	if ([self.delegate respondsToSelector:@selector(emotionsPickerView:selectedEmotion:)])
		[self.delegate emotionsPickerView:self selectedEmotion:emotionVO];
}

- (void)emotionItemView:(HONEmoticonPickerItemView *)emotionItemView deselectedEmotion:(HONEmotionVO *)emotionVO {
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
