//
//  HONEmotionsPickerDisplayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 00:03 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"

#import "PicoSticker.h"

#import "HONEmotionsPickerDisplayView.h"
#import "HONImageLoadingView.h"
#import "HONTableViewBGView.h"

const CGSize kEmotionSize = {188.0f, 188.0f};
const CGSize kEmotionPaddingSize = {22.0f, 0.0f};

const CGRect kEmotionIntroFrame = {88.0f, 88.0f, 12.0f, 12.0f};
const CGRect kEmotionNormalFrame = {0.0f, 0.0f, 188.0f, 188.0f};

@interface HONEmotionsPickerDisplayView () <PicoStickerDelegate>
@property (nonatomic, strong) NSMutableArray *emotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *holderView;
@property (nonatomic, strong) UIView *loaderHolderView;
@property (nonatomic, strong) UIView *emotionHolderView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *previewGradientImageView;
@property (nonatomic, strong) UIImageView *previewThumbImageView;
@property (nonatomic, strong) HONTableViewBGView *bgView;
@property (nonatomic) CGFloat emotionInsetAmt;
@property (nonatomic) CGSize emotionSpacingSize;
@property (nonatomic) UIOffset indHistory;

@end

@implementation HONEmotionsPickerDisplayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_indHistory = UIOffsetZero;
		_emotionSpacingSize = CGSizeMake(kEmotionSize.width + kEmotionPaddingSize.width, kEmotionSize.height + kEmotionPaddingSize.height);
		_emotionInsetAmt = 0.5 * (320.0 - kEmotionSize.width);
		
		_emotions = [NSMutableArray array];
		
		_previewImageView = [[UIImageView alloc] initWithFrame:frame];
		_previewImageView.frame = CGRectOffset(_previewImageView.frame, 0.0, -100.0);
		[self addSubview:_previewImageView];
		
		_previewGradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"previewGradient"]];
		_previewGradientImageView.hidden = YES;
		[self addSubview:_previewGradientImageView];
		
		_bgView = [[HONTableViewBGView alloc] initAsType:HONTableViewBGViewTypeUndetermined withCaption:NSLocalizedString(@"empty_stickers", @"Select a sticker and\nbackground") usingTarget:self action:nil];
		[_bgView setYOffset:-144.0];
		_bgView.hidden = NO;
		[self addSubview:_bgView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 65.0, 320.0, kEmotionNormalFrame.size.height)];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.contentInset = UIEdgeInsetsMake(0.0, _emotionInsetAmt, 0.0, _emotionInsetAmt);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		_loaderHolderView = [[UIView alloc] initWithFrame:CGRectZero];
		[_scrollView addSubview:_loaderHolderView];
		
		_emotionHolderView = [[UIView alloc] initWithFrame:CGRectZero];
		[_scrollView addSubview:_emotionHolderView];
		
		_previewThumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(258.0, 227.0, 49.0, 37.0)];
		_previewThumbImageView.image = [UIImage imageNamed:@"addSelfieButton_nonActive"];
		_previewThumbImageView.userInteractionEnabled = YES;
		[_previewThumbImageView addSubview:[[UIImageView alloc] initWithFrame:CGRectMake(0.0, -19.0, 49.0, 86.0)]];
		[self addSubview:_previewThumbImageView];
		
		
		[[HONImageBroker sharedInstance] maskView:_previewThumbImageView withMask:[UIImage imageNamed:@"selfiePreviewMask"]];
		
		UIButton *previewThumbButton = [UIButton buttonWithType:UIButtonTypeCustom];
		previewThumbButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[previewThumbButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchDown];
		[_previewThumbImageView addSubview:previewThumbButton];
		
		[self _updateDisplayWithCompletion:nil];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)addEmotion:(HONEmotionVO *)emotionVO {
//	NSLog(@"STICKER:[%@]", emotionVO.pcContent);
	
	[_emotions addObject:emotionVO];
	
	if ([_emotions count] == 1) {
		[UIView animateWithDuration:0.125 animations:^(void) {
			_bgView.alpha = 0.0;
		}];
	}
	
	[self _addImageEmotion:emotionVO];
	[self _updateDisplayWithCompletion:^(BOOL finished) {
	}];

//	[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"badminton_racket_fast_movement_swoosh_002"];
}

