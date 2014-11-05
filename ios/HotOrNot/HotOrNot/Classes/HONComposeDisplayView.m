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

#import "HONComposeDisplayView.h"
#import "HONImageLoadingView.h"
#import "HONLineButtonView.h"

const CGSize kEmotionSize = {188.0f, 188.0f};
const CGSize kEmotionPaddingSize = {64.0f, 0.0f};

const CGRect kEmotionIntroFrame = {88.0f, 88.0f, 12.0f, 12.0f};
const CGRect kEmotionNormalFrame = {0.0f, 0.0f, 188.0f, 188.0f};

const CGFloat kEmotionTransposeDuration = 0.00125;
const CGFloat kEmotionTransposeDelay = 0.000;
const CGFloat kEmotionTransposeDamping = 0.875;
const CGFloat kEmotionTransposeForce = 0.125;

const CGFloat kEmotionIntroDuration = 0.00250;
const CGFloat kEmotionIntroDelay = 0.125;
const CGFloat kEmotionIntroDamping = 0.750;
const CGFloat kEmotionIntroForce = 0.000;

const CGFloat kEmotionOutroDuration = 0.00250;
const CGFloat kEmotionOutroDelay = 0.000;
const CGFloat kEmotionOutroDamping = 0.950;
const CGFloat kEmotionOutroForce = 0.250;


@interface HONComposeDisplayView () <PicoStickerDelegate>
@property (nonatomic, strong) NSMutableArray *emotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *holderView;
@property (nonatomic, strong) UIView *loaderHolderView;
@property (nonatomic, strong) UIView *emotionHolderView;
@property (nonatomic, strong) UIButton *fullscreenButton;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *previewGradientImageView;
@property (nonatomic, strong) NSTimer *tintTimer;
@property (nonatomic, strong) HONLineButtonView *bgView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@property (nonatomic) CGFloat emotionInsetAmt;
@property (nonatomic) CGSize emotionSpacingSize;
@property (nonatomic) UIOffset indHistory;

@end

@implementation HONComposeDisplayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_indHistory = UIOffsetZero;
		_emotions = [NSMutableArray array];
		_emotionSpacingSize = CGSizeMake(1.0 + (kEmotionSize.width + kEmotionPaddingSize.width), kEmotionSize.height + kEmotionPaddingSize.height);
		_emotionInsetAmt = 0.5 * (320.0 - kEmotionSize.width);
		
		_previewImageView = [[UIImageView alloc] initWithFrame:frame];
		_previewImageView.image = [UIImage imageNamed:@"bgComposeUnderlay"];
		[self addSubview:_previewImageView];
		
		_previewGradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgComposeOverlay"]];
		[self addSubview:_previewGradientImageView];
		
		_bgView = [[HONLineButtonView alloc] initAsType:HONLineButtonViewTypeUndetermined withCaption:NSLocalizedString(@"empty_stickers", @"Select a sticker and\nbackground") usingTarget:self action:nil];
		[_bgView setYOffset:-144.0];
		_bgView.hidden = YES;
		[self addSubview:_bgView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight + 22.0, 320.0, kEmotionNormalFrame.size.height)];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.contentInset = UIEdgeInsetsMake(0.0, _emotionInsetAmt, 0.0, _emotionInsetAmt);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.userInteractionEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		_loaderHolderView = [[UIView alloc] initWithFrame:CGRectZero];
		[_scrollView addSubview:_loaderHolderView];
		
		_emotionHolderView = [[UIView alloc] initWithFrame:CGRectZero];
		[_scrollView addSubview:_emotionHolderView];
		
//		_fullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_fullscreenButton.frame = self.frame;
//		[_fullscreenButton addTarget:self action:@selector(_goFullScreen) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:_fullscreenButton];
		
		UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraButton.frame = CGRectMake(0.0, 297.0, 50.0, 50.0);
		[cameraButton setBackgroundImage:[UIImage imageNamed:@"addPhotoButton_nonActive"] forState:UIControlStateNormal];
		[cameraButton setBackgroundImage:[UIImage imageNamed:@"addPhotoButton_Active"] forState:UIControlStateHighlighted];
		[cameraButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cameraButton];
		
		[self _updateDisplayWithCompletion:nil];
		
