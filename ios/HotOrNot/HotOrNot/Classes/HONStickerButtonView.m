//
//  HONStickerPickerItemView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/21/2014 @ 20:44 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONStickerButtonView.h"
#import "HONImageLoadingView.h"

const CGRect kNormalFrame = {0.0f, 0.0f, 64.0f, 64.0f};
const CGRect kActiveFrame = {-8.0f, -8.0f, 80.0f, 80.0f};

@interface HONStickerButtonView ()
@property (nonatomic, strong) HONEmotionVO *emotionVO;
@property (nonatomic, strong) PicoSticker *picoSticker;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic) BOOL isSelected;
@end

@implementation HONStickerButtonView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isSelected = NO;
		
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stickerItemBG"]]];
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_imageView.layer.borderColor = [UIColor clearColor].CGColor;
		_imageView.layer.borderWidth = 2.5f;
		_imageView.layer.shouldRasterize = YES;
		_imageView.layer.rasterizationScale = 3.0f;
		[self addSubview:_imageView];
		
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageView asLargeLoader:NO];
		_imageLoadingView.alpha = 0.00667;
		[_imageLoadingView startAnimating];
		[_imageView addSubview:_imageLoadingView];
		
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _imageView.frame;
		[selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:selectButton];
	}
	
	return (self);
}

- (id)initAtPosition:(CGPoint)position withEmotion:(HONEmotionVO *)emotionVO withDelay:(CGFloat)delay {
	if ((self = [self initWithFrame:CGRectMake(position.x, position.y, CGRectGetWidth(kActiveFrame), CGRectGetHeight(kActiveFrame))]))  {
		_emotionVO = emotionVO;
		
//		NSLog(@"EMOTION STICKER:[%@]", emotionVO.largeImageURL);
		if (_emotionVO.imageType == HONEmotionImageTypeGIF) {
			if (!_animatedImageView) {
				_animatedImageView = [[FLAnimatedImageView alloc] init];
				_animatedImageView.contentMode = UIViewContentModeScaleAspectFit; // centers in frame
				_animatedImageView.clipsToBounds = YES;
			}
			
			_animatedImageView.frame = _imageView.frame;
			[_imageView addSubview:_animatedImageView];
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSURL *url = [NSURL URLWithString:_emotionVO.smallImageURL];
				NSData *data = [NSData dataWithContentsOfURL:url];
				FLAnimatedImage *animatedImage1 = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					_animatedImageView.animatedImage = animatedImage1;
					_emotionVO.animatedImageView = _animatedImageView;
				});
			});
			
		} else if (_emotionVO.imageType == HONEmotionImageTypePNG)
			[self performSelector:@selector(_loadImage) withObject:nil afterDelay:delay];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goSelect {
	CGSize scaleSize = CGSizeMake(kActiveFrame.size.width / kNormalFrame.size.width, kActiveFrame.size.height / kNormalFrame.size.height);;
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(kActiveFrame) - CGRectGetMidX(kNormalFrame), CGRectGetMidY(kActiveFrame) - CGRectGetMidY(kNormalFrame));
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	
	[UIView animateWithDuration:0.0625 delay:0.000
		 usingSpringWithDamping:0.875 initialSpringVelocity:0.000
						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
	 
					 animations:^(void) {
						 _imageView.transform = transform;
					 } completion:^(BOOL finished) {
						 CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
						 [UIView animateWithDuration:0.125 delay:0.000
							  usingSpringWithDamping:0.805 initialSpringVelocity:0.333
											 options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
						  
										  animations:^(void) {
											  _imageView.transform = transform;
										  } completion:^(BOOL finished) {
											  if ([self.delegate respondsToSelector:@selector(stickerButtonView:selectedEmotion:)])
												  [self.delegate stickerButtonView:self selectedEmotion:_emotionVO];
										  }];
					 }];
}


#pragma mark - UI Presentation
- (void)_loadImage {
//	_picoSticker = [[PicoSticker alloc] initWithPCContent:_emotionVO.pcContent];
//	_picoSticker.frame = kNormalFrame;
//	_picoSticker.alpha = 0.0;
//	[_imageView addSubview:_picoSticker];
	//
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_picoSticker.alpha = 1.0;
//		_imageLoadingView.alpha = 0.0;
//	} completion:^(BOOL finished) {
//		[_imageLoadingView removeFromSuperview];
//		_imageLoadingView = nil;
//	}];
	
	
	UIImageView *emojiImageView = [[UIImageView alloc] initWithFrame:CGRectInset(kNormalFrame, 5.0, 5.0)];
	emojiImageView.alpha = 0.0;
	[_imageView addSubview:emojiImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		emojiImageView.image = image;
		_emotionVO.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			emojiImageView.alpha = 1.0;
			_imageLoadingView.alpha = 0.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		_imageLoadingView.alpha = 0.0;
	};
	
	[emojiImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_emotionVO.largeImageURL]
															cachePolicy:kOrthodoxURLCachePolicy
														timeoutInterval:[HONAppDelegate timeoutInterval]]
						  placeholderImage:nil
								   success:imageSuccessBlock
								   failure:imageFailureBlock];
}


@end
