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

const CGSize kImageSpacing2Size = {75.0f, 73.0f};

@interface HONEmotionsPickerView () <HONEmotionItemViewDelegate>
@property (nonatomic, strong) __block NSMutableArray *availableEmotions;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bgImageView;
//@property (nonatomic, strong) UIImageView *deleteButtonImageView;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) HONPaginationView *paginationView;
@property (nonatomic) int prevPage;
@property (nonatomic) int totalPages;
@property (nonatomic) BOOL isGlobal;
@end

@implementation HONEmotionsPickerView
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
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 5.0, 320.0, 272.0)];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
        
		UILabel *stickerPackLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,3,280,18 )];
        stickerPackLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
        stickerPackLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
        stickerPackLabel.backgroundColor = [UIColor clearColor];
        stickerPackLabel.textAlignment = NSTextAlignmentCenter;
        stickerPackLabel.text = NSLocalizedString(@"my_sticker", nil);
        [self addSubview:stickerPackLabel];
		
		UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		deleteButton.frame = CGRectMake(160.0, self.frame.size.height - 50.0, 160.0, 50.0);
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"deleteButton_nonActive"] forState:UIControlStateNormal];
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"deleteButton_Active"] forState:UIControlStateHighlighted];
		[deleteButton addTarget:self action:@selector(_goDelete) forControlEvents:UIControlEventTouchDown];
		[self addSubview:deleteButton];
        
        UIButton *globalButton = [UIButton buttonWithType:UIButtonTypeCustom];
		globalButton.frame = CGRectMake(0, self.frame.size.height - 50.0, 160.0, 50.0);
		[globalButton setBackgroundImage:[UIImage imageNamed:@"globalStoreButton_nonActive"] forState:UIControlStateNormal];
		[globalButton setBackgroundImage:[UIImage imageNamed:@"globalStoreButton_Active"] forState:UIControlStateHighlighted];
		[globalButton addTarget:self action:@selector(_goGlobal) forControlEvents:UIControlEventTouchDown];
		[self addSubview:globalButton];
		
		
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeSelfieclub])
			[_availableEmotions addObject:[HONEmotionVO emotionWithDictionary:dict]];
		
		for (NSDictionary *dict in [[HONStickerAssistant sharedInstance] fetchStickersForPakType:HONStickerPakTypeFree])
			[_availableEmotions addObject:[HONEmotionVO emotionWithDictionary:dict]];
		
		_totalPages = ((int)([_availableEmotions count] / (COLS_PER_ROW * ROWS_PER_PAGE))) + 1;
		_scrollView.contentSize = CGSizeMake(_totalPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
		
		_paginationView = [[HONPaginationView alloc] initAtPosition:CGPointMake(160.0, 242.0) withTotalPages:_totalPages usingDiameter:6.0 andPadding:8.0];
		[_paginationView updateToPage:0];
		[self addSubview:_paginationView];
		
		[self _buildGrid];
	}
	
	return (self);
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	CGPoint touchLocation = [[touches anyObject] locationInView:self];
//
//	if (CGRectContainsPoint(_deleteButtonImageView.frame, touchLocation))
//		_deleteButtonImageView.image = [UIImage imageNamed:@"emojiDeleteButton_Active"];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	CGPoint touchLocation = [[touches anyObject] locationInView:self];
//
//	if (CGRectContainsPoint(_deleteButtonImageView.frame, touchLocation)) {
//		_deleteButtonImageView.image = [UIImage imageNamed:@"emojiDeleteButton_nonActive"];
//		[self _goDelete];
//	}
//}


#pragma mark - Public APIs
- (void)scrollToPage:(int)page {
	[_scrollView scrollRectToVisible:CGRectMake(page * _scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:NO];
	[_paginationView updateToPage:page];
}

- (void)disablePagesStartingAt:(int)page {
	for (int i=page; i<[_pageViews count]; i++) {
		UIView *pageView = (UIView *)[_pageViews objectAtIndex:i];
		pageView.userInteractionEnabled = NO;
	}
}

#pragma mark - Navigation
- (void)_goDelete {
	if ([self.delegate respondsToSelector:@selector(emotionsPickerView:deselectedEmotion:)])
		[self.delegate emotionsPickerView:self deselectedEmotion:(HONEmotionVO *)[_selectedEmotions lastObject]];
	
	[_selectedEmotions removeLastObject];
}

-(void)_goGlobal {
    [self.delegate emotionsPickerView:self globalButton:YES];

//    //_bgImageView.image = [UIImage imageNamed:@"emojiPanelBG"];
//    [self.delegate emotionsPickerViewShowActionSheet:self];
//    _isGlobal = !_isGlobal;
//    if(_isGlobal){
//        _bgImageView.image = [UIImage imageNamed:@"cameraEmojiBoardBackground_Paid"];
//        for(UIView *view in _pageViews){
//            view.hidden = YES;
//        }
//    } else {
//        _bgImageView.image = [UIImage imageNamed:@"emojiPanelBG"];
//        for(UIView *view in _pageViews){
//            view.hidden = NO;
//        }
//    }
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
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(10.0 + (i * _scrollView.frame.size.width), 14.0, COLS_PER_ROW * kImageSpacing2Size.width, ROWS_PER_PAGE * kImageSpacing2Size.height)];
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
		
		HONEmoticonPickerItemView *emotionItemView = [[HONEmoticonPickerItemView alloc] initAtPosition:CGPointMake(col * kImageSpacing2Size.width, row * kImageSpacing2Size.height) withEmotion:vo withDelay:cnt * 0.125];
		// HONEmoticonPickerItemView *emotionItemView = [[HONEmoticonPickerItemView alloc] initWithFrame:CGRectMake(col * kImageSpacing2Size.width, row * kImageSpacing2Size.height, 75.0,73.0) withEmotion:vo withDelay:cnt * 0.125];
		
		emotionItemView.delegate = self;
		//		emotionItemView.userInteractionEnabled = (cnt < (COLS_PER_ROW * ROWS_PER_PAGE) || ([[HONContactsAssistant sharedInstance] totalInvitedContacts] >= [HONAppDelegate clubInvitesThreshold]));
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
	int offsetPage = MIN(MAX(round(scrollView.contentOffset.x / scrollView.frame.size.width), 0), _totalPages);
	
	if (offsetPage != _prevPage) {
		[_paginationView updateToPage:offsetPage];
		
		if ([self.delegate respondsToSelector:@selector(emotionsPickerView:didChangeToPage:withDirection:)])
			[self.delegate emotionsPickerView:self didChangeToPage:offsetPage withDirection:(_prevPage < offsetPage) ? 1 : -1];
		
		_prevPage = offsetPage;
	}
}




@end