- (void)removeEmotion:(HONEmotionVO *)emotionVO {
	if ([_emotions count] > 0) {
		if (_scrollView.contentOffset.x == (MAX(_scrollView.frame.size.width, [_emotions count] * _emotionSpacingSize.width) - _scrollView.frame.size.width) - (([_emotions count] <= 1) ? _scrollView.contentInset.left : -_scrollView.contentInset.right)) {
			[_emotions removeLastObject];
			[self _removeImageEmotion];
		
		} else {
			[self _updateDisplayWithCompletion:^(BOOL finished) {
				[_emotions removeLastObject];
				[self _removeImageEmotion];
			}];
		}
	}
}

- (void)flushEmotions {
	while ([_emotionHolderView.subviews count] > 0)
		[self _removeImageEmotion];
	
	[_emotions removeAllObjects];
	_emotions = [NSMutableArray array];
}

- (void)updatePreview:(UIImage *)previewImage {
	_previewImageView.image = previewImage;
	_previewGradientImageView.hidden = NO;
	
	_previewThumbImageView.image = [UIImage imageNamed:@"addSelfieButtonB_nonActive"];
//	((UIImageView *)[_previewThumbImageView.subviews firstObject]).image = previewImage;
}


#pragma mark - Navigation
- (void)_goCamera {
	if ([self.delegate respondsToSelector:@selector(emotionsPickerDisplayViewShowCamera:)])
		[self.delegate emotionsPickerDisplayViewShowCamera:self];
}


#pragma mark - UI Presentation
- (void)_addImageEmotion:(HONEmotionVO *)emotionVO {
	_emotionHolderView.frame = CGRectMake(_emotionHolderView.frame.origin.x, 0.0, [_emotions count] * _emotionSpacingSize.width, kEmotionNormalFrame.size.height);
	_loaderHolderView.frame = _emotionHolderView.frame;
	
	CGSize scaleSize = CGSizeMake(kEmotionIntroFrame.size.width / kEmotionNormalFrame.size.width, kEmotionIntroFrame.size.height / kEmotionNormalFrame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(kEmotionIntroFrame) - CGRectGetMidX(kEmotionNormalFrame), CGRectGetMidY(kEmotionIntroFrame) - CGRectGetMidY(kEmotionNormalFrame));
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(([_emotions count] - 1) * _emotionSpacingSize.width, 0.0, kEmotionNormalFrame.size.width, kEmotionNormalFrame.size.height)];
	imageView.alpha = 0.0;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.transform = transform;
	[imageView setTag:[_emotions count]];
	[_emotionHolderView addSubview:imageView];
	
		
//	if (emotionVO.picoSticker == nil) {
		HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:imageView asLargeLoader:NO];
		imageLoadingView.frame = imageView.frame;
		imageLoadingView.frame = CGRectOffset(imageLoadingView.frame, - 22.0, - 22.0);
		imageLoadingView.alpha = 0.667;
		[imageLoadingView setTag:[_emotions count]];
		[imageLoadingView startAnimating];
		[_loaderHolderView addSubview:imageLoadingView];
	
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		};
	
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
			
			[UIView animateWithDuration:0.250 delay:0.125
				 usingSpringWithDamping:0.750 initialSpringVelocity:0.000
								options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
			 
							 animations:^(void) {
								 imageView.alpha = 1.0;
								 imageView.transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
							 } completion:^(BOOL finished) {
								 [self _updateDisplayWithCompletion:nil];
								 
								 HONImageLoadingView *loadingView = [[_loaderHolderView subviews] lastObject];
								 [loadingView stopAnimating];
								 [loadingView removeFromSuperview];
							 }];
		};
		
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.largeImageURL]
														   cachePolicy:kOrthodoxURLCachePolicy
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:imageSuccessBlock
								  failure:imageFailureBlock];