//		[self _changeTint];
//		_tintTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(_changeTint) userInfo:nil repeats:YES];
	}
	
	return (self);
}

- (void)dealloc {
	_scrollView.delegate = nil;
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
}

- (void)removeLastEmotion {
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
	[self _updateDisplayWithCompletion:nil];
}

- (void)updatePreview:(UIImage *)previewImage {
	_previewImageView.image = previewImage;
	_previewGradientImageView.hidden = NO;
}

- (void)updatePreviewWithAnimatedImageView:(FLAnimatedImageView *)animatedImageView {
	FLAnimatedImageView *animImageView = [[FLAnimatedImageView alloc] init];
	animImageView.frame = CGRectMakeFromSize(CGSizeMake(320.0, 320.0));
	animImageView.contentMode = UIViewContentModeScaleToFill; // stretches w/o ratio -- UIViewContentModeScaleAspectFill; // stretches w/ ratio -- UIViewContentModeScaleAspectFit; // centers in frame
	animImageView.clipsToBounds = YES;
	animImageView.animatedImage = animatedImageView.animatedImage;
	[_previewImageView addSubview:animImageView];
}

- (void)scrollToEmotion:(HONEmotionVO *)emotionVO atIndex:(int)index {
	[self scrollToEmotionIndex:index + 1];
	
//	__block int ind = 0;
//	[_emotions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONEmotionVO *vo = (HONEmotionVO *)obj;
//		NSLog(@"scrollToEmotionPosition:[%@][%@]", vo.emotionID, emotionVO.emotionID);
//		if ([vo.emotionID isEqualToString:emotionVO.emotionID]) {
//			ind = (int)idx;
//			*stop = YES;
//		}
//	}];
}


- (void)scrollToEmotionIndex:(int)index {
	NSLog(@"scrollToEmotionIndex:[%d]", index);
	int offset = (MAX(_scrollView.frame.size.width, (index * _emotionSpacingSize.width)) + ((index != 0) ? -kEmotionPaddingSize.width : 0.0)) - _scrollView.frame.size.width;// - (([_emotions count] <= 1) ? _scrollView.contentInset.left : -_scrollView.contentInset.right);
	offset -= ((index == 0) ? _scrollView.contentInset.left : -_scrollView.contentInset.right);

//	[UIView animateWithDuration:0.00250 delay:0.000
//		 usingSpringWithDamping:0.875 initialSpringVelocity:0.125
//						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
//	 
//					 animations:^(void) {
						 [_scrollView setContentOffset:CGPointMake(offset, 0.0) animated:[[HONAnimationOverseer sharedInstance] isScrollingAnimationEnabledForScrollView:self]];
						 
//					 } completion:^(BOOL finished) {
//						 _scrollView.contentSize = CGSizeMake(offset, _scrollView.contentSize.height);
	
						 [UIView animateWithDuration:0.25 animations:^(void) {
							 _bgView.alpha = ([_emotions count] == 0);
						 }];
//					 }];
	
	NSLog(@"scrollView.contentOffset:[%.02f]:= scrollView.contentInset:[%@]", _scrollView.contentOffset.x, NSStringFromUIEdgeInsets(_scrollView.contentInset));
}


#pragma mark - Navigation
- (void)_goCamera {
	if ([self.delegate respondsToSelector:@selector(composeDisplayViewShowCamera:)])
		[self.delegate composeDisplayViewShowCamera:self];
}

- (void)_goFullScreen {
//	if ([self.delegate respondsToSelector:@selector(composeDisplayViewGoFullScreen:)])
//		[self.delegate composeDisplayViewGoFullScreen:self];
}


