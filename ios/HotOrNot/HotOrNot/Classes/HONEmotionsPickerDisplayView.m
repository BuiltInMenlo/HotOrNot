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

#define COLS_PER_ROW 6
#define SPACING

//NSString * const kBaseCaption = @"- is feeling…";
const CGSize kImageSize = {188.0f, 188.0f};
const CGSize kImagePaddingSize = {0.0f, 0.0f};

const CGRect kEmotionIntroFrame = {88.0f, 88.0f, 12.0f, 12.0f};
const CGRect kEmotionNormalFrame = {0.0f, 0.0f, 188.0f, 188.0f};

@interface HONEmotionsPickerDisplayView () <PicoStickerDelegate>
@property (nonatomic, strong) NSMutableArray *emotions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *holderView;
@property (nonatomic, strong) UIView *loaderHolderView;
@property (nonatomic, strong) UIView *emotionHolderView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *previewThumbImageView;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic) CGPoint prevPt;
@property (nonatomic) BOOL isDragging;
@end

@implementation HONEmotionsPickerDisplayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_emotions = [NSMutableArray array];
		_isDragging = NO;
		
		[self addSubview:[[UIImageView alloc] initWithImage:image]];
		
		_previewImageView = [[UIImageView alloc] initWithFrame:frame];
		_previewImageView.userInteractionEnabled = YES;
		[self addSubview:_previewImageView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 69.0, 320.0, kImageSize.height)];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.contentInset = UIEdgeInsetsMake(0.0, (320.0 - (kImageSize.width + kImagePaddingSize.width)) * 0.5, 0.0, (320.0 - (kImageSize.width + kImagePaddingSize.width)) * 0.5);
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		_loaderHolderView = [[UIView alloc] initWithFrame:CGRectZero];
		[_scrollView addSubview:_loaderHolderView];
		
		_emotionHolderView = [[UIView alloc] initWithFrame:CGRectZero];
		[_scrollView addSubview:_emotionHolderView];
		
		_emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dottedBackground"]];
		_emptyImageView.frame = CGRectOffset(_emptyImageView.frame, 63.0, 63.0);
		[self addSubview:_emptyImageView];
		
		UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, 194.0, 46.0)];
		emptyLabel.backgroundColor = [UIColor clearColor];
		emptyLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		emptyLabel.textColor = [UIColor lightGrayColor];
		emptyLabel.textAlignment = NSTextAlignmentCenter;
		emptyLabel.numberOfLines = 2;
		emptyLabel.text = @"select a sticker\nor take selfie";
		[_emptyImageView addSubview:emptyLabel];
		
		_previewThumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(271.0, 239.0, 39.0, 39.0)];
		_previewThumbImageView.image = [UIImage imageNamed:@"addSelfieButtonB_nonActive"];
		_previewThumbImageView.userInteractionEnabled = YES;
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
			_emptyImageView.alpha = 0.0;
		}];
	}
	
	[self _addImageEmotion:emotionVO];
	[self _updateDisplayWithCompletion:^(BOOL finished) {
	}];

//	[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"badminton_racket_fast_movement_swoosh_002"];
}

- (void)removeEmotion:(HONEmotionVO *)emotionVO {
	if (_scrollView.contentSize.width - _scrollView.contentInset.left == _scrollView.contentOffset.x) {
		[_emotions removeLastObject];
		[self _removeImageEmotion];
	
	} else {
		[self _updateDisplayWithCompletion:^(BOOL finished) {
			[_emotions removeLastObject];
			[self _removeImageEmotion];
		}];
	}
}

- (void)updatePreview:(UIImage *)previewImage {
//	_previewImageView.image = previewImage;
	
//	UIImageView *holderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, 150.0, 200.0)];
//	holderImageView.image = previewImage;
//	[_previewImageView addSubview:holderImageView];
	
	for (UIView *view in _previewThumbImageView.subviews) {
		if (view.tag != 1)
			[view removeFromSuperview];
	}
	
	UIImageView *thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -15.0, 39.0, 69.0)];
	thumbImageView.image = previewImage;
	[_previewThumbImageView addSubview:thumbImageView];
}


#pragma mark - Navigation
- (void)_goCamera {
	if ([self.delegate respondsToSelector:@selector(emotionsPickerDisplayViewShowCamera:)])
		[self.delegate emotionsPickerDisplayViewShowCamera:self];
}


#pragma mark - UI Presentation
- (void)_addImageEmotion:(HONEmotionVO *)emotionVO {
	_emotionHolderView.frame = CGRectMake(_emotionHolderView.frame.origin.x, _emotionHolderView.frame.origin.y, [_emotions count] * (kImageSize.width + kImagePaddingSize.width), _scrollView.contentSize.height);
	_loaderHolderView.frame = _emotionHolderView.frame;

	CGSize scaleSize = CGSizeMake(kEmotionIntroFrame.size.width / kEmotionNormalFrame.size.width, kEmotionIntroFrame.size.height / kEmotionNormalFrame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(kEmotionIntroFrame) - CGRectGetMidX(kEmotionNormalFrame), CGRectGetMidY(kEmotionIntroFrame) - CGRectGetMidY(kEmotionNormalFrame));
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(([_emotions count] - 1) * (kImageSize.width + kImagePaddingSize.width), 0.0, kImageSize.width, kImageSize.height)];
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
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:imageSuccessBlock
								  failure:nil];
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
		 usingSpringWithDamping:1.000 initialSpringVelocity:0.250
						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
	 
					 animations:^(void) {
						 imageView.alpha = 0.0;
						 imageView.transform = CGAffineTransformMake(1.333, 0.0, 0.0, 1.333, 0.0, 0.0);
						 
					 } completion:^(BOOL finished) {
						 [imageView removeFromSuperview];
						 
						 _emotionHolderView.frame = CGRectMake(_emotionHolderView.frame.origin.x, _emotionHolderView.frame.origin.y, [_emotions count] * (kImageSize.width + kImagePaddingSize.width), _scrollView.contentSize.height);
						 _loaderHolderView.frame = _emotionHolderView.frame;

						 [self _updateDisplayWithCompletion:nil];
					 }];
}


- (void)_updateDisplayWithCompletion:(void (^)(BOOL finished))completion {
	int offset = [_emotions count] * (kImageSize.width + kImagePaddingSize.width);
	int orgX = MAX(_scrollView.frame.size.width, offset);
	
	[UIView animateWithDuration:0.250 delay:0.000
		 usingSpringWithDamping:0.875 initialSpringVelocity:0.125
						options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
	 
					 animations:^(void) {
						 [_scrollView setContentOffset:CGPointMake((orgX - _scrollView.frame.size.width) - (([_emotions count] <= 1) ? _scrollView.contentInset.left : -_scrollView.contentInset.right), 0.0) animated:NO];

					 } completion:^(BOOL finished) {
						 _scrollView.contentSize = CGSizeMake(orgX, _scrollView.contentSize.height);
						 
						 [UIView animateWithDuration:0.25 animations:^(void) {
							 _emptyImageView.alpha = ([_emotions count] == 0);
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
	NSLog(@"[*:*] scrollViewDidScroll:[%@] (%@)", NSStringFromCGSize(scrollView.contentSize), NSStringFromCGPoint(scrollView.contentOffset));
}

#pragma mark - PicoSticker Delegates
- (void)picoSticker:(id)sticker tappedWithContentId:(NSString *)contentId {
	NSLog(@"[*:*] sticker.tag:[%d] (%@)", ((PicoSticker *)sticker).tag, contentId);
}

@end