//
//	} else {
//	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(([_emotions count] - 1) * (kImageSize.width + kImagePaddingSize.width), 0.0, (kImageSize.width + kImagePaddingSize.width), (kImageSize.height + kImagePaddingSize.height))];
//	holderView.alpha = 0.0;
//	holderView.contentMode = UIViewContentModeScaleAspectFit;
//	holderView.transform = transform;
//	[_emotionHolderView addSubview:holderView];
//	PicoSticker *picoSticker = [[PicoSticker alloc] initWithPCContent:emotionVO.pcContent];
//	picoSticker.frame = CGRectMake(([_emotions count] - 1) * (kImageSize.width + kImagePaddingSize.width), 0.0, (kImageSize.width + kImagePaddingSize.width), (kImageSize.height + kImagePaddingSize.height));
//	picoSticker.alpha = 0.0;
//	picoSticker.contentMode = UIViewContentModeScaleAspectFit;
//	picoSticker.transform = transform;
//	[_emotionHolderView addSubview:picoSticker];

		
//		[UIView animateWithDuration:0.200 delay:0.125
//			 usingSpringWithDamping:0.750 initialSpringVelocity:0.000
//							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
//		 
//						 animations:^(void) {
//							 picoSticker.alpha = 1.0;
//							 picoSticker.transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
//						 } completion:^(BOOL finished) {}];
//	}
}

- (void)_removeImageEmotion {
	UIImageView *imageView = [_emotionHolderView.subviews lastObject];
	
	if ([imageView.layer.animationKeys count] > 0) {
		[imageView.layer removeAllAnimations];
		[imageView removeFromSuperview];
		
		imageView = [_emotionHolderView.subviews lastObject];
	}
		
	
	[UIView animateWithDuration:0.125 delay:0.000
		 usingSpringWithDamping:0.950 initialSpringVelocity:0.250
						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
	 
					 animations:^(void) {
						 imageView.alpha = 0.0;
						 imageView.transform = CGAffineTransformMake(1.333, 0.0, 0.0, 1.333, 0.0, 0.0);
						 
					 } completion:^(BOOL finished) {
						 [imageView removeFromSuperview];
						 
						 _emotionHolderView.frame = CGRectMake(_emotionHolderView.frame.origin.x, _emotionHolderView.frame.origin.y, [_emotions count] * _emotionSpacingSize.width, kEmotionNormalFrame.size.height);
						 _loaderHolderView.frame = _emotionHolderView.frame;

						 [self _updateDisplayWithCompletion:nil];
					 }];
}