#pragma mark - UI Presentation
- (void)_addImageEmotion:(HONEmotionVO *)emotionVO {
	_emotionHolderView.frame = CGRectMake(_emotionHolderView.frame.origin.x, 0.0, [_emotions count] * _emotionSpacingSize.width, kEmotionNormalFrame.size.height);
	_loaderHolderView.frame = _emotionHolderView.frame;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(([_emotions count] - 1) * _emotionSpacingSize.width, 0.0, kEmotionNormalFrame.size.width, kEmotionNormalFrame.size.height)];
	imageView.alpha = 0.0;
	imageView.userInteractionEnabled = YES;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.transform = [[HONViewDispensor sharedInstance] affineTransformView:imageView toSize:kEmotionIntroFrame.size];
	[imageView setTag:[_emotions count]];
	[_emotionHolderView addSubview:imageView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:imageView asLargeLoader:NO];
	imageLoadingView.frame = imageView.frame;
	imageLoadingView.frame = CGRectOffset(imageLoadingView.frame, - 22.0, - 22.0);
	imageLoadingView.alpha = 0.00667;
	[imageLoadingView setTag:[_emotions count]];
	[imageLoadingView startAnimating];
	[_loaderHolderView addSubview:imageLoadingView];

//	NSLog(@"EMOTION STICKER:[%@]", emotionVO.largeImageURL);
	if (emotionVO.imageType == HONEmotionImageTypeGIF) {
		_animatedImageView = [[FLAnimatedImageView alloc] init];
		_animatedImageView.frame =CGRectMakeFromSize(kEmotionNormalFrame.size);
		_animatedImageView.contentMode = UIViewContentModeScaleAspectFit; // centers in frame
		_animatedImageView.clipsToBounds = YES;
		_animatedImageView.animatedImage = emotionVO.animatedImageView.animatedImage;
		[imageView addSubview:_animatedImageView];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//			[UIView animateWithDuration:kEmotionIntroDuration delay:kEmotionIntroDelay
//				 usingSpringWithDamping:kEmotionIntroDamping initialSpringVelocity:kEmotionIntroForce
//								options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
//			 
//							 animations:^(void) {
								 imageView.alpha = 1.0;
								 imageView.transform = CGAffineTransformMakeNormal();//(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
//							 } completion:^(BOOL finished) {
								 [self _updateDisplayWithCompletion:nil];
								 
								 [imageLoadingView stopAnimating];
								 [imageLoadingView removeFromSuperview];
//							 }];
		});
		
	} else if (emotionVO.imageType == HONEmotionImageTypePNG) {
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		};
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
			
//			[UIView animateWithDuration:kEmotionIntroDuration delay:kEmotionIntroDelay
//				 usingSpringWithDamping:kEmotionIntroDamping initialSpringVelocity:kEmotionIntroForce
//								options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
			
//							 animations:^(void) {
								 imageView.alpha = 1.0;
								 imageView.transform = CGAffineTransformMakeNormal();//(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
//							 } completion:^(BOOL finished) {
								 [self _updateDisplayWithCompletion:nil];
								 
								 [imageLoadingView stopAnimating];
								 [imageLoadingView removeFromSuperview];
//							 }];
		};
		
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.largeImageURL]
														   cachePolicy:kOrthodoxURLCachePolicy
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:imageSuccessBlock
								  failure:imageFailureBlock];
	}
	
	
	
	
//	if (emotionVO.picoSticker == nil) {
	
	
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

		
//	[UIView animateWithDuration:kEmotionOutroDuration delay:kEmotionOutroDelay
//		 usingSpringWithDamping:kEmotionOutroDamping initialSpringVelocity:kEmotionOutroForce
//							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
//		 
//						 animations:^(void) {
//							 picoSticker.alpha = 1.0;
//							 picoSticker.transform = CGAffineTransformMakeNormal;//(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
//						 } completion:^(BOOL finished) {}];
//	}
}

