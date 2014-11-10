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

const CGSize kStickerPaddingSize = {0.0f, 0.0f};

const CGFloat kStickerOutroDuration = 0.125;
const CGFloat kStickerOutroDelay = 0.125;
const CGFloat kStickerOutroDamping = 0.950;
const CGFloat kStickerOutroForce = 0.125;

@interface HONStickerSummaryView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *stickers;
@property (nonatomic, strong) NSMutableArray *stickerViews;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpGestureRecognizer;
@property (nonatomic, strong) HONEmotionVO *selectedEmotionVO;
@property (nonatomic) int scrollThreshold;
@property (nonatomic) int stickerSize;
@property (nonatomic) int stickerSpacing;
@property (nonatomic) int currentIndex;
@end

@implementation HONStickerSummaryView
@synthesize delegate = _delegate;
@synthesize scrollThreshold = _scrollThreshold;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_stickerSize = frame.size.height;
		_stickerSpacing = frame.size.height + kStickerPaddingSize.width;
		_stickers = [NSMutableArray array];
		_stickerViews = [NSMutableArray array];
		_selectedEmotionVO = nil;
		
		_scrollThreshold = ceil(self.frame.size.width / _stickerSpacing);
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectFromSize(self.frame.size)];
		_scrollView.backgroundColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.965];
		_scrollView.contentSize = CGSizeMake(0.0, _scrollView.frame.size.height);
		_scrollView.contentInset = UIEdgeInsetsZero;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
		_lpGestureRecognizer.minimumPressDuration = 0.5;
		_lpGestureRecognizer.delegate = self;
		_lpGestureRecognizer.delaysTouchesBegan = YES;
		[self addGestureRecognizer:_lpGestureRecognizer];
	}
	
	return (self);
}

- (id)initAtPosition:(CGPoint)position withHeight:(CGFloat)height {
	if ((self = [self initWithFrame:CGRectMake(position.x, position.y, 320.0 - position.x, height)])) {
		
	}
	
	return (self);
}

- (void)dealloc {
	_scrollView.delegate = nil;
}


#pragma mark - Public APIs
- (void)appendStickerAndSelect:(HONEmotionVO *)emotionVO {
	[self appendSticker:emotionVO];
	
	UIView *stickerView = (UIView *)[_stickerViews lastObject];
	UIButton *button = [stickerView.subviews lastObject];
	[button setSelected:YES];
	
	[self scrollToStickerAtIndex:(int)[_stickers count] - 1];
}

- (void)appendSticker:(HONEmotionVO *)emotionVO {
	UIView *stickerView = [[UIView alloc] initWithFrame:CGRectMake(_stickerSpacing * [_stickers count], 0.0, _stickerSize, _stickerSize)];
	
	CGRect frame = CGRectFromSize(CGSizeMake(_stickerSize, _stickerSize));
	if (emotionVO.imageType == HONEmotionImageTypeGIF) {
		FLAnimatedImageView *animatedImageView = [[FLAnimatedImageView alloc] init];
		animatedImageView.frame = frame;
		animatedImageView.contentMode = UIViewContentModeScaleAspectFit;
		animatedImageView.clipsToBounds = YES;
		animatedImageView.animatedImage = emotionVO.animatedImageView.animatedImage;
		[stickerView addSubview:animatedImageView];
		
	} else if (emotionVO.imageType == HONEmotionImageTypePNG) {
		UIImageView *thumbImageView = [[UIImageView alloc] initWithFrame:frame];
		thumbImageView.image = emotionVO.image;
		[stickerView addSubview:thumbImageView];
	}
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = frame;
	[button setBackgroundImage:[UIImage imageNamed:@"blackMatte_000"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"blackMatte_000"] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[UIImage imageNamed:@"blackMatte_000"] forState:UIControlStateSelected];
	[button setBackgroundImage:[UIImage imageNamed:@"blackMatte_000"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
	[button addTarget:self action:@selector(_goSelectSticker:) forControlEvents:UIControlEventTouchUpInside];
	[button setTag:[_stickers count]];
	[stickerView addSubview:button];
	
	[_scrollView addSubview:stickerView];
	[_stickerViews addObject:stickerView];
	[_stickers addObject:emotionVO];
	
//	int size = ([_stickers count] == _scrollThreshold) ? (_stickerSpacing * 0.6) : ([_stickers count] > _scrollThreshold) ? _stickerSpacing : 0;
//	int size = ([_stickers count] <= _scrollThreshold) ? 0 : _stickerSpacing;
	_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width + _stickerSpacing, _scrollView.contentSize.height);
//	[self scrollToStickerAtIndex:[_stickers count] - 1];
}

- (void)removeLastSticker {
	[self removeStickerAtIndex:(int)[_stickers count] - 1];
}

- (void)removeStickerAtIndex:(int)index {
	index = MIN(MAX(0, index), (int)[_stickers count] - 1);
	
	UIView *stickerView = [_stickerViews objectAtIndex:index];
	[stickerView removeFromSuperview];
	[_stickers removeObjectAtIndex:_currentIndex];
}

- (void)scrollToStickerAtIndex:(int)index {
	_currentIndex = index;
	
	int overhang = (_scrollThreshold * _stickerSpacing) - _scrollView.frame.size.width;
	
	int offset = 0;
	if (index < _scrollThreshold * 0.5) {
		offset = 0;
	
	} else if (index >= (_scrollThreshold * 0.5) && index < ([_stickers count] - (_scrollThreshold * 0.5))) {
		offset = (overhang * 1.75) + (_stickerSpacing * (MAX(0, (index - (_scrollThreshold * 0.5)))));
	
	} else if (index >= ([_stickers count] - (_scrollThreshold * 0.5))) {
		offset = (_scrollView.contentSize.width > _scrollView.frame.size.width) ? _scrollView.contentSize.width - _scrollView.frame.size.width : 0;
	
	} else {
		offset = _scrollView.contentOffset.x;
	}
	
	[_scrollView setContentOffset:CGPointMake(offset, 0.0) animated:[[HONAnimationOverseer sharedInstance] isScrollingAnimationEnabledForScrollView:self]];
}

- (void)selectStickerAtIndex:(int)index {
	index = MIN(MAX(0, index), (int)[_stickers count] - 1);
	
	_selectedEmotionVO = (HONEmotionVO *)[_stickers objectAtIndex:index];
	[_stickerViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIView *view = (UIView *)obj;
		UIButton *btn = [view.subviews lastObject];
		[btn setSelected:(btn.tag == index)];
	}];
	
	_currentIndex = index;
	[self scrollToStickerAtIndex:index];
}