- (void)_updateDisplayWithCompletion:(void (^)(BOOL finished))completion {
	int offset = MAX(_scrollView.frame.size.width, [_emotions count] * _emotionSpacingSize.width);
	offset = ([_emotions count] != 1) ? offset - kEmotionPaddingSize.width : offset;
	
	[UIView animateWithDuration:0.250 delay:0.000
		 usingSpringWithDamping:0.875 initialSpringVelocity:0.125
						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
	 
					 animations:^(void) {
						 [_scrollView setContentOffset:CGPointMake((offset - _scrollView.frame.size.width) - (([_emotions count] <= 1) ? _scrollView.contentInset.left : -_scrollView.contentInset.right), 0.0) animated:NO];

					 } completion:^(BOOL finished) {
						 _scrollView.contentSize = CGSizeMake(offset, _scrollView.contentSize.height);
						 
						 [UIView animateWithDuration:0.25 animations:^(void) {
							 _bgView.alpha = ([_emotions count] == 0);
						 }];
						 
						 if (completion)
							 completion(YES);
					 }];
	
			 
//	NSLog(@"\n\t\t|--|--|--|--|--|--|:|--|--|--|--|--|--|");
//	NSLog(@"FONT ATTRIBS:[%@]", _label.font.fontDescriptor.fontAttributes);
//	NSLog(@"--// %@ @ (%d) //--", [_label.font.fontDescriptor.fontAttributes objectForKey:@"NSFontNameAttribute"], (int)_label.font.pointSize);
//	NSLog(@"DRAW SIZE:[%@] ATTR SIZE:[%@]", NSStringFromCGSize(_captionSize), NSStringFromCGSize(_label.attributedText.size));
//	NSLog(@"X-HEIGHT:[%f]", _label.font.xHeight);
//	NSLog(@"CAP:[%f]", _label.font.capHeight);
//	NSLog(@"ASCENDER:[%f] DESCENDER:[%f]", _label.font.ascender, _label.font.descender);
//	NSLog(@"LINE HEIGHT:[%f]", _label.font.lineHeight);
//	NSLog(@"[=-=-=-=-=-=-=-=-=|=-=-=-=-=-=-=-=-=|:|=-=-=-=-=-=-=-=-=|=-=-=-=-=-=-=-=-=]");
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"[*:*] scrollViewDidScroll:[%@] (%@)", NSStringFromCGSize(scrollView.contentSize), NSStringFromCGPoint(scrollView.contentOffset));
	
	int axisInd = (_emotionInsetAmt + scrollView.contentOffset.x) / _emotionSpacingSize.width;
	int axisCoord = (axisInd * _emotionSpacingSize.width) - _emotionInsetAmt;
	
	int currInd = _indHistory.horizontal;
	int updtInd = MAX(0, MIN([_emotions count], axisInd));
	int changeDir = 0;
	
	if (updtInd == currInd) {
//		NSLog(@"\n‹~|≈~~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~|[ EQL ]|~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~~≈|~›");
		changeDir = 0;
		
	} else if (updtInd < currInd) {
//		NSLog(@"\n‹~|≈~~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~|[ DEC ]|~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~~≈|~›");
//		NSLog(@"LOWER:[%.02f] COORD:[%d] UPPER:[%.02f] contentOffset:[%d] updtInd:[%d]", (axisCoord - _emotionInsetAmt), axisCoord, (axisCoord + _emotionInsetAmt), scrollView.contentOffset.x, updtInd);
		
		if (scrollView.contentOffset.x < (axisCoord + _emotionInsetAmt) && scrollView.contentOffset.x > (axisCoord - _emotionInsetAmt)) {
			_indHistory = UIOffsetMake(currInd - 1, currInd);
			if ([self.delegate respondsToSelector:@selector(emotionsPickerDisplayView:scrolledEmotionsToIndex:fromDirection:)])
				[self.delegate emotionsPickerDisplayView:self scrolledEmotionsToIndex:currInd - 1 fromDirection:1];
		} else
			return;
	
	} else if (updtInd > currInd) {
//		NSLog(@"\n‹~|≈~~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~|[ INC ]|~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~~≈|~›");
//		NSLog(@"LOWER:[%.02f] COORD:[%d] UPPER:[%.02f] contentOffset:[%d] updtInd:[%d]", (axisCoord - _emotionInsetAmt), axisCoord, (axisCoord + _emotionInsetAmt), scrollView.contentOffset.x, updtInd);
		
		if (scrollView.contentOffset.x > (axisCoord - _emotionInsetAmt) && scrollView.contentOffset.x < (axisCoord + _emotionInsetAmt)) {
			_indHistory = UIOffsetMake(currInd + 1, currInd);
			if ([self.delegate respondsToSelector:@selector(emotionsPickerDisplayView:scrolledEmotionsToIndex:fromDirection:)])
				[self.delegate emotionsPickerDisplayView:self scrolledEmotionsToIndex:currInd + 1 fromDirection:-1];
		
		} else
			return;
	}

//	NSLog(@"scrollView.contentOffset:[%.02f]:= range:[%@] OF ind:[%d]", scrollView.contentOffset.x, NSStringFromRange(range), ind);
}

#pragma mark - PicoSticker Delegates
- (void)picoSticker:(id)sticker tappedWithContentId:(NSString *)contentId {
	NSLog(@"[*:*] sticker.tag:[%d] (%@)", ((PicoSticker *)sticker).tag, contentId);
}

@end