- (void)_removeImageEmotion {
	UIImageView *imageView = [_emotionHolderView.subviews lastObject];
	
	if ([imageView.layer.animationKeys count] > 0) {
		[imageView.layer removeAllAnimations];
	}
		
	
//	[UIView animateWithDuration:kEmotionOutroDuration delay:kEmotionOutroDelay
//		 usingSpringWithDamping:kEmotionOutroDamping initialSpringVelocity:kEmotionOutroForce
//						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
	
//					 animations:^(void) {
						 imageView.alpha = 0.0;
						 imageView.transform = CGAffineTransformMake(1.333, 0.0, 0.0, 1.333, 0.0, 0.0);
						 
//					 } completion:^(BOOL finished) {
						 [imageView removeFromSuperview];
						 
						 _emotionHolderView.frame = CGRectMake(_emotionHolderView.frame.origin.x, _emotionHolderView.frame.origin.y, [_emotions count] * _emotionSpacingSize.width, kEmotionNormalFrame.size.height);
						 _loaderHolderView.frame = _emotionHolderView.frame;

						 [self _updateDisplayWithCompletion:nil];
//					 }];
}


- (void)_updateDisplayWithCompletion:(void (^)(BOOL finished))completion {
	int offset = MAX(_scrollView.frame.size.width, [_emotions count] * _emotionSpacingSize.width);
	offset = ([_emotions count] != 1) ? offset - kEmotionPaddingSize.width : offset;
	
//	[UIView animateWithDuration:kEmotionTransposeDuration delay:kEmotionTransposeDelay
//		 usingSpringWithDamping:kEmotionTransposeDamping initialSpringVelocity:kEmotionTransposeForce
//						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
//	 
//					 animations:^(void) {
						 [_scrollView setContentOffset:CGPointMake((offset - _scrollView.frame.size.width) - (([_emotions count] <= 1) ? _scrollView.contentInset.left : -_scrollView.contentInset.right), 0.0) animated:[[HONAnimationOverseer sharedInstance] isScrollingAnimationEnabledForScrollView:self]];

//					 } completion:^(BOOL finished) {
						 _scrollView.contentSize = CGSizeMake(offset, _scrollView.contentSize.height);
						 
//						 [UIView animateWithDuration:0.25 animations:^(void) {
//							 _bgView.alpha = ([_emotions count] == 0);
//						 }];
	
						 if (completion)
							 completion(YES);
//					 }];
	
			 
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

- (void)_changeTint {
	UIColor *color = [[HONColorAuthority sharedInstance] honRandomColor];
	[UIView animateWithDuration:2.0 animations:^(void) {
		[[HONViewDispensor sharedInstance] tintView:_previewImageView withColor:color];
	} completion:nil];
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
			if ([self.delegate respondsToSelector:@selector(composeDisplayView:scrolledEmotionsToIndex:fromDirection:)])
				[self.delegate composeDisplayView:self scrolledEmotionsToIndex:currInd - 1 fromDirection:1];
		} else
			return;
	
	} else if (updtInd > currInd) {
//		NSLog(@"\n‹~|≈~~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~|[ INC ]|~≈~¡~≈~!~≈~¡~≈~!~≈~¡~≈~!~≈~¡~~≈|~›");
//		NSLog(@"LOWER:[%.02f] COORD:[%d] UPPER:[%.02f] contentOffset:[%d] updtInd:[%d]", (axisCoord - _emotionInsetAmt), axisCoord, (axisCoord + _emotionInsetAmt), scrollView.contentOffset.x, updtInd);
		
		if (scrollView.contentOffset.x > (axisCoord - _emotionInsetAmt) && scrollView.contentOffset.x < (axisCoord + _emotionInsetAmt)) {
			_indHistory = UIOffsetMake(currInd + 1, currInd);
			if ([self.delegate respondsToSelector:@selector(composeDisplayView:scrolledEmotionsToIndex:fromDirection:)])
				[self.delegate composeDisplayView:self scrolledEmotionsToIndex:currInd + 1 fromDirection:-1];
		
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
