//
//  HONStickerSummaryView.m
//  HotOrNot
//
//  Created by BIM  on 10/29/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONStickerSummaryView.h"

const CGSize kStickerSize = {50.0f, 50.0f};
const CGSize kStickerPaddingSize = {0.0f, 0.0f};

@interface HONStickerSummaryView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *stickers;
@property (nonatomic, strong) NSMutableArray *stickerViews;
@property (nonatomic) int stickerSpacing;
@property (nonatomic) int currentIndex;
@end

@implementation HONStickerSummaryView
@synthesize delegate = _delegate;
@synthesize scrollThreshold = _scrollThreshold;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_stickerSpacing = kStickerSize.width + kStickerPaddingSize.width;
		_stickers = [NSMutableArray array];
		_stickerViews = [NSMutableArray array];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_scrollView.backgroundColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.965];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.contentInset = UIEdgeInsetsZero;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
	}
	
	return (self);
}

- (id)initAtPosition:(CGPoint)position {
	if ((self = [self initWithFrame:CGRectMake(position.x, position.y, 320.0 - position.x, 50.0)])) {
		
	}
	
	return (self);
}

- (void)dealloc {
	_scrollView.delegate = nil;
}


#pragma mark - Public APIs
- (void)appendSticker:(HONEmotionVO *)emotionVO {
	UIView *stickerView = [[UIView alloc] initWithFrame:CGRectMake(_stickerSpacing * [_stickers count], 0.0, kStickerSize.width, kStickerSize.height)];
	
	if (emotionVO.imageType == HONEmotionImageTypeGIF) {
		FLAnimatedImageView *animatedImageView = [[FLAnimatedImageView alloc] init];
		animatedImageView.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
		animatedImageView.contentMode = UIViewContentModeScaleAspectFit;
		animatedImageView.clipsToBounds = YES;
		animatedImageView.animatedImage = emotionVO.animatedImageView.animatedImage;
		[stickerView addSubview:animatedImageView];
		
	} else if (emotionVO.imageType == HONEmotionImageTypePNG) {
		UIImageView *thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
		thumbImageView.image = emotionVO.image;
		[stickerView addSubview:thumbImageView];
	}
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0.0, 297.0, 50.0, 50.0);
	[button setBackgroundImage:[UIImage imageNamed:@"blackMatte-128_000"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"blackMatte-128_020"] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[UIImage imageNamed:@"blackMatte-128_033"] forState:UIControlStateSelected];
	[button setBackgroundImage:[UIImage imageNamed:@"blackMatte-128_033"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
	[button addTarget:self action:@selector(_goSelectSticker:) forControlEvents:UIControlEventTouchDown];
	[button setTag:[_stickers count]];
	[stickerView addSubview:button];
	
	[_scrollView addSubview:stickerView];
	[_stickerViews addObject:stickerView];
	[_stickers addObject:emotionVO];
	
	int offset = ([_stickers count] == _scrollThreshold) ? (_stickerSpacing * 0.6) : ([_stickers count] > _scrollThreshold) ? _stickerSpacing : 0;
	_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width + offset, _scrollView.contentSize.height);
	_scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x + offset, _scrollView.contentOffset.y);
}

- (void)removeLastSticker {
	[self removeStickerAtIndex:[_stickers count] - 1];
}

- (void)removeStickerAtIndex:(int)index {
	index = MIN(MAX(0, index), [_stickers count] - 1);
	
	UIView *stickerView = [_stickerViews objectAtIndex:index];
	[stickerView removeFromSuperview];
	[_stickers removeObjectAtIndex:index];
}

- (void)scrollToStickerAtIndex:(int)index {
	[_scrollView setContentOffset:CGPointMake(_stickerSpacing * (MIN(MAX(0, index), [_stickers count] - 1)), 0.0) animated:NO];
}

- (void)setScrollThreshold:(int)scrollThreshold {
	_scrollThreshold = scrollThreshold;
}


#pragma mark - Navigation
- (void)_goSelectSticker:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	[_stickerViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIView *view = (UIView *)obj;
		UIButton *btn = [view.subviews lastObject];
		[btn setSelected:btn.tag == button.tag];
		*stop = btn.tag = button.tag;
	}];
	
	[self scrollToStickerAtIndex:button.tag];
	
	if ([self.delegate respondsToSelector:@selector(stickerSummaryView:didSelectThumb:)])
		[self.delegate stickerSummaryView:self didSelectThumb:(HONEmotionVO *)[_stickers objectAtIndex:button.tag]];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"[*:*] scrollViewDidScroll:[%@] (%@)", NSStringFromCGSize(scrollView.contentSize), NSStringFromCGPoint(scrollView.contentOffset));
}


@end