#pragma mark - Navigation
- (void)_goSelectSticker:(id)sender {
	UIButton *button = (UIButton *)sender;
	int ind = (int)button.tag;
	
	_selectedEmotionVO = (HONEmotionVO *)[_stickers objectAtIndex:ind];
	[_stickerViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIView *view = (UIView *)obj;
		UIButton *btn = [view.subviews lastObject];
		[btn setSelected:NO];
	}];
	
	[button setSelected:YES];
	
	if ([self.delegate respondsToSelector:@selector(stickerSummaryView:didSelectThumb:atIndex:)])
		[self.delegate stickerSummaryView:self didSelectThumb:_selectedEmotionVO atIndex:ind];
	
	_currentIndex = ind;
	[self scrollToStickerAtIndex:ind];
	
	NSLog(@"_goSelectSticker:[%d]", _currentIndex);
}

- (void)_goLongPress:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
		return;
	
	NSLog(@"gestureRecognizer.state:[%@]", (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"Began" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"Canceled" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"Ended" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"Failed" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"Possible" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"Recognized" : @"UNKNOWN");
	HONEmotionVO *emotionVO = (HONEmotionVO *)[_stickers lastObject];
	
	UIView *stickerView = (UIView *)[_stickerViews lastObject];
	UIButton *button = (UIButton *)[stickerView.subviews lastObject];
	[button setSelected:NO];
	
	if (_currentIndex == [_stickers count] - 1) {
		//CGAffineTransform transform = [[HONViewDispensor sharedInstance] affineFrameTransformationByPercentage:0.10 forView:stickerView];
		CGAffineTransform transform = [[HONViewDispensor sharedInstance] affineTransformView:stickerView byPercentage:0.10];
		[UIView animateWithDuration:kStickerOutroDuration delay:kStickerOutroDelay
			 usingSpringWithDamping:kStickerOutroDamping initialSpringVelocity:kStickerOutroForce options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
						 animations:^(void) {
							 stickerView.alpha = 0.0;
							 stickerView.transform = transform;
							 
						 } completion:^(BOOL finished) {
							 [_stickerViews removeLastObject];
							 [_stickers removeLastObject];
							 
							 [stickerView removeFromSuperview];
							 
							 _currentIndex = (int)[_stickers count] - 1;
							 int size = ([_stickers count] == _scrollThreshold) ? (_stickerSpacing * 0.6) : ([_stickers count] > _scrollThreshold) ? _stickerSpacing : 0;
							 
							 _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width - size, _scrollView.contentSize.height);
							 //[self scrollToStickerAtIndex:_currentIndex];
							 [self selectStickerAtIndex:_currentIndex];
						 }];
	}
	
	[_stickerViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
	}];
	
	if ([self.delegate respondsToSelector:@selector(stickerSummaryView:deleteLastSticker:)])
		[self.delegate stickerSummaryView:self deleteLastSticker:emotionVO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"[*:*] scrollViewDidScroll:[%@] (%@)", NSStringFromCGSize(scrollView.contentSize), NSStringFromCGPoint(scrollView.contentOffset));
}


@end
